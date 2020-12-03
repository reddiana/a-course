https://github.com/kubeflow/fairing.git

[KFServing – 클라우드 저장소를 이용하여 InferenceService 배포와 예측 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/04/18/kfserving-클라우드-저장소를-이용하여-inferenceservice-배포와-예측/)

[Fairing :: Amazon EKS Workshop](https://www.eksworkshop.com/advanced/420_kubeflow/fairing/)





[kfserving/docs/samples/storage/s3 at master · kubeflow/kfserving (github.com)](https://github.com/kubeflow/kfserving/tree/master/docs/samples/storage/s3)

# minio cli

- [MinIO | The complete guide to the MinIO client](https://docs.min.io/docs/minio-client-complete-guide.html)

```
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
mv mc /usr/bin

vi ~/.mc/config.json
...
                "myminio": {
                        "url": "http://minio-service.kubeflow:9000",
                        "accessKey": "minio",
                        "secretKey": "minio123",
                        "api": "S3v4",
                        "path": "auto"
                },
...

mc rm --recursive --force myminio/dataset/covid-19/

git clone https://github.com/sds-arch-cert/Covid19-X-Rays.git
mc cp -r Covid19-X-Rays/all/* myminio/dataset/covid-19/

mc tree myminio/
```

```
ls          list buckets and objects
mb          make a bucket
rb          remove a bucket
cp          copy objects
cat         display object contents
mv          move objects
tree        list buckets and objects in a tree format
rm          remove objects
```

# Tensorflow

- [examples/s3.md at master · tensorflow/examples (github.com)](https://github.com/tensorflow/examples/blob/master/community/en/docs/deploy/s3.md)

```python
os.environ.update({
    'S3_ENDPOINT'          : 'minio-service.kubeflow:9000',
    'AWS_ACCESS_KEY_ID'    : 'minio',
    'AWS_SECRET_ACCESS_KEY': 'minio123',
    'S3_USE_HTTPS'         : '0',	# Whether or not to use HTTPS. Disable with 0.                        
    'S3_VERIFY_SSL'        : '0' 	# If HTTPS is used, controls if SSL should be enabled. Disable with 0.
})    

save_model(model, 's3://my-test/covid/1')
```

# Minio SDK

```python
from minio import Minio
from minio.error import ResponseError

minioClient = Minio('minio-service.kubeflow:9000',
                    access_key='minio', secret_key='minio123', secure=False)
try:
    minioClient.fget_object('my-test', 'titanic/test.csv',  '/tmp/test.csv')
    minioClient.fget_object('my-test', 'titanic/train.csv', '/tmp/train.csv')
except ResponseError as err:
    print(err)
    
test_df  = pd.read_csv('/tmp/test.csv')
train_df = pd.read_csv('/tmp/train.csv')    
```



# Boto3

```python
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import numpy as np
import boto3
import io

s3 = boto3.resource('s3', region_name='us-east-2')
bucket = s3.Bucket('sentinel-s2-l1c')
object = bucket.Object('tiles/10/S/DG/2015/12/7/0/B01.jp2')

file_stream = io.StringIO()
object.download_fileobj(file_stream)
img = mpimg.imread(file_stream)
# whatever you need to do
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
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: minio-secret
  namespace: myspace
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
  namespace: myspace
secrets:
- name: minio-secret
- name: kfserving-secret
EOF

```

```
cat << EOF | kubectl apply -f -
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
        storageUri: 's3://model/covid/1'
EOF

```

