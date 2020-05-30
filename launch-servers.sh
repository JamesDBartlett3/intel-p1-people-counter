#!/bin/bash
export HWS=/home/openvino/workspace
export LOGDIR=$HWS/logs

# Set up virtual environment
echo 'alias python=python3.5' >> ~/.bashrc
echo 'alias python3=python3.5' >> ~/.bashrc
echo 'source /opt/intel/openvino/bin/setupvars.sh -pyver 3.5' >> ~/.bashrc
source ~/.bashrc

# All logs will go here
mkdir -p $LOGDIR

# Run every service on the background and redirect logs
cd $HWS/webservice/server/node-server
node ./server.js > $LOGDIR/mosca_server.log 2>&1 &
echo "Mosca Server started."

cd $HWS/webservice/ui
npm run dev > $LOGDIR/gui.log 2>&1 &
echo "GUI service started."

cd $HWS
ffserver -f ./ffmpeg/server.conf > $LOGDIR/ffserver.log 2>&1 &
echo "FFmpeg Server started."


# Start an infinite loop and wait for the user to press Q to stop the container
printf "The app is now running. You may access the interface at http://127.0.0.1:3004\n"
while [ true ] ; do
sleep 1;
done
