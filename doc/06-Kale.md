

# 이슈

## serviceaccount "pipeline-runner" not found: 해결

#### kale 말고 그냥 Katib하면 잘 된다

```yaml
root@red-edu-2:/home/red_suh# k describe job -n myspace        redmoon-1-9n4wfcn5
Name:           redmoon-1-9n4wfcn5
Namespace:      myspace
Selector:       controller-uid=0d04c960-47b8-4bb3-a19e-97a124dea25b
Labels:         controller-uid=0d04c960-47b8-4bb3-a19e-97a124dea25b
                job-name=redmoon-1-9n4wfcn5
Annotations:    <none>
Controlled By:  Trial/redmoon-1-9n4wfcn5
Parallelism:    1
Completions:    1
Start Time:     Fri, 04 Dec 2020 18:57:28 +0000
Pods Statuses:  1 Running / 0 Succeeded / 0 Failed
Pod Template:
  Labels:       controller-uid=0d04c960-47b8-4bb3-a19e-97a124dea25b
                job-name=redmoon-1-9n4wfcn5
  Annotations:  sidecar.istio.io/inject: false
  Containers:
   redmoon-1-9n4wfcn5:
    Image:      kubeflow-registry.default.svc.cluster.local:30000/katib-job:8840FE5A
    Port:       <none>
    Host Port:  <none>
    Command:
      python
      /app/01-fashion-mnist-katib-train.py
      --learning_rate=0.007214257611988764
      --dropout_rate=0.6426773367227961
    Limits:
      nvidia.com/gpu:  0
    Environment:       <none>
    Mounts:            <none>
  Volumes:             <none>
Events:
  Type    Reason            Age   From            Message
  ----    ------            ----  ----            -------
  Normal  SuccessfulCreate  77s   job-controller  Created pod: redmoon-1-9n4wfcn5-spd8m

```



#### Kale에서 Katib할 때만 안된다

왜 pipeline을 하려고 하느냐. 이런게 있구나

- Labels:         access-ml-pipeline=true
- Service Account:  pipeline-runner

```
root@red-edu-2:~# k get job -A
NAMESPACE      NAME                                COMPLETIONS   DURATION   AGE
istio-system   istio-cleanup-secrets-1.1.6         1/1           81s        41m
istio-system   istio-grafana-post-install-1.1.6    1/1           81s        41m
istio-system   istio-security-post-install-1.1.6   1/1           84s        41m
kubeflow       spark-operatorcrd-cleanup           1/1           93s        38m
myspace        mymy-e-jxpd9-c447vrjb               0/1                      5s

root@red-edu-2:~# k describe job -n myspace mymy-e-jxpd9-c447vrjb
Name:           mymy-e-jxpd9-c447vrjb
Namespace:      myspace
Selector:       controller-uid=907f67aa-c13a-4b04-8785-acb14edc979c
Labels:         access-ml-pipeline=true
                controller-uid=907f67aa-c13a-4b04-8785-acb14edc979c
                job-name=mymy-e-jxpd9-c447vrjb
Annotations:    <none>
Controlled By:  Trial/mymy-e-jxpd9-c447vrjb
Parallelism:    1
Completions:    1
Pods Statuses:  0 Running / 0 Succeeded / 0 Failed
Pod Template:
  Labels:           access-ml-pipeline=true
                    controller-uid=907f67aa-c13a-4b04-8785-acb14edc979c
                    job-name=mymy-e-jxpd9-c447vrjb
  Annotations:      sidecar.istio.io/inject: false
  Service Account:  pipeline-runner
  Containers:
   mymy-e-jxpd9-c447vrjb:
    Image:      gcr.io/arrikto/katib-kfp-trial:7a304af-feaafdd
    Port:       <none>
    Host Port:  <none>
    Command:
      python3 -u -c "from kale.common.kfputils                import create_and_wait_kfp_run;                create_and_wait_kfp_run(                    pipeline_id='9a4b2d18-ce44-4281-b4d5-f0de83b5fb0f',                    run_name='mymy-e-jxpd9-c447vrjb',                    experiment_name='mymy-e-jxpd9', learning_rate='0.03', dropout_rate='0.14450858048937923',                )"
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type     Reason        Age                From            Message
  ----     ------        ----               ----            -------
  Warning  FailedCreate  13s (x2 over 23s)  job-controller  Error creating: pods "mymy-e-jxpd9-c447vrjb-" is forbidden: error looking up service account myspace/pipeline-runner: serviceaccount "pipeline-runner" not found
```

좀 뒤늣게 다른 exp로 한건데

```
root@red-edu-2:~# k logs -n myspace                pod/kiki-e-hsmrv-random-6ff9567fb5-7qml9
INFO:hyperopt.utils:Failed to load dill, try installing dill via "pip install dill" for enhanced pickling support.
INFO:hyperopt.fmin:Failed to load dill, try installing dill via "pip install dill" for enhanced pickling support.
ERROR:grpc._server:Exception calling application: Method not implemented!
Traceback (most recent call last):
  File "/usr/local/lib/python3.6/site-packages/grpc/_server.py", line 434, in _call_behavior
    response_or_iterator = behavior(argument, context)
  File "/usr/src/app/github.com/kubeflow/katib/pkg/apis/manager/v1alpha3/python/api_pb2_grpc.py", line 135, in ValidateAlgorithmSettings
    raise NotImplementedError('Method not implemented!')
NotImplementedError: Method not implemented!
```

버전을 낮춰보자. 예전엔 분명 됐다 `0.5.0`인가에서 ==> 이거네 젠장

#### 근데 kale에서 그냥 pipeline만 하는건 왜 또 잘되는거냐. pipeline만 돌리고 살펴보자



# 실행 오브젝트

### Pipeline 실행

```
root@red-edu-2:~# k get all -A | grep pipi
kubeflow               pod/pipi-p-ibt29-bcj8h-2084194895                                  2/2     Running            0          13s
kubeflow               pod/pipi-p-ibt29-bcj8h-2291359296                                  0/1     Completed          0          16s
```



### Katib 실행

```
root@red-edu-2:~# k get all -A | grep kiki
myspace                pod/kiki-e-hsmrv-random-6ff9567fb5-7qml9                           1/1     Running            0          79s


myspace                service/kiki-e-hsmrv-random                            ClusterIP      10.104.29.70     <none>        6789/TCP                                                                                                                                                                                  79s


myspace                deployment.apps/kiki-e-hsmrv-random                           1/1     1            1           79s

myspace                replicaset.apps/kiki-e-hsmrv-random-6ff9567fb5                           1         1         1       79s






myspace        job.batch/kiki-e-hsmrv-kclqdvxp                 0/1                      67s
myspace     trial.kubeflow.org/kiki-e-hsmrv-kclqdvxp                 Running     True     67s
myspace     suggestion.kubeflow.org/kiki-e-hsmrv                 Running   True     1           1          79s

myspace     experiment.kubeflow.org/kiki-e-hsmrv                 Running     79s



```

