[kubeflow/katib: Repository for hyperparameter tuning (github.com)](https://github.com/kubeflow/katib)



[Kubeflow – Katib 소개 – 지구별 여행자 (kangwoo.kr)](https://kangwoo.kr/2020/03/20/kubeflow-katib-소개/)

[katib/workflow-design.md at master · kubeflow/katib (github.com)](https://github.com/kubeflow/katib/blob/master/docs/workflow-design.md)



```sh
#!/bin/bash

TAG=haha:hoho

cat << EOF | docker build -t $TAG -f - . 
FROM brightfly/kubeflow-jupyter-lab:tf2.0-gpu
COPY 01-1-fashion-mnist-katib-train.py /app/
CMD ['python', '/app/01-fashion-mnist-katib-train.py']
EOF

docker push $TAG
```





이게 뭐야

- Experiment

- Suggestion

- Trial

# 실행 오브젝트

```
root@red-edu-2:~# k get all -A | grep fashion-mnist-experiment-2
myspace                pod/fashion-mnist-experiment-2-gnqf2p7d-vqvbx                      0/2     ImagePullBackOff   0          54s

myspace                pod/fashion-mnist-experiment-2-nbk4tb9w-z9gnn                      0/2     ErrImagePull       0          54s
myspace                pod/fashion-mnist-experiment-2-random-6498f969f7-2mh98             1/1     Running            0          67s

myspace                service/fashion-mnist-experiment-2-random              ClusterIP      10.106.14.186    <none>        6789/TCP                                                                                                                                                                                  67s


myspace                deployment.apps/fashion-mnist-experiment-2-random             1/1     1            1           67s

myspace                replicaset.apps/fashion-mnist-experiment-2-random-6498f969f7             1         1         1       67s



myspace        job.batch/fashion-mnist-experiment-2-gnqf2p7d   0/1           54s        54s
myspace        job.batch/fashion-mnist-experiment-2-nbk4tb9w   0/1           54s        54s


myspace     suggestion.kubeflow.org/fashion-mnist-experiment-2   Running   True     2           2          67s

myspace     experiment.kubeflow.org/fashion-mnist-experiment-2   Running     67s

myspace     trial.kubeflow.org/fashion-mnist-experiment-2-gnqf2p7d   Running     True     54s
myspace     trial.kubeflow.org/fashion-mnist-experiment-2-nbk4tb9w   Running     True     54s
```



### Metrics Collector

[Kubeflow – Katib : Metrics Collector – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/03/21/kubeflow-katib-metrics-collector/)

metricsCollectorSpec 이런 식으로 들어감

```
apiVersion: "kubeflow.org/v1alpha3"
kind: Experiment
metadata:
  namespace: admin
  name: random-stdout-filter-example
spec:
  metricsCollectorSpec:
    collector:
      kind: StdOut
    source:
      filter:
        metricsFormat:
          - "([\\w|-]+)\\s*:\\s*((-?\\d+)(\\.\\d+)?)"
...          
```

###### StdOud 메트릭 수집기에 필터 적용하기

```
metricsCollectorSpec:
    collector:
      kind: StdOut
    source:
      filter:
        metricsFormat:
          - "([\\w|-]+)\\s*:\\s*((-?\\d+)(\\.\\d+)?)"
```

###### TensorFlowEvent 메트릭 수집기 사용하기

```
metricsCollectorSpec:
    collector:
      kind: TensorFlowEvent
    source:
      fileSystemPath:
        path: /train
        kind: Directory
```

###### File 메트릭 수집기 사용하기

```
metricsCollectorSpec:
    collector:
      kind: File
    source:
      filter:
        metricsFormat:
        - "([\\w|-]+)\\s*=\\s*((-?\\d+)(\\.\\d+)?)"
      fileSystemPath:
        path: "/var/log/katib/mnist.log"
        kind: File
```

