# Deploying the M-CORD profile chart

To deploy the M-CORD profile chart:

```shell
helm dep update xos-profiles/mcord
helm install -n mcord xos-profiles/mcord --set proxySshUser=ubuntu
```

The value of `proxySshUser` should be set to the user account corresponding
to the public key added to the node when
[prepping the nodes for VTN](../prereqs/vtn-setup.md).
