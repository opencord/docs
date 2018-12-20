# Install SEBA Charts

This page walks through the sequence of Helm operations needed to
bring up the SEBA profile. It assumes the Platform has already been
installed.

## Installing SEBA

In order to run SEBA you need to have the [CORD Platform](../../platform.md) installed.

### SEBA as a whole

To install the SEBA Profile you can use the corresponding chart:

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
