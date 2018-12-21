# SEBA Services

This chart contains all the XOS services needed to install SEBA.

{% include "../partials/helm/add-cord-repo.md" %}

You can then install it using:

```bash
helm install -n seba-service cord/seba-services
```
