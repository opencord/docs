# Helm Reference Guide

For information on how to install `helm` please refer to [Installing helm](../prereqs/helm.md)

## What is Helm?

{% include "/partials/helm/description.md" %}

## CORD Helm Charts

### Download the helm-charts Repository

You can get the CORD helm-chars by cloning the `helm-charts` repository:

```shell
git clone https://gerrit.opencord.org/helm-charts
```

> **Note:** If you have downloaded the CORD code following the [Getting the Source
> Code](../developer/getting_the_code.md) guide, you'll find it in
> `~/cord/helm-charts`.

**IMPORTANT: All the helm commands needs to be executed from within this directory**

### Add the CORD Repository to Helm

If you don't want to download the repository, you can just add the OPENCord charts to your helm repo:

```shell
helm repo add cord https://charts.opencord.org/master
helm repo update
```

If you decide to follow this route, the `cord/` prefix needs to be
added to specify the repo to use. For example:

```shell
helm install -n xos-core xos-core
```

will become

```shell
helm install -n xos-core cord/xos-core
```

## CORD Example Values

As you may have noticed, there is an `example` folder
in the `helm-chart` repository.
The files contained in that repository are examples of possible overrides
to obtain a custom deployment.

For example, it is possible to deploy a single instance of `kafka`,
for development purposes, by using this value file:

```shell
helm install --name cord-kafka incubator/kafka -f examples/kafka-single.yaml
```
