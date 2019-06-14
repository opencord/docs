# ELK Stack

> In order to use Elastic Stack the `logging` helm-chart needs to be installed.
> That is part of the `cord-platform` helm-chart, but if you need to install it,
> please refer to [this guide](../charts/logging-monitoring.md#logging-charts).

CORD uses ELK Stack for logging information at all levels. CORD’s ELK Stack
logger collects information from several components, including the XOS Core,
API, and various Synchronizers. Together with logs events and alarms are
collected in ELK Stack.

On a running POD, ELK can be accessed at `http://<pod-ip>:30601`.

For most purposes, the logs in ELK Stack should contain enough information
to diagnose problems. Furthermore, these logs thread together facts across
multiple components by using the identifiers of XOS data model objects.

**Important!**

To start using Kibana, you must create an index under *Management > Index
Patterns*.  Create one with a name of `logstash-*`, then you can search for
events in the *Discover* section.

## Examples Query

More information about using
[Kibana](https://www.elastic.co/guide/en/kibana/current/getting-started.html)
to access ELK Stack logs is available elsewhere, but to illustrate how the
logging system is used in CORD, consider the following example quieries.

### XOS Related queries

The first example query enlists log messages in the implementation of a
particular service synchronizer, in a given time range:

```sql
+synchronizer_name:rcord-synchronizer AND +@timestamp:[now-1h TO now]
```

A second query gets log messages that are linked to the _Network_ data model
across all services:

```sql
+model_name: RCordSubscriber
```

The same query can be refined to include the identifier of the specific
_Network_ object in question. You can obtain the object id from the object’s
page in the XOS GUI.

```sql
+model_name: RCordSubscriber AND +pk:68
```

A final example lists log messages in a service synchronizer that
contain Python exceptions, and will usually correspond to anomalous
execution:

```sql
+synchronizer_name:rcord-synchronizer AND +exception
```

## REST APIs based queries

The first thing you need to do to use the REST APIs is to find the port on which the service is exposed.
At the moment the [official chart](https://github.com/helm/charts/tree/master/incubator/elasticsearch)
won't let us specify a port, so that will change for every deployment.

To find the correct port, run this command anywhere you have the `kubectl` tool installed:

```bash
export ELK_PORT=$(kubectl get svc logging-elasticsearch-client -o json | jq .spec.ports[0].nodePort)
```

You can then query the REST API on that port, for example:

```bash
curl -XGET "http://localhost:$ELK_PORT"
{
  "name" : "logging-elasticsearch-client-587599fbdc-bkfhn",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "Nwc4HpeBQrOOcL4IWVyRAw",
  "version" : {
    "number" : "6.5.4",
    "build_flavor" : "oss",
    "build_type" : "tar",
    "build_hash" : "d2ef93d",
    "build_date" : "2018-12-17T21:17:40.758843Z",
    "build_snapshot" : false,
    "lucene_version" : "7.5.0",
    "minimum_wire_compatibility_version" : "5.6.0",
    "minimum_index_compatibility_version" : "5.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

Following are some SEBA related querying example. This examples are executed from within the cluster,
if you want to run them from a client machine replace `localhost` with the `cluster-ip`.

### Get current authentication status for a particular ONU

```bash
curl -XGET "http://localhost:$ELK_PORT/_search" -H 'Content-Type: application/json' -d'
{
  "size": 1, 
  "sort": {
    "timestamp": "desc"
  },
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "serialNumber": "PSMO12345678"
          }
        }
      ],
      "filter": {
         "term": {
          "kafka_topic": "authentication.events"
        }
      }
    }
  }
}' | jq .hits.hits[0]
```

Example response:

```json
{
  "_index": "logstash-2019.05.30",
  "_type": "doc",
  "_id": "Kw_bCWsBPqzdKVIdSbxC",
  "_score": null,
  "_source": {
    "authenticationState": "APPROVED",
    "deviceId": "of:0000aabbccddeeff",
    "@version": "1",
    "portNumber": "128",
    "kafka_topic": "authentication.events",
    "@timestamp": "2019-05-30T17:48:14.343Z",
    "timestamp": "2019-05-30T17:48:14.308Z",
    "kafka_key": "%{[@metadata][kafka][key]}",
    "serialNumber": "PSMO12345678",
    "type": "cord-kafka",
    "kafka_timestamp": "1559238494311"
  },
  "sort": [
    1559238494308
  ]
}
```

### Get all the events regarding a particular ONU

```bash
curl -XGET "http://localhost:$ELK_PORT/_search" -H 'Content-Type: application/json' -d'
{
  "sort": {
    "timestamp": "desc"
  },
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "serialNumber": "PSMO12345678"
          }
        }
      ]
    }
  }
}' | jq .hits.hits
```

### Get all the events regarding a particular action

If you want to list all the authentication events, regardless fo the ONU serial number:

```bash
curl -XGET "http://localhost:$ELK_PORT/_search" -H 'Content-Type: application/json' -d'
{
  "sort": {
    "timestamp": "desc"
  },
  "query": {
    "bool": {
      "filter": {
        "term": {
          "kafka_topic": "authentication.events"
        }
      }
    }
  }
}
' | jq .hits.hits
```

### Get Operational status of the RADIUS server

Operational status can be queried from Elastic search using Rest API calls.
Three possible values for operational status are: 
1) In Use
2) Unknown
3) Unavailable 

```bash
curl -XGET "http://localhost:$ELK_PORT/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "filter": {
        "term": {
          "kafka_topic": "radiusoperationalstatus.events"
        }
      }
    }
  }
}' | jq .hits.hits[0]._source.radiusoperationalstatus
```

Example Response:

```bash
"In Use"
```
