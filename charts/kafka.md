# Kafka Helm chart

The *kafka* helm chart is not maintained by CORD, but it is available online
at: <https://github.com/kubernetes/charts/tree/master/incubator/kafka>

To install Kafka using the `cord-kafka` name run the following commands:

```shell
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm install --version 0.8.8 \
             --set configurationOverrides."offsets.topic.replication.factor"=1 \
             --set configurationOverrides."log.retention.hours"=4 \
             --set configurationOverrides."log.message.timestamp.type"="LogAppendTime" \
             --set replicas=1 \
             --set persistence.enabled=false \
             --set zookeeper.replicaCount=1 \
             --set zookeeper.persistence.enabled=false \
             -n cord-kafka incubator/kafka
```

> NOTE: Historically there were two kafka busses deployed (another one named
> `voltha-kafka`) but these have been consolidated.

## Optional tool: viewing events with kafkacat

Optionally, you can deploy a *kafkacat* container to to listen for Kafka events and debug:

{% include "../partials/helm/add-cord-repo.md" %}

Then, you can proceed with the kafkacat installation:

```shell
helm install -n kafkacat cord/kafkacat
```

Once the container is up and running you can exec into the pod and run kafkacat
to perform various diagnostic commands.

```shell
kubectl exec -it kafkacat-##########-##### bash
```

For a complete reference, please refer to the [`kafkacat`
guide](https://github.com/edenhill/kafkacat)

 A few examples:

- List available topics:

```shell
kafkacat -b cord-kafka -L
```

- Listen for events on a particular topic:

```shell
kafkacat -b cord-kafka -C -t <kafka-topic>
```

- Some example topics to listen on:

```shell
kafkacat -b cord-kafka -C -t xos.log.core
kafkacat -b cord-kafka -C -t xos.gui_events
kafkacat -b cord-kafka -C -t voltha.events
kafkacat -b cord-kafka -C -t onu.events
kafkacat -b cord-kafka -C -t authentication.events
kafkacat -b cord-kafka -C -t dhcp.events
```
