# Deploy VOLTHA

## Prerequisites

Install the etcd-operator helm chart first. This chart provides a convenient way of creating and managing etcd clusters. When VOLTHA installs it will attempt to use etcd-operator to create its etcd cluster. Once installed etcd-operator can be left running.

```shell
helm install -n etcd-operator stable/etcd-operator --version 0.8.3
```

Wait for etcd-operator to create the EtdCluster CustomResourceDefinitions.  This should only be a couple of seconds after the etcd-operator pods are running.  Check the CRD are ready by running the following:

```shell
kubectl get crd | grep etcd
```

## Install

{% include "../partials/helm/add-cord-repo.md" %}

To install the VOLTHA helm chart:

```shell
helm install -n voltha cord/voltha --version=1.0.6 \
    --set etcd-cluster.clusterSize=3
```

Allow all etcd-cluster pods to start before using VOLTHA.  If not all etcd-cluster pods are starting successfully,
you may want to try `--set etcd-cluster.clusterSize=1` above.

## Uninstall

```shell
helm delete --purge voltha
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
ssh voltha@<node-ip> -p 30110
```

The default VOLTHA password is *admin*.

## Building and using development images

In some cases you may want to build custom images to try out development code. In order to do that, from the CORD repository, do:

```shell
cd incubator/voltha
REPOSITORY=voltha/ TAG=dev VOLTHA_BUILD=docker make build
cd ~/cord/automation-tools/developer
bash tag_and_push.sh -f dev -r 192.168.99.100:30500
```

This set of commands builds the VOLTHA containers and pushes them to a local
[docker registry](../partials/push-images-to-registry.md) using a tag called *dev*.

Once the images are pushed to a docker registry on the POD, you can create a values file like the following one, to override the default chart values, so use your images:

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

Then, install VOLTHA using:

```shell
helm install -n voltha -f voltha-values.yaml cord/voltha --version=1.0.6
```
