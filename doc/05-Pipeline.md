[Kubeflow Pipelines로 고객평생가치 예측 아키텍처 및 디자인  | 솔루션  | Google Cloud](https://cloud.google.com/solutions/predicting-clv-kubeflow-pipelines-architecture-design?hl=ko)

[MLOps: 머신러닝의 지속적 배포 및 자동화 파이프라인  | Google Cloud](https://cloud.google.com/solutions/machine-learning/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning?hl=ko)





## 홈페이지

[Concepts | Kubeflow](https://www.kubeflow.org/docs/pipelines/overview/concepts/)

[Building Pipelines with the SDK | Kubeflow](https://www.kubeflow.org/docs/pipelines/sdk/)



## 지구별 여행자 블로그

- [Kubeflow – Kubeflow Pipelines 이해하기 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/03/28/kubeflow-kubeflow-pipelines-이해하기/)
- [Kubeflow Pipelines – SDK를 사용해서 파이프라인 만들기 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/03/28/kubeflow-pipelines-sdk를-사용해서-파이프라인-만들기/)
- [Kubeflow Pipelines – DSL 이해하기 #1 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/03/28/kubeflow-pipelines-dsl-이해하기-1/)
- [Kubeflow Pipelines – DSL 이해하기 #2 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/04/04/kubeflow-pipelines-dsl-이해하기-2/)

- [Kubeflow Pipelines – 재사용 가능한 컴포넌트 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/04/04/kubeflow-pipelines-재사용-가능한-컴포넌트/)

- [Kubeflow Pipelines – 경량 파이썬 컴포넌트 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/04/04/kubeflow-pipelines-경량-파이썬-컴포넌트/)

- [Kubeflow Pipelines – 파이프라인 메트릭 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/04/04/kubeflow-pipelines-파이프라인-메트릭/)
- [Kubeflow Pipelines – 파이프 라인 UI에서 결과 시각화 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/04/04/kubeflow-pipelines-파이프-라인-ui에서-결과-시각화/)
- [Kubeflow Pipelines – 파이프라인에서 외부 저장소를 이용하기 – 지구별 여행자 (kangwoo.kr)](https://www.kangwoo.kr/2020/04/04/kubeflow-pipelines-파이프라인에서-외부-저장소를-이용하기/)



# Pipeline 생성

#### 생성 절차

1. Pipelines DSL(SDK)을 사용하여 파이프라인 함수와 컴포넌트 함수를 작성
2. 파이프 라인을 컴파일 하여 YAML 파일을 생성하고 압축(.gz)
3. 파이프 라인(.gz)을 업로드하고, 실행

#### Pipeline 컴파일 방법

- 방법1: 
  shell에서 cli 명령을 사용: dsl-compile

  ```bash
  dsl-compile --py [path/to/python/file] --output my_pipeline.zip
  ```

- 방법2: 
  Pipelines SDK 를 사용: kfp.compiler.Compiler.compile

  ```python
  kfp.compiler.Compiler().compile(my_pipeline, 'my_pipeline.zip')
  ```

#### Pipeline 실행 방법

- 방법1: 
  Pipelines SDK 를 사용

  ```python
  client = kfp.Client()
  my_experiment = client.create_experiment(name='hello-exp-demo')
  my_run = client.run_pipeline(my_experiment.id, 'my-pipeline', 'my_pipeline.zip')
  ```

- 방법2:
  Kubeflow Pipelines UI를 사용

# Pipeline SDK

- [kfp.compiler](https://kubeflow-pipelines.readthedocs.io/en/latest/source/kfp.compiler.html) : 파이프 라인을 컴파일 할 수 있는 기능을 제공하고 있습니다.
  - `kfp.compiler.Compiler.compile` : Python DSL 코드를 Kubeflow Pipelines 서비스가 처리 할 수 있는 단일 정적 구성 (YAML 형식)으로 컴파일

```python
@dsl.pipeline(
  name='hello-pl-demo',
  description='hi there description'
)
def my_pipeline(a: int = 1, b: str = "default value"):
  ...

Compiler().compile(my_pipeline, 'path/to/workflow.yaml')
```

- [kfp.component](https://kubeflow-pipelines.readthedocs.io/en/latest/source/kfp.components.html) : 파이프 라인 컴포넌트와 상호 작용하기 위한 기능을 제공하고 있습니다.
  팩토리 함수를 리턴합니다. 그런 다음 팩토리 함수를 호출하여 컴포넌트 컨테이너 이미지를 실행하는 파이프 라인 태스크 (ContainerOp)의 인스턴스를 구성
  - `kfp.components.func_to_container_op` : **Python 함수**를 파이프 라인 컴포넌트로 변환하고 팩토리 함수를 리턴
  - `kfp.components.load_component_from_file` : **파일**에서 파이프 라인 컴포넌트를 로드하고 팩토리 함수를 리턴
  - `kfp.components.load_component_from_url` : **URL**에서 파이프 라인 컴포넌트를 로드하고 팩토리 함수를 리턴

- kfp.containers : 컴포넌트 컨테이너 이미지를 빌드하는 기능을 제공하고 있습니다.
  - `build_image_from_working_dir` : 파이썬 작업 디렉토리를 사용하여 새 컨테이너 이미지를 빌드하고 푸시. (현재는 Google Cloud Platform (GCP) 환경에서만 사용 가능) <- TODO 확인 필요
- [kfp.dsl](https://kubeflow-pipelines.readthedocs.io/en/latest/source/kfp.dsl.html) : 파이프 라인 및 컴포넌트를 정의하고 상호 작용하는 데 사용할 수있는 DSL (Domain-Specific Language)
  - `kfp.dsl.ContainerOp` : 컨테이너 이미지로 구현 된 파이프 라인 Op
  - `kfp.dsl.PipelineParam` 한 파이프 라인 컴포넌트에서 다른 파이프 라인 컴포넌트로 전달할 수있는 파이프 라인 파라미터
  - 데코레이터
    - `kfp.dsl.component` : 파이프 라인 컴포넌트를 반환하는 **DSL 함수**의 데코레이터(ContainerOp).
    - `kfp.dsl.pipeline` : 파이프 라인을 반환하는 Python 함수의 데코레이터
    - `kfp.dsl.python_component`: 파이프 라인 컴포넌트 메타 데이터를 함수 객체에 추가하는 **Python 함수**의 데코레이터
  - `kfp.dsl.types`:  Kubeflow Pipelines SDK에서 사용하는 타입들이 정의되어 있습니다. 타입에는 String, Integer, Float 및 Bool과 같은 기본 타입과 GCPProjectID 및 GCRPath와 같은 도메인 별 타입이 있습니다. [DSL 정적 유형 검사](https://www.kubeflow.org/docs/pipelines/sdk/static-type-checking/)에 대해서는 안내서를 참조하실 수 있습니다.
  - K8s 리소스 관련
    - `kfp.dsl.ResourceOp` : K8s 리소스를 직접 조작하는 Op (`create`, `get`, `apply` 등 ).
    - `kfp.dsl.VolumeOp` : K8s PersistentVolumeClaim 을 생성하는 파이프 라인 Op
    - `kfp.dsl.VolumeSnapshotOp` : 새로운 볼륨 스냅 샷을 생성하는 파이프 라인 Op
    - `kfp.dsl.PipelineVolume` : 파이프 라인의 단계간에 데이터를 전달하기 위해 사용하는 볼륨
- [kfp.Client](https://kubeflow-pipelines.readthedocs.io/en/latest/source/kfp.client.html) : Kubeflow Pipelines API 용 Python 클라이언트 라이브러리
  - `kfp.Client.create_experiment` : 파이프 라인 [experiment](https://www.kubeflow.org/docs/pipelines/concepts/experiment/) 을 만들고, [experiment](https://www.kubeflow.org/docs/pipelines/concepts/experiment/) 개체를 반환
  - `kfp.Client.run_pipeline` 파이프 라인을 실행(run)하고 실행(run) 개체를 반환





