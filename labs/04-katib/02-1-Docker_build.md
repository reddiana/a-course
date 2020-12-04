Host에 ssh로 접속하여 아래 명령을 실행

```sh
REGISTRY=kubeflow-registry.default.svc.cluster.local:30000
TAG=$REGISTRY/katib-job:latest

cat << EOF | docker build -t $TAG -f - . 
FROM brightfly/kubeflow-jupyter-lab:tf2.0-gpu
COPY 01-1-fashion-mnist-katib-train.py /app/
CMD ['python', '/app/01-1-fashion-mnist-katib-train.py']
EOF

docker push $TAG
```