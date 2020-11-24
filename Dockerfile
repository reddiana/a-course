FROM gcr.io/kubeflow-images-public/tensorflow-2.1.0-notebook-gpu:1.0.0

USER root

RUN apt-get update 

# opencv에서 사용
RUN apt-get -y install ffmpeg libsm6 libxext6

RUN pip install --upgrade pip

# enum 최신 버전이 kubeflow-kale 등에서 설치 에러 발생시킴
RUN pip install enum34==1.1.8 

RUN pip install kubeflow-fairing \
                minio \
                opencv-python \
                matplotlib \
                imutils \
                scikit-learn 
                # kfp \
                # flask \
                # jupyter \

# Kale 설치
RUN pip install kubeflow-kale==0.5.0
RUN jupyter labextension install kubeflow-kale-labextension@0.5.0 --debug 

# 아래 내용 보안정책 확인하여 위규라면 삭제할 것
RUN echo "jovyan ALL=NOPASSWD: ALL" >> /etc/sudoers 
USER jovyan

ENTRYPOINT ["tini", "--"]
CMD ["sh","-c", "jupyter lab --notebook-dir=/home/${NB_USER} --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]
