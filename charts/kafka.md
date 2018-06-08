# Kafka Helm chart

The `kafka` helm chart is not maintained by CORD,
but it is available online at: <https://github.com/kubernetes/charts/tree/master/incubator/kafka>

To install kafka you can use:

```shell
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm install --name cord-kafka incubator/kafka
```

If you are experierencing problems with a multi instance installation of kafka,
you can try to install a single instance of it:

```shell
helm install --name cord-kafka incubator/kafka -f examples/kafka-single.yaml
```