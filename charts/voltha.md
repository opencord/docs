# Deploying VOLTHA

```shell
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
helm dep build
helm install -n voltha voltha
```
