FROM python:3.6
MAINTAINER Albert Lee <Albert.Lee@boston.gov>

RUN apt-get update && \
        apt-get install -y \
        build-essential \
        cmake \
        git \
        wget \
        git \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libavformat-dev \
        libpq-dev
RUN git clone https://github.com/jasperproject/jasper-client.git jasper \ && chmod +x jasper/jasper.py \ && pip install --upgrade setuptools \ && pip install -r jasper/client/requirements.txt
RUN pip install --upgrade seaborn jupyter notebook plotly dash==0.21.1 dash-renderer==0.13.0 dash-html-components==0.11.0 dash-core-components==0.23.0

# Set up Jupyter Notebook for dev
RUN jupyter notebook --generate-config
RUN echo "c = get_config()" >> .jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.ip = '*'" >> .jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.port = 80" >> .jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.open_browser = False" >> .jupyter/jupyter_notebook_config.py

WORKDIR /
ENV OPENCV_VERSION="3.4.1"
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
&& unzip ${OPENCV_VERSION}.zip \
&& mkdir /opencv-${OPENCV_VERSION}/cmake_binary \
&& cd /opencv-${OPENCV_VERSION}/cmake_binary \
&& cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=OFF \
  -DENABLE_AVX=ON \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python3.6 -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python3.6) \
  -DPYTHON_INCLUDE_DIR=$(python3.6 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python3.6 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
&& make install \
&& rm /${OPENCV_VERSION}.zip \
&& rm -r /opencv-${OPENCV_VERSION}
