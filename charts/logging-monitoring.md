# Deploy Logging and Monitoring components

To read more about logging and monitoring in CORD, please refer to [the design
document](https://docs.google.com/document/d/1hCljvKzsNW9D2Y1cbvOTNOCbTy1AgH33zXvVjbicjH8/edit).

There are currently two charts that deploy logging and monitoring
functionality, `nem-monitoring` and `logging`.  Both of these charts depend on
having [kafka](kafka.md) instances running in order to pass messages.


## `nem-monitoring` charts

```shell
helm dep update nem-monitoring
helm install -n nem-monitoring nem-monitoring
```

> NOTE: In order to display `voltha` kpis you need to have `voltha`
> and `voltha-kafka` installed.

### Monitoring Dashboards

This chart exposes two dashboards:

- [Grafana](http://docs.grafana.org/) on port `31300`
- [Prometheus](https://prometheus.io/docs/) on port `31301`

## `logging` charts

```shell
helm dep up logging
helm install -n logging logging
```

For smaller developer/test environments without persistent storage, please use
the `examples/logging-single.yaml` file to run the logging chart, which doesn't
create PVC's.

### Logging Dashboard

The [Kibana](https://www.elastic.co/guide/en/kibana/current/index.html)
dashboard can be found on port `30601`

To start using Kibana, you must create an index under *Management > Index
Patterns*.  Create one with a name of `logstash-*`, then you can search for
events in the *Discover* section.
