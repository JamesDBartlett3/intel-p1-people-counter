FROM openvino/ubuntu18_runtime:2020.2
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
                  usbutils"
RUN apt-get update && \
    apt-get install -y ${DEPENDENCIES} && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && apt-get upgrade -y
ENV INSTALLDIR /opt/intel/openvino
RUN /bin/bash ${INSTALLDIR}/bin/setupvars.sh