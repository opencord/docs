# Multi-Node

A multi-node Kubernetes installation is recommended for production deployments and and larger trials.

Kubespray is a popular tool for deploying Kubernetes on multiple nodes:

* **Kubespray**
  * Documentation: [https://github.com/kubernetes-incubator/kubespray](https://github.com/kubernetes-incubator/kubespray)
  * Minimum requirements:
    * At least three machines \(more info on hardware requirements on the Kubernetes website\)

For simplicity, CORD provides some easy-to-use automation scripts to quickly setup Kubespray on an arbitrary number of target machines. This is meant only for _lab trials_ and _demo use_.

## Requirements

* **Operator/Developer Machine** \(1x, either physical or virtual machine\)
  * Has the following software installed:
    * Git
    * Python 2 with `virtualenv` installed \(used for setting up ansible and modules to run the kubespray playbooks\)
    * Python 3 \(for running the kubespray inventory script\)
  * Is able to reach the target servers \(ssh into them\)
* **Target/Cluster Machines** \(at least 3x, either physical or virtual machines\)
  * Run Ubuntu 16.04 server
  * Able to communicate together \(ping one each other\)
  * Have the same user _cord_ configured, that you can use to remotely access them from the operator machine
  * A user \(i.e. _cord_\) is sudoer on each machine, and it doesn't need a password to get sudoer privileges \(see to authorize a password-less access from the development/management machine in the sections below\)

## Download the Kubespray Installation Scripts

On the operator machine

```text
git clone https://gerrit.opencord.org/automation-tools
```

Inside this directory, you will find a folder called _kubespray-installer_; the following assumes you are running commands in this directory

The main script \(_setup.sh_\) provides a help message with instructions. To see it, run _./setup.sh --help_.

The main functions are:

* Install Kubespray on an arbitrary number of target machines
* Export the k8s configuration file path as environment variable to

   let the user access a specific deployment

## Prepare for the Kubespray installation

Before starting the installation make sure that

* The development/management machine has password-less access to the target machine\(s\), meaning the public key of the development/management machine has been copied in the authorization\_keys files on the target machines. If you don't know how to do a script called _copy-ssh-keys.sh_ is provided. To copy your public key to a target machine run _./copy-ssh-keys.sh TARGET\_MACHINE\_IP_. Repeat this procedure for each target machine.
* All target machines don't mount any swap partition. The setup script should do this automatically, but many times this doesn't work as it should. Doing this manually is easy as installing Ubuntu without a swap partition or -once the OS is already installed- commenting out the corresponding line in _/etc/fstab_ and reboot.
* By default the installation script assumes that the user on all the target machines is _cord_. If this is not the case an environment variable should be exported: _export REMOTE\_SSH\_USER='my-remote-user'_.

## Install Kubespray

The following example assumes that

* Remote machines have the following IP addresses:
  * 10.90.0.101
  * 10.90.0.102
  * 10.90.0.103
* The deployment/POD has been given the arbitrary name _onf_

The installation procedure goes through the following steps \(in this order\):

* Cleans up any old Kubespray installation folder \(may be there from previous installations\)
* Clones the official Kubespray installation repository
* Installs required software and configures the target machines as prescribed in the Kubespray guide
* Deploys Kubespray
* Downloads and exports the access configuration outside the Kubespray folder, so it won’t be removed at the next execution of the script \(for example while trying to re-deploy the POD, or while deploying a different POD\)

To run the installation script, type

```text
./setup.sh -i onf 10.90.0.101 10.90.0.102 10.90.0.103
```

> **NOTE:** at the beginning of the installation you will be asked to insert your password multiple times. **NOTE:** the official Kubespray installation script will automatically change the hostname of the target machine\(s\) with nodeX \(where X is an incremental number starting from 1\).

At the end of the procedure, Kubespray should be installed and running on the remote machines.

The configuration file to access the POD will be saved in the sub-directory _inventories/onf/artifacts/admin.conf_.

If you want to deploy another POD without affecting your existing deployment run the following:

```text
./setup.sh -i my_other_deployment 192.168.0.1 192.168.0.2 192.168.0.3
```

Your _onf.conf_ configuration will be always there, and your new _my\_other\_deployment.conf_ file as well!

## Access the Kubespray Deployment

Kubectl and helm \(see [here](./) for more details\) need to be pointed to a specific cluster before being used. This is done through standard KUBECONFIG files.

The script also helps you to automatically export the path pointing to an existing KUBECONFIG file, previously generated during the installation.

To do so, for example against the onf pod just deployed, simply type

```text
source setup.sh -s onf
```

At this point, you can start to use _kubectl_ and _helm_.

## Next Step

Once you are done, you are ready to install Kubctl and Helm, so return to [here](./#get-your-kubeconfig-file) in the installation guide.

