# Helm Installation guide

## What is helm?

{% include "/partials/helm/description.md" %}

## How to install helm

The full instructions and basic commands to get started with helm can be found
here: <https://docs.helm.sh/using_helm/#quickstart>

For simplicity here are are few commands that you can use to install `helm` on
your system:

### macOS

```shell
brew install kubernetes-helm
```

### Linux

```shell
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
tar -zxvf helm-v2.9.1-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
```

### Initialize helm and setup Tiller

```shell
helm init
```

Once `helm` is installed you should be able to run the command `helm list`
without errors

## What is an helm chart?

Charts are the packaging format used by helm.
A chart is a collection of files that describe
a related set of Kubernetes resources.

For example in CORD we are using charts to define every single components,
such as:

- [xos-core](../charts/xos-core.md)
- [onos](../charts/onos.md)
- [voltha](../charts/voltha.md)

You can find the full chart documentation here:
<https://docs.helm.sh/developing_charts/#charts>
