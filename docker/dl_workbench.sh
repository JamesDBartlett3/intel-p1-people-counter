#/bin/bash
docker run -p 127.0.0.1:5665:5665 \
        -v /dev/bus/usb:/dev/bus/usb \
        --device-cgroup-rule='c 189:* rmw' \
        -volume ~/.workbench:/home/openvino/.workbench \
        -it openvino/workbench:latest
