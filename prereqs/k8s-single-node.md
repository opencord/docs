# Single-Node Kubernetes

We suggest a single-node Kubernetes installation for most development,
testing, and small lab-trial deployments.

There are two popular single-node versions of Kubernetes.

* **Minikube**
    * Documentation: <https://kubernetes.io/docs/getting-started-guides/minikube/>
    * Minimum requirements:
        * One machine, either a physical machine or a VM. It could also be your own PC! It installs natively also on macOS.
* **Mikrok8s**
    * Documentation: <https://microk8s.io/>
    * One machine, Linux based, either physical machine or virtual. It could also be your own PC!

We recommend Minikube, which is easy to set up and use. The following
comments on two considerations:

* If you want to install Minikube on a Linux machine (either a
  physical machine or a VM on your laptop or in the cloud), you will
  need to follow the instructions at <https://github.com/kubernetes/minikube#linux-continuous-integration-without-vm-support>.

* If you want to run Minikube directly on your Windows or MacOS
  system, you will need to follow the instructions at
  <https://kubernetes.io/docs/getting-started-guides/minikube/#installation>.

## Done?

Once you are done, you are ready to install Kubctl and Helm, so return to 
[here](kubernetes.md#get-your-kubeconfig-file) in the installation guide.
