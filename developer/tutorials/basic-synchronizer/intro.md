# Synchronizer Hello World

If you're looking at your first experience in writing an XOS synchronizer,
you are in the right place! Let's start with the basics.

## What do you need?

In order to complete this tutorial you need to have few tools installed on
your system:

- A Kubernetes environment, I'll suggest to use [Minikube](../../../prereqs/k8s-single-node.md#standard-minikube-installation-vm-support)
- Python 2.7 (to verify you can just run `python --version` in a terminal)
- A text editor / IDE of your choice

> Before getting started with this tutorial you may find that
> [Defining Models in CORD](../../../xos/README.md) contains interesting informations
> about the Synchronizers concepts and modeling in general.

## What we'll cover in this tutorial?

This exercise does not pretend to be an extensive guide on the synchronizer,
it's only purpose is to guide you through the most common use case:
defining a synchronization step for a single model.

In particular we'll look at how to:

- Define models in XOS
- Load the models in the core
- Create an example TOSCA recipe to create those models
- Write a sync_step for those models
- Write unit tests for that sync step

# Preparation

## Setting up your development environment

Before getting started you'll need to have [Minikube](../../../prereqs/k8s-single-node.md#standard-minikube-installation-vm-support)
installed. From this point onward we assume you are able to run commands this
two commands on your laptop without errors:

```shell
helm list
kubectl get pods
```

For simplicity sake we also assume that you have the source code checked out
under `~/cord`. You can follow this [guide](../../getting_the_code.md) to get it.

## xos-core deployment

In order to execute our synchronizer, we need to have the xos-core chart deployed.
You can follow this guide to deploy it, and once done you should be able to see
this containers running:

```shell
$ kubectl get pods

NAME                             READY     STATUS    RESTARTS   AGE
xos-chameleon-6fb76d5689-s7vxb   1/1       Running   0          21h
xos-core-58bcf4f477-79hs7        1/1       Running   0          21h
xos-db-566dd8c6f9-l24h5          1/1       Running   0          21h
xos-gui-665c5f85bc-kdmbm         1/1       Running   0          21h
xos-redis-5cf77fd49f-fcw5h       1/1       Running   0          21h
xos-tosca-69588f677c-77lll       1/1       Running   0          20h
xos-ws-748c7f9f75-cnjnh          1/1       Running   0          21h
```

## Synchronizer location and folder structure

XOS Services are located under `~/cord/orchestration/xos_services`.

We need to create a folder to store our synchronizer code, and that is generally
called with the same name of the synchronizer.
We are going to create a new folder called `hello-world` in there.

```shell
cd ~/cord/orchestration/xos_services
mkdir hello-world && cd hello-world
```

A synchronizer repository has traditionally this structure:

```shell
hello-world
├── Dockerfile.synchronizer
├── VERSION
├── samples
│.  └── hello-world.yaml
└── xos
	├── synchronizer
	│   ├── config.yaml
	│   ├── hello-world-synchronizer.py
	│   ├── models
	│   │   └── hello-world.xproto
	│   ├── steps
	│   │   ├── sync_hello_world_service.py
	│   │   ├── sync_hello_world_service_instance.py
	│   │   ├── test_sync_hello_world_service.py
	│   │   └── test_sync_hello_world_service_instance.py
	│   └── test_config.yaml
	└── unittest.cfg
```

We'll get to the test configuration later on, so let's leave that on the side
for now. But let's go trough the other folders:

- the `Dockerfile.synchronizer` contains the definition of the docker image we'll build in order to run the synchronizer
- the `VERSION` file contains the version of our code, it is reported to the core
- the `xos/synchronizer` contains all of out code and will be bundled in the docker image

And the files:

- `samples/hello-world.yaml` is an example of a TOSCA recipe to operate those models
- `xos/synchronizer/hello-world-synchronizer.py` is main synchronizer process
- `xos/synchronizer/models/hello-world.xproto` contains the models definition
- `xos/synchronizer/steps/sync_hello_world_service.py` contains the operations that need to be performed to synchronize the backend

## Creating the synchronizer entry point

The synchronizer entry point is a pretty standard file that is responsible to:

- load the synchronizer configuration
- load and run the synchronizer framework

Add this content to the `hello-world-synchronizer.py` file:

```python
import importlib
import os
import sys
from xosconfig import Config

config_file = os.path.abspath(os.path.dirname(os.path.realpath(__file__)) + '/config.yaml')
Config.init(config_file, 'synchronizer-config-schema.yaml')

observer_path = os.path.join(os.path.dirname(os.path.realpath(__file__)),"../../synchronizers/new_base")
sys.path.append(observer_path)
mod = importlib.import_module("xos-synchronizer")
mod.main()
```

## Defining the synchronizer configuration

In `xos/synchronizer/config.yaml` add this content:

```yaml
name: hello-world
accessor:
  username: admin@opencord.org
  password: letmein
  endpoint: xos-core:50051
models_dir: "/opt/xos/synchronizers/hello-world/models"
steps_dir: "/opt/xos/synchronizers/hello-world/steps"
required_models:
  - HelloWorldService
  - HelloWorldServiceInstance
logging:
  version: 1
  handlers:
    console:
      class: logging.StreamHandler
  loggers:
    'multistructlog':
      handlers:
          - console
      level: DEBUG
```

# Defining models in CORD

If you are not familiar with the CORD modeling language, called `xProto`,
I suggest you to start from the [Modeling Guide](../../../xos/README.md)

