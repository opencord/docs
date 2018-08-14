# Kafka Helm chart

The `kafka` helm chart is not maintained by CORD,
but it is available online at: <https://github.com/kubernetes/charts/tree/master/incubator/kafka>

To install kafka you can use:

```shell
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm install --name cord-kafka \
--set replicas=1 \
--set persistence.enabled=false \
--set zookeeper.servers=1 \
--set zookeeper.persistence.enabled=false \
incubator/kafka
```

If you are experierencing problems with a multi instance installation of kafka,
you can try to install a single instance of it:

```shell
helm install --name cord-kafka incubator/kafka -f examples/kafka-single.yaml
```

## Viewing events on the bus

As a debugging tool you can deploy a container containing `kafkacat` and use
that to listen for events:

```shell
helm install -n kafkacat xos-tools/kafkacat/
```

Once the container is up and running you can exec into the pod and use this 
command to listen for events on a particular topic:

```shell
kafkacat -C -b <kafka-service> -t <kafka-topic>
```

For a complete reference, please refer to the [`kafkacat` guide](https://github.com/edenhill/kafkacat)

### Most common topics

Here are some of the most common topic you can listen to on `cord-kafka`:

```shell
kafkacat -b cord-kafka -t onu.events
kafkacat -b cord-kafka -t authentication.events
kafkacat -b cord-kafka -t dhcp.events
```