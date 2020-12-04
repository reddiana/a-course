

pip show kubeflow-fairing
Name: kubeflow-fairing
Version: 1.0.2

[Releases · kubeflow/fairing (github.com)](https://github.com/kubeflow/fairing/releases) : 2020-1204 현재 latest v1.0.2





[kubeflow/fairing: Python SDK for building, training, and deploying ML models (github.com)](https://github.com/kubeflow/fairing)

[Welcome to Kubeflow Fairing SDK API reference — Kubeflow Fairing v0.7.0 documentation (kubeflow-fairing.readthedocs.io)](https://kubeflow-fairing.readthedocs.io/en/latest/index.html)

[Kubeflow – Fairing – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/03/14/kubeflow-fairing/)



#### Preprocessor 

- **python** : 입력 파일을 컨테이너 이미지에 직접 복사합니다.
- **notebook** : 노트북을 실행 가능한 파이썬 파일로 변환합니다. 그리고 노트북 코드에서 파이썬 코드가 아닌 부분을 제거합니다.
- **full_notebook** : 파이썬 코드가 아닌 부분들을 포함해서 전체 노트북을 그대로 실행합니다. 별다른 설정이 없다면, 노트북 실행에 papermill을 사용합니다.
- **function** : FunctionPreProcessor는 단일 함수를 전처리합니다. function_shim.py을 사용하여 함수를 직접 호출합니다.

#### Builder

- **append** : 기존 컨테이너 이미지를 바탕으로, 코드를 새 레이어로 추가합니다. 이 빌더는 기본 이미지를 가져 와서 이미지를 작성하지 않고, 추가된 부분만 컨테이너 이미지 레지스트리에 푸시합니다. 그래서 학습 작업을 위한 컨테이너 이미지를 작성하는 데 시간이 상대적으로 적게 소모됩니다. 그리고 파이썬 라이브러인 containerregistry을 사용하기 때문에, 도커 데몬이 필요 없습니다.
- **docker** : 로컬 도커 데몬을 사용하여, 학습 작업에 사용할 컨테이너 이미지를 빌드하고, 컨테이너 이미지 레지스트리에 푸시합니다
- **cluster** : 쿠버네티스 클러스터에서 학습 작업에 사용할 컨테이너 이미지를 빌드하고, 컨테이너 이미지 레지스트리에 푸시합니다

#### Deployer 

- **Job** : 쿠버네티스 Job 리소스를 사용하여 학습 작업을 시작합니다.
- **TfJob** : Kubeflow의 TFJob 컴포넌트를 사용하여 텐서플로우 학습 작업을 시작합니다. (예제: [fairing/main.py at master · kubeflow/fairing (github.com)](https://github.com/kubeflow/fairing/blob/master/examples/distributed-training/main.py))
- **PyTorchJob** : Kubeflow의 PyTorchJob 컴포넌트를 사용하여 PyTorch 학습 작업을 시작합니다.
- **GCPJob** : GCP에게 학습 작업 보냅니다.
- **Serving** : 쿠버네티스의 디플로이먼트(deployment)와 서비스(service)를 사용하여, 예측(prediction) 엔드포인트를 서빙합니다.
- **KFServing** : KFServing을 사용하여, 예측(prediction) 엔드포인트를 서빙합니다.

### 학습 작업 삭제하기

작업이 완료되어도 Job은 삭제되지 않습니다.

다음 명령어를 실행하면 admin 네임스페이스의 mnist-job-0a3bd86kp 라는 이름의 Job을 삭제할 수 있습니다.

kubectl -n admin delete job mnist-job-0a3bd86kp