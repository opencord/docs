# SEBA-in-a-Box

This document describes how to set up SEBA-in-a-Box (SiaB).  SiaB is a
functional SEBA pod capable of running E2E tests.  It takes about 10 minutes
to install on a physical server or VM.

The default configuration of SiaB incorporates an emulated OLT/ONU
provided by Ponsim and an emulated AGG switch provided by Mininet.
Mininet is also configured with a host that stands in as the BNG and
runs a DHCP server. The Ponsim setup installs a single OLT, ONU, and RG.
The RG is able to authenticate itself via 802.1x, run dhclient to get an
IP address from the DHCP server in Mininet, and finally ping the BNG.
This demonstrates end-to-end connectivity between the RG and BNG via the
ONU, OLT, and agg switch.

[This page](siab-with-fabric-switch.md) describes how to set up SiaB with a physical switch instead of an emulated Mininet topology. An external server running DHCP services connected to the switch acts as the BNG.

## Quick start

A Makefile can be used to install SEBA-in-a-Box in an automated manner on an Ubuntu 16.04 system:

```bash
mkdir -p ~/cord
cd ~/cord
git clone https://gerrit.opencord.org/automation-tools
cd automation-tools/seba-in-a-box
```

To build a SiaB that uses the released service versions specified in the Helm charts:

```bash
make    # or 'make stable'
```

To build a SiaB that uses the latest development code:

```bash
make latest
```

After a successful install, you will see the message:

```text
SEBA-in-a-Box installation finished!
```

If the install fails for some reason, you can re-run the make command and the install will try to resume where it left off.

You can optionally install the logging and nem-monitoring charts during the installation by passing one or both of them (space delimited) via the INFRA\_CHARTS variable.  E.g.:

```bash
make INFRA_CHARTS='logging nem-monitoring' stable
```

To test basic SEBA functionality, you can run:

```bash
make run-tests
```

## Installation procedure

The rest of this page describes a manual method for installing SEBA-in-a-Box.

### Prerequisites

Before installing SiaB, you need a Kubernetes cluster (can be a single
node) with the Calico CNI plugin installed.  You also need Helm and a
few other software packages.

The server or VM on which you are installing SEBA-in-a-Box should have
at least two CPU cores, 8GB RAM, and 30GB disk space.  *Apparmor and
SELinux should be disabled.*

### Kubernetes

You need to have Kubernetes with CNI enabled.  An easy way to set up a
single-node Kubernetes that meets the requirements is with kubeadm.
Instructions for installing kubeadm on various platforms can be found
[here](https://www.google.com/url?q=https://kubernetes.io/docs/setup/inde
pendent/install-kubeadm/&sa=D&ust=1542238113244000).  

*NOTE: the setup has not been made to work with minikube; we recommend
installing kubeadm instead.*

Here’s an example of installing kubeadm on an Ubuntu 16.04 server:

```bash
echo "Installing docker..."
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 0EBFCD88
sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
sudo apt-get update
sudo apt-get install -y "docker-ce=17.03*"

echo "Installing kubeadm..."
sudo apt-get update
sudo apt-get install -y ebtables ethtool apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF >/tmp/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo cp /tmp/kubernetes.list /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt install -y "kubeadm=1.11.3-*" "kubelet=1.11.3-*" "kubectl=1.11.3-*"
sudo swapoff -a
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

If running on a single node, taint the master node so that we can schedule pods on it:

```bash
kubectl taint nodes --all node-role.kubernetes.io/master-
```

### Calico CNI Plugin

Install the Calico CNI plugin in Kubernetes:

```bash
kubectl apply -f \
  https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
```

### Helm

An example of installing Helm:

```bash
echo "Installing helm..."
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
cat > /tmp/helm.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: helm
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: helm
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: helm
    namespace: kube-system
