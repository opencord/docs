# Developer Workflows

This section describes a typical workflow for developing the CORD
control plane. This workflow does not include any data plane
elements (e.g., the underlying switching fabric or access devices).

## Setting Up a Local Development Environment

It is straightforward to set up a local Kubernetes environment on your laptop.
The recommended way to do this is to use Minikube. This guide assumes
you have done that. See the
[Single-Node](../prereqs/k8s-single-node.md) case in the
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
up, for example, the R-CORD profile. This uses images published
on DockerHub:

```shell
cd ~/cord/build/helm-charts
helm install xos-core -n xos-core
helm dep update xos-profiles/rcord-lite
helm install xos-profiles/rcord-lite -n rcord-lite
```

> **Note:** You can replace the `rcord-lite` profile with the one you want to work on. 

### Deploy a Single Instance of Kafka

Some profiles require a `kafka` message bus to work properly.
If you need to deploy it for development purposes, a single instance
deployment will be enough. You can do so as follows:

```shell
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
install --name cord-kafka incubator/kafka -f examples/kafka-single.yaml
```

## Making and Deploying Changes

Assuming you have
[downloaded the CORD source code](getting_the_code.md) and the entire
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

You will then need to build the containers from source:

```shell
cd ~/cord/automation-tools/developer
python imagebuilder.py -f ../../helm-charts/examples/filter-images.yaml -x
```

At this point, the images containing your changes will be available
in the Docker environment used by Minikube.

> **Note:** In some cases you can rebuild a single docker image to make the process
> faster, but this assume that you have a good knowledge of the system and you
> know what you’re doing.

All that is left is to teardown and re-deploy the containers.

```shell
helm del --purge xos-core
helm del --purge rcord-lite
helm install xos-core -n xos-core -f examples/image-tag-candidate.yaml -f examples/imagePullPolicy-IfNotPresent.yaml
helm dep update xos-profiles/rcord-lite
helm install xos-profiles/rcord-lite -n rcord-lite -f examples/image-tag-candidate.yaml -f examples/imagePullPolicy-IfNotPresent.yaml
```

In some cases it is possible to use the `helm` upgrade command,
but if you made changes to the XOS models we suggest you redeploy
everything.

> **Note:** if your changes are only in the synchronizer steps, after rebuilding
> the containers, you can just delete the corresponding POD and kubernetes will
> restart it with the new image.

## Pushing Changes to a Remote Registry

If you have a remote POD that you want to test your changes on, you
need to push your docker images to a registry that can be accessed
from the POD.

The way we recommend doing this is via a private docker-registry.
You can find more informations about what a
docker-registry is [here](../prereqs/docker-registry.md).

{% include "/partials/push-images-to-registry.md" %}
