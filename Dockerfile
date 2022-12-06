# See https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
FROM nvidia/cuda:11.3.0-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Git, libgl, libglib, Python
RUN apt-get update && apt-get -y install \
    zip htop screen \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    cmake \
    build-essential \
    curl \
    wget \
    gnupg2 \
    lsb-release \
    ca-certificates \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    wget \
    libbz2-dev \
    python3 \
    python3-pip \
    python3-venv \
    libpython3-dev

# Add requirements
ADD requirements.txt /yolov7/requirements.txt
WORKDIR /yolov7
RUN python3.8 -m venv /venv
RUN . /venv/bin/activate && pip install --upgrade wheel pip
RUN . /venv/bin/activate && pip install -r requirements.txt

# Install TensorRT, detectron2, pycuda
ENV CUDA_HOME=/usr/local/cuda
ENV C_INCLUDE_PATH=$C_INCLUDE_PATH:$CUDA_HOME/include
ENV CPATH=$CPATH:$CUDA_HOME/include
ENV LIBRARY_PATH=$LIBRARY_PATH:$CUDA_HOME/lib64
ENV PATH=$PATH:$CUDA_HOME/bin
ENV CUDA_INC_DIR=$CUDA_HOME/include
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_HOME/lib64:/usr/lib/x86_64-linux-gnu
RUN . /venv/bin/activate && pip install nvidia-pyindex
RUN . /venv/bin/activate && pip install nvidia-tensorrt
RUN . /venv/bin/activate && pip install pycuda onnx_graphsurgeon
RUN . /venv/bin/activate && pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu113/torch1.10/index.html

# Install Torch2TRT (0.0.4 at time of testing)
RUN . /venv/bin/activate && pip install git+https://github.com/NVIDIA-AI-IOT/torch2trt

# Install eCAL from wheel
RUN . /venv/bin/activate && pip install \
    https://github.com/eclipse-ecal/ecal/releases/download/v5.10.2/ecal5-5.10.2-1focal-cp38-cp38-linux_x86_64.whl

# Install ROS Noetic
ENV ROS_PKG=ros_base
ENV ROS_DISTRO=noetic
ENV ROS_ROOT="/opt/ros/${ROS_DISTRO}"
ENV ROS_PYTHON_VERSION=3
ENV PROVIDENTIA_ROSWS=/rosws
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN . /venv/bin/activate && apt-get update && apt-get -y install \
    ros-noetic-desktop-full \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool
RUN echo "source ${ROS_ROOT}/setup.bash" >> /root/.bashrc
RUN . /venv/bin/activate && rosdep init && rosdep update

# Inject this repo
ADD https://github.com/WongKinYiu/yolov7/releases/download/v0.1/yolov7-seg.pt yolov7-seg.pt
ADD . /yolov7
