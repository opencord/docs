# Helm Installation guide

The paragraph assumes that *Kubernetes* has already been installed and *kubectl* can access the pod.

CORD uses helm to deploy containers on Kubernetes. As such helm should be installed before trying to deploy any CORD container.

Helm documentation can be found at <https://docs.helm.sh/>

## What is helm?

{% include "/partials/helm/description.md" %}

## Install helm (and tiller)

Helm is made of two components:

* the helm client, most times also called simply helm: the client component, basically the CLI utility
* tiller: the server side component, interpreting the client commands and executing tasks on the Kubernetes pod

Helm can be installed on any device able to reach the Kubernetes POD (i.e. the developer laptop, another server in the network). Tiller should be installed on the Kubernetes pod itself, through the kubectl CLI.

### Install helm client

Follow the instructions at <https://docs.helm.sh/using_helm/#installing-helm>

### Install tiller

To install tiller type the following commands from any device already able to access the Kubernetes pod.

```shell
helm init
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
helm init --service-account tiller --upgrade
```

Once *helm* and *tiller* are installed you should be able to run the command *helm ls* without errors.

## Done?

You're ready to deploy CORD components through helm charts! [Install CORD](../profiles/intro.md).

The CORD helm charts reference guide can be found [here](../charts/helm.md).
