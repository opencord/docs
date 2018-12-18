# Base Kubernets

This chart contains all the XOS services that interacts with Kubernetes.

You can install it using:

```bash
helm dep update xos-profiles/base-kubernetes
helm install -n base-kubernetes xos-profiles/base-kubernetes/
```