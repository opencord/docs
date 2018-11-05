# Deploy ONOS

## Configurations

The same chart can be used to deploy different flavors of ONOS, depending on
the configuration applied. These configurations can be found in the
`helm-charts/configs` directory.

* **onos**: ONOS configured for the CORD scenarios with Trellis (Fabric), VOLTHA,
  and VTN
* **no configuration applied**: if no configurations are applied, a generic
  ONOS instance will be installed

## ONOS with CORD configuration

```shell
helm install -n onos -f configs/onos.yaml onos
```

**Nodeports exposed**

* OpenFlow: 31653
* SSH: 30115
* REST/UI: 30120
* Karaf debugger: 30555

## Use VOLTHA-ONOS

_This is intendend for development purposes_

```shell
helm install -n onos -f configs/onos-voltha.yaml onos
```

**Nodeports exposed**

* OpenFlow: 31653
* SSH: 30115
* REST/UI: 30120
* Karaf debugger: 30555

## Generic ONOS

```shell
helm install -n onos onos
```

**Nodeports exposed**: None

## ONOS logging

### `onos-log-agent` Sidecar container

By default, the onos helm chart will run a sidecar container to ship logs using
[Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
to [Kafka](kafka.md) for aggregation of logs with the rest of the CORD
platform.

This container is named `onos-log-agent`, and because 2 containers are running
in the pod when you run `kubectl` you may need to use the `-c` option to
specify which container you want to interact with.  For example, to view the
ONOS logs via kubectl, you would use:

    kubectl logs onos-7bbc9555bf-2754p -c onos

and to view the filebeat logs:

    kubectl logs onos-7bbc9555bf-2754p -c onos-log-agent

If this the sidecar isn't required, it can be disabled when installing the
chart by passing `--set log_agent.enabled=false` or by using a values file.

### Modifying ONOS logging levels

An option can be added either to the default ONOS *values.yaml* file, or
overritten through an external configuration file. Here is an example:

```yaml
application_logs: |
  log4j.logger.org.opencord.olt = DEBUG
  log4j.logger.org.opencord.kafka = DEBUG
  log4j.logger.org.opencord.sadis = DEBUG
```
