# Local Development

This section describes a typical workflow for developing the CORD
control plane. This workflow does not include any data plane
elements (e.g., the underlying switching fabric or access devices).

## Setting Up a Local Development Environment

It is straightforward to set up a local Kubernetes environment on your laptop.
The recommended way to do this is to use Minikube. This guide assumes
you have done that. See the
[Single-Node](../../prereqs/k8s-single-node.md) case in the
Installation Guide for more information, or you can go directly
to the documentation for Minikube:
<https://kubernetes.io/docs/getting-started-guides/minikube/#installation>

> **Note:** If you are going to do development on Minikube you may want to increase
> its memory from the default 512MB. You can do this using this command to
> start Minikube: `minikube start --cpus 2 --memory 4096`

In addition to Minikube running on your laptop, you will also need to
install Helm: <https://docs.helm.sh/using_helm/#installing-helm>.

Once both Helm and Minikube are installed, you can deploy the
core components of XOS, along with the services that make
up, for example, the SEBA profile. This uses images published
on DockerHub:

```shell
cd ~/cord/helm-charts
```

In this folder you can choose from the different charts which one to
deploy. For example to deploy SEBA you can follow
[these instructions](../../profiles/seba/install.md). Alternatively, if
you are working on a new profile or a new service that is not part of
any existing profile, you can install just the
[CORD Platform](../../installation/platform.md).

## Making and Deploying Changes

Assuming you have
[downloaded the CORD source code](../getting_the_code.md) and the entire
source tree for CORD is under `~/cord`, you can edit and re-deploy the
code as follows.

> **Note:** To develop a single synchronizer you may not need the full CORD source,
> but this assume  that you have a good knowledge of the system and you know
> what you’re doing.

First you will need to point Docker to the one provided by Minikube
(_note that you don’t need to have docker installed,
as it comes with the Minikube installation_).

```shell
eval $(minikube docker-env)
```

You will then need to build the containers from source, so enter the repo you modified:

```shell
cd ~/cord/orchestration/xos-services/rcord
DOCKER_REPOSITORY=xosproject/ DOCKER_TAG=candidate make docker-build
```

At this point, the images containing your changes will be available
in the Docker environment used by Minikube.

> **Note:** In some cases the command to build the docker image may vary. 
> Please check the Makefile within the repo for more informations. 

All that is left is to teardown and re-deploy the containers.

```shell
helm del --purge <chart-name>
helm dep update <cart-name>
helm install <chart-name> -n <chart-name> -f examples/image-tag-candidate.yaml -f examples/imagePullPolicy-IfNotPresent.yaml
```

In some cases it is possible to use the `helm` upgrade command,
but if you made changes to the XOS models we suggest you redeploy
everything.

> **Note:** if your changes are only in the synchronizer steps, after rebuilding
> the containers, you can just delete the corresponding POD and kubernetes will
> restart it with the new image.

## Pushing Changes to a Docker Registry

If you have a remote POD that you want to test your changes on, you
need to push your docker images to a docker registry that can be accessed
from the POD.

The way we recommend doing this is via a private docker registry.
You can find more information about what a docker registry is in the
[offline installation section](../../installation/offline-install.md).

{% include "/partials/push-images-to-registry.md" %}
