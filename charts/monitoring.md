# Deploy Monitoring

To read more about the monitoring in CORD, please refer to this [document](https://docs.google.com/document/d/1hCljvKzsNW9D2Y1cbvOTNOCbTy1AgH33zXvVjbicjH8/edit).

To install the required components in you cluster:

```shell
helm dep update nem-monitoring
helm install -n nem-monitoring nem-monitoring
```

> NOTE: In order to display `voltha` kpis you need to have `voltha`
> and `voltha-kafka` installed.

## Access the monitoring dashboard

This chart exposes two dashboards:

- grafana on port `31300`
- prometheus on port `31301`
