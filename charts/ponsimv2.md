# PONSIM v2 Helm Chart

The `ponsimv2` chart deploys the PON Simulator (PONSIM) containers (a virtual OLT, ONU, and RG) in the context of VOLTHA.
This chart is used by [SiaB](../profiles/seba/siab.md).
More details about PONSIM can be found in [its README](https://github.com/opencord/voltha/blob/master/ponsim/v2/README.md).

You must install the [PONNET](ponnet.md) chart before installing this one.
At that point you can install PONSIM.

{% include "../partials/helm/add-cord-repo.md" %}

To install:

```shell
helm install -n ponsimv2 cord/ponsimv2 --version 1.2.1 \
    --set numOlts=1 \
    --set numOnus=1
```

Arguments _numOlts_ and _numOnus_ can be set between 1 and 4.

After a successful install you will see containers like these running in the
VOLTHA namespace:

```bash
$ kubectl -n voltha get pod -l app=ponsim
NAME                      READY   STATUS    RESTARTS   AGE
olt0-fb58fb79f-26g46      1/1     Running   0          22h
onu0-0-5db946744d-bh5ms   1/1     Running   0          22h
rg0-0-69cdbf6b58-dx6lm    1/1     Running   0          21h
```

If any of the containers do not come up successfully, the issue is likely
that the [PONNET](ponnet.md) chart is not loaded or was not able to create
the necessary Linux bridges.
