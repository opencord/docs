# Deploy ONOS

The same chart can be used to deploy different flavors of ONOS, depending on the configuration applied (configurations available in the configs folder).

* **onos-fabric**: a specific version of ONOS used to control the Trellis fabric
* **onos-voltha**: a specific version of ONOS used to control VOLTHA
* **onos-vtn**: a speciic version of ONOS used to control VTN
* **no configuration applied**: if no configurations are applied, a generic ONOS instance will be installed

## ONOS (manages fabric + voltha)

```shell
helm install -n onos -f configs/onos.yaml onos
```

**Nodeports exposed**

* OpenFlow: 31653
* SSH: 30115
* REST/UI: 30120
* Karaf debugger: 30555

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

**Nodeports exposed**

No ports are exposed

## Modify default debug level

An option can be added either to the default ONOS *values.yaml* file, or overritten through an external configuration file. Here is an example:

```yaml
application_logs: |
  log4j.logger.org.opencord.olt = DEBUG
  log4j.logger.org.opencord.kafka = DEBUG
  log4j.logger.org.opencord.sadis = DEBUG
```
