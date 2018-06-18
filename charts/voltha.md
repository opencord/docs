# Deploy VOLTHA

## First Time Installation

Add the kubernetes helm charts incubator repository
```shell
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```

Build dependencies
```shell
helm dep build voltha
```

There's an etcd-operator **known bug** we're trying to solve that
prevents users to deploy Voltha straight since the first time. We
found a workaround. 

Few steps:

Install Voltha (without etcd operator)
```shell
helm install -n voltha --set etcd-operator.customResources.createEtcdClusterCRD=false voltha
```

Uninstall Voltha
```shell
helm delete --purge voltha
```

Deploy Voltha
```shell
helm install -n voltha voltha
```

## Standard Installation Process

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

## How to access the VOLTHA CLI

Assuming you have not changed the default ports in the chart,
you can use this command to access the VOLTHA CLI:

```shell
ssh voltha@<pod-ip> -p 30110
```
