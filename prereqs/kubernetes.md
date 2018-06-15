# Kubernetes

CORD runs on any version of Kubernetes (1.9 or greater), and uses the
Helm client-side tool. If you are new to Kubernetes, we recommend
<https://kubernetes.io/docs/tutorials/> as a good place to start.

Although you are free to set up Kubernetes and Helm in whatever way makes
sense for your deployment, the following provides guidelines, pointers, and
automated scripts that might be helpful.

## Install Kubernetes

The following sections, [Single Node Cluster](k8s-single-node.md) and [Multi Node Cluster](k8s-multi-node.md), offer pointers and scripts to install your favorite
version of Kubernetes. Start there, then come back here and follow the
steps in the following three subsections.

## Export KUBECONFIG

Once Kubernetes is installed, you should have a KUBECONFIG configuration file containing all the details of your deployment: address of the machine(s),
credentials, and so on. The file can be used to access your Kubernetes deployment
from any client able to communicate with the Kubernetes installation. To manage
the pod, export a KUBECONFIG variable containing the path to the configuration
file:

```shell
export KUBECONFIG=/path/to/your/kubeconfig/file
```

You can also permanently export this environment variable, so you don’t have to
export it every time you open a new window in your terminal. More info on this
topic at
<https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/>.

## Install Kubectl

Again assuming Kubernetes is already installed, the next step is to
install the CLI tools used to interact with it. *kubectl* is the basic tool
you need. It can be installed on any device able to reach the Kubernetes
just installed (i.e., the development laptop, another server, the same machine
where Kubernetes is installed).

To install kubectl, follow this step-by-step guide: <https://kubernetes.io/docs/tasks/tools/install-kubectl/>.

To test the kubectl installation run:

```shell
kubectl get pods
```

Kubernetes should reply to the request showing the pods already deployed.
If you've just installed Kubernetes, likely you won't see any pod, yet.
That's fine, as long as you don't see errors.

