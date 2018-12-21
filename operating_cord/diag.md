# Monitoring and Logging

CORD is usually configured with monitoring and logging capabilities,
built around Prometheus and ELK Stack, respectively. Both consume
events/metrics/logs posted to Kafka. The data they collect can be
viewed on their respective dashboards:

* **Metrics:** Collected by [Prometheus](https://prometheus.io/) and
  viewable using [Grafana](http://docs.grafana.org/) at port 31300.

* **Logs:** Collected by [Elk Stack](https://www.elastic.co/elk-stack)
  and viewable using
  [Kabana](https://www.elastic.co/guide/en/kibana/current/index.html)
  at port 30601.
