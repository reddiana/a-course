# A교육과정-KF

[TOC]

# MicroK8S + Kubeflow 설치 


- [ ] 시스템 요구사항
- [ ] 설치 스크립트
  
  - https://www.kubeflow.org/docs/started/workstation/getting-started-multipass/
  
```bash
$ sudo apt update
$ #sudo apt install -y snapd

# Install MicroK8s with Snap by running the following command:
$ sudo snap install microk8s --classic

$ sudo usermod -a -G microk8s $(whoami)
$ sudo chown -f -R $(whoami) ~/.kube

# 로그아웃하고 재로그인

# Verify that MicroK8s is running:deployment.apps/hello-world
$ microk8s status --wait-ready

# Having installed MicroK8s, you can now enable common services on your MicroK8s deployment. To do that, run the following command:
$ microk8s enable dns dashboard storage registry
```

```sh
set -o vi
alias d='docker'
alias k='microk8s kubectl'
alias kubectl='microk8s kubectl'
alias kw='watch "microk8s kubectl get pod -A"'
alias kww='watch "microk8s kubectl get pod -A | grep -v Running"'
```

### K8s Dashboard 접속

```bash
$ microk8s enable dashboard
```

#### 방법1. kubectl proxy

```bash
$ microk8s kubectl proxy --accept-hosts=.* --address=0.0.0.0 &
```

- http://35.206.221.225:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

#### 방법2. NodePort <- 채택

```
$ microk8s kubectl edit -n kube-system service/kubernetes-dashboard
```

- https://35.206.228.182:30443

#### 인증

```bash
$ token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
$ microk8s kubectl -n kube-system describe secret $token
```

```
eyJhbGciOiJSUzI1NiIsImtpZCI6IlRpQ0tqQ2FVd2xOR3NkR3hnVF9IR056UTZpZXFENVdPZlNpR3NZbzQ3TUkifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkZWZhdWx0LXRva2VuLXc4aG00Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImRlZmF1bHQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIyMWVkNmQ1ZC0wNTZkLTQwZmItOWUyYS04MzU4YzBmODE4YzgiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06ZGVmYXVsdCJ9.ikkZ72-FROc_WsVDsWHfrilNrOYX1BX8Lb9EKcjswN7zMsqVPO4YdnZzqW0RUGSAAJg1EJvlxdHqmCq6ZTqj1JtD0ANuLjzkzPShI4ZhgKotfkq6Nc4TE_aT0rIi-CYEXN4DYc0J_cp1lpIe2-bN628GC_MFtYt56QNAgRZiN3IyJy0Or7Mrv1aXkDaxDotX4FIsNGFwK0tgbSgDaBM5_GZQgVVoXE3TigqYDpC_KB98vGZwjvAKbxhCbDI06U3y0ZEEPOPLyWzXPNJVd50bTUkIhFYksl1uemu7IGT6V4dLsGF9RuimmT45U_1TgHkRp0dqmFv9A1NJ2xp4XgLdrA
```

### 추가선택


```bash
# Optional: To enable NVIDIA GPU hardware support, also run 
$ microk8s enable gpu.
```

### Kubeflow 설치

```bash
# Deploy Kubeflow by running this command:
$ microk8s enable kubeflow
```

- https://35.206.228.182:30947

#### 설치이슈 1 : oidc-gatekeeper

- Kubeflow can't be enabled after Nov. 2020 microk8s releases (always timeout) #1754 https://github.com/ubuntu/microk8s/issues/1754
- oidc-gatekeeper - required key AUTHSERVICE_URL_PREFIX missing value #5407 https://github.com/kubeflow/kubeflow/issues/5407 

##### 조치

- oidc-gatekeeper deployment의 환경변수 부분에 AUTHSERVICE_URL_PREFIX 추가

```bash
$ microk8s kubectl edit -n kubeflow deployment.apps/oidc-gatekeeper
...
    spec:
      containers:
      - env:
        - name: AUTHSERVICE_URL_PREFIX
          value: /authservice/
```



#### 설치이슈 2

- https://github.com/ubuntu/microk8s/issues/1669#issuecomment-714489692
- https://github.com/ubuntu/microk8s/issues/1723

```
red_suh@redsuh:~$ microk8s enable kubeflow
...
Waiting for service pods to become ready.
Kubeflow could not be enabled:
Error from server (NotFound): mutatingwebhookconfigurations.admissionregistration.k8s.io "katib-mutating-webhook-config" not found
Error from server (NotFound): validatingwebhookconfigurations.admissionregistration.k8s.io "katib-validating-webhook-config" not found

Command '('microk8s-kubectl.wrapper', 'delete', 'mutatingwebhookconfigurations/katib-mutating-webhook-config', 'validatingwebhookconfigurations/katib-validating-webhook-config')' returned non-zero exit status 1
Failed to enable kubeflow
red_suh@redsuh:~$
```

