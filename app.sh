#!/bin/bash

# Source the Environment
source /opt/intel/openvino/bin/setupvars.sh -pyver 3.5

clear
echo "====================================================="
echo "Ladies and gentlemen, start your Inference Engines..."
printf "=====================================================\n\n"
printf "Launching App. \nPlease open the browser component to observe the results.\n"
python3 main.py -i resources/Pedestrian_Detect_2_1_1.mp4 \
    -m models/IRs/ssd_mobilenet_v2_coco/frozen_inference_graph.xml \
    -l /opt/intel/openvino/deployment_tools/inference_engine/lib/intel64/libcpu_extension_sse4.so \
    -d CPU -pt 0.6 | ffmpeg -v warning -f rawvideo -pixel_format bgr24 -video_size 768x432 \
    -framerate 24 -i - http://0.0.0.0:3004/fac.ffm > /dev/null 2>&1
clear
echo "================================="
echo "Inference completed successfully!"
printf "=================================\n\n"
printf "Reminder: The UI & video servers are still installed, and running in the background.\n\n"
printf "If you'd like to run the inference again, simply execute the 'app.sh' script from this terminal, and it will automatically re-connect to the background services.\n\n"