# Install OMEC

This page walks through the sequence of Helm operations needed to bring up OMEC.
It assumes the platform has already been installed.

OMEC is composed of two charts, omec-control-plane and omec-data-plane.
You can deploy both charts together in a single cluster or separately
in a central and edge cluster, respectively.
Before installing the charts, refer to [this page](../configure/omec.md)
to create `override-values.yaml` file that contains values overriding each
chart's default settings for your environment. This file will be passed to Helm
install command.

## Install OMEC charts

{% include "../../../partials/helm/add-cord-repo.md" %}

Then, proceed with the OMEC charts installation.
Please note that you must install omec-data-plane first, then the omec-control-plane:

```shell
$ helm install cord/omec-data-plane \
    --namespace omec \
    --name omec-data-plane \
    --values override-values.yaml

$ helm install cord/omec-control-plane \
    --namespace omec \
    --name omec-control-plane \
    --values override-values.yaml
```

In case you're deploying control plane and data plane to different clusters, edge and central,
just point the correct K8S context with `--kube-context` option when running helm install command.
See [this page](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/) for configuring access to multiple K8S clusters.

```shell
$ helm install cord/omec-data-plane \
    --kube-context edge \
    --namespace omec \
    --name omec-data-plane \
    --values override-values.yaml

$ helm install cord/omec-control-plane \
    --kube-context central \
    --namespace omec \
    --name omec-control-plane \
    --values override-values.yaml
```

## Install OMEC to a specific node

You may need to deploy some OMEC components to specific nodes to properly
allocate resources. For example, let's assume that you have 3 node single cluster
and want to deploy control plane components to node1 and node2, and data plane
components to node3 for some reason.
In that case, you can use node selector by overriding `nodeSelectors.enabled=true`.
You'll also need to add a label to the nodes.

```shell
$ kubectl label nodes node1 omec-cp=enabled
$ kubectl label nodes node2 omec-cp=enabled
$ kubectl label nodes node3 omec-dp=enabled
$ kubectl get nodes --show-labels
NAME    STATUS   ROLES    AGE   VERSION   LABELS
node1   Ready    master   2d    v1.15.3   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=node1,kubernetes.io/os=linux,node-role.kubernetes.io/master=,omec-cp=enabled
node2   Ready    master   2d    v1.15.3   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=node2,kubernetes.io/os=linux,node-role.kubernetes.io/master=,omec-cp=enabled
node3   Ready    master   2d    v1.15.3   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=node3,kubernetes.io/os=linux,node-role.kubernetes.io/master=,omec-dp=enabled
```

You can also override node labels used as nodeSelector for each OMEC component.

## Verify your installation

Once the installation completes, monitor your setup using `kubectl get pods -n omec`.
Wait until all pods are in *Running* state and "job-hss-bootstrap" and "job-hss-db-sync"
pods are in *Complete* state.

```shell
$ kubectl get pods -n omec
NAME                      READY   STATUS      RESTARTS   AGE
cassandra-0               1/1     Running     0          103s
hss-0                     1/1     Running     0          103s
job-hss-bootstrap-vm645   0/1     Completed   0          103s
job-hss-db-sync-5hj9v     0/1     Completed   0          103s
mme-0                     4/4     Running     0          103s
spgwc-0                   1/1     Running     0          103s
spgwu-0                   1/1     Running     0          2m17s
sriov-device-plugin-6wsg7 1/1     Running     0          2m17s
sriov-device-plugin-bmhzz 1/1     Running     0          2m17s
sriov-device-plugin-kbc8m 1/1     Running     0          2m17s
```

If control plane and data plane are deployed in different clusters, edge and central,
the pod status of each cluster is as follows.

```shell
$ kubectl config use-context edge
$ kubectl get pods -n omec
NAME                      READY   STATUS      RESTARTS   AGE
spgwu-0                   1/1     Running     0          2m17s
sriov-device-plugin-6wsg7 1/1     Running     0          2m17s
sriov-device-plugin-bmhzz 1/1     Running     0          2m17s
sriov-device-plugin-kbc8m 1/1     Running     0          2m17s

$ kubectl config use-context central
$ kubectl get pods -n omec
NAME                      READY   STATUS      RESTARTS   AGE
cassandra-0               1/1     Running     0          103s
hss-0                     1/1     Running     0          103s
job-hss-bootstrap-vm645   0/1     Completed   0          103s
job-hss-db-sync-5hj9v     0/1     Completed   0          103s
mme-0                     4/4     Running     0          103s
spgwc-0                   1/1     Running     0          103s
```
