# Docker Registry

This guide will help you in deploying an insecure `docker-registry`. 
The tipical usecases for such registry are development, POCs or lab trials.

**Please be aware that this is NOT intended for production use**

## What is a docker registry?

If you have ever used docker, for sure you have used a docker registry.
The most used `docker-registry` is the default public one: `hub.docker.com`

In certain cases, such as development or when the public registry is not
reachable, you may want to setup a private version on it, to push and pull
your images in a more controlled way.

For more information about docker registries, please take a look
at the [official documentation](https://docs.docker.com/registry/).

## Deploy an insecure docker registry on top of Kubernets

We suggest to use the official helm-chart to deploy a docker-registry,
and this command will deploy it and expose it on port `30500`:

```shell
helm install stable/docker-registry --set service.nodePort=30500,service.type=NodePort -n docker-registry
```

> In any moment you can check the images available on your registry with this
> command:
> ```shell
> curl -X GET https://KUBERNETES_IP:30500/v2/_catalog
> ```

## Push the images to the docker registry

{% include "/partials/push-images-to-registry.md" %}