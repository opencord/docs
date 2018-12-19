# PONNET Helm Chart

The `ponnet` Helm chart installs and configures Kubernetes CNI plugins
for [PONSIM](ponsimv2.md).  Currently it creates two Linux bridges, `pon0`
and `pon1`, that allow a L2 dataplane to be created between the PONSIM
RG and components upstream of the PONSIM OLT.  Note that the bridges
are not actually created until [PONSIM](ponsimv2.md) is installed.

You can install the chart using:

```bash
helm install -n ponnet ponnet
```

The chart modifies the base Kubernetes setup by installing the `bridge`
CNI.  The underlying Kubernetes installation must be configured with
CNI enabled.  Note that this does not seem to work on `minikube`.
