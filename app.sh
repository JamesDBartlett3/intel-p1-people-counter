#!/bin/bash
clear
echo "Ladies and gentlemen, start your Inference Engines..."
echo "Launching App. Please open the browser component to observe the results. "
python3 main.py -i resources/Pedestrian_Detect_2_1_1.mp4 \
    -m models/[openvino_ir]_mobilenet-ssd/mobilenet-ssd.xml \
    -l /opt/intel/openvino/deployment_tools/inference_engine/lib/intel64/libcpu_extension_sse4.so \
    -d CPU -pt 0.6 | ffmpeg -v warning -f rawvideo -pixel_format bgr24 -video_size 768x432 \
    -framerate 24 -i - http://0.0.0.0:3004/fac.ffm > /dev/null 2>&1