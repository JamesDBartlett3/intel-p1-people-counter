#!/bin/bash

export HWS=$(pwd)
export LOGDIR=$HWS/logs

# Source the Environment
source /opt/intel/openvino/bin/setupvars.sh -pyver 3.5

# Install dependencies (if needed)
python3 -m pip install numpy tqdm requests pyyaml paho-mqtt --upgrade -t /usr/local/lib/python3.5/dist-packages

# All logs will go here
mkdir -p $LOGDIR

# Install every service and redirect logs
echo "Installing Mosca..."
cd $HWS/webservice/server
npm install > $LOGDIR/npm_mosca.log 2>&1
echo "Mosca installed."

echo "Installing NodeJS UI..."
cd ../ui
npm install > $LOGDIR/npm_ui.log 2>&1
echo "NodeJS UI installed."

# Run every service on the background and redirect logs
echo "Starting Mosca Server..."
cd $HWS/webservice/server/node-server
node ./server.js > $LOGDIR/mosca_server.log 2>&1 &
echo "Mosca Server started."

echo "Starting NodeJS UI Service..."
cd $HWS/webservice/ui
npm run dev > $LOGDIR/gui.log 2>&1 &
echo "NodeJS UI Service started."

cd $HWS
echo "Starting FFmpeg Server..."
sudo ffserver -f ./ffmpeg/server.conf > $LOGDIR/ffserver.log 2>&1 &
echo "FFmpeg Server started."