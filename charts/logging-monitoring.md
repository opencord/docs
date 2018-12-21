# Deploy Logging and Monitoring components

To read more about logging and monitoring in CORD, please refer to [the design
document](https://docs.google.com/document/d/1hCljvKzsNW9D2Y1cbvOTNOCbTy1AgH33zXvVjbicjH8/edit).

There are currently two charts that deploy logging and monitoring
functionality, `nem-monitoring` and `logging`.  Both of these charts depend on
having [kafka](kafka.md) instances running in order to pass messages.

## Add the cord repository

{% include "../partials/helm/add-cord-repo.md" %}

## nem-monitoring charts

```shell
helm install -n nem-monitoring cord/nem-monitoring
```

> NOTE: In order to display `voltha` kpis you need to have `voltha`
> and `cord-kafka` installed.

### Monitoring Dashboards

This chart exposes two dashboards:

- [Grafana](http://docs.grafana.org/) on port *31300*
- [Prometheus](https://prometheus.io/docs/) on port *31301*

## logging charts

By default, the logging charts rely on the [Persistent Storage](storage.md)
charts to provide a persistent ElasticSearch database.  You must install those
first before running the `logging` chart.

```shell
helm install -n logging cord/logging
```

In development or testing scenarios where persistence isn't required, this
command will load the logging chart without persistence:

```shell
helm install --set elasticsearch.cluster.env.MINIMUM_MASTER_NODES="1" \
             --set elasticsearch.client.replicas=1 \
             --set elasticsearch.master.replicas=2 \
             --set elasticsearch.master.persistence.enabled=false \
             --set elasticsearch.data.replicas=1 \
             --set elasticsearch.data.persistence.enabled=false \
             -n logging cord/logging
```

### Logging Dashboard

The [Kibana](https://www.elastic.co/guide/en/kibana/current/index.html)
dashboard can be found on port `30601`

To start using Kibana, you must create an index under *Management > Index
Patterns*.  Create one with a name of `logstash-*`, then you can search for
events in the *Discover* section.
