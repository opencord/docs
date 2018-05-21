# Helm Installation guide
The paragraph assumes you’ve already installed a version of Kubernetes on your system, and that you’re able to access it using Kubectl.

CORD also uses Helm to deploy containers on Kubernetes.

Helm documentation can be found at <https://docs.helm.sh/>

Please, make sure you install Helm on your systems, before proceeding.

## What is helm?

{% include "/partials/helm/description.md" %}

## How to install Helm

Full instructions and basic commands to get started with Helm can be found
at <https://docs.helm.sh/using_helm/#quickstart>

For simplicity here are are few commands that you can use to install `helm` on
your system:

### macOS

```shell
brew install kubernetes-helm
```

### Linux (example using Ubuntu 16.04 and Helm 2.9)

```shell
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
tar -zxvf helm-v2.9.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
```

### Initialize helm and setup Tiller

```shell
helm init
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
helm init --service-account tiller --upgrade
```

Once `helm` is installed you should be able to run the command `helm ls`
without errors

## What is a Helm chart?

Charts are the packaging format used by helm. A chart is a collection of files that describe a related set of Kubernetes resources.

CORD uses charts to define each component. For example:

- [xos-core](../charts/xos-core.md)
- [onos](../charts/onos.md)
- [voltha](../charts/voltha.md)

More info on Helm charts at <https://docs.helm.sh/developing_charts/#charts>
