#!/usr/bin/env python3
"""People Counter."""


"""
NOTE TO UDACITY MENTORS:
This file is based primarily on the main.py found in the official Intel IoT Devkit "People Counter Python" repo on GitHub:
https://github.com/intel-iot-devkit/people-counter-python/blob/master/main.py

A fair amount of the code and comments from that file remain unchanged in this file. 
However, I did make significant enhancements, particularly in the sections that deal with false negatives. 
Intel's code did not have a mechanism for handling false negatives, so all of those parts are 100% original, coded by me. 
"""


"""
 Copyright (c) 2018 Intel Corporation.
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit person to whom the Software is furnished to do so, subject to
 the following conditions:
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

import os
import sys
import time
import socket
import json
import cv2

import numpy as np
import logging as log
import paho.mqtt.client as mqtt

from argparse import ArgumentParser
from inference import Network

# MQTT server environment variables
HOSTNAME = socket.gethostname()
IPADDRESS = socket.gethostbyname(HOSTNAME)
MQTT_HOST = IPADDRESS
MQTT_PORT = 3001
MQTT_KEEPALIVE_INTERVAL = 60


def build_argparser():
    """
    Parse command line arguments.

    :return: command line arguments
    """
    parser = ArgumentParser()
    parser.add_argument(
        "-m",
        "--model",
        required=True,
        type=str,
        help="Path to an xml file with a trained model.",
    )
    parser.add_argument(
        "-i", "--input", required=True, type=str, help="Path to image or video file"
    )
    parser.add_argument(
        "-l",
        "--cpu_extension",
        required=False,
        type=str,
        default=None,
        help="MKLDNN (CPU)-targeted custom layers."
        "Absolute path to a shared library with the"
        "kernels impl.",
    )
    parser.add_argument(
        "-d",
        "--device",
        type=str,
        default="CPU",
        help="Specify the target device to infer on: "
        "CPU, GPU, FPGA or MYRIAD is acceptable. Sample "
        "will look for a suitable plugin for device "
        "specified (CPU by default)",
    )
    parser.add_argument(
        "-pt",
        "--prob_threshold",
        type=float,
        default=0.5,
        help="Probability threshold for detections filtering" "(0.5 by default)",
    )
    parser.add_argument(
        "-pc",
        "--perf_counts",
        type=str,
        default=False,
        help="Print performance counters",
    )
    return parser


def performance_counts(perf_count):
    """
    print information about layers of the model.

    :param perf_count: Dictionary consists of status of the layers.
    :return: None
    """
    print(
        "{:<70} {:<15} {:<15} {:<15} {:<10}".format(
            "name", "layer_type", "exec_type", "status", "real_time, us"
        )
    )
    for layer, stats in perf_count.items():
        print(
            "{:<70} {:<15} {:<15} {:<15} {:<10}".format(
                layer,
                stats["layer_type"],
                stats["exec_type"],
                stats["status"],
                stats["real_time"],
            )
        )


def ssd_out(frame, result):
    """
    Parse SSD output.

    :param frame: frame from camera/video
    :param result: list contains the data to parse ssd
    :return: person count and frame
    """
    current_count = 0
    for obj in result[0][0]:
        # Draw bounding box for object when its probability is more than
        #  the specified threshold
        if obj[2] > prob_threshold:
            xmin = int(obj[3] * initial_w)
            ymin = int(obj[4] * initial_h)
            xmax = int(obj[5] * initial_w)
            ymax = int(obj[6] * initial_h)
            cv2.rectangle(frame, (xmin, ymin), (xmax, ymax), (185, 0, 245), 2)
            current_count += 1
    return frame, current_count


# function to check if the bounding box is touching one of the frame boundary triggers
def rect_intersect(frame, boxA, boxB, rgb):
    xA = max(boxA[0], boxB[0])
    yA = max(boxA[1], boxB[1])
    xB = min(boxA[2], boxB[2])
    yB = min(boxA[3], boxB[3])

    # draw the frame boundary trigger box
    cv2.rectangle(
        frame, (boxA[0], boxA[1]), (boxA[2], boxA[3]), (rgb[0], rgb[1], rgb[2]), 2
    )

    # if boxes intersect, return True
    if abs(max((xB - xA, 0)) * max((yB - yA), 0)) > 0:
        return True
    else:
        return False


def main():
    """
    Load the network and parse the SSD output.

    :return: None
    """
    # Connect to the MQTT server
    client = mqtt.Client()
    client.connect(MQTT_HOST, MQTT_PORT, MQTT_KEEPALIVE_INTERVAL)

    args = build_argparser().parse_args()

    # Flag for the input image
    single_image_mode = False

    cur_request_id = 0
    last_count = 0
    last_touched_border = "None"
    total_count = 0
    start_time = 0
    thirty_frames = np.empty(30)
    thirty_frames.fill(0)
    running_avg = 0
    lag = 0
    a_red = [0, 0, 185]
    a_green = [0, 185, 0]
    a_blue = [185, 0, 0]
    l_red = list(a_red)
    l_green = list(a_green)
    l_blue = list(a_blue)
    ltb_text_color = l_blue

    # Initialise the class
    infer_network = Network()
    # Load the network to IE plugin to get shape of input layer
    n, c, h, w = infer_network.load_model(
        args.model, args.device, 1, 1, cur_request_id, args.cpu_extension
    )[1]

    # Checks for live feed
    if args.input == "CAM":
        input_stream = 0

    # Checks for input image
    elif args.input.endswith(".jpg") or args.input.endswith(".bmp"):
        single_image_mode = True
        input_stream = args.input

    # Checks for video file
    else:
        input_stream = args.input
        assert os.path.isfile(args.input), "Specified input file doesn't exist"

    cap = cv2.VideoCapture(input_stream)

    if input_stream:
        cap.open(args.input)

    if not cap.isOpened():
        log.error("ERROR! Unable to open video source")
    global initial_w, initial_h, prob_threshold
    prob_threshold = args.prob_threshold
    initial_w = cap.get(3)
    initial_h = cap.get(4)
    while cap.isOpened():
        flag, frame = cap.read()
        if not flag:
            break
        key_pressed = cv2.waitKey(60)
        # Start async inference
        image = cv2.resize(frame, (w, h))
        # Change data layout from HWC to CHW
        image = image.transpose((2, 0, 1))
        image = image.reshape((n, c, h, w))
        # Start asynchronous inference for specified request.
        inf_start = time.time()
        infer_network.exec_net(cur_request_id, image)
        # Wait for the result
        if infer_network.wait(cur_request_id) == 0:
            det_time = time.time() - inf_start
            # Results of the output layer of the network
            result = infer_network.get_output(cur_request_id)
            if args.perf_counts:
                perf_count = infer_network.performance_counter(cur_request_id)
                performance_counts(perf_count)
            frame, current_count = ssd_out(frame, result)
            inf_time_message = "Inference time: {:.3f}ms".format(det_time * 1000)
            cv2.putText(
                frame,
                inf_time_message,
                (75, 15),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                l_blue,
                1,
            )

            # [min_dist_from_left, min_dist_from_top, max_dist_from_left, max_dist_from_top]
            bottom_border = [
                0,
                int(initial_h - 5),
                int(initial_w - 150),
                int(initial_h),
            ]
            right_border = [int(initial_w - 5), 0, int(initial_w), int(initial_h - 150)]

            # get bounding box coordinates from result & convert to int32
            bounding_box = np.array(
                result[0][0][0][3:7] * [initial_w, initial_h, initial_w, initial_h]
            ).astype("int32")

            # store bounding box coordinates as string for display
            bbox_coordinates = (
                "xyMin: ("
                + str(bounding_box[0])
                + ", "
                + str(bounding_box[1])
                + "), "
                + "xyMax: ("
                + str(bounding_box[2])
                + ", "
                + str(bounding_box[3])
                + ")"
            )

            # check if bounding box is touching either the bottom or right border of the frame
            if rect_intersect(frame, bottom_border, bounding_box, a_green):
                last_touched_border = "Bottom"
                ltb_text_color = l_green
            if rect_intersect(frame, right_border, bounding_box, a_red):
                last_touched_border = "Right"
                ltb_text_color = l_red

            # display last touched border on-screen
            cv2.putText(
                frame,
                "Last Touched Border: ",
                (80, 35),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                l_blue,
                1,
            )
            cv2.putText(
                frame,
                last_touched_border,
                (255, 35),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                ltb_text_color,
                2,
            )
            cv2.putText(
                frame,
                bbox_coordinates,
                (85, 55),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                l_blue,
                1,
            )

            # thirty frame running average of current_count
            thirty_frames[:-1] = thirty_frames[1:]
            thirty_frames[-1] = current_count
            running_avg = round(np.mean(thirty_frames), 2)

            # if a person was detected in at least 20%
            # of the last 30 frames, set current_count to 1
            # otherwise, set current_count to 0
            if running_avg >= 0.2:
                current_count = 1
            else:
                current_count = 0

            # When new person enters the video
            if current_count > last_count and last_touched_border == "Bottom":
                start_time = time.time()
                total_count += current_count - last_count
                client.publish("person", json.dumps({"total": total_count}))

            # Person duration in the video is calculated
            if (
                current_count < last_count
                and last_touched_border == "Right"
                and bounding_box[0] + bounding_box[2] == 0
            ):
                current_count = 0
                duration = int(time.time() - start_time)
                if duration > 0:
                    # Publish messages to the MQTT server
                    client.publish(
                        "person/duration", json.dumps({"duration": duration})
                    )

            client.publish("person", json.dumps({"count": current_count}))
            last_count = current_count

            if key_pressed == 27:
                break

        # Send frame to the ffmpeg server
        sys.stdout.buffer.write(frame)
        sys.stdout.flush()

        if single_image_mode:
            cv2.imwrite("output_image.jpg", frame)
    cap.release()
    cv2.destroyAllWindows()
    client.disconnect()
    infer_network.clean()


if __name__ == "__main__":
    main()
    exit(0)
