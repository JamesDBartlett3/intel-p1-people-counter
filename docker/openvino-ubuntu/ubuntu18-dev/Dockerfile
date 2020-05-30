FROM openvino/ubuntu18_dev:2019_R3.1
USER root
WORKDIR /home/openvino
RUN chown openvino -R /home/openvino
ARG DEPENDENCIES="autoconf \
                  automake \
                  build-essential \
                  cmake \
                  cpio \
                  curl \
                  gnupg2 \
                  libdrm2 \
                  libglib2.0-0 \
                  lsb-release \
                  libgtk-3-0 \
                  libtool \
                  python3-pip \
                  udev \
                  unzip \
                  usbutils \
                  nodejs \
                  python3-pip \
                  libzmq3-dev \
                  libkrb5-dev \
                  ffmpeg \
                  cmake \
                  git"
RUN apt-get update && \
    apt-get install -y ${DEPENDENCIES} && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && apt-get upgrade -y
ENV INSTALLDIR /opt/intel/openvino
COPY init-services.sh ${WORKDIR}
RUN /bin/bash ${INSTALLDIR}/bin/setupvars.sh
RUN python3 -m pip install wheel
RUN python3 -m pip install numpy
RUN python3 -m pip install paho-mqtt

