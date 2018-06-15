# Docker Registry (Optional)

The section describes how to install an **insecure** *docker registry* in Kubernetes, using the standard Kubernetes helm charts.

A local docker registry can be used to push container images directly to the cluster,
which could be useful for example in the following cases:

* The CORD POD has no Internet access, so container images cannot be downloaded directly from DockerHub to the POD.

* You are developing new CORD components, or modifying existing ones. You may want to test your changes before uploading the image to the official docker repository. In this case, your workflow might be to build your new container and push it to the local registry.

More informations about docker registries can be found at <https://docs.docker.com/registry/>.

> **Note:** *Insecure* registries can be used for development, POCs or lab trials. **You should not use this in production.** There are planty of documents online that guide you through secure registry setup.

## Deploy a Registry Using Helm

Helm provides a default helm chart to deploy an insecure registry on your
Kubernetes cluster. The following command deploys the registry and exposes
the port *30500*. (You may want to change it with any value that fit your
deployment needs.)

```shell
helm install stable/docker-registry --set service.nodePort=30500,service.type=NodePort -n docker-registry
```

The registry can be queried at any time, for example:

```shell
curl -X GET https://KUBERNETES_IP:30500/v2/_catalog
```

{% include "/partials/push-images-to-registry.md" %}

## Modify the Helm Charts to Use Your Images

Now that your custom images are in the local docker registry on the Kubernetes
cluster, you can modify the CORD helm charts to instruct the system to consume
them instead of using the default images from DockerHub.

Image names and tags are specified in the *values.yaml* file of each chart
(look in the main chart directory), or alternatively, in the configuration
files in the config directory.

Simply modify the values as needed, uninstall the containers previously deployed,
and deploy them again.

> **Note**: It is better to extend the existing helm charts, rather than directly modifying them. This way you can keep the original configuration as it is, and just override some values when needed. You can do this by writing your additional configuration yaml file, and parsing it as needed, adding `-f my-additional-config.yml` to your helm commands.

The full CORD helm charts reference documentation is available [here](../charts/helm.md).
