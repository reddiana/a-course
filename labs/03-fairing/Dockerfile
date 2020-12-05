FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-dev ffmpeg libsm6 libxext6 

RUN  pip3 install --upgrade pip && \
     pip3 install \
        tensorflow \
        sklearn \
        opencv-python \   
        pillow \
        dill \
        minio
        
CMD ['python3']        
