# Deploy VOLTHA

## First Time Installation

Add the kubernetes helm charts incubator repository
```shell
cd voltha
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```

Build dependencies
```shell
helm dep build
```

There's an etcd-operator **known bug** we're trying to solve that
prevents users to deploy Voltha straight since the first time. We
found a workaround.

Few steps:

Install minimal etcd operator and kafka necessary for
 Voltha (*Run the following commands only once*)
```shell
#Install etcd operator without the ETCD cluster CRD
helm install --name voltha-etcd --set etcdCluster.size=1 stable/etcd-operator

#Install kafka and zookeeper with one replica each
helm install --name voltha-kafka --set replicas=1 \
--set zookeeper.servers=1 \
--set persistence.enabled=false \
--set zookeeper.persistence.enabled=false incubator/kafka

#Upgrade the etcd operator to install the Cluster CRD with one replica
helm upgrade --set etcdCluster.size=1 \
--set customResources.createEtcdClusterCRD=true \
voltha-etcd stable/etcd-operator
```

## Standard Installation Process

Run the following command from the `helm-charts` directory
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

## Standard Uninstallation Process

```shell
helm delete --purge voltha
```

You can uninstall and deploy voltha any number of times you want. 
The devices state will be maintained in etcd even if you uninstall 
and deploy voltha again.