# Install Platform

Once the prerequisites have been met, the next step to installing CORD is
to bring up the Helm charts for the platform components. This includes the
following steps:

## Install ONOS

Install [onos](./charts/onos.md#onos-manages-fabric--voltha). 
It will manage the fabric infrastructure.

## Install XOS

Install [xos-core](./charts/xos-core.md). It will orchestrate the services.

## Install Kafka

Install [cord-kafka](./charts/kafka.md). It will implement a shared 
message bus.

## Install Logging and Monitoring

Install [loggin-monitoring](./charts/logging-monitoring.md). Log and monitor
events in the POD.
