#!/bin/bash
docker run -it --rm \
	--device-cgroup-rule='c 189:* rmw' \
	-v /dev/bus/usb:/dev/bus/usb \
	-v $(pwd):/home/openvino/intel-p1-people-counter \
	jamesdbartlett3/openvino-ncs2-runtime:01 \
	/bin/bash
    