https://github.com/kubeflow/fairing.git

[KFServing – 클라우드 저장소를 이용하여 InferenceService 배포와 예측 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/04/18/kfserving-클라우드-저장소를-이용하여-inferenceservice-배포와-예측/)

[Fairing :: Amazon EKS Workshop](https://www.eksworkshop.com/advanced/420_kubeflow/fairing/)



# S3

- [examples/s3.md at master · tensorflow/examples (github.com)](https://github.com/tensorflow/examples/blob/master/community/en/docs/deploy/s3.md)

Using the above information, we can configure Tensorflow to communicate to an S3 endpoint by setting the following environment variables:

```
AWS_ACCESS_KEY_ID=XXXXX                 # Credentials only needed if connecting to a private endpoint
AWS_SECRET_ACCESS_KEY=XXXXX
AWS_REGION=us-east-1                    # Region for the S3 bucket, this is not always needed. Default is us-east-1.
S3_ENDPOINT=s3.us-east-1.amazonaws.com  # The S3 API Endpoint to connect to. This is specified in a HOST:PORT format.
S3_USE_HTTPS=1                          # Whether or not to use HTTPS. Disable with 0.
S3_VERIFY_SSL=1                         # If HTTPS is used, controls if SSL should be enabled. Disable with 0.
```

# Jupyter Notebook

```

```



# Fairing



# Pipeline

# KFServing

```
$ echo -n 'minio' | base64
bWluaW8=

$ echo -n 'minio123' | base64
bWluaW8xMjM=
```

```
# kubectl apply -f -
apiVersion: v1
kind: Secret
data:
  awsAccessKeyID: bWluaW8=
  awsSecretAccessKey: bWluaW8xMjM=
metadata:
  name: minio-secret
  namespace: myspace
  annotations:
    serving.kubeflow.org/s3-endpoint: minio-service.kubeflow:9000
    serving.kubeflow.org/s3-usehttps: "0"
    serving.kubeflow.org/s3-verifyssl: "0"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kfserving-sa
  namespace: myspace
secrets:
- name: minio-secret
- name: kfserving-secret
```

```
# kubectl apply -f -
apiVersion: serving.kubeflow.org/v1alpha2
kind: InferenceService
metadata:
  name: kfserving-fmnist
  namespace: kubeflow
spec:
  default:
    predictor:
      serviceAccountName: kfserving-sa
      tensorflow:
        storageUri: 's3://kubeflow-pvc/saved_model'

```



