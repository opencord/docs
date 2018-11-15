# Deploy VOLTHA

VOLTHA depends on having a [kafka message bus](kafka.md) deployed with a name
of `cord-kafka`, so deploy that with helm before deploying the voltha chart.


## First Time Installation

Download the helm charts `incubator` repository:

```shell
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```

Install the etcd-operator helm chart.   This chart provides a convenient way of creating and managing etcd clusters.   When voltha installs it will attempt to use etcd-operator to create its etcd cluster.  Once installed etcd-operator can be left running.

```shell
helm install -n etcd-operator stable/etcd-operator --version 0.8.0
```

Allow etcd-operator enough time to create the EtdCluster CustomResourceDefinitions.  This should only be a couple of seconds after the etcd-operator pods are running.  Check the CRD are ready by running the following:

```shell
kubectl get crd | grep etcd
```



Update dependencies within the voltha chart:

```shell
helm dep up voltha
```

Install the voltha helm chart.   This will create the voltha pods and additionally create the etcd-cluster pods

```shell
helm install -n voltha voltha
```

Allow enough time for the 3 etcd-cluster pods to start before using the voltha pods.

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

## Building and using development images

In some cases you want to build custom images to try out development code.
The suggested way to do that is:

```shell
cd ~/cord/incubator/voltha
REPOSITORY=voltha/ TAG=dev VOLTHA_BUILD=docker make build
cd ~/cord/automation-tools/developer
bash tag_and_push.sh dev 192.168.99.100:30500
```

_This set of commands will build the VOLTHA containers and push them to a local
[docker registry](../prereqs/docker-registry.md) using a TAG called `dev`_

> NOTE: Read more about the `tag_and_push` script [here](../prereqs/docker-registry.md)

Once the images are pushed to a docker registry on the POD,
you can use a values file like the following one:

```yaml
# voltha-values.yaml
images:
  vcore:
    repository: '192.168.99.100:30500/voltha-voltha'
    tag: 'dev'
    pullPolicy: 'Always'

  vcli:
    repository: '192.168.99.100:30500/voltha-cli'
    tag: 'dev'
    pullPolicy: 'Always'

  ofagent:
    repository: '192.168.99.100:30500/voltha-ofagent'
    tag: 'dev'
    pullPolicy: 'Always'

  netconf:
    repository: '192.168.99.100:30500/voltha-netconf'
    tag: 'dev'
    pullPolicy: 'Always'

  envoy_for_etcd:
    repository: '192.168.99.100:30500/voltha-envoy'
    tag: 'dev'
    pullPolicy: 'Always'

```

and you can install VOLTHA using:

```shell
helm install -n voltha voltha -f voltha-values.yaml
```
