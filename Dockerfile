# FROM nvcr.io/nvidia/tensorflow:18.06-py3
# FROM nvcr.io/nvidia/tensorflow:18.10-py3
# FROM nvcr.io/nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
FROM nvcr.io/nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

ENV cwd="/home/"
WORKDIR $cwd

RUN apt-get -y update
# RUN apt-get -y upgrade

RUN apt-get install -y \
    software-properties-common \
    build-essential \
    checkinstall \
    cmake \
    pkg-config \
    yasm \
    git \
    vim \
    curl \
    wget \
    gfortran \
    libjpeg8-dev \
    libpng-dev \
    libtiff5-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libdc1394-22-dev \
    libxine2-dev \
    sudo \
    apt-transport-https \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    dbus-x11 \
    vlc \
    iputils-ping \
    python3-dev \
    python3-pip

# INSTALL TENSORRT
ARG TENSORRT=nv-tensorrt-repo-ubuntu1804-cuda10.0-trt7.0.0.11-ga-20191216_1-1_amd64.deb
# From Tensort installation instructions
ARG TENSORRT_KEY=/var/nv-tensorrt-repo-cuda10.0-trt7.0.0.11-ga-20191216/7fa2af80.pub
# custom Tensorrt Installation
ADD $TENSORRT /tmp
# Rename the ML repo to something else so apt doesn't see it
RUN mv /etc/apt/sources.list.d/nvidia-ml.list /etc/apt/sources.list.d/nvidia-ml.list.bkp && \
    dpkg -i /tmp/$TENSORRT && \
    apt-key add $TENSORRT_KEY && \
    apt-get update && \
    apt-get install -y tensorrt
RUN apt-get install -y python3-libnvinfer-dev uff-converter-tf

# INSTALL BAZEL
# RUN curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
# RUN echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
# RUN apt update && apt install -y bazel

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata python3-tk
ENV TZ=Asia/Singapore
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get clean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* && apt-get -y autoremove

### APT END ###

RUN pip3 install --no-cache-dir --upgrade pip 

# INSTALL VLC
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git &&\
    cd nv-codec-headers &&\
    make install &&\
    cd .. && rm -r nv-codec-headers
RUN pip3 install --no-cache-dir python-vlc

# INSTALL FFMPEG
RUN git clone https://git.ffmpeg.org/ffmpeg.git &&\
    cd ffmpeg &&\
    git checkout n3.4.7 &&\
    ./configure --enable-cuda --enable-cuvid --enable-nvenc --enable-nonfree --enable-libnpp --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 &&\
    make -j8 &&\
    make install &&\
    cd .. && rm -r ffmpeg
RUN pip3 install --no-cache-dir ffmpeg-python 

RUN pip3 install --no-cache-dir \
    numpy==1.15.3 \
    GPUtil \
    tqdm \
    requests \
    protobuf

RUN pip3 install --no-cache-dir  \
    scipy==1.0.0 \
    matplotlib \
    Pillow==5.3.0 \
    opencv-python \
    scikit-image

RUN pip3 install --no-cache-dir \
    torch==1.4.0 \
    torchvision==0.5.0

RUN pip3 install --no-cache-dir jupyter
RUN echo 'alias jup="jupyter notebook --allow-root --no-browser"' >> ~/.bashrc

RUN pip3 install --no-cache-dir tensorboard==1.14
RUN pip3 install --no-cache-dir python-dotenv

# DETECTRON2 DEPENDENCY: PYCOCOTOOLS 
RUN pip3 install --no-cache-dir cython
RUN git clone https://github.com/pdollar/coco
RUN cd coco/PythonAPI \
    && python3 setup.py build_ext install \
    && cd ../.. \
    && rm -r coco

# INSTALL DETECTRON2
RUN git clone https://github.com/facebookresearch/detectron2.git /detectron2
RUN cd /detectron2 &&\
    git checkout 185c27e4b4d2d4c68b5627b3765420c6d7f5a659 &&\
    python3 -m pip install -e .
# RUN rm -r detectron2



# RUN git clone https://github.com/tensorflow/tensorflow.git 

# ENV PYTHON_BIN_PATH="/usr/bin/python3" \
#     USE_DEFAULT_PYTHON_LIB_PATH=1 \
#     TF_NEED_JEMALLOC=1 \
#     TF_NEED_GCP=0 \
#     TF_NEED_HDFS=0 \
#     TF_NEED_S3=0 \
#     TF_NEED_KAFKA=0 \
#     TF_ENABLE_XLA=0 \
#     TF_NEED_GDR=0 \
#     TF_NEED_VERBS=0 \
#     TF_NEED_OPENCL_SYCL=0 \
#     TF_NEED_CUDA=1 \
#     TF_CUDA_VERSION=10.0 \
#     CUDA_TOOLKIT_PATH=/usr/local/cuda \
#     TF_CUDNN_VERSION=7.0 \
#     CUDNN_INSTALL_PATH=/usr/loca/cuda \
#     TF_NEED_TENSORRT=1 \
#     TENSORRT_INSTALL_PATH=/usr/lib/x86_64-linux-gnu \
#     TF_NCCL_VERSION=1.3 \
#     TF_CUDA_COMPUTE_CAPABILITIES=3.5,5.2 \
#     TF_CUDA_CLANG=0 \
#     GCC_HOST_COMPILER_PATH=/usr/bin/gcc \
#     TF_NEED_MPI=0 \
#     CC_OPT_FLAGS="-march=native" \
#     TF_SET_ANDROID_WORKSPACE=0

# RUN cd tensorflow && git checkout r1.9 \
#     && ./configure \
#     && bazel build --config=opt --config=cuda //tensorflow/tools/pip_package:build_pip_package \


