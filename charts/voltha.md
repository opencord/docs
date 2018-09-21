# Deploy VOLTHA

VOLTHA depends on having a [kafka message bus](kafka.md) deployed with a name
of `cord-kafka`, so deploy that with helm before deploying the voltha chart.


## First Time Installation

Download the helm charts `incubator` repository:

```shell
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```

Update dependencies within the voltha chart:

```shell
helm dep up voltha
```

There is an `etcd-operator` **known bug** that prevents deploying
Voltha correctly the first time. We suggest the following workaround:

First, install Voltha without an `etcd` custom resource definition:

```shell
helm install -n voltha --set etcd-operator.customResources.createEtcdClusterCRD=false voltha
```

Then upgrade Voltha, which defaults to using the `etcd` custom
resource definition:

```shell
helm upgrade --set etcd-operator.customResources.createEtcdClusterCRD=true voltha ./voltha
```

After this first installation, you can use the standard
install/uninstall procedure described below.

## Standard Uninstall

```shell
helm delete --purge voltha
```

## Standard Install

```shell
helm install -n voltha voltha
```

## Nodeports Exposed

* Voltha CLI
    * Inner port: 5022
    * Nodeport: 30110
* Voltha REST APIs
    * Inner port: 8882
    * Nodeport: 30125

## Accessing the VOLTHA CLI

Assuming you have not changed the default ports in the chart,
you can use this command to access the VOLTHA CLI:

```shell
ssh voltha@<pod-ip> -p 30110
```

The default VOLTHA password is `admin`.
