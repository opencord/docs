# ONOS

{% include "../partials/helm/add-cord-repo.md" %}

Then, to install ONOS run:

```shell
helm install -n onos cord/onos --version 1.1.2
```

**Nodeports exposed**

* OpenFlow: 31653
* SSH: 30115
* REST/UI: 30120
* Karaf debugger: 30555

## Accessing the ONOS CLI

Assuming you have not changed the default ports in the chart,
you can use this command to access the ONOS CLI:

```shell
ssh karaf@<node-ip> -p 30115
```

The default ONOS password is `karaf`.

## ONOS logging

### onos-log-agent sidecar container

By default, the onos helm chart will run a sidecar container to ship logs using
[Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
to [Kafka](kafka.md) for aggregation of logs with the rest of the CORD
platform.

This container is named `onos-log-agent`, and because 2 containers are running
in the pod when you run `kubectl` you may need to use the `-c` option to
specify which container you want to interact with.  For example, to view the
ONOS logs via kubectl, you would use:

```shell
kubectl logs onos-7bbc9555bf-2754p -c onos
```

and to view the filebeat logs:

```shell
kubectl logs onos-7bbc9555bf-2754p -c onos-log-agent
```

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

A configuration file called *onos-debug.yaml* can be found in the *configs* folder of the helm-chart repository. That already contains examplar lines to augment the ONOS logging level while deploying the ONOS pod. To use the onos-debug configuration, run:

```shell
helm install -n onos -f configs/onos-debug.yaml cord/onos
```
