# Deploy M-CORD Profile

{% include "../partials/helm/add-cord-repo.md" %}

Then, to deploy the M-CORD profile, run the following:

```shell
helm install -n mcord cord/mcord --set proxySshUser=ubuntu
```

The value of *proxySshUser* should be set to the user account corresponding
to the public key added to the node when [prepping the nodes for VTN](../prereqs/vtn-setup.md).
