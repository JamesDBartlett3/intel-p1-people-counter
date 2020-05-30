#!/bin/bash
export HWS=/home/openvino
export LOGDIR=$HWS/logs

# Set up virtual environment
python3 -m pip install tqdm requests pyyaml -t /usr/local/lib/python3.5/dist-packages
echo 'source /opt/intel/openvino/bin/setupvars.sh -pyver 3.5' >> ~/.bashrc
source ~/.bashrc
clear

# All logs will go here
mkdir -p $LOGDIR

# Install every service and redirect logs
cd $HWS/webservice/server
npm install > $LOGDIR/npm_mosca.log 2>&1
echo "Mosca installed."

cd ../ui
npm install > $LOGDIR/npm_ui.log 2>&1
echo "UI installed."

# Run every service on the background and redirect logs
cd $HWS/webservice/server/node-server
node ./server.js > $LOGDIR/mosca_server.log 2>&1 &
echo "Mosca Server started."

cd $HWS/webservice/ui
npm run dev > $LOGDIR/gui.log 2>&1 &
echo "GUI service started."

cd $HWS
sudo ffserver -f ./ffmpeg/server.conf > $LOGDIR/ffserver.log 2>&1 &
echo "FFmpeg Server started."