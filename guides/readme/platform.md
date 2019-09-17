# Install Platform

Once the prerequisites have been met, the next step to installing CORD is to bring up the Helm charts for the platform components.

## CORD Platform as a Whole

Then, to install the CORD Platform you can use the corresponding chart:

```text
helm install -n cord-platform cord/cord-platform --version=7.0.0
```

### Disabling monitoring and logging

In some cases, for example while testing/development, you may want to disable the `logging` or `monitoring` capabilites to reduce load. You can disable those features by adding this to the installation commands:

```text
--set logging.enabled=false
--set nem-monitoring.enabled=false
```

To disable both of them you can use:

```text
helm install -n cord-platform cord/cord-platform --version=7.0.0 --set logging.enabled=false --set nem-monitoring.enabled=false
```

## Alternatively, install the CORD Platform as set of Separate Components

Alternatively, you may want to install the individual components separately. The following are the individual components included in the _cord-platform_ chart:

* [ONOS](../../references/helm/onos.md#onos-manages-fabric--voltha)
* [XOS](../../references/helm/xos-core.md)
* [Kafka](../../references/helm/kafka.md)

Optionally, you may also want to install logging and monitoring infrastructure components:

* [Logging-Monitoring](../../references/helm/logging-monitoring.md)

## Verify your installation and next steps

Once the installation completes, monitor your setup using `kubectl get pods`. Wait until all pods are in _Running_ state.

> **Note:** Your pods may periodically transition into _error_ state. This is expected. They will retry and eventually get to the desired state.

You're now ready to install the desired profile. Please, continue to the [profile section](profiles.md).

