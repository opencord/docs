# Prerequisites

This page will introduce the pre-installation before installing OMEC, which includes:   

* Installing OS;  
* Nodes Configuration;  
* SCTP Setup;  
* SR-IOV Setup;
* Install Kubernetes;
* Install CORD and COMAC;
* Fabric Configuration.

The introduction is based on multi-cluster: Edge and Central. If you want to install single cluster, you can ignore the central part.  

## Install OS on All Nodes 

COMAC supports both Ubuntu 16.04 or Ubuntu 18.04. You can select any of them.


## Config All Nodes

* **Configure cluster node names**
    
  COMAC will install kubernets on the first node. So on edge 1 and central 1, add other node name and IP addresses to "/etc/hosts" file:
  
  ```shell
  127.0.0.1 localhost localhost.localdomain
  192.168.170.3 edge1
  192.168.170.4 edge2
  192.168.170.5 edge3
  ```
  ```shell
  192.168.171.3 central1
  192.168.171.4 central2
  192.168.171.5 central3
  ```
  If you just want to run a single cluster, you only need to config the edge cluster.
  

* **IP address configuration**
  
  After installing OS to nodes, we need to config the two NICs on each node. As described in the hardware requirements section, each nodes should have 2 NICs and the 1G NIC is for management network and 10G NIC is for user dataplane traffic.  
  
  For example, if the 1G inerface for management network is: 10.90.0.0/16, the 10G interface for fabric is 119.0.0.0/24. Then we can config the cluster like this:
 
  Edge1:
 
  ```shell   
  auto eth0
  iface eth0 inet static  
  address 192.168.170.3 
  netmask 255.255.0.0 
  gateway 10.90.0.1
 
  auto eth2  
  iface eth2 inet static
  address 119.0.0.101
  netmask 255.255.255.0
  ```

  Edge2:

  ```shell   
  auto eth0
  iface eth0 inet static  
  address 192.168.170.4 
  netmask 255.255.0.0 
  gateway 10.90.0.1
 
  auto eth2  
  iface eth2 inet static
  address 119.0.0.102
  netmask 255.255.255.0
  ```

  Edge3:
 
  ```shell   
  auto eth0
  iface eth0 inet static  
  address 192.168.170.5
  netmask 255.255.0.0 
  gateway 10.90.0.1

  auto eth2  
  iface eth2 inet static
  address 119.0.0.103
  netmask 255.255.255.0
  ```

  If you want to run multi-cluster, you can config the second cluster in the same way.  


* **SSH Key Configuration** 
   
  COMAC uses kubespray to insalll the kubernetes cluster. The Ansible tool inside kubespray needs to ssh into each node and execute the playbook. So we need to setup ssh login with key instead of password for each node.
  
  Login Edge1, run the following commands:
  
  ```shell
  cord@edge1:~$ ssh-keygen
  cord@edge1:~$ ssh-copy-id localhost
  cord@edge1:~$ ssh-copy-id edge2
  cord@edge1:~$ ssh-copy-id edge3
  ```
  
  Then ssh into each node, make sure the ssh key works without password.
 
* **Clone repos** 
  
  On Edge1:
  
  ```shell
  cord@edge1:~$ git clone https://github.com/kubernetes-incubator/kubespray.git -b release-2.11
  cord@edge1:~$ git clone https://gerrit.opencord.org/automation-tools
  cord@edge1:~$ git clone https://gerrit.opencord.org/pod-configs
  cord@edge1:~$ git clone https://gerrit.opencord.org/helm-charts
  ```

## SCTP Setup

   The protocol for S1-MME interface is SCTP, but SCTP is not loaded by ubuntu OS by default. So we need to setup SCTP on all nodes:

  ```shell
$sudo modprobe nf_conntrack_proto_sctp
$echo ‘nf_conntrack_proto_sctp’ >> /etc/modules
  ```
  
  You can verify whether he sctp module is loaded by command:
  
  ```shell
$sudo lsmod | grep sctp
  ```

## SR-IOV Setup

   In this release, we pre-setup the SR-IOV support on the nodes which will run SPGWU and CDN containers. Also with COMAC, you can specify which node to run the SPGWU and which node to run CDN container. By default, COMAC run SPGWU on edge3 and CDN on edge2. 
   
   The name of 10G interface on each node is eth2.
   
   COMAC use “*VFIO driver*” for userspace APP with DPDK for SPGWU. Run the following command on the node where you want to run SPGWU container on edge3:  

  ```shell
cord@edge3:~$ git clone https://gerrit.opencord.org/automation-tools
cord@edge3:~$ sudo automation-tools/comac/scripts/node-setup.sh eth2
  ```
  You can verify it with command:
  
  ```shell
cord@edge3:~$ ip link show
  ```
  
  COMAC use “*Netdevice driver*” for CDN. Run the following command on the node where you want to run CDN container on edge2:
    
  ```shell
cord@edge2:~$ sudo su
cord@edge2:/home/cord# echo '8' > /sys/class/net/eth2/device/sriov_numvfs
  ```
 You can verify it with command:
  
  ```shell
cord@edge2:/home/cord# ip link show
  ```

## Install Kubernetes 

You can refer to the [Kubernetes page](https://guide.opencord.org/prereqs/kubernetes.html) for installation. In this section, we only describe the COMAC specific work.

You can specify which node to run the OMEC control plane and which node to run the OMEC data plane in 
"*kubespray/inventory/comac/hosts.ini*".   

For example, on central cluster, you can specify:

```shell
[omec-cp]
central1
central2

[omec-cp:vars]
node_labels={"omec-cp":"enabled"}
```

On edge cluster, you can specify:

```shell
[omec-dp]
edge3

[omec-dp:vars]
node_labels={"omec-dp":"enabled"}
```

## Install CORD and COMAC

* **Install CORD** 

```shell
cord@edge1:~$ helm init --wait --client-only
cord@edge1:~$ helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
cord@edge1:~$ helm repo add cord https://charts.opencord.org
cord@edge1:~$ helm repo update
cord@edge1:~$ helm install -n cord-platform cord/cord-platform --version 7.0.0 -f automation-tools/comac/sample/omec-override-values-multi.yaml
```

* **Install COMAC** 

```shell
cord@edge1:~$ helm install -n comac-platform --version 0.0.6 cord/comac-platform --set mcord-setup.enabled=false --set etcd-cluster.enabled=false 
```
## Fabric Configuration
  
You can refer to [Trellis Underlay Fabric](https://wiki.opencord.org/display/CORD/) for more info on how to config the fabric. 

  You can modify the exmpale file "mcord-local-cluster-fabric-accelleran.yaml" according to your netowrk, and insert fabric configuration with command:
  
  ```shell
$ cd pod-configs/tosca-configs/mcord
curl -H "xos-username: admin@opencord.org" -H "xos-password: letmein" -X POST --data-binary @mcord-local-cluster-fabric-accelleran.yaml http://192.168.87.151:30007/run

  ```



