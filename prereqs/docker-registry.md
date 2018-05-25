# Docker Registry (optional)

The guide describes how to install an **insecure** *docker registry* in Kubernetes, using the standard Kubernetes helm charts.

Local docker registries can be used to push container images directly to the pod, which could be useful for example in the following cases:

* The CORD POD has no Internet access, so container images cannot be downloaded directly from DockerHub to the POD
* You're developing new CORD components, or modifying existing ones. You may want to test your changes before uploading the image to the official docker repository. So, you build your new container and you push it to the local registry.

More informations about docker registries at <https://docs.docker.com/registry/>

> NOTE: *Insecure* registries can be used for development, POCs or lab trials. **You should not use this in production.** There are planty of documents online that guide you through secure registries setup.

## Deploy an insecure docker registry on Kubernetes using helm

Helm provides a default helm chart to deploy an insecure registry on your Kubernetes pod.

The following command deploys the registry and exposes the nodeport *30500* (you may want to change it with any value that fit your deployment needs) to access it:

```shell
helm install stable/docker-registry --set service.nodePort=30500,service.type=NodePort -n docker-registry
```

The registry can be queried at any time, for example:

```shell
curl -X GET https://KUBERNETES_IP:30500/v2/_catalog
```

{% include "/partials/push-images-to-registry.md" %}

## Modify the default helm charts to use your images, instead of the default ones

Now that your custom images are in the local docker registry on the Kubernetes pod, you can modify the CORD helm charts to instruct the system to consume them, instead of using the default ones (from DockerHub).

Image names and tags are specified in the *values.yaml* file of each chart (just look in the main chart folder), or -alternatively- in the configuration files, in the config folder.

Simply modify the values as needed, uninstall the containers previously deployed, and deploy them again.

> **NOTE**: it's better to extend the existing helm charts, rather than directly modifying them. This way you can keep the original configuration as it is, and just override some values when needed. You can do this writing your additional configuration yaml file, and parsing it as needed, adding -f my-additional-config.yml to your helm commands.

The full CORD helm charts reference documentation is available [here](../charts/helm.md).