We are going to define the two most common models for any synchronizer:
`HelloWorldService` and `HelloWorldServiceInstance`.
You can take a look [here](../../../xos/core_models.md#model-glossary)
if you want to refresh the difference between the two, but in short:

- `Service` models contains service specific details
- `ServiceInstance` models contains subscriber specific details for that service.

To define your models, open the `hello-world.xproto` file and add this content:

```text
option name = "hello-world";
option app_label = "hello-world";

message HelloWorldService (Service){
    required string hello_from = 1 [help_text = "The name of who is saying hello", null = False, db_index = False, blank = False];
}

message HelloWorldServiceInstance (ServiceInstance){
    option owner_class_name="HelloWorldService";
    required string hello_to = 1 [help_text = "The name of who is being greeted", null = False, db_index = False, blank = False];
}
```

This will create two models, `HelloWorldService` that extends the `Service` model,
and `HelloWorldServiceInstance` that extends `ServiceInstance` models.
Both of this model will inherit the attributes defined in the parent classes,
you can see what they are in the [core.xproto](https://github.com/opencord/xos/blob/master/xos/core/models/core.xproto) file.

# Load models in the core

Service models are pushed to the core trough a mecanism that is called `dynamic onboarding`
or `dynamic loading`. In practice when a synchronizer container runs, the first thing it does
after establishing a connection, is to push its models to the core container.

So the first step we need to take is to build and deploy our synchronizer container
in the test environment.

## Building the synchronizer container

We assume that you understand the Docker concepts of `container` and `image`,
if not we strongly suggest to take a look here: [Docker concepts](https://docs.docker.com/get-started/#docker-concepts)

The first thing we need to do is to define a `Dockerfile`,
to do that open `Dockerfile.synchronizer` and add this content:

```text
FROM xosproject/xos-synchronizer-base:candidate

COPY xos/synchronizer /opt/xos/synchronizers/hello-world
COPY VERSION /opt/xos/synchronizers/hello-world/

ENTRYPOINT []

WORKDIR "/opt/xos/synchronizers/hello-world"

CMD bash -c "python hello-world-synchronizer.py"
```

This file is used to build our synchronizer container image. As you noticed it
inheriths `FROM xosproject/xos-synchronizer-base:candidate` so we'll need to obtain that image.

We can use this commands:

```shell
eval $(minikube docker-env) # this will point our shell on the minikube docker daemon
docker pull xosproject/xos-synchronizer-base:master
docker tag xosproject/xos-synchronizer-base:master xosproject/xos-synchronizer-base:candidate
```

> To learn more about the usage of the `candidate` tag, please read on
[Imagebuilder](../../../developer/imagebuilder.md)) but keep in mind that
this is mostly a tool needed by platform developers when they need test API changes
across multiple nested containers.

Now we can build our synchronizer image by executing (from the `orchestration/xos_service/hello-world` directory):

```shell
eval $(minikube docker-env)
docker build -t xosproject/hello-world-synchronizer:candidate -f Dockerfile.synchronizer .
```

## Run you synchronizer container

You can create this simple Kubernetes resource in a file called `kb8s-hello-world.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-world-synchronizer
spec:
  containers:
    - name: hello-world-synchronizer
      image: xosproject/hello-world-synchronizer:candidate
      volumeMounts:
      - name: certchain-volume
        mountPath: /usr/local/share/ca-certificates/local_certs.crt
        subPath: config/ca_cert_chain.pem
  volumes:
    - name: certchain-volume
      configMap:
        name: ca-certificates
        items:
          - key: chain
            path: config/ca_cert_chain.pem
  restartPolicy: Never
```

and run it using `kubectl create -f kb8s-hello-world.yaml`

You can check the logs of your synchronizer using:

```shell
kubetcl logs -f hello-world-synchronizer
```

This is the output you should see:
```text
Service version is 1.0.0.dev
required_models, found:        models=HelloWorldService, HelloWorldServiceInstance
Loading sync steps             step_dir=/opt/xos/synchronizers/hello-world/steps synchronizer_name=hello-world
Loaded sync steps              steps=[] synchronizer_name=hello-world
Skipping event engine due to no event_steps dir. synchronizer_name=hello-world
Skipping model policies thread due to no model_policies dir. synchronizer_name=hello-world
No sync steps, no policies, and no event steps. Synchronizer exiting. synchronizer_name=hello-world
```

and you can check that your models are onboarded in the XOS GUI.

> To open the GUI you can execute `minikube service xos-gui` and the default
> credentials are `admin@opencord.org/letmein`



TODO: create a sample TOSCA

TODO: create sync step

TODO: unit test? (is this the right place? maybe not)










DO we need this here? it looks pretty long and slightly out of topic
## Creating and helm chart for our synchronizer

If you are not sure what helm is, you should look at our [Helm reference](../../../charts/helm.md)
chapter and at the official [Helm documentation](https://helm.sh)

To create a chart for your synchronizer start creating this folder structure,
the location of this folder doesn't really matter, but in CORD the helm charts
are defined under the `helm-charts` repo (`~/cord/helm-charts`):

```shell
hello-world
├── Chart.yaml
├── templates
│   ├── _helpers.tpl
│   ├── configmap.yaml
│   └── deployment.yaml
└── values.yaml
```

> To save some time you can copy an helm chart of an existing service,
> for instance `hippie-oss` and just replace the name in every file.
> Note that in some places
