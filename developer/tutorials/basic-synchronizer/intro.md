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

## Preparation

### Setting up your development environment

Before getting started you'll need to have [Minikube](../../../prereqs/k8s-single-node.md#standard-minikube-installation-vm-support)
installed. From this point onward we assume you are able to run commands this
two commands on your laptop without errors:

```shell
helm list
kubectl get pods
```

For simplicity sake we also assume that you have the source code checked out
under `~/cord`. You can follow this [guide](../../getting_the_code.md) to get it.

### xos-core deployment

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

### Synchronizer location and folder structure

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

### Creating the synchronizer entry point

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

### Defining the synchronizer configuration

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

## Defining models in CORD

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

## Load models in the core

Service models are pushed to the core trough a mecanism that is called `dynamic onboarding`
or `dynamic loading`. In practice when a synchronizer container runs, the first thing it does
after establishing a connection, is to push its models to the core container.

So the first step we need to take is to build and deploy our synchronizer container
in the test environment.

### Building the synchronizer container

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

### Run you synchronizer container

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

### Create TOSCA recipes to create you models

The TOSCA engine expose the definition for the onboard model as they are generated
from `xProto`. You can consult them at any time connecting to the TOSCA endpoint from
a browser:

```text
http://<minikube-ip>:30007
```

> You can find the minikube ip by executing this command on your system:
> `minikube ip`

In this page you'll find a list of all the avilable resource, just search for
`helloworldservice` and visit the corresponding page at:

```text
http://<minikube-ip>:30007/custom_type/helloworldservice
```

You'll see the TOSCA definition for the `HelloWorldService` model.

You can use that (and the `HelloWorldServiceInstance` model definition too) to
create an instance of both models. For your convenience it will look like this:

Save this content to a file called `hello-world-tosca.yaml`
```yaml
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/helloworldservice.yaml
  - custom_types/helloworldserviceinstance.yaml
  - custom_types/servicegraphconstraint.yaml

description: Create an instance of HelloWorldService and one of HelloWorldServiceInstance

topology_template:
  node_templates:

    service:
      type: tosca.nodes.HelloWorldService
      properties:
        name: HelloWorld
        hello_from: Jhon Snow

    serviceinstance:
      type: tosca.nodes.HelloWorldServiceInstance
      properties:
        name: HelloWorld Service Instance
        hello_to: Daenerys Targaryen

    constraints:
      type: tosca.nodes.ServiceGraphConstraint
      properties:
        constraints: '["HelloWorld"]'
```

This TOSCA will create an instance of your service and
an instance of your service instance.

> The `contraint` section is used only to define the position of the nodes
> in the service graph. For more informations on that look [here](../../../xos-gui/developer/service_graph.md)
> but it's really not important for the scope of this tutorial.

You can submit this TOSCA using this command:

```shell
curl -H "xos-username: admin@opencord.org" -H "xos-password: letmein" -X POST --data-binary @hello-world-tosca.yaml http://<minikube-ip>:30007/run
Created models: ['service', 'serviceinstance', 'serviceinstance']
```

Once this command has been executed you connect to the GUI at:

```shell
http://<minikube-ip>:30001
```

And see your models.

> HINT: In the home page press the `Service Instances` button to display
> `ServiceInstance` models, and the navigate to the `Hello World` sub menu to the left.

## Create your first synchronizer steps

At this point in the tutorial we assume we have an idea of what a synchronizer
is, and what `sync_step`s are used for, but to refresh your mind,
`sync_step` are the actual responsible to map changes in the XOS data model,
to API calls in the component you want to manage.

We are not going to write code that actually do something, as that is
depending on the APIs that the target component expose, but we are going to
demonstrate some basic concepts of the synchronizer framework.

### A successful sync step

Before moving forward, we can remove the container we just deployed using:

```shell
kubectl delete pod hello-world-synchronizer
```

To create the `sync_step` we'll have to create two files in `xos/synchronizer/sync_step`.

The first one is to synchronize the `HelloWorldService` and it's called `sync_hello_world_service.py`.

Every `sync_step` extends the `SyncStep` base class, and overrides two methods:

- `sync_record`
- `delete_record`

