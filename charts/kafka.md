# Kafka Helm chart

The `kafka` helm chart is not maintained by CORD,
but it is available online at: <https://github.com/kubernetes/charts/tree/master/incubator/kafka>

To install kafka you can use:

```shell
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm install -f examples/kafka-single.yaml --version 0.8.8 -n cord-kafka incubator/kafka
helm install -f examples/kafka-single.yaml --version 0.8.8 -n voltha-kafka incubator/kafka
```

## Viewing events with kafkacat

As a debugging tool you can deploy a container containing `kafkacat` and use
that to listen for events:

```shell
helm install -n kafkacat xos-tools/kafkacat/
```

Once the container is up and running you can exec into the pod and use various
commands.  For a complete reference, please refer to the [`kafkacat`
guide](https://github.com/edenhill/kafkacat)

 A few examples:

- List available topics:
  ```shell
  kafkacat -L -b <kafka-service>
  ```

- Listen for events on a particular topic:
  ```shell
  kafkacat -C -b <kafka-service> -t <kafka-topic>
  ```

- Some common topics to listen for on `cord-kafka` and `voltha-kafka`:

  ```shell
  kafkacat -b cord-kafka -t onu.events
  kafkacat -b cord-kafka -t authentication.events
  kafkacat -b cord-kafka -t dhcp.events
  kafkacat -b voltha-kafka -t voltha.events
  ```
