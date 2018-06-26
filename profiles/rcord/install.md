# R-CORD Profile

The latest version of R-CORD differs from versions included in earlier
releases in that it does not include the vSG service. In the code,
this new configuration is called `rcord-lite`, but since it is the
only version of Residential CORD currently supported, we simply
call it the *R-CORD profile.*

## Prerequisites

- Kubernetes: Follow one of these guides to install either a [single
   node](../../prereqs/k8s-single-node.md) or a [multi
   node](../../prereqs/k8s-multi-node.md) cluster.
- Helm: Follow this [guide](../../prereqs/helm.md).

## Install VOLTHA

When running on a physical POD with OLT/ONU hardware, the
first step to bringing up R-CORD is to install the
[VOLTHA helm chart](../../charts/voltha.md).

## Install CORD Platform

The R-CORD profile has dependencies on the following platform
charts, so they need to be installed next:

- [xos-core](../../charts/xos-core.md)
- [onos-fabric](../../charts/onos.md#onos-fabric)
- [onos-voltha](../../charts/onos.md#onos-voltha)

## Install R-CORD Profile

You are now ready to install the R-CORD profile:

```shell 
helm dep update xos-profiles/rcord-lite
helm install -n rcord-lite xos-profiles/rcord-lite
```

Optionally, if you want to use the "bottom up" subscriber provisioning
workflow described in the [Operations Guide](configuration.md), you
will also need to install the following two charts:

- [cord-kafka](../../charts/kafka.md)
- [hippie-oss](../../charts/hippie-oss.md)

> **Note:** If you install both VOLTHA and the optional Kafka, you
> will end up with two instantiations of Kafka: `kafka-voltha` and
> `kafka-cord`.

Once your R-CORD deployment is complete, please read the
following guide to understand how to configure it:
[Configure R-CORD](configuration.md)

## Customize an R-CORD Install

Define a `my-rcord-values.yaml` that looks like:

```yaml
# in service charts
addressmanager:
  imagePullPolicy: 'Always'
fabric:
  imagePullPolicy: 'Always'
onos-service:
  imagePullPolicy: 'Always'
volt:
  imagePullPolicy: 'Always'
vsg-hw:
  imagePullPolicy: 'Always'
kubernetes:
  imagePullPolicy: 'Always'
vrouter:
  imagePullPolicy: 'Always'
xos-gui:
  imagePullPolicy: 'Always'
simpleexampleservice:
  imagePullPolicy: 'Always'
```

and use it during the installation with:

```shell
helm install -n rcord-lite xos-profiles/rcord-lite -f my-rcord-values.yaml
```
