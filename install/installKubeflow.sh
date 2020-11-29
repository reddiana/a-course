#!/bin/bash

echo "================================="
echo "도커 설치"
echo "---------------------------------"

apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

echo "================================="
echo "kubectl 설치"
echo "---------------------------------"

cd ~

mkdir kubeflow
cd kubeflow

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "================================="
echo "minikube 설치"
echo "---------------------------------"

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

echo "================================="
echo "minikube 기동"
echo "---------------------------------"
sysctl fs.protected_regular=0

minikube start \
  --driver=none \
  --extra-config=apiserver.service-account-issuer=api \
  --extra-config=apiserver.service-account-signing-key-file=/var/lib/minikube/certs/apiserver.key \
  --extra-config=apiserver.service-account-api-audiences=api \
  --insecure-registry "kubeflow-registry.default.svc.cluster.local" \
  --kubernetes-version v1.15.2 
  
echo "================================="
echo "방화벽 해제"
echo "---------------------------------"
ufw disable  
  
echo "================================="
echo "K8s 대쉬보드 설치"
echo "---------------------------------"

minikube addons enable dashboard 
minikube addons enable metrics-server

echo "================================="
echo "Private Registry 설치"
echo "---------------------------------"

kubectl apply -f kubeflow-registry-deploy.yaml
kubectl apply -f kubeflow-registry-svc.yaml

echo "================================="
echo "Kubeflow 설치"
echo "---------------------------------"

export KF_HOME=~/kubeflow
export KF_NAME=sds-kubeflow

rm -rf ${KF_HOME}

mkdir -p $KF_HOME
cd $KF_HOME

rm -f ./kfctl*
wget https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz
tar -xvf kfctl_*.tar.gz	

export PATH=$PATH:$KF_HOME
export KF_DIR=${KF_HOME}/${KF_NAME}
export CONFIG_URI=https://github.com/kubeflow/manifests/raw/master/kfdef/kfctl_k8s_istio.v1.0.2.yaml

mkdir -p ${KF_DIR}
cd ${KF_DIR}
kfctl apply -V -f ${CONFIG_URI}

echo "================================="
echo "Private Registry 설치"
echo "---------------------------------"

kubectl apply -f kubeflow-registry-deploy.yaml
kubectl apply -f kubeflow-registry-svc.yaml

echo "================================="
echo "완료"
echo "---------------------------------"

watch "kubectl get pod -A | grep -v Running"  
