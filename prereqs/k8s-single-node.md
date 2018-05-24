# Install Minikube on a single node

Usually single-node Kubernetes installation are suggested for development, testing, and small lab-trial deployments.

## Kubernetes single-node well-known releases

* **Minikube**
    * Documentation: <https://kubernetes.io/docs/getting-started-guides/minikube/>
    * Minimum requirements:
        * One machine, either a physical machine or a VM. It could also be your own PC! It installs natively also on macOS.
* **Mikrok8s**
    * Documentation: <https://microk8s.io/>
    * One machine, Linux based, either physical machine or virtual. It could also be your own PC!

## Minikube installation walkthrough

Install Minikube is so easy that there's no need for us to provide additional custom scripts. What we can do instead, is to point you to the official Minikube installation guide:

### Install Minikube directly on the Linux OS (no VM support)

**Suggested if you want to install Minikube on a Linux machine, either that this is a physical machine or a VM you created (even runing on your laptop)**

Instructions avaialble at <https://github.com/kubernetes/minikube#linux-continuous-integration-without-vm-support>

### Standard Minikube installation (VM support)

**Suggested if you want to run Minikube directly on your Windows or macOS system**

Instructions available at <https://kubernetes.io/docs/getting-started-guides/minikube/#installation>

## Done?

Are you done? You're ready to install kubectl and helm. Instructions [here](kubernetes.md#get-your-kubeconfig-file).
