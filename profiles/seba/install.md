# Install SEBA Charts

This page walks through the sequence of Helm operations needed to
bring up the SEBA profile. It assumes the Platform has already been
installed.

## Installing SEBA

In order to run SEBA you need to have the [CORD Platform](../../platform.md) installed.

Specifically, wait for the three EtcdCluster CustomResourceDefinitions to
appear in Kubernetes:

```shell
kubectl get crd | grep etcd | wc -l
```

Once the CRDs are present, proceed with the `seba` chart installation.

### SEBA as a whole

{% include "../../partials/helm/add-cord-repo.md" %}

Then, proceed with the SEBA chart installation:

```shell
helm install -n seba cord/seba --version=1.0.0
```

### Alternatively, install SEBA as separate components

The main reason to install the SEBA Profile by installing its standalone
components is if you're developing on it and you need granular control.

These are the components included in the `seba` chart:

- [VOLTHA and etcd-operator](../../charts/voltha.md)
- [seba-services](../../charts/seba-services.md)
- [base-kubernetes](../../charts/base-kubernetes.md)

## Verify your installation and next steps

Once the installation completes, monitor your setup using `kubectl get pods`.
Wait until all pods are in *Running* state and “tosca-loader” pods are in *Completed* state.

>**Note:** Your pods may periodically transition into *error* state. This is expected. They will retry and eventually get to the desired state.
>**Note:** Depending on the profile you're installing, you may need to check also different namespaces (for example, check the voltha namespace if you're installing SEBA with `kubectl get pods -n voltha`)

You're now ready to install the desired workflow. At the moment SEBA supports the AT&T workflow only. Please, continue to the [AT&T workflow section](workflows/att-install.md).
