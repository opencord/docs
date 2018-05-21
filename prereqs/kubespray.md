# Multi-node Kubernetes

Usually multi-node Kubernetes installation are suggested for production and larger trials.

## Kubernetes, multi-node well-known releases

* Kubespray
    * Documentation: <https://github.com/kubernetes-incubator/kubespray>
    * What is used for: usually, for production deployments
    * Minimum requirements:
        * At least three machines (more info on hardware requirements on the Kubernetes website)

## Kubespray lab-trial installation scripts

For your convenience CORD provides some easy to use automated scripts to quickly install a lab environment in few commands.
The goal of this script is to install Kubespray on a set of (minimum 3) target machines.

At the end of the procedure, Kubespray should be installed.

### Requirements

* At least 4 machines: operator machine (i.e. laptop) + at least 3 target servers
* Operator machine
    * Has Git installed
    * Has Python3 installed (<https://www.python.org/downloads/>)
    * Has Stable version of Ansible installed (<http://docs.ansible.com/ansible/latest/intro_installation.html>)
    * Is able to reach the target servers (ssh into them)
* Target servers
    * Have Ubuntu 16.04 installed 
    * Are able to communicate together (ping one each other)
    * They have the same user *cord* configured, that you can use to remotely access them from the operator machine
    * The user *cord* is sudoer on each machine, and it doesn't need a password to get sudoer access

### More on the Kubespray installation scripts

All scripts are in the kubespray-installer folder just downloaded. From now on the guide assumes you’re running commands from this folder.

The main script (*setup.sh*) provides an helper with instructions. Just run *./setup.sh --help* to see it.

The two main functions are:

* Install Kubespray on an arbitrary number of target machines
* Export the k8s configuration file path as environment variable to let the user access a specific deployment

### Get the Kubespray installation scripts

On the operator machine
```shell
git clone https://gerrit.opencord.org/automation-tools
```

Inside, you will find a folder called *kubespray-installer*

### Install Kubespray

In the following example we assume that

* Remote machines have the following IP addresses:
    * 10.90.0.101
    * 10.90.0.102
    * 10.90.0.103

* The deployment/POD has been given an arbitrary name: onf

The installation procedure goes through the following steps (right in this order):

* Cleans up any old Kubespray folder previously downloaded
* Downloads a new, stable Kubespray installation repository
* Copies the public key of the operator over to each target machine
* Installs required software and configures the target machines as prescribed in the Kubespray guide
* Deploys Kubespray
* Downloads and exports the access configuration outside the Kubespray folder, so it won’t be removed at the next execution of the script (for example while trying to re-deploy the POD, or while deploying a different POD)

To run the installation script, type
```shell
./setup.sh -i onf 10.90.0.101 10.90.0.102 10.90.0.103
```

**NOTE:** the first time you use the script, you will be promped to insert your password multiple times.

At the end of the procedure, Kubespray should be installed and running on the remote machines.

The configuration file to access the POD will be saved in the subfolder *configs/onf.conf*.

Want to deploy another POD without affecting your existing deployment?

Runt the following:
```shell
./setup.sh -i my_other_deployment 192.168.0.1 192.168.0.2 192.168.0.3
```

Your *onf.conf* configuration will be always there, and your new *my_other_deployment.conf* file as well!

### Access the Kubespray deployment

Kubectl and helm need to be pointed to a specific cluster, before being used.

The script helps you also to automatically export the path pointing to an existing Kubespray configuration, previously generated during the installation.

For example, if you want to run *kubectl get nodes* against the *onf* cluster just deployed, you should run:

```shell
source setup.sh -s onf
```

This will automatically run for you

```shell
export FULL_PATH/kubespray-installer/configs/onf.conf
```

As a result, you’ll now be able to successfully run *kubectl get nodes*.