EOF
kubectl create -f /tmp/helm.yaml
helm init --service-account helm
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```

### Other prerequisites

Install the `http` and `jq` commands.  Run: `sudo apt install -y httpie jq`

## Get the Helm charts

Before we can start installing SEBA components, we need to get the charts.

```bash
mkdir -p cord
cd cord
git clone https://gerrit.opencord.org/helm-charts
```

## Install Kafka and ONOS

Run these commands:

```bash
cd ~/cord/helm-charts
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm install -n cord-kafka --version=0.13.3 -f examples/kafka-single.yaml incubator/kafka
# Wait for Kafka to come up
kubectl wait pod/cord-kafka-0 --for condition=Ready --timeout=180s
helm install -n onos onos
```

## Install VOLTHA charts

Run these commands to install VOLTHA:

```bash
cd ~/cord/helm-charts
# Install the etcd-operator helm chart:
helm install -n etcd-operator stable/etcd-operator --version 0.8.3
# Allow etcd-operator enough time to create the EtdcCluster
# CustomResourceDefinitions. This should only be a couple of seconds after the
# etcd-operator pods are running. Check the CRD are ready by running the following:
kubectl get crd | grep etcd
# After EtcdCluster CRD is in place
helm dep up voltha
helm install -n voltha -f configs/seba-ponsim.yaml voltha
```

**Before proceeding**

Run: `kubectl get pod|grep etcd-cluster`

You should see the etcd-cluster pod up and running.

```bash
$ kubectl get pod|grep etcd-cluster
etcd-cluster-0000                                             1/1       Running     0          20m
```

## Install Ponsim charts

Run these commands to install Ponsim (after installing VOLTHA):

```bash
cd ~/cord/helm-charts
helm install -n ponnet ponnet
# Wait for CNI changes
~/cord/helm-charts/scripts/wait_for_pods.sh kube-system
helm install -n ponsimv2 ponsimv2
# Iptables setup
sudo iptables -P FORWARD ACCEPT
```

**Before proceeding**

Run: `kubectl -n voltha get pod`

Make sure that all of the pods in the voltha namespace are in Running state.

```bash
$ kubectl -n voltha get pod
NAME                                        READY     STATUS    RESTARTS   AGE
default-http-backend-846b65fb5f-rklfb       1/1       Running   0          6h
freeradius-765c9b486c-6qs7t                 1/1       Running   0          6h
netconf-7d7c96c88b-29cv2                    1/1       Running   0          6h
nginx-ingress-controller-6db99757f7-d9cpk   1/1       Running   0          6h
ofagent-7d7b854cd4-fx6gq                    1/1       Running   0          6h
olt-5455744678-hqbwh                        1/1       Running   0          6h
onu-5df655b9c9-prfjz                        1/1       Running   0          6h
rg-75845c54bc-fjgrf                         1/1       Running   0          6h
vcli-6875544cf-rfdrh                        1/1       Running   0          6h
vcore-0                                     1/1       Running   0          6h
voltha-546cb8fd7f-5n9x4                     1/1       Running   3          6h
```

If you see the olt pod in CrashLoopBackOff state, try deleting (`helm delete --purge`) and reinstalling the ponsimv2 chart.

## Install Mininet

Run these commands to install Mininet:

```bash
cd ~/cord/helm-charts
sudo modprobe openvswitch
helm install -n mininet mininet
```

After the Mininet pod is running, you can get to the `mininet>` prompt using:

```bash
kubectl attach -ti deployment.apps/mininet
```

To detach press Ctrl-P Ctrl-Q.

**Before proceeding**

Run: `brctl show`

You should see two interfaces on each of the pon0 and pon1 Linux bridges.

```bash
$ brctl show
bridge name     bridge id               STP enabled     interfaces
docker0         8000.02429d07b4e2       no
pon0            8000.bec4912b1f6a       no              veth25c1f40b
                                                        veth2a4c914f
pon1            8000.0a580a170001       no              veth3cc603fe
                                                        vethb6820963
```

## Enable pon0 to forward EAPOL packets

This is necessary to enable the RG to authenticate.  Run these commands:

```bash
echo 8 > /tmp/pon0_group_fwd_mask
sudo cp /tmp/pon0_group_fwd_mask /sys/class/net/pon0/bridge/group_fwd_mask
```

## Install NEM charts

Run these commands:

```bash
cd ~/cord/helm-charts
helm dep update xos-core
helm install -n xos-core xos-core
helm dep update xos-profiles/seba-services
helm install -n seba-services xos-profiles/seba-services
helm dep update workflows/att-workflow
helm install -n att-workflow workflows/att-workflow -f configs/seba-ponsim.yaml
helm dep update xos-profiles/base-kubernetes
helm install -n base-kubernetes xos-profiles/base-kubernetes
```

**Before proceeding**

Run:  `kubectl get pod`

You should see all the NEM pods in Running state, except a number of `*-tosca-loader` pods which should eventually be in Completed state.  The latter may go through CrashLoopBackOff state and get restarted a few times first (less than 10).  To wait until this occurs you can run:

```bash
~/cord/helm-charts/scripts/wait_for_pods.sh
```

## Load TOSCA into NEM

Run this commands:

```bash
helm install -n ponsim-pod xos-profiles/ponsim-pod
```

**Before proceeding**

Wait for the ponsim-pod container to reach Completed state, then log into the XOS GUI at `http://<hostname>:30001` (credentials: admin@opencord.org / letmein).  You should see an AttWorkflowDriver Service Instance with authentication state AWAITING.

