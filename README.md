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

## Setup

To clone my GitHub repo into your Udacity workspace, first select the "Reset Data" function from the Menu in the lower-left corner, to restore the workspace to its default settings. 
When it asks you to confirm by typing "reset data" into the box, do so. 

Resetting the data usually takes a minute or two. After that finishes, use the terminal in the Workspace to enter the following commands:

```
mkdir ../_old/
mv ./* ../_old/
git init .
git remote add origin https://github.com/JamesDBartlett3/intel-p1-people-counter.git
git pull origin main

```

Now, since we've replaced all of the code files in the workspace, we need to re-load the Jupyter tabs, so they display the ones we've just downloaded. Open the File menu, and select "Close All Tabs." Then, open the File Browser pane, and double-click the file "Guide.ipynb." This will automatically re-open all of the default tabs, and they will now contain the updated code. 
        
## Run the application

From the /home/workspace directory:

* To launch everything, simply run the big_red_button.sh script by typing this command into the terminal:
`./big_red_button.sh`

Wait for the script to install and launch the back-end services. This usually takes 2-3 minutes.
When the script finishes its setup stage, you will be prompted to click the “Open App” button to view the output. 
Do that.

That's all!
