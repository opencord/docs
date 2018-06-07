# Deploy VOLTHA

## First Time Installation

Add the kubernetes helm charts incubator repository

```shell
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```

Build dependencies and step out of the voltha directory
```shell
helm dep build
cd ..
```

Prerequisite:

We need Kafka/Zookeeper for the Voltha components to work so if you have not installed it already, install it with the following command.

```shell
#Install kafka and zookeeper with one replica each
helm install --name voltha-kafka --set replicas=1 \
--set zookeeper.servers=1 \
--set persistence.enabled=false \
--set zookeeper.persistence.enabled=false incubator/kafka
```
Note: We are assigning the name **voltha-kafka** to the helm kafka helm release. The Voltha helm chart assumes that this is the name of the kafka service. If you installed kafka independently with another name, you need to modify the **kafkaReleaseName** variable in the voltha helm chart for Voltha to work with your installation of kafka.

## Standard Installation Process

Run the following command from the `helm-charts` directory
```shell
helm install -n voltha voltha
```

Note: This will install voltha components as well as etcd.

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

Note: This will uninstall the etcd store as well so your device state is lost.
