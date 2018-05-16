# Helm

For informations on how to install `helm` please refer to [Installing helm](../prereqs/helm.md)

## What is Helm?

{% include "/partials/helm/description.md" %}

## How to get CORD Helm charts

### Donwload the helm-charts repository

You can get the CORD helm-chars by cloning the `helm-charts` repository:

```shell
git clone https://gerrit.opencord.org/helm-charts
```

> If you have downloaded the CORD code following the
> [Getting the Source Code](../developer/getting_the_code.md) guide,
> you'll find it in `~/cord/helm-charts`.

### Add the CORD repository to helm (NOT YET AVAILABLE)

```shell
helm repo add ...
```

## CORD example values

As you may have noticed, there is an `example` folder
in the `helm-chart` repository.
The files contained in that repository are examples of possible overrides
to obtain a custom deployment.

For example, it is possible to deploy a single instance of `kafka`,
for development purposes, by using this value file:

```shell
helm install --name cord-kafka incubator/kafka -f examples/kafka-single.yaml
```
