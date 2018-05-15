# ONOS Helm chart

This chart can be used to deploy an ONOS container.
Traditionally it is used to deploy three different ONOSes in the system,
depending by what is required.

## ONOS-Fabric

`helm install -n onos-fabric -f configs/onos-fabric.yaml onos`

Ports exposed:

- ovsdb: 31640
- OpenFlow: 31653
- SSH: 31101
- UI: 31181

## ONOS-VOLHTA

> NOTE: This requires [VOLTHA](voltha.md) to be installed

`helm install -n onos-voltha -f configs/onos-voltha.yaml onos`

Ports exposed:

- SSH: 30115
- UI: 30120

## ONOS-VTN

`helm install -n onos-cord -f configs/onos-cord.yaml onos`

## Overridable values

This is a sample `values.yaml` that can be used to override values
through the `-f` option:

```yaml
imagePullPolicy: Always
onosImage: 'onosproject/onos:1.13.1'

services:
  openflowServiceType: NodePort
  ovsdbServiceType: NodePort
  sshServiceType: NodePort
  uiServiceType: NodePort
  ovsdb:
    nodePort: 31640
  openflow:
    nodePort: 31653
  ssh:
    nodePort: 31101
  ui:
    nodePort: 31181
```
