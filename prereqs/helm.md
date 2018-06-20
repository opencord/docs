# Helm

{% include "/partials/helm/description.md" %}

The following assumes that *Kubernetes* has already been installed
and *kubectl* can access the POD. CORD uses helm to deploy containers
on Kubernetes, and as such, it should be installed before trying to
deploy any CORD container.

Helm documentation can be found at <https://docs.helm.sh/>. It consists
of two components:

* `helm`: The helm client is basically a CLI utility.
* `tiller`: The server side component, which executes client commands on the Kubernetes cluster.

Helm can be installed on any device that is able to reach the
Kubernetes POD (i.e. the developer laptop, another server in the
network). Tiller should be installed on the Kubernetes cluster itself.

> **Note:** if you've installed Minikube you'll likely need to install *socat* as well before proceeding, otherwise errors will be thrown. For example, on Ubuntu do *sudo apt-get install socat*.

## Install Helm Client

Follow the instructions at <https://github.com/kubernetes/helm/blob/master/docs/install.md#installing-the-helm-client>

## Install Tiller

Enter the following commands from any device thsat is already
able to access the Kubernetes cluster.

```shell
helm init
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
helm init --service-account tiller --upgrade
```

Once *helm* and *tiller* are installed you should be able to run the
command *helm ls* without errors.

## Next Step

Once you are done, you are ready to deploy CORD components using their
helm charts! See [Bringing Up CORD](../profiles/intro.md). For more detailed
information, see the [helm chart reference guide](../charts/helm.md).
