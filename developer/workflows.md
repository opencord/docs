# Developer Workflows

This document is intended to describe the workflow to
develop the control plane of CORD.

## Setting up a local development environment

The first thing you’ll need to work on the control plane of CORD, known as XOS,
is to setup a local Kubernetes environment.
The suggested way to achieve that is to use Minikube on your laptop,
and this guide assume that it will be the environment going forward.

You can follow this guide to get started with Minikube:
<https://kubernetes.io/docs/getting-started-guides/minikube/#installation>

> Note: If you are going to do development on Minikube you may want to
>increase it’s memory from the default 512MB,
>you can do that using this command to start Minikube:
>`minikube start --cpus 2 --memory 4096`

Once Minikube is up and running on your laptop you can proceed with
the following steps to bring XOS up.

Once Minikube is installed you’ll need to install Helm:
<https://docs.helm.sh/using_helm/#installing-helm>

At this point you should be able to deploy the core components of XOS
and the services required by R-CORD from images published on dockerhub.

> NOTE: You can replace the `xos-profile` with the one you need to work on.

```shell
cd ~/cord/build/helm-charts
helm install xos-core -n xos-core
helm dep update xos-profiles/rcord-lite
helm install xos-profiles/rcord-lite -n rcord-lite
```

## Making changes and deploy them

You can follow this guide to [get the CORD source code](getting_the_code.md).

We assume that now you have the entire CORD tree under `~/cord`

> Note: to develop a single synchronizer you may not need the full CORD source,
but this assume  that you have a good knowledge of the system and
you know what you’re doing.

As first you’ll need to point Docker to the one provided by Minikube
(_note that you don’t need to have docker installed,
as it comes with the Minikube installation_).

```shell
eval $(minikube docker-env)
```

Then you’ll need to build the XOS containers from source:

```shell
cd ~/cord/build
python scripts/imagebuilder.py -f helm-charts/examples/filter-images.yaml
```

At this point the images containing your changes will be available
in the Docker environment used by Minikube.

> Note: in some cases you can rebuild a single docker image to make
the process faster, but this assume that you have a good knowledge of the system
and you know what you’re doing.

All that is left is to teardown and redeploy the containers.

```shell
helm del --purge xos-core
helm del --purge rcord-lite
helm install xos-core -n xos-core -f examples/candidate-tag-values.yaml -f examples/if-not-present-values.yaml
helm dep update xos-profiles/rcord-lite
helm install xos-profiles/rcord-lite -n rcord-lite -f examples/candidate-tag-values.yaml -f examples/if-not-present-values.yaml
```

In some cases is possible to use the helm upgrade command,
but if you made changes to the models we suggest to redeploy everything

> Note: if your changes are only in the synchronizer steps,
after rebuilding the containers, you can just delete the corresponding POD
and kubernetes will restart it with the new image

## Pushing changes to a remote registry

If you have a remote POD you want to test your changes on, you need to push your
docker images on a registry that can be accessed from the POD itself.

The way we suggest to do this is via a private docker-registry,
you can find more informations about what a 
docker-registry is [here](../prereqs/docker-registry.md).

{% include "/partials/push-images-to-registry.md" %}