# RCORD Lite

## Prerequisites

Lorem ipsum dolor sit amet, consectetur adipisicing elit. Nobis veritatis eligendi vitae dolorem animi non unde odio, hic quasi totam recusandae repellat minima provident aliquam eveniet a tempora saepe. Iusto.

- A Kubernetes cluster (you can follow one of this guide to install a [single node cluster](../prereqs/minikube.md) or a [multi node cluster](../prereqs/kubespray.md))
- Helm, follow [this guide](../prereqs/helm.md)

## CORD Components

Lorem ipsum dolor sit amet, consectetur adipisicing elit. Fugit et quam tenetur maiores dolores ipsum hic ex doloremque, consectetur porro sequi vitae tempora in consequuntur provident nostrum nobis. Error, non?

Then you need to install this charts:

- [xos-core](../charts/xos-core.md)
- [onos-fabric](../charts/onos.md#onos-fabric)
- [onos-voltha](../charts/onos.md#onos-voltha)

## Install the RCORD-Lite helm chart

```
helm install -n rcord-lite xos_profiles/rcord-lite
```

### How to customize the RCORD-Lite helm chart

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

```bash
helm install -n rcord-lite xos_profiles/rcord-lite -f my-rcord-lite-values.yaml
```