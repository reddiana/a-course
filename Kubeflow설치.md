[TOC]

# TODO

- [ ] MLOps 개요 교재추가
- [ ] Kale 교재추가

  - [ ] https://github.com/sds-arch-cert/kubeflow-edu.git 
  - [ ] Kale 추가된 image 작성
- [ ] 실사례 pipeline 예제 (당근마켓 등)
- [ ] TFServing으로 KFServing 활용 예제
- [ ] KF의 K8s 리소스 정리

  - [ ] Role 정리 https://www.kubeflow.org/docs/notebooks/submit-kubernetes/



```
git clone https://github.com/reddiana/a-course.git
cd a-course
git config credential.helper store
```

# GCP 인스턴스 준비

- 이름: red-edu
- 머신구성
  - 머신계열 > 일반용도
    - 시리즈: N1
    - 머신유형: 커스텀
      - 코어: 8 vCPU
      - 메모리: 36 GB
      - 메모리확장: 선택안함
- 부팅 디스크
  - 운영체계/버전: Ubuntu 20.04 LTS
  - 부팅디스크 유형: 표준 영구 디스크
  - 크기: 300GB
- 네트워킹
  - 네트워크 태그: kubeflow
  - 네트워크 인터페이스
    - 외부IP: 임시
      - 네트워크 서비스 계층: 표준



https://www.kubeflow.org/docs/started/workstation/minikube-linux/

모든 설치 과정은 root 계정으로 진행

### 도커설치

```bash
apt-get update
apt install -y docker.io
systemctl start docker
systemctl enable docker
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
install minikube-linux-amd64 /usr/local/bin/minikube
sysctl fs.protected_regular=0
```

### Alias

```sh
cat << EOF >> /etc/bash.bashrc
set -o vi
alias d='docker'
alias k='kubectl'
alias kubectl='kubectl'
alias kw='watch "kubectl get pod -A"'
alias kww='watch "kubectl get pod -A | grep -v Running"'
EOF
```

### Start minikube

```SHELL
minikube start \
  --driver=none \
  --extra-config=apiserver.service-account-issuer=api \
  --extra-config=apiserver.service-account-signing-key-file=/var/lib/minikube/certs/apiserver.key \
  --extra-config=apiserver.service-account-api-audiences=api \
  --insecure-registry "kubeflow-registry.default.svc.cluster.local" \
  --kubernetes-version v1.15.2 
```

```
* Preparing Kubernetes v1.15.2 on Docker 19.03.8 ...
  - kubelet.resolv-conf=/run/systemd/resolve/resolv.conf
! Unable to restart cluster, will reset it: getting k8s client: client config: client config: context "minikube" does not exist

X Exiting due to HOST_JUJU_LOCK_PERMISSION: Failed kubeconfig update: writing kubeconfig: Error writing file /root/.kube/config: failed to acquire lock for /root/.kube/config: {Name:mk72a1487fd2da23da9e8181e16f352a6105bd56 Clock:{} Delay:500ms Timeout:1m0s Cancel:<nil>}: unable to open /tmp/juju-mk72a1487fd2da23da9e8181e16f352a6105bd56: permission denied
* Suggestion: Run 'sudo sysctl fs.protected_regular=0', or try a driver which does not require root, such as '--driver=docker'
* Related issue: https://github.com/kubernetes/minikube/issues/6391
```

```
sysctl fs.protected_regular=0
```

### K8s 대쉬보드 설정

```
minikube addons enable dashboard metrics-server
minikube addons list
```

```
kubectl edit svc -n kubernetes-dashboard kubernetes-dashboard
```

```yaml
...
  ports:
  - nodePort: 30003  # 여기
    port: 80
    protocol: TCP
    targetPort: 9090
  selector:
    k8s-app: kubernetes-dashboard
  sessionAffinity: None
  type: NodePort  # 여기
...
```

### Kubeflow 설치

##### Version 확인

- [Releases · kubeflow/kfctl (github.com)](https://github.com/kubeflow/kfctl/releases/)
- [manifests/kfdef at master · kubeflow/manifests (github.com)](https://github.com/kubeflow/manifests/tree/master/kfdef)

##### 설치

```bash
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
```

### Private Registry 설치

```
kubectl apply -f kubeflow-registry-deploy.yaml
kubectl apply -f kubeflow-registry-svc.yaml
```

```
> kubectl get svc kubeflow-registry
NAME                TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
kubeflow-registry   NodePort   10.102.220.65   <none>        30000:30000/TCP   4m12s
```

```
cat << EO_HOSTS >> /etc/hosts
10.102.220.65	kubeflow-registry.default.svc.cluster.local
EO_HOSTS
```
