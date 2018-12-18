# Install Platform

Once the prerequisites have been met, the next step to installing CORD is
to bring up the Helm charts for the platform components. 

## CORD Platform as a whole

To install the CORD Platform you can use the corresponding chart:

```shell
helm install -n cord-platform cord/cord-platform --version=6.1.0
```

## CORD Platform as separate components

The main reason to install the CORD Platform by installing its standalone components
is if you're developing on it and you need granular control.

There are the components included in the `cord-platform` chart:

- [ONOS](./charts/onos.md#onos-manages-fabric--voltha)
- [xos-core](./charts/xos-core.md)
- [cord-kafka](./charts/kafka.md)
- [logging-monitoring](./charts/logging-monitoring.md)
