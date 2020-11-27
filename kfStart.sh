#!/bin/bash

# kubernetes-version v1.15.2
minikube start \
  --extra-config=apiserver.service-account-issuer=api \
  --extra-config=apiserver.service-account-signing-key-file=/var/lib/minikube/certs/apiserver.key \
  --extra-config=apiserver.service-account-api-audiences=api \
  --kubernetes-version v1.15.2 \
  --insecure-registry "kubeflow-registry.default.svc.cluster.local:30000" \
  --insecure-registry "10.0.0.0/24" \
  --cpus 6 --memory 14336 --disk-size=200g 
  #--insecure-registry "my.sds.redii.net" \
  #--insecure-registry "registry.kube-system.svc.cluster.local" \

# 방화벽 비활성
sudo ufw disable

# 뜨는데 오래 걸린다
# watch 'kubectl get pod -A | grep -vi running'
  
