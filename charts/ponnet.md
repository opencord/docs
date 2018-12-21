# PONNET Helm Chart

The `ponnet` Helm chart installs and configures Kubernetes CNI plugins
for [PONSIM](ponsimv2.md).  Currently it creates two Linux bridges, `pon0`
and `pon1`, that allow a L2 dataplane to be created between the PONSIM
RG and components upstream of the PONSIM OLT.  Note that the bridges
are not actually created until [PONSIM](ponsimv2.md) is installed.

{% include "../partials/helm/add-cord-repo.md" %}

You can then install the chart using:

```bash
helm install -n ponnet cord/ponnet
```

The chart modifies the underlying Kubernetes setup by installing the *bridge* CNI and adding configuration files to create the two bridges.  Kubernetes must be configured with CNI enabled.  Note that this chart does not seem to work on *minikube*.
