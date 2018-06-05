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
> [Defining Models in CORD](xos/README.md) contains interesting informations
> about the Synchronizers concepts and modeling in general.

## What we'll cover in this tutorial?

This exercise does not pretend to be an extensive guide on the synchronizer,
it's only purpose is to guide you through the most common use case:
defining a synchronization step for a single model.

In particular we'll look at how to:

- Define a model in XOS
- Load the model in the core
- Write a sync_step for that model
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
└── xos
	├── synchronizer
	│   ├── hello-world-synchronizer.py
	│   ├── hello-world_config.yaml
	│   ├── models
	│   │   └── hello-world.xproto
	│   ├── steps
	│   │   ├── sync_hello_world_service.py
	│   │   └── test_sync_hello_world_service.py
	│   └── test_config.yaml
	└── unittest.cfg
```

We'll get to the test configuration later on, so let's leave that on the side
for now. But let's go trough the other folders:

- the `Dockerfile.synchronizer` contains the definition of the docker image we'll build in order to run the synchronizer
- the `VERSION` file contains the version of our code, it is reported to the core
- the `xos/synchronizer` contains all of out code and will be bundled in the docker image

And the files:

- `xos/synchronizer/hello-world-synchronizer.py` is main synchronizer process
- `xos/synchronizer/models/hello-world.xproto` contains the models definition
- `xos/synchronizer/steps/sync_hello_world_service.py` contains the operations that need to be performed to synchronize the backend