#!/bin/bash

echo "Sourcing the Environment..."
source /opt/intel/openvino/bin/setupvars.sh -pyver 3.5
echo "Done."
echo "Killing any lingering background processes from earlier sessions..."
killall ffserver
killall node
killall npm
echo "Done."
echo "Installing and launching Mosca, NodeJS, and FFmpeg services in the background..."
/bin/bash /home/workspace/init_services.sh
sleep 5
echo "Done."
echo "Background services are now standing by... Launching main app..."
/bin/bash /home/workspace/app.sh
