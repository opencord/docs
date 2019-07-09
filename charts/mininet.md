# Mininet Helm Chart

The `mininet` chart deploys Mininet for use by [SiaB](../profiles/seba/siab.md).
It creates a virtual agg switch (Open vSwitch) that connects the downstream
Ponsim OLTs to an upstream virtual BNG.

You must install the [PONNET](ponnet.md) chart before installing this one.

{% include "../partials/helm/add-cord-repo.md" %}

To install:

```shell
helm install -n mininet cord/mininet \
    --set numOlts=1 \
    --set numOnus=1
```

Arguments _numOlts_ and _numOnus_ can be set between 1 and 4.  The chart connects bridge _nniX_
to the agg switch for _X_ between 0 and _numOlts_ - 1.

For each _X_ above, a double-tagged interface is created on the virtual BNG for _Y_ between 0 and
_numOnus_ - 1.  This interface has an IP address of _172.(18 + X).Y.10_, an outer VLAN of 222 + _X_,
and an inner VLAN of 111 + _Y_.  The virtual BNG also runs a DHCP server on each interface serving
addresses in the _172.(18 + X).Y.0/24_ subnet.
