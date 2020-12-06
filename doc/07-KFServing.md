[KFServing InferenceService 배포와 예측 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/04/11/kfserving-inferenceservice-배포와-예측/)

[KFServing – 클라우드 저장소를 이용하여 InferenceService 배포와 예측 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/04/18/kfserving-클라우드-저장소를-이용하여-inferenceservice-배포와-예측/)

[kfserving/docs/samples/storage/s3 at master · kubeflow/kfserving (github.com)](https://github.com/kubeflow/kfserving/tree/master/docs/samples/storage/s3)



```
kubectl delete inferenceservice -n kubeflow  kfserving-covid19

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: minio-secret
  namespace: kubeflow
  annotations:
    serving.kubeflow.org/s3-endpoint: minio-service.kubeflow:9000
    serving.kubeflow.org/s3-usehttps: "0"
    serving.kubeflow.org/s3-verifyssl: "0"
data:
  awsAccessKeyID: bWluaW8=
  awsSecretAccessKey: bWluaW8xMjM=
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kfserving-sa
  namespace: kubeflow
secrets:
- name: minio-secret
---
apiVersion: serving.kubeflow.org/v1alpha2
kind: InferenceService
metadata:
  name: kfserving-covid19
  namespace: kubeflow
spec:
  default:
    predictor:
      serviceAccountName: kfserving-sa
      tensorflow:
        storageUri: 's3://model/covid/'
EOF

kubectl get inferenceservice -n kubeflow  kfserving-covid19

k get po -n kubeflow | grep covid

```



```
# inferenceservice.serving.kubeflow.org/kfserving-covid19 created


kubectl get inferenceservice -n kubeflow  kfserving-covid19


NAME                URL   READY   DEFAULT TRAFFIC   CANARY TRAFFIC   AGE
kfserving-covid19         False                                      91s


kubectl describe inferenceservice -n kubeflow  kfserving-covid19

k get po -n kubeflow | grep covid

```



```
MODEL_NAME=kfserving-covid19
INGRESS_HOST=10.109.3.50
INGRESS_PORT=80
SERVICE_HOSTNAME=$(kubectl get inferenceservice -n kubeflow $MODEL_NAME -o jsonpath='{.status.url}' | cut -d "/" -f 3)
SERVING_URL=http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/$MODEL_NAME:predict

curl -v -H "Host: ${SERVICE_HOSTNAME}" ${SERVING_URL} -d @./input.json

curl -v -H "Host: kfserving-covid19.kubeflow.example.com" http://35.206.247.237:32380/v1/models/kfserving-covid19:predict
```





```
root@red-edu-1:~# kubectl -n istio-system get service kfserving-ingressgateway
NAME                       TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)                                                                                                                                                                                   AGE
kfserving-ingressgateway   LoadBalancer   10.109.3.50   <pending>     15020:31383/TCP,80:32380/TCP,443:32390/TCP,31400:32400/TCP,15011:31337/TCP,8060:30709/TCP,853:30471/TCP,15029:30452/TCP,15030:30885/TCP,15031:31246/TCP,15032:31204/TCP,15443:30103/TCP   6h29m

NAME                       TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)                                                                                                                                                                                   AGE
kfserving-ingressgateway   NodePort   10.109.3.50   <none>        15020:31383/TCP,80:32380/TCP,443:32390/TCP,31400:32400/TCP,15011:31337/TCP,8060:30709/TCP,853:30471/TCP,15029:30452/TCP,15030:30885/TCP,15031:31246/TCP,15032:31204/TCP,15443:30103/TCP   6h32m

```

