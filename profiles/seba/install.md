# Install SEBA Charts

This page walks through the sequence of Helm operations needed to
bring up the SEBA profile. It assumes the Platform has already been
installed.

## Installing SEBA

In order to run SEBA you need to have the [CORD Platform](../../platform.md) installed.

### SEBA as a whole

To install the SEBA Profile requires two steps.  First, install the
`etcd-operator` chart that is required by [VOLTHA](../../charts.voltha.md):

```shell
helm install -n etcd-operator stable/etcd-operator --version=0.8.0
```

Wait a few seconds for the EtcdCluster CustomResourceDefinitions to
appear in Kubernetes:

```shell
kubectl get crd | grep etcd
```

Once the CRDs are present, install the main `seba` chart:

```shell
helm install -n seba cord/seba --version=1.0.0
```

### SEBA as separate components

The main reason to install the SEBA Profile by installing its standalone
components is if you're developing on it and you need granular control.

There are the components included in the `seba` chart:

- [VOLTHA and etcd-operator](../../charts/voltha.md)
- [seba-services](../../charts/seba-services.md)
- [base-kubernetes](../../charts/base-kubernetes.md)
