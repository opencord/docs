# PONNET Helm Chart

The `ponnet` Helm chart installs and configures Kubernetes CNI plugins
for [PONSIM](ponsimv2.md).   It creates Linux bridges
that allow a L2 dataplane to be created between the PONSIM
RG and components upstream of the PONSIM OLT.  Note that the bridges
are not actually created until [PONSIM](ponsimv2.md) is installed.

{% include "../partials/helm/add-cord-repo.md" %}

You can then install the chart using:

```bash
helm install -n ponnet cord/ponnet \
    --set numOlts=1 \
    --set numOnus=1
```

The chart modifies the underlying Kubernetes setup by installing the *bridge* CNI and adding configuration files in `/etc/cni/net.d` 
to create Linux bridges for Ponsim.  Arguments _numOlts_ and _numOnus_ can be set between 1 and 4.  The chart writes `nniX.conf` for 
_X_ between 0 and _numOlts_ - 1; for each _X_, it writes `ponX.Y.conf` for _Y_ between 0 and _numOnus_ - 1.

In order to use this chart, Kubernetes must be configured with CNI enabled.  Note that this chart does not seem to work on *minikube*.
