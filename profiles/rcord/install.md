# R-CORD Profile

The latest version of R-CORD differs from versions included in earlier
releases in that it does not include the vSG service. In the code this
configuration is called `rcord-lite`, but since it is the only version
of Residential CORD currently supported, we usually simply call it
the "R-CORD" profile.

## Prerequisites

- A Kubernetes cluster (you can follow one of this guide to install a [single
  node cluster](../../prereqs/k8s-single-node.md) or a [multi node
  cluster](../../prereqs/k8s-multi-node.md))
- Helm, follow [this guide](../../prereqs/helm.md)

## CORD Components

R-CORD has dependencies on this charts, so they need to be installed first:

- [xos-core](../../charts/xos-core.md)
- [onos-fabric](../../charts/onos.md#onos-fabric)
- [onos-voltha](../../charts/onos.md#onos-voltha)

## Installing the R-CORD Profile

```shell
helm dep update xos-profiles/rcord-lite
helm install -n rcord-lite xos-profiles/rcord-lite
```

Now that your R-CORD deployment is complete, please read this 
to understand how to configure it: [Configure R-CORD](configuration.md)

## Customizing an R-CORD Install

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

