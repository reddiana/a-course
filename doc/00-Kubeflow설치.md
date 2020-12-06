[TOC]

### GCP 인스턴스 준비

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

이하 모든 설치 과정은 root 계정으로 진행

### Alias (선택)

```sh
sudo su
cat << EOF >> /etc/bash.bashrc
set -o vi
alias d='docker'
alias k='kubectl'
alias kubectl='kubectl'
alias kw='watch "kubectl get pod -A"'
alias kww='watch "kubectl get pod -A | grep -v Running"'
EOF
exit
```

### 설치 스크립트로 설치 & 기동

- 도커 설치
- kubectl 설치
- minikube 설치
- minikube 기동
- 방화벽 해제
- K8s 대쉬보드 설치
- Kubeflow 설치
- Private Registry 설치

```
sudo su
git clone https://github.com/reddiana/a-course.git
git config credential.helper store
cd a-course/lab/00-install
sh installKubeflow.sh
```

### K8s 대쉬보드 설정

```bash
# 스크립트로 되는지 테스트 해보자
kubectl patch svc kubernetes-dashboard --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]'
```



```
kubectl edit svc -n kubernetes-dashboard kubernetes-dashboard
```

```yaml
...
  ports:
  - port: 80
    protocol: TCP
    targetPort: 9090
    nodePort: 30003  # 추가    
  selector:
    k8s-app: kubernetes-dashboard
  sessionAffinity: None
  type: NodePort  # 변경
...
```

```
kubectl get svc -n kubernetes-dashboard kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes-dashboard   NodePort   10.98.226.19   <none>        80:30003/TCP   4m14s
```

### Private Registry 확인

```
kubectl get svc kubeflow-registry
NAME                TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)           AGE
kubeflow-registry   NodePort   10.106.167.176   <none>        30000:30000/TCP   16m

curl kubeflow-registry.default.svc.cluster.local:30000/v2/_catalog
{"repositories":[]}
```

### minio 설정 (선택)

```
kubectl edit svc -n kubeflow minio-service
```

```
...
  ports:
  - port: 9000
    protocol: TCP
    targetPort: 9000
    nodePort: 32001 # 추가    
  selector:
    app: minio
    app.kubernetes.io/component: minio
    app.kubernetes.io/instance: minio-0.2.5
    app.kubernetes.io/managed-by: kfctl
    app.kubernetes.io/name: minio
    app.kubernetes.io/part-of: kubeflow
    app.kubernetes.io/version: 0.2.5
  sessionAffinity: None
  type: NodePort # 변경
...
```

```
kubectl get svc -n kubeflow minio-service
NAME            TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
minio-service   NodePort   10.100.140.196   <none>        9000:31900/TCP   19m
```

### minikube 기동 (멈췄을 경우)

```SHELL
sysctl fs.protected_regular=0
minikube start \
  --driver=none \
  --extra-config=apiserver.service-account-issuer=api \
  --extra-config=apiserver.service-account-signing-key-file=/var/lib/minikube/certs/apiserver.key \
  --extra-config=apiserver.service-account-api-audiences=api \
  --kubernetes-version v1.15.2 
```

### 교육 git 주소
```
git clone https://github.com/reddiana/a-course.git
cd a-course
git config --global user.email "red.suh@samsung.com"
git config --global user.name "서세일"
git config credential.helper store
git config log.follow true

git clone https://github.com/sds-arch-cert/kubeflow-edu.git
git clone https://github.com/kubeflow-kale/examples.git ./kale-example
git clone https://github.com/zhongli1990/Covid19-X-Rays.git
```

### 이슈

재기동 시 minio-pv-claim 못 찾음.  minio pod event에 다음 로그 있음

```
persistentvolumeclaim "minio-pv-claim" not found
Error: stat /tmp/hostpath-provisioner/kubeflow/minio-pv-claim: no such file or directory
```

실제로 /tmp/hostpath-provisioner/kubeflow/에 다른 pvc에 해당되는 디렉토리는 있는데 minio-pv-claim는 없음

```
 ll /tmp/hostpath-provisioner/kubeflow/
total 20
drwxr-xr-x 5 root             root 4096 Nov 29 14:15 ./
drwxr-xr-x 3 root             root 4096 Nov 29 14:15 ../
drwxr-xr-x 3 root             root 4096 Nov 29 14:15 katib-mysql/
drwxr-xr-x 3 root             root 4096 Nov 29 14:15 metadata-mysql/
drwxr-xr-x 5 systemd-coredump root 4096 Nov 29 14:15 mysql-pv-claim/
```



- [Kubeflow Pipelines error due to missing PVCs · Issue #277 · agilestacks/components (github.com)](https://github.com/agilestacks/components/issues/277)
- [minio-pvc and mysql-pv-claim Pods stuck in Pending state although I have created 3 persistent volume · Issue #3481 · kubeflow/kubeflow (github.com)](https://github.com/kubeflow/kubeflow/issues/3481)