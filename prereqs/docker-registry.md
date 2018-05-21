# Docker Registry

The guide describes how to install an insecure *docker-registry* in Kubernetes.
The tipical usecases for such registry are development, POCs or lab trials.

> **This is not meant for production use**

## What is a docker registry?

If you have ever used docker, for sure you have used a docker registry.
The most used *docker-registry* is the default, public one: <https://hub.docker.com>.

In some cases, such as development or when the public registry is not
reachable, you may want to setup a private registry, to push and pull images in a more controlled way.

More information about docker registries at <https://docs.docker.com/registry/>.

## Deploy an insecure docker registry on top of Kubernetes

Helm provides a default helm-chart to deploy the registry,
The follogin command deploys it and exposes it on node port *30500*:

```shell
helm install stable/docker-registry --set service.nodePort=30500,service.type=NodePort -n docker-registry
```

The registry can be queried at any time:

> ```shell
> curl -X GET https://KUBERNETES_IP:30500/v2/_catalog
> ```

## Push images to the docker registry

{% include "/partials/push-images-to-registry.md" %}
