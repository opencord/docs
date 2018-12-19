# PONSIM v2 Helm Chart

The `ponsimv2` chart deploys the PON Simulator (PONSIM) containers
(a virtual OLT, ONU, and RG) in the context of VOLTHA.
This chart is used by [SiaB](../profiles/seba/siab.md).
More details about PONSIM can be found in
[its README](https://github.com/opencord/voltha/blob/master/ponsim/v2/README.md).

You must install the [PONNET](ponnet.md) chart before installing this one.
At that point you can install PONSIM using:

```bash
helm install -n ponsimv2 ponsimv2
```

After a successful install you will see containers like these running in the
VOLTHA namespace:

```bash
$ kubectl -n voltha get pod
NAME                                        READY     STATUS    RESTARTS   AGE
...
olt-77468cfccd-7ltzr                        1/1       Running   0          10m
onu-6d7d5db8f-pk59s                         1/1       Running   0          10m
rg-5fbddf9bdf-b292r                         1/1       Running   0          10m
...
```

If any of the containers do not come up successfully, the issue is likely
that the [PONNET](ponnet.md) chart is not loaded or was not able to create
the two Linux bridges.
