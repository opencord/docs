# Helm

The following assumes that _Kubernetes_ has already been installed and _kubectl_ can access the POD. CORD uses helm to deploy containers on Kubernetes, and as such, it should be installed before trying to deploy any CORD container.

Helm documentation can be found at [https://docs.helm.sh/](https://docs.helm.sh/). It consists of two components:

* `helm`: The helm client is basically a CLI utility.
* `tiller`: The server side component, which executes client commands on the Kubernetes cluster.

Helm can be installed on any device that is able to reach the Kubernetes POD \(i.e. the developer laptop, another server in the network\). Tiller should be installed on the Kubernetes cluster itself.

> **Note:** if you've installed Minikube you'll likely need to install _socat_ as well before proceeding, otherwise errors will be thrown. For example, on Ubuntu do _sudo apt-get install socat_.

## Install Helm Client

Follow the instructions at [https://github.com/kubernetes/helm/blob/master/docs/install.md\#installing-the-helm-client](https://github.com/kubernetes/helm/blob/master/docs/install.md#installing-the-helm-client)

## Install Tiller

Enter the following commands from any device thsat is already able to access the Kubernetes cluster.

```text
helm init
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
helm init --service-account tiller --upgrade
```

Once _helm_ and _tiller_ are installed you should be able to run the command _helm ls_ without errors.

## Next Step

Once you are done, you are ready to deploy CORD components using their helm charts! Start by brining up the [CORD Platform](../../platform.md). For more detailed information, see the [Helm Reference](../../../../references/helm/).

