# Kubernetes

A generic CORD installation can run on any version of Kubernetes (>=1.9) and Helm.

Internet is full of different releases of Kubernetes, as of resources that can help to get you going. If on one side it may sound confusing, the good news is that you’re not alone!

Pointing you to a specific version of Kubernetes wouldn’t probably make much sense, since each Kubernetes version may be specific to different deployment needs. Anyway, we think it’s good to point you to some well known releases, that can be used for different types of deployments.

**New to Kubernetes?** Tutorials are a good place to start. More at <https://kubernetes.io/docs/tutorials/>.

Following paragraphs provide guidelines, pointers and automated scripts to let you quickly install both Kubernetes and Helm.

## Step by step installation

### Install Kubernetes

First, choose what version of Kubernetes you'd like to run. In the following sections of the guide we offer pointers and scripts to get your favorite version of Kubernetes installed. Start from there. Then, come back here and continue over the next paragraphs, below.

### Get your KUBECONFIG file

Once Kubernetes is installed, you should have a KUBECONFIG configuration file containing all the details of your deployment (address of the machine(s), credentials, ...). The file can be used to access your Kubernetes deployment from any client able to communicate with the Kubernetes installation. To manage the pod, export a KUBECONFIG variable containing the path to the configuration file:

```shell
export KUBECONFIG=/path/to/your/kubeconfig/file
```

You can also permanently export this environment variable, so you don’t have to export it every time you open a new window in your terminal. More info on this topic at <https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/>.

### Install kubectl

You've installed Kubernetes. Now it's time to install the CLI tools to interact with it. *kubectl* is the basic tool you need. It can be installed on any device able to reach the Kubernetes just installed (i.e. the development laptop, another server, the same machine where Kubernetes is installed). To install kubectl, follow this guide: <https://kubernetes.io/docs/tasks/tools/install-kubectl/>.

To test the kubectl installation run:

```shell
kubectl get pods
```

Kubernetes should reply to the request showing the pods already deployed. If you've just installed Kubernetes, likely you won't see any pod, yet. That's fine, as long as you don't see errors.

### Install helm

CORD uses a tool called helm to deploy containers on Kubernetes. As such, helm needs to be installed before being able to deploy CORD containers. More info on helm and how to install it can be found [here](helm.md).
