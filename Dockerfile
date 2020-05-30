FROM openvino/ubuntu18_runtime:2019_R3.1
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
                  zlib1g-dev \
                  python3-pip \
                  python3-wheel \
                  udev \
                  unzip \
                  usbutils \
                  nodejs \
                  npm \
                  libzmq3-dev \
                  libkrb5-dev \
                  ffmpeg \
                  git"
RUN apt-get update && \
    apt-get install -y ${DEPENDENCIES} && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && apt-get upgrade -y

ENV INSTALLDIR /opt/intel/openvino
ENV HOMEDIR /home/openvino
ENV WORKSPACE /home/openvino/workspace

RUN git clone https://github.com/JamesDBartlett/nd131-openvino-fundamentals-project-starter.git ${WORKSPACE}
RUN cd /tmp; curl https://www.python.org/ftp/python/3.5.9/Python-3.5.9.tgz | tar -xz; cd Python-3.5.9; ./configure --enable-optimizations; make altinstall
RUN python3.5 -m pip install tqdm requests pyyaml numpy paho-mqtt -t /usr/local/lib/python3.5/dist-packages
RUN cd ${WORKSPACE}/webservice/server; npm install
RUN cd ${WORKSPACE}/webservice/ui; npm install

COPY launch-servers.sh ${HOMEDIR}

CMD ["/bin/bash", "/home/openvino/launch-servers.sh"]