# Base Kubernets

This chart contains all the XOS services that interacts with Kubernetes.

{% include "../partials/helm/add-cord-repo.md" %}

You can then install it using:

```shell
helm install -n base-kubernetes cord/base-kubernetes
```
