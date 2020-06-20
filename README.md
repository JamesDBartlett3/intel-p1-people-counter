# Deploy a People Counter App at the Edge

| Details            |              |
|-----------------------|---------------|
| Programming Language: |  Python 3.5

![people-counter-python](./images/people-counter-image.png)

## What it Does

The people counter application will demonstrate how to create a smart video IoT solution using Intel® hardware and software tools. The app will detect people in a designated area, providing the number of people in the frame, average duration of people in frame, and total count.

## How it Works

The counter will use the Inference Engine included in the Intel® Distribution of OpenVINO™ Toolkit. The model used should be able to identify people in a video frame. The app should count the number of people in the current frame, the duration that a person is in the frame (time elapsed between entering and exiting a frame) and the total count of people. It then sends the data to a local web server using the Paho MQTT Python package.

![architectural diagram](./images/arch_diagram.png)

## Requirements

### Hardware

- None

### Software

- This project MUST be run in the Udacity workspace. It will not work elsewhere.
        
## Run the application

From the main directory:

* To launch everything, run the big_red_button.sh script:
./big_red_button.sh

Then use the “Open App” button to view the output. 
