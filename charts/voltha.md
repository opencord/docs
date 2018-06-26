# Deploy VOLTHA

## First Time Installation

Download the helm charts `incubator` repository

```shell
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```

Build dependencies

```shell
helm dep build voltha
```

Install the kafka dependency

```shell
helm install --name voltha-kafka \
--set replicas=1 \
--set persistence.enabled=false \
--set zookeeper.servers=1 \
--set zookeeper.persistence.enabled=false \
incubator/kafka
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
helm upgrade voltha ./voltha
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
