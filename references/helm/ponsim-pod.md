# PONSIM Pod

This chart just loads TOSCA for adding a PONSIM OLT and Mininet AGG Switch to XOS. It is used by [SiaB](../intro/seba/install/siab-overview/siab.md).

You can then install it using:

```text
helm install -n ponsim-pod cord/ponsim-pod \
    --set numOlts=1 \
    --set numOnus=1
```

Arguments _numOlts_ and _numOnus_ can be set between 1 and 4.

