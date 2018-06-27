# Local Persistent Volume Helm chart

## Introduction

The `local-persistent-volume` helm chart is a utility helm chart. It was
created mainly to persist the `xos-core` DB data but this helm can be used
to persist any data.

It uses a relatively new kubernetes feature (it's a beta feature
in Kubernetes 1.10.x) that allows us to define an independent persistent
store in a kubernetes cluster.

The helm chart mainly consists of the following kubernetes resources:

- A storage class resource representing a local persistent volume
- A persistent volume resource associated with the storage class and a specific directory on a specific node
- A persistent volume claim resource that claims certain portion of the persistent volume on behalf of a pod

The following variables are configurable in the helm chart:

- `storageClassName`: The name of the storage class resource
- `persistentVolumeName`: The name of the persistent volume resource
- `pvClaimName`: The name of the persistent volume claim resource
- `volumeHostName`: The name of the kubernetes node on which the data will be persisted
- `hostLocalPath`: The directory or volume mount path on the chosen chosen node where data will be persisted
- `pvStorageCapacity`: The capacity of the volume available to the persistent volume resource (e.g. 10Gi)

Note: For this helm chart to work, the volume mount path or directory specified in the `hostLocalPath` variable needs to exist before the helm chart is deployed.

## Standard Install

```shell
helm install -n local-store local-persistent-volume
```

## Standard Uninstall

```shell
helm delete --purge local-store
```
