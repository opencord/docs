# Deploy ONOS

The same chart can be used to deploy different flavors of ONOS, depending on the configuration applied (configurations available in the configs folder).

* **onos-fabric**: a specific version of ONOS used to control the Trellis fabric
* **onos-voltha**: a specific version of ONOS used to control VOLTHA
* **onos-vtn**: a speciic version of ONOS used to control VTN
* **no configuration applied**: if no configurations are applied, a generic ONOS instance will be installed

## onos-fabric

```shell
helm install -n onos-fabric -f configs/onos-fabric.yaml onos
```

**Nodeports exposed**

* ovsdb: 31640
* OpenFlow: 31653
* SSH: 31101
* REST/UI: 31181

## onos-voltha

> **Note:** This requires [VOLTHA](voltha.md) to be installed

```shell
helm install -n onos-voltha -f configs/onos-voltha.yaml onos
```

**Nodeports exposed**

* SSH: 30115
* REST/UI: 30120

## onos-cord (onos-vtn)

```shell
helm install -n onos-cord -f configs/onos-cord.yaml onos
```

**Nodeports exposed**

* SSH: 32101
* REST/UI: 32181

## Generic ONOS

```shell
helm install -n onos onos
```

The configuration doesn't expose any nodeport.
