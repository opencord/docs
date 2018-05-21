# Kubernetes

A generic CORD installation can run on any version of Kubernetes (>=1.9) and Helm.

Internet is full of different releases of Kubernetes, as of resources that can help to get you going.
If on one side it may sound confusing, the good news is that you’re not alone!

Pointing you to a specific version of Kubernetes wouldn’t probably make much sense, since each Kubernetes version may be specific to different deployment needs.
Anyway, we think it’s good to point you to some well known releases, that can be used for different types of deployments.

Following paragraphs provide guidelines, pointers and automated scripts to let you quickly install both Kubernetes and Helm.

Whatever version of Kubernetes you’ve installed, a client tool called “kubectl” is usually needed to interact with your Kubernetes installation. To install kubectl on your development machine, follow this guide: <https://kubernetes.io/docs/tasks/tools/install-kubectl/>.

Once Kubernetes is installed, you should have a KubeConfig configuration file containing all details of your deployment (address of the machine(s), credentials, ...). The file can be used to access your Kubernetes deployment from either Kubectl or Helm. Here is how:

export KUBECONFIG=/path/to/your/kubeconfig/file

You can also permanently export this environment variable, so you don’t have to export it each time you open a new window in your terminal. More info on this topic can be found here: <https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/>.

To test if the installation and the configuration steps were successful, type:

```shell
kubectl get pods
```

Kubernetes should reply to your request, and don’t output any error.

More on Kubernetes and Kubectl commands can be found on the official Kubernetes website, <https://kubernetes.io/docs/tutorials/>.

