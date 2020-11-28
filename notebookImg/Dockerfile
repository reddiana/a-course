FROM gcr.io/kubeflow-images-public/tensorflow-2.1.0-notebook-gpu:1.0.0

USER root

RUN apt-get update 

RUN apt-get install -y dnsutils

# opencv에서 사용
RUN apt-get install -y ffmpeg libsm6 libxext6

RUN pip install --upgrade --no-cache-dir pip

# enum 최신 버전이 kubeflow-kale 등에서 설치 에러 발생시킴
RUN pip install --no-cache-dir enum34==1.1.8 

RUN pip install --upgrade --no-cache-dir \
                kubeflow-fairing \
                kfp \
                kubeflow-katib \
                kfserving

RUN pip install --upgrade --no-cache-dir \
                minio \
                ipython-sql \
                pandas \
                opencv-python \
                matplotlib \
                seaborn \
                scikit-learn 

RUN pip install --upgrade --no-cache-dir \
                jupyterlab 

# 아쉽게도 더이상 지원하지 않음
# https://github.com/Kaggle/jupyterlab 
# RUN jupyter labextension install @kaggle/jupyterlab

# https://github.com/lckr/jupyterlab-variableInspector
RUN jupyter labextension install @lckr/jupyterlab_variableinspector

# https://github.com/jupyterlab/jupyterlab-toc
RUN jupyter labextension install @jupyterlab/toc 

# https://github.com/jupyterlab/jupyterlab-git
RUN pip install --upgrade --no-cache-dir \
                jupyterlab-git && \
    jupyter lab build

# Kale 설치
# RUN pip install kubeflow-kale==0.5.0
# RUN jupyter labextension install kubeflow-kale-labextension@0.5.0 --debug 
RUN pip install kubeflow-kale && \
    jupyter labextension install kubeflow-kale-labextension --debug 

# Bash를 기본 쉘로
ENV SHELL /bin/bash

# 기본 환경 세팅
RUN echo "set -o vi"         >> /etc/bash.bashrc & \
    echo "alias ll='ls -al'" >> /etc/bash.bashrc

# 아래 내용 보안정책 확인하여 위규라면 삭제할 것
RUN echo "jovyan ALL=NOPASSWD: ALL" >> /etc/sudoers 

USER jovyan

ENTRYPOINT ["tini", "--"]
CMD ["sh","-c", "jupyter lab --notebook-dir=/home/${NB_USER} --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]
