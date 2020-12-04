[kubeflow/katib: Repository for hyperparameter tuning (github.com)](https://github.com/kubeflow/katib)



# 이슈

```
# k describe  job -n myspace        red-1021-1441-exp-tlb0j-7r6c7n2x
Name:           red-1021-1441-exp-tlb0j-7r6c7n2x
Namespace:      myspace
...
Pod Template:
  Labels:           access-ml-pipeline=true
                    controller-uid=09315f19-6fca-4ce0-91b5-3ee71e0d5f6c
                    job-name=red-1021-1441-exp-tlb0j-7r6c7n2x
  Annotations:      sidecar.istio.io/inject: false
  Service Account:  pipeline-runner
  Containers:
   red-1021-1441-exp-tlb0j-7r6c7n2x:
    Image:      gcr.io/arrikto/katib-kfp-trial:7a304af-feaafdd
...
Events:
  Type     Reason        Age                   From            Message
  ----     ------        ----                  ----            -------
  Warning  FailedCreate  82s (x63 over 5h47m)  job-controller  Error creating: pods "red-1021-1441-exp-tlb0j-7r6c7n2x-" is forbidden: error looking up service account myspace/pipeline-runner: serviceaccount "pipeline-runner" not found
```



[Kubeflow – Katib 소개 – 지구별 여행자 (kangwoo.kr)](https://kangwoo.kr/2020/03/20/kubeflow-katib-소개/)

[katib/workflow-design.md at master · kubeflow/katib (github.com)](https://github.com/kubeflow/katib/blob/master/docs/workflow-design.md)



```sh
#!/bin/bash

TAG=haha:hoho

cat << EOF | docker build -t $TAG -f - . 
FROM brightfly/kubeflow-jupyter-lab:tf2.0-gpu
COPY 01-1-fashion-mnist-katib-train.py /app/
CMD ['python', '/app/01-1-fashion-mnist-katib-train.py']
EOF

docker push $TAG
```





이게 뭐야

- Experiment

- Suggestion

- Trial



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