To automatically check for this condition you can run:

```bash
http -a admin@opencord.org:letmein GET \
      http://127.0.0.1:30001/xosapi/v1/att-workflow-driver/attworkflowdriverserviceinstances | \
      jq '.items[0].authentication_state' | grep AWAITING
```

## ONOS customizations

Right now it’s necessary to install some custom configuration to ONOS directly.  Run this command:

```bash
http -a karaf:karaf POST \
    http://127.0.0.1:30120/onos/v1/configuration/org.opencord.olt.impl.Olt defaultVlan=65535
```

The above command instructs the ONU to exchange untagged packets with the RG, rather than packets tagged with VLAN 0.

At this point the system should be fully installed and functional.  

## Validating the install

### Authenticate the RG

Enter the RG pod in the voltha namespace:

```bash
RG_POD=$( kubectl -n voltha get pod -l "app=rg" -o jsonpath='{.items[0].metadata.name}' )
kubectl -n voltha exec -ti $RG_POD bash
```

Inside the pod, run this command:

```bash
wpa_supplicant -i eth0 -Dwired -c /etc/wpa_supplicant/wpa_supplicant.conf
```

You should see output like the following:

```bash
$ wpa_supplicant -i eth0 -Dwired -c /etc/wpa_supplicant/wpa_supplicant.conf
Successfully initialized wpa_supplicant
eth0: Associated with 01:80:c2:00:00:03
WMM AC: Missing IEs
eth0: CTRL-EVENT-EAP-STARTED EAP authentication started
eth0: CTRL-EVENT-EAP-PROPOSED-METHOD vendor=0 method=4
eth0: CTRL-EVENT-EAP-METHOD EAP vendor 0 method 4 (MD5) selected
eth0: CTRL-EVENT-EAP-SUCCESS EAP authentication completed successfully
```

Hit Ctrl-C after this point to get back to the shell prompt.

**Before proceeding**

In the XOS GUI, the AttDriverWorkflow Service Instance should now be in APPROVED state.  You can check for this by running:

```bash
http -a admin@opencord.org:letmein GET \
      http://127.0.0.1:30001/xosapi/v1/att-workflow-driver/attworkflowdriverserviceinstances | \
      jq '.items[0].authentication_state' | grep APPROVED
```

The FabricCrossconnect Service Instance should have a check in the Backend status column.  You can check for this by running:

```bash
http -a admin@opencord.org:letmein GET \
      http://127.0.0.1:30001/xosapi/v1/fabric-crossconnect/fabriccrossconnectserviceinstances | \
      jq '.items[0].backend_status'|grep OK
```

### Obtain an IP address for the RG

Run the following commands inside the RG pod.

```bash
ifconfig eth0 0.0.0.0
dhclient
```

You should see output like the following:

```bash
$ dhclient
mv: cannot move '/etc/resolv.conf.dhclient-new.46' to '/etc/resolv.conf': Device or resource busy
```

You can ignore the Device or resource busy errors.  The issue is that `/etc/resolv.conf` is mounted into the RG container by Kubernetes and dhclient wants to overwrite it.

**Before proceeding**

Make sure that eth0 inside the RG container has an IP address on the 172.18.0.0/24 subnet:

```bash
$ ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 0a:58:0a:16:00:06
          inet addr:172.18.0.54  Bcast:172.18.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:600 errors:0 dropped:559 overruns:0 frame:0
          TX packets:15 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:57517 (57.5 KB)  TX bytes:3042 (3.0 KB)
```

### Ping the emulated BNG

The emulated BNG has an IP address of 172.18.0.10.  After successfully running dhclient you should be able to ping it from the RG.

```bash
$ ping -c 3 172.18.0.10
PING 172.18.0.10 (172.18.0.10) 56(84) bytes of data.
64 bytes from 172.18.0.10: icmp_seq=1 ttl=64 time=34.9 ms
64 bytes from 172.18.0.10: icmp_seq=2 ttl=64 time=39.6 ms
64 bytes from 172.18.0.10: icmp_seq=3 ttl=64 time=37.4 ms

--- 172.18.0.10 ping statistics ---

3 packets transmitted, 3 received, 0% packet loss, time 2002ms

rtt min/avg/max/mdev = 34.940/37.343/39.615/1.917 ms
```

That’s it.  Currently it’s not possible to send traffic to destinations on the Internet.

## Uninstall SEBA-in-a-Box

If you're done with your testing, or want to change the version you are installing,
the easiest way to remove a SiaB installation is to use the `make reset-kubeadm` target.

## Getting help

Report any problems to `acb` on the CORD Slack channel.
