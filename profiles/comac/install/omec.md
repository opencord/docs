# Install OMEC Charts

This page walks through the sequence of Helm operations needed to bring up OMEC.
It assumes the platform has already been installed.

OMEC is composed of two charts, omec-control-plane and omec-data-plane.
You can deploy both charts together in a single cluster or separately
in a central and edge cluster, respectively.
Before installing the charts, refer to [this page](../configure/omec.md)
to create `override-values.yaml` file that contains values overriding each
chart's default settings for your environment. This file will be passed to Helm
install command.

## Installing OMEC

{% include "../../../partials/helm/add-cord-repo.md" %}

Then, proceed with the OMEC charts installation.
Please note that you must install omec-data-plane first, then the omec-control-plane:

```shell
helm install --namespace omec -n omec-data-plane cord/omec-data-plane -f override-values.yaml
helm install --namespace omec -n omec-control-plane cord/omec-control-plane -f override-values.yaml
```

## Verify your installation

Once the installation completes, monitor your setup using `kubectl get pods -n omec`.
Wait until all pods are in *Running* state and "job-hss-bootstrap" and "job-hss-db-sync"
pods are in *Complete* state.

```shell
kubectl get pods -n omec
NAME                      READY   STATUS      RESTARTS   AGE
cassandra-0               1/1     Running     0          103s
hss-0                     1/1     Running     0          103s
job-hss-bootstrap-vm645   0/1     Completed   0          103s
job-hss-db-sync-5hj9v     0/1     Completed   0          103s
mme-0                     4/4     Running     0          103s
spgwc-0                   1/1     Running     0          103s
spgwu-0                   1/1     Running     0          2m17s
```
