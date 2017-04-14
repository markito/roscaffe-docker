FROM ubuntu:14.04
MAINTAINER markito@apache.org

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
        sudo -E apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116 && \
        apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        python-setuptools \
        vim \
        libgflags-dev libgoogle-glog-dev liblmdb-dev \
        libopenblas-dev \
        python-scipy \
        ros-indigo-velodyne \
        ros-indigo-cv-bridge && \
        pip install -U pip && \
        rm -rf /var/lib/apt/lists/* && \
        git clone -b ${CLONE_TAG} --depth 1 https://github.com/BVLC/caffe.git . && \
            pip install --upgrade pip && \
            cd python && for req in $(cat requirements.txt) pydot; do pip install $req; done && cd .. && \
            mkdir build && cd build && \
            cmake -DCPU_ONLY=1 .. && \
            make -j"$(nproc)"


ENV CAFFE_ROOT=/opt/caffe
WORKDIR $CAFFE_ROOT

# FIXME: use ARG instead of ENV once DockerHub supports this
ENV CLONE_TAG=rc4


ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

RUN wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/miniconda

ENV PATH="/opt/miniconda/bin:$PATH"
#ADD . /scripts/
#RUN conda env create -f /scripts/environment.yaml

WORKDIR /workspace
