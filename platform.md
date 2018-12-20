# Install Platform

Once the prerequisites have been met, the next step to installing CORD is
to bring up the Helm charts for the platform components. 

## CORD Platform as a Whole

To install the CORD Platform you can use the corresponding chart:

```shell
helm install -n cord-platform cord/cord-platform --version=6.1.0
```

## CORD Platform as Separate Components

Sometimes it his helpful (for example, when developing) to install the
individual components that make up the CORD Platform one at a time.
The following are the individual components included in the
`cord-platform` chart:

- [ONOS](./charts/onos.md#onos-manages-fabric--voltha)
- [XOS](./charts/xos-core.md)
- [Kafka](./charts/kafka.md)
- [Logging-Monitoring](./charts/logging-monitoring.md)
