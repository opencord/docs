# Multi-Node Kubernetes

A multi-node Kubernetes installation is recommended for
production deployments and and larger trials.

Kubespray is a popular tool for deploying Kubernetes on multiple nodes:

* **Kubespray**
    * Documentation: <https://github.com/kubernetes-incubator/kubespray>
    * Minimum requirements:
        * At least three machines (more info on hardware requirements on the Kubernetes website)

For simplicity, CORD provides some easy-to-use automation scripts to
quickly setup Kubespray on an arbitrary number of target machines.
This is meant only for *lab trials* and *demo use*.

## Requirements

* **Operator machine** (1x, either physical or virtual machine)
    * Has Git installed
    * Has Python3 installed (<https://www.python.org/downloads/>)
    * Has Stable version of Ansible installed (<http://docs.ansible.com/ansible/latest/intro_installation.html>)
    * Is able to reach the target servers (ssh into them)
* **Target machines** (at least 3x, either physical or virtual machines)
    * Run Ubuntu 16.04 server
    * Able to communicate together (ping one each other)
    * Have the same user *cord* configured, that you can use to remotely access them from the operator machine
    * The user *cord* is sudoer on each machine, and it doesn't need a password to get sudoer privileges

## Download the Kubespray Installation Scripts

On the operator machine
```shell
git clone https://gerrit.opencord.org/automation-tools
```

Inside this directory, you will find a folder called *kubespray-installer*;
the following assumes you are running commands in this directory

The main script (*setup.sh*) provides a help message with
instructions. To see it, run *./setup.sh --help*.

The two main functions are:

* Install Kubespray on an arbitrary number of target machines
* Export the k8s configuration file path as environment variable to
   let the user access a specific deployment

## Install Kubespray

The following example assumes that

* Remote machines have the following IP addresses:
    * 10.90.0.101
    * 10.90.0.102
    * 10.90.0.103

* The deployment/POD has been given the arbitrary name *onf*

The installation procedure goes through the following steps (in this order):

* Cleans up any old Kubespray installation folder (may be there from previous installations)
* Clones the official Kubespray installation repository
* Copies the public key of the operator machine, over to each target machine
* Installs required software and configures the target machines as prescribed in the Kubespray guide
* Deploys Kubespray
* Downloads and exports the access configuration outside the Kubespray folder, so it won’t be removed at the next execution of the script (for example while trying to re-deploy the POD, or while deploying a different POD)

To run the installation script, type
```shell
./setup.sh -i onf 10.90.0.101 10.90.0.102 10.90.0.103
```

At the beginning of the installation you will be asked to insert your
password multiple times.

At the end of the procedure, Kubespray should be installed and running
on the remote machines.

The configuration file to access the POD will be saved in the
sub-directory *configs/onf.conf*.

If you want to deploy another POD without affecting your existing
deployment run the following:
```shell
./setup.sh -i my_other_deployment 192.168.0.1 192.168.0.2 192.168.0.3
```

Your *onf.conf* configuration will be always there, and your
new *my_other_deployment.conf* file as well!

## Access the Kubespray Deployment

Kubectl and helm (see [here](kubernetes.md) for more details) need to
be pointed to a specific cluster before being used. This is done
through standard KUBECONFIG files.

The script also helps you to automatically export the path pointing to
an existing KUBECONFIG file, previously generated during the installation.

To do so, for example against the onf pod just deployed, simply type

```shell
source setup.sh -s onf
```

At this point, you can start to use *kubectl*  and *helm*.

## Done?

Once you are done, you are ready to install Kubctl and Helm, so return to 
[here](kubernetes.md#get-your-kubeconfig-file) in the installation
guide.

