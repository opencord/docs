# Deploy XOSSH

{% include "../partials/helm/add-cord-repo.md" %}

Then, to deploy the XOS-Shell run the following:

```shell
helm install -n xossh cord/xossh
```