Take a look here for a more complete [synchronizer reference](../../../xos/dev/sync_reference.md#sync-steps)

Here is an example of `sync_step` that will only log changes on the `HelloWorldService` model:

```python
from synchronizers.new_base.SyncInstanceUsingAnsible import SyncStep 
from synchronizers.new_base.modelaccessor import HelloWorldService 

from xosconfig import Config 
from multistructlog import create_logger 

log = create_logger(Config().get('logging')) 

class SyncHelloWorldService(SyncStep):
    provides = [HelloWorldService]

    observes = HelloWorldService

    def sync_record(self, o):
        log.info("HelloWorldService has been updated!", object=str(o), hello_from=o.hello_from)

    def delete_record(self, o):
        log.info("HelloWorldService has been deleted!", object=str(o), hello_from=o.hello_from)
```

Let's start deploying this first step and see what is happening.
The first thing we'll need to do, is to rebuild out synchronizer container:

```shell
eval $(minikube docker-env)
docker build -t xosproject/hello-world-synchronizer:candidate -f Dockerfile.synchronizer .
```

and then we need to start it again:

```shell
kubectl create -f kb8s-hello-world.yaml
```

At his point, running `kubectl logs -f hello-world-synchronizer` you should see
that your synchronizer is not exiting anymore, but is looping waiting for changes
in the models.

Everytime you make a change to the model, you'll see that:

- The event is logged in the synchronizer log (`kubectl logs -f hello-world-synchronizer`)
- The `backend_code` and backend status of the model are updated
- The model is not picked up by the synchronizer untill you make some chages to it

When you make changes to the models (you can do this via the GUI or updating the TOSCA you created before)
you will see a meeage similar to this one in the logs:

```shell
Syncing object                            model_name=HelloWorldService pk=1 synchronizer_name=hello-world thread_id=140152420452096
HelloWorldService has been updated!       hello_from=u'Jhon Snow' object=HelloWorld
Synced object                             model_name=HelloWorldService pk=1 synchronizer_name=hello-world thread_id=140152420452096
```

> Note that the `sync_record` method is triggered also when a model is created,
> so as soon as you start the synchronizer you'll see the above message.

If you delete the model, you'll see the `delete_record` method being invoked.

### Handling errors in the sync steps

In this case we are going to trigger an error, to demonstrare how the synchronizer
framework is going to helo us in dealing with them.

Let's start creating the `sync_step` for `HelloWorldServiceInstance` 
in a file named `sync_hello_world_service.py`.

```python
from synchronizers.new_base.SyncInstanceUsingAnsible import SyncStep, DeferredException 
from synchronizers.new_base.modelaccessor import HelloWorldServiceInstance 

from xosconfig import Config 
from multistructlog import create_logger 

log = create_logger(Config().get('logging')) 

class SyncHelloWorldServiceInstance(SyncStep):
    provides = [HelloWorldServiceInstance]

    observes = HelloWorldServiceInstance

    def sync_record(self, o):
        log.debug("HelloWorldServiceInstance has been updated!", object=str(o), hello_to=o.hello_to)

        if o.hello_to == "Tyrion Lannister":
          raise DeferredException("Maybe later")

        if o.hello_to == "Joffrey Baratheon":
          raise Exception("Maybe not")

        log.info("%s is saying hello to %s" % (o.owner.leaf_model.hello_from, o.hello_to))

    def delete_record(self, o):
        log.debug("HelloWorldServiceInstance has been deleted!", object=str(o), hello_to=o.hello_to)
```
To run this code you'll need to:

- delete the running container
- rebuild the image
- run the container again

In this case we are emulating an error in our `sync_step`, in real life
this can be caused by a connection error or malformed data or ... many reasons.

Head to the GUI and start playing a little bit with the models!

If you set the `HelloWorldServiceInstance.hello_to` property to `Tyrion Lannister`
you'll see this keep popping up:

```shell
HelloWorldServiceInstance has been updated! hello_to=u'Tyrion Lannister' object=HelloWorld Service Instance
sync step failed!              e=DeferredException('Maybe later',) model_name=HelloWorldServiceInstance pk=1 synchronizer_name=hello-world
Traceback (most recent call last):
  File "/opt/xos/synchronizers/new_base/event_loop.py", line 357, in sync_cohort
    self.sync_record(o, log)
  File "/opt/xos/synchronizers/new_base/event_loop.py", line 227, in sync_record
    step.sync_record(o)
  File "/opt/xos/synchronizers/hello-world/steps/sync_hello_world_service_instance.py", line 18, in sync_record
    raise DeferredException("Maybe later")
DeferredException: Maybe later
```

Here is what happens when an error succeds happens. The synchronizer framework will:

- Log the exception
- Set the `backend_code` of that instance to `2`
- Set the `Exception` error in the `backend_status`
- Keep retring

> HINT: to see `backend_code` and `backend_status` in the GUI you can press `d`
> to open the debug tab while looking at a model detail view.












