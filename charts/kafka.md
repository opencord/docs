# Kafka Helm chart

The `kafka` helm chart is not maintained by CORD,
but it is available online at: <https://github.com/kubernetes/charts/tree/master/incubator/kafka>

To install kafka you can use:

```shell
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm install --name cord-kafka incubator/kafka
```