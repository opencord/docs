# SEBA Quick Start

This section provides instructions to quickly bring up SEBA.

>**Note:** This Quick start assumes that [prerequisite](prereqs/README.md) hardware and software (up to Kubernetes and Helm) have already been installed.

## Install components as a whole

```shell
# Add the CORD repository and update indexes
helm repo add cord https://charts.opencord.org
helm repo update

# Install the CORD platform
helm install -n cord-platform --version 6.1.0 cord/cord-platform

# Wait until 3 etcd CRDs are present in Kubernetes
kubectl get crd | grep -i etcd | wc -l

# Install the SEBA profile
helm install -n seba --version 1.0.0 cord/seba

# Install the AT&T workflow
helm install -n att-workflow --version 1.0.0 cord/att-workflow
```

## Alternatively, install as separate components

```shell
# Add the official Kubernetes incubator repostiory (for Kafka) and update the indexes
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm repo update

# Add the CORD repository and update the indexes
helm repo add cord https://charts.opencord.org
helm repo update

# Install the CORD platform components
helm install -n onos cord/onos
helm install -n xos-core cord/xos-core
helm install --version 0.8.8 \
             --set configurationOverrides."offsets.topic.replication.factor"=1 \
             --set configurationOverrides."log.retention.hours"=4 \
             --set configurationOverrides."log.message.timestamp.type"="LogAppendTime" \
             --set replicas=1 \
             --set persistence.enabled=false \
             --set zookeeper.replicaCount=1 \
             --set zookeeper.persistence.enabled=false \
             -n cord-kafka incubator/kafka

# Optionally, install the logging and monitoring infrastructure components
helm install -n nem-monitoring cord/nem-monitoring
helm install --set elasticsearch.cluster.env.MINIMUM_MASTER_NODES="1" \
             --set elasticsearch.client.replicas=1 \
             --set elasticsearch.master.replicas=2 \
             --set elasticsearch.master.persistence.enabled=false \
             --set elasticsearch.data.replicas=1 \
             --set elasticsearch.data.persistence.enabled=false \
             -n logging cord/logging

# Install etcd-operator and wait until 3 etcd CRDs are present in Kubernetes
helm install -n etcd-operator stable/etcd-operator --version 0.8.0
kubectl get crd | grep -i etcd | wc -l

# Install the rest of the SEBA profile components
helm install -n voltha cord/voltha
helm install -n seba-service cord/seba-services
helm install -n base-kubernetes cord/base-kubernetes

# Install the AT&T workflow
helm install -n att-workflow --version 1.0.0 cord/att-workflow
```

## Verify your installation and next steps

Once the installation completes, monitor your setup using `kubectl get pods`.
Wait until all pods are in *Running* state and “tosca-loader” pods are in *Completed* state.

>**Note:** The tosca-loader pods may periodically transition into *error* state. This is expected. They will retry and eventually get to the desired state.
>**Note:** Depending on the profile you're installing, you may need to check also different namespaces (for example, check the voltha namespace if you're installing SEBA with `kubectl get pods -n voltha`)

Your POD is now installed and ready for use. To learn how to operate your POD continue to the [SEBA configuration section](./profiles/seba/configuration.md).
