# registry 다익스트라



| 주소                                   | ClusterIP | NodePort | push | pull |                                                              |
| -------------------------------------- | --------- | -------- | ---- | ---- | ------------------------------------------------------------ |
| registry.kube-system.svc.cluster.local | 1         | 1        | SUCC | FAIL | Jod이 Pod 생성 시 Get https://registry.kube-system.svc.cluster.local/v2/: dial tcp: lookup registry.kube-system.svc.cluster.local: no such host |
| NodePort + CoreDNS host                |           | 2        | FAIL |      | SSLError: [SSL: WRONG_VERSION_NUMBER] wrong version number (_ssl.c:852) |
| HostOS에 docker-registry 설치          |           |          | FAIL |      | SSLError: [SSL: WRONG_VERSION_NUMBER] wrong version number (_ssl.c:852) |

### 1. registry.kube-system.svc.cluster.local + ClusterIP

```
Failed to pull image "registry.kube-system.svc.cluster.local/tensorboard-job:8FD514F5": rpc error: code = Unknown desc = Error response from daemon: Get https://registry.kube-system.svc.cluster.local/v2/: dial tcp: lookup registry.kube-system.svc.cluster.local: no such host
```

- registry.kube-system.svc.cluster.local 이런 형식으로 접근하는게 뭐지?

- 왜 Pod 생성시에는 dial tcp: lookup registry.kube-system.svc.cluster.local: no such host 이딴 소리 하지

- Notebook Pod에서 테스트해보면 잘 된다

  ```
  curl registry.kube-system.svc.cluster.local/v2/_catalog
  {"repositories":["tensorboard-job"]}
  ```
  
- [Add cluster DNS to node resolv.conf (cannot pull image from cluster-internal host name) · Issue #2162 · kubernetes/minikube (github.com)](https://github.com/kubernetes/minikube/issues/2162) 

### 2. CoreDNS에 host 등록 + NodePort

- NodePort 32080, 32443 으로 등록

  ```
  kubectl edit svc -n kube-system registry
  ```

  ```
    ports:
    - name: http
      nodePort: 32080
      port: 80
      protocol: TCP
      targetPort: 5000
    - name: https
      nodePort: 32443
      port: 443
      protocol: TCP
      targetPort: 443
    selector:
      actual-registry: "true"
      kubernetes.io/minikube-addons: registry
    sessionAffinity: None
    type: NodePort
  
  ```

- CoreDNS에 host 등록: 

  - 192.168.49.2  my.sds.redii.net
  - 192.168.49.2은 Minikube service IP
  
- Pod 안에서 curl 테스트는 통과함

  ```
  > curl my.sds.redii.net:32080/v2/_catalog
  {"repositories":["tensorboard-job"}
  ```

- 근데 이러면 minikube 기동시 에러남. 무시하자

  ```
  minikube start ...
  ```

  ```
  * Verifying registry addon...
  ! Enabling 'registry' returned an error: running callbacks: [sudo KUBECONFIG=/var/lib/minikube/kubeconfig /var/lib/minikube/binaries/v1.15.2/kubectl apply -f /etc/kubernetes/addons/registry-rc.yaml -f /etc/kubernetes/addons/registry-svc.yaml -f /etc/kubernetes/addons/registry-proxy.yaml: Process exited with status 1
  stdout:
  replicationcontroller/registry unchanged
  daemonset.apps/registry-proxy unchanged
  
  stderr:
  The Service "registry" is invalid:
  * spec.ports[0].nodePort: Forbidden: may not be used when `type` is 'ClusterIP'
  * spec.ports[1].nodePort: Forbidden: may not be used when `type` is 'ClusterIP'
  ]
  ```

  근데도 조회하면 나옴

  ```
  $ minikube service -n kube-system registry
  |-------------|----------|-------------|---------------------------|
  |  NAMESPACE  |   NAME   | TARGET PORT |            URL            |
  |-------------|----------|-------------|---------------------------|
  | kube-system | registry | http/80     | http://192.168.49.2:32080 |
  |             |          | https/443   | http://192.168.49.2:32443 |
  |-------------|----------|-------------|---------------------------|
  * Opening service kube-system/registry in default browser...
    - http://192.168.49.2:32080
  * Opening service kube-system/registry in default browser...
    - http://192.168.49.2:32443
  ```

- fairing 실행 시

  ```
  Loading Docker credentials for repository 'my.sds.redii.net:32080/tensorboard-job:65817DB'
  ...
  SSLError: [SSL: WRONG_VERSION_NUMBER] wrong version number (_ssl.c:852)
  ```

  뭐야 minikube start 할 때 `--insecure-registry` 옵션 두개 써서 안됨?

- `--insecure-registry`  한개만 써도 동일함

  ```
  Loading Docker credentials for repository 'my.sds.redii.net:32080/tensorboard-job:8E96E1B3'
  ...
  SSLError: [SSL: WRONG_VERSION_NUMBER] wrong version number (_ssl.c:852)
  ```

### 3. HostOS에 docker-registry 설치

10.178.0.38/32

```
docker run -dit --name docker-registry -p 5000:5000 registry

cat /etc/hosts
127.0.0.1 localhost  my.sds.redii.net

minikube start \
...
  --insecure-registry "my.sds.redii.net" \
...

ip addr 해보니 10.178.0.38

kubectl edit configmap -n kube-system coredns
...
        hosts {
            10.178.0.38  my.sds.redii.net
```

결과는

```
[W 201125 18:21:31 append:94] Pushing image my.sds.redii.net:5000/fairing-job:5880E125...
[I 201125 18:21:31 docker_creds_:234] Loading Docker credentials for repository 'my.sds.redii.net:5000/fairing-job:5880E125'
...
SSLError: [SSL: WRONG_VERSION_NUMBER] wrong version number (_ssl.c:852)
```

- Pod 안에서 curl 테스트는 통과함

  - haha는 HostOS에서 push 한거

  ```
   > curl my.sds.redii.net:5000/v2/_catalog
  {"repositories":["haha"]}
  ```

- [Loading Docker credentials for repository: SSLError · Issue #460 · kubeflow/fairing (github.com)](https://github.com/kubeflow/fairing/issues/460)

# CoreDNS

```
 kubectl edit configmap -n kube-system coredns
```

192.168.49.2  my.sds.redii.net 추가

```yaml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           upstream
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
        hosts {
            192.168.49.2  my.sds.redii.net
            fallthrough
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2020-11-24T06:44:11Z"
  name: coredns
  namespace: kube-system
  resourceVersion: "512708"
  selfLink: /api/v1/namespaces/kube-system/configmaps/coredns
  uid: 0e8bd79f-3d62-423a-97b0-e8878c989584
```

# minikube start 옵션

```
minikube start \
...
  --insecure-registry "my.sds.redii.net" \
  --insecure-registry "10.0.0.0/24" \
... 
```



```
registry.kube-system.svc.cluster.local

curl kubeflow-registry.default.svc.cluster.local:30000/v2/_catalog

192.168.49.2  my.sds.redii.net

curl -v 10.110.110.100/v2/_catalog

curl -v my.sds.redii.net:32080/v2/_catalog

curl -v 10.107.33.54:32080/v2/_catalog

curl -v 192.168.49.2:32080/v2/_catalog

ImagePullBackOff

curl -X GET http://localhost:32000/v2/fairing-job/tags/list
```







