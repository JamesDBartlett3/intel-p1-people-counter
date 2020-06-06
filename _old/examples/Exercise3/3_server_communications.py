import argparse
import cv2
import sys
import numpy as np
import socket
import json
import paho.mqtt.client as mqtt
from random import randint
from inference import Network

INPUT_STREAM = "test_video.mp4"
CPU_EXTENSION = "/opt/intel/openvino/deployment_tools/inference_engine/lib/intel64/libcpu_extension_sse4.so"
ADAS_MODEL = "/home/workspace/models/semantic-segmentation-adas-0001.xml"


CLASSES = ['road', 'sidewalk', 'building', 'wall', 'fence', 'pole', 
'traffic_light', 'traffic_sign', 'vegetation', 'terrain', 'sky', 'person',
'rider', 'car', 'truck', 'bus', 'train', 'motorcycle', 'bicycle', 'ego-vehicle']

HOSTNAME = socket.gethostname()
IPADDRESS = socket.gethostbyname(HOSTNAME)
MQTT_HOST = IPADDRESS
MQTT_PORT = 3001
MQTT_KEEPALIVE_INTERVAL = 60

def get_args():
    parser = argparse.ArgumentParser("Run inference on an input video")
    i_desc = "The location of the input file"
    d_desc = "The device name, if not 'CPU'"
    parser.add_argument("-i", help=i_desc, default=INPUT_STREAM)
    parser.add_argument("-d", help=d_desc, default='CPU')
    args = parser.parse_args()
    return args


def draw_masks(result, width, height):
    classes = cv2.resize(result[0].transpose((1,2,0)), (width,height), 
        interpolation=cv2.INTER_NEAREST)
    unique_classes = np.unique(classes)
    out_mask = classes * (255/20)
    out_mask = np.dstack((out_mask, out_mask, out_mask))
    out_mask = np.uint8(out_mask)
    return out_mask, unique_classes


def get_class_names(class_nums):
    class_names= []
    for i in class_nums:
        class_names.append(CLASSES[int(i)])
    return class_names


def infer_on_video(args, model):
    client = mqtt.Client()
    client.connect(MQTT_HOST,MQTT_PORT,MQTT_KEEPALIVE_INTERVAL)
    plugin = Network()
    plugin.load_model(model, args.d, CPU_EXTENSION)
    net_input_shape = plugin.get_input_shape()
    cap = cv2.VideoCapture(args.i)
    cap.open(args.i)
    width = int(cap.get(3))
    height = int(cap.get(4))
    while cap.isOpened():
        flag, frame = cap.read()
        if not flag:
            break
        key_pressed = cv2.waitKey(60)
        p_frame = cv2.resize(frame, (net_input_shape[3], net_input_shape[2]))
        p_frame = p_frame.transpose((2,0,1))
        p_frame = p_frame.reshape(1, *p_frame.shape)
        plugin.async_inference(p_frame)
        if plugin.wait() == 0:
            result = plugin.extract_output()
            out_frame, classes = draw_masks(result, width, height)
            class_names = get_class_names(classes)
            speed = randint(50,70)
            client.publish("class",json.dumps({"class_names":class_names}))
            client.publish("speedometer",json.dumps({"speed":speed}))
        sys.stdout.buffer.write(out_frame)
        sys.stdout.flush()
        if key_pressed == 27:
            break
    cap.release()
    cv2.destroyAllWindows()
    client.disconnect()

    
def main():
    args = get_args()
    model = ADAS_MODEL
    infer_on_video(args, model)


if __name__ == "__main__":
    main()
