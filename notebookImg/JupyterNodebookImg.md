# Base Image

- https://console.cloud.google.com/gcr/images/kubeflow-images-staging/GLOBAL

- https://github.com/kubeflow/kubeflow/blob/master/components/tensorflow-notebook-image/Dockerfile

  

# 추가 내용

- sudo 권한 부여하기: https://thebook.io/006718/part01/ch03/02/03/



# 설치 패키지



# 적용

```bash
kubectl edit configmap -n kubeflow jupyter-web-app-config
```

```yaml
    spawnerFormDefaults:
      image:
        ...
        options:
          - reddiana/jupyterlab-kale:latest
          - gcr.io/kubeflow-images-public/tensorflow-1.15.2-notebook-cpu:1.0.0
          - gcr.io/kubeflow-images-public/tensorflow-1.15.2-notebook-gpu:1.0.0
          - gcr.io/kubeflow-images-public/tensorflow-2.1.0-notebook-cpu:1.0.0
          - gcr.io/kubeflow-images-public/tensorflow-2.1.0-notebook-gpu:1.0.0
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

