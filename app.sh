#!/bin/bash
docker run --rm -d -p 127.0.0.1:3004:3004 \
    -v /dev/bus/usb:/dev/bus/usb \
    --device-cgroup-rule='c 189:* rmw' \
    jamesdbartlett3/intel-p1-people-counter
echo "finished"