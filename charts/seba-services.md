# SEBA Services

This chart contains all the XOS services needed to install SEBA.

You can install it using:

```bash
helm dep update xos-profiles/seba-services
helm install -n seba-service xos-profiles/seba-services/
```