# Install SEBA Charts

This page walks through the sequence of Helm operations needed to
bring up the SEBA profile. It assumes the Platform has already been
installed.

## Installing SEBA

In order to run SEBA you need to have the [CORD Platform](../../platform.md) installed.

Specifically, wait for the EtcdCluster CustomResourceDefinitions to
appear in Kubernetes:

```shell
kubectl get crd | grep etcd
```

Once the CRDs are present, proceed with the `seba` chart installation.

### SEBA as a whole

{% include "../../partials/helm/add-cord-repo.md" %}

Then, proceed with the SEBA chart installation:

```shell
helm install -n seba cord/seba --version=1.0.0
```

### SEBA as separate components

The main reason to install the SEBA Profile by installing its standalone
components is if you're developing on it and you need granular control.

These are the components included in the `seba` chart:

- [VOLTHA and etcd-operator](../../charts/voltha.md)
- [seba-services](../../charts/seba-services.md)
- [base-kubernetes](../../charts/base-kubernetes.md)
