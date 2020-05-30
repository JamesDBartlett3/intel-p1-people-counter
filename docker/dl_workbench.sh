docker run --rm -p 127.0.0.1:5665:5665 \
        -v /dev/bus/usb:/dev/bus/usb \
        --device-cgroup-rule='c 189:* rmw' \
        -it openvino/workbench:latest \
        -volume ~/.workbench:/home/openvino/.workbench
