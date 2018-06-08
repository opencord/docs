# R-CORD Profile

The latest version of R-CORD differs from versions included in earlier
releases in that it does not include the vSG service. In the code this
configuration is called RCORD-Lite, but since it is the only version
of Residential CORD currently supported, we usually simply call it
"R-CORD."

## Prerequisites

- A Kubernetes cluster (you can follow one of this guide to install a [single
  node cluster](../../prereqs/k8s-single-node.md) or a [multi node
  cluster](../../prereqs/k8s-multi-node.md))
- Helm, follow [this guide](../../prereqs/helm.md)

## CORD Components

RCORD-Lite has dependencies on this charts, so they need to be installed first:

- [xos-core](../../charts/xos-core.md)
- [onos-fabric](../../charts/onos.md#onos-fabric)
- [onos-voltha](../../charts/onos.md#onos-voltha)

## Install the RCORD-Lite Helm Chart

```shell
helm dep update xos-profiles/rcord-lite
helm install -n rcord-lite xos-profiles/rcord-lite
```

Now that the your RCORD-Lite deployment is complete, please read this 
to understand how to configure it: [Configure RCORD-Lite](configuration.md)

## How to Customize the RCORD-Lite Helm Chart

Define a `my-rcord-lite-values.yaml` that looks like:

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
helm install -n rcord-lite xos-profiles/rcord-lite -f my-rcord-lite-values.yaml
```