### Kubeflow 접속

- 어캐 하는지 모르겠다 https://microk8s.io/docs/addon-kubeflow

- [ ] MLOps 개요 교재추가
- [ ] Kale 교재추가
  
  - [ ] https://github.com/sds-arch-cert/kubeflow-edu.git 
  - [ ] Kale 추가된 image 작성
- [ ] 실사례 pipeline 예제 (당근마켓 등)
- [ ] TFServing으로 KFServing 활용 예제
- [ ] KF의 K8s 리소스 정리
  
  - [ ] Role 정리 https://www.kubeflow.org/docs/notebooks/submit-kubernetes/





# Minikube + Kubeflow 설치

https://www.kubeflow.org/docs/started/workstation/minikube-linux/

모든 설치 과정은 일반계정(not root)으로 진행

### 도커설치

```bash
sudo apt-get update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $(whoami)
# 로그아웃 후 다시 로그인
```

### Install kubectl

```bash
mkdir kubeflow
cd kubeflow
```

```SHELL
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

### Install minikube

[Kubernetes: minikube releases](https://github.com/kubernetes/minikube/releases) page.

```SHELL
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### Start minikube

```SHELL
minikube start \
	--driver=docker \
	--cpus 6 --memory 14336 --disk-size=150g \	
	--extra-config=apiserver.service-account-issuer=api \
	--extra-config=apiserver.service-account-signing-key-file=/var/lib/minikube/certs/apiserver.key \
	--extra-config=apiserver.service-account-api-audiences=api
#	--cpus 6 --memory 12288 --disk-size=120g \	
```

### K8s Dashboard 접속

```bash
$ minikube addons enable dashboard
$ minikube addons list
$ minikube dashboard &
$ kubectl proxy --address='0.0.0.0' --disable-filter=true &

# 이건 뭐지?
$ kubectl proxy --accept-hosts=.* --address=0.0.0.0 &
```

이거 봐야하나

- https://www.youtube.com/watch?v=-TGBsb0oMeA

### Kubeflow 설치

- [Kubeflow releases page](https://github.com/kubeflow/kfctl/releases/).

##### Version

- v1.1.1
  - kfctl: https://github.com/kubeflow/kfctl/releases/download/v1.1.0/kfctl_v1.1.0-0-g9a3621e_linux.tar.gz
  - config-yaml: https://github.com/kubeflow/manifests/raw/master/kfdef/kfctl_k8s_istio.v1.1.0.yaml
- v.1.0.2
  - kfctl: https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz
  - config-yaml: https://github.com/kubeflow/manifests/raw/master/kfdef/kfctl_k8s_istio.v1.0.2.yaml

##### 설치

```bash
export KF_NAME=sds-kubeflow
export KF_HOME=~/kubeflow

mkdir -p $KF_HOME
cd $KF_HOME

rm -f ./kfctl*
wget https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz
tar -xvf kfctl_*.tar.gz	
# 
export PATH=$PATH:$KF_HOME

export KF_DIR=${KF_HOME}/${KF_NAME}
export CONFIG_URI=https://github.com/kubeflow/manifests/raw/master/kfdef/kfctl_k8s_istio.v1.0.2.yaml

mkdir -p ${KF_DIR}
cd ${KF_DIR}
kfctl apply -V -f ${CONFIG_URI}

```















# Base Image

- https://console.cloud.google.com/gcr/images/kubeflow-images-staging/GLOBAL
- https://github.com/kubeflow/kubeflow/blob/master/components/tensorflow-notebook-image/Dockerfile
- sudo 권한 부여하기: https://thebook.io/006718/part01/ch03/02/03/

```dockerfile
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

# docker build -t kubeflow-registry.default.svc.cluster.local:30000/tensorflow-2.1.0-notebook-gpu:1.0.0.SDS.0.1.4 .

# docker push kubeflow-registry.default.svc.cluster.local:30000/tensorflow-2.1.0-notebook-gpu:1.0.0.SDS.0.1.4

# kubectl edit cm jupyter-web-app-config -n kubeflow
```



```dockerfile
FROM kubeflow-registry.default.svc.cluster.local:30000/tensorflow-2.1.0-notebook-gpu:1.0.0.SDS.0.1.4
USER root
COPY ./requirements.txt requirements.txt
RUN pip install -r requirements.txt 
USER jovyan
```



  ```
(mlpipeline) root@smaster:~/notebookImage# cat > requirements.txt << EOF
numpy==1.16.4
pandas==0.25.1
scikit-learn==0.20.4
opencv-python 
imutils 
EOF

  ```


```

```