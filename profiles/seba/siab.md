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

### Quick start: Build SiaB using released charts

To build a SiaB that uses the released service versions specified in the Helm charts:

```bash
make    # or 'make stable'
```

> NOTE that `make` or `make stable` will install SEBA with the container versions that are
> defined in the helm charts. If you want to install SEBA 1.0 please use: `make siab-1.0`

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

### Quick start: Build SiaB using latest development code

To build a SiaB that uses the latest development code:

```bash
make latest [NUM_OLTS=n] [NUM_ONUS_PER_OLT=m]
```

With the `latest` target, you can specify the number of OLTs (up to 4) and number of ONUs per OLT that you want to
create.  Each OLT associates with "m" number of ONUs.  If you specify more than one OLT you will see several OLT/ONU/RG containers when you run `kubectl -n voltha get pod`:

Naming convention:
```
1st OLT - olt0-xxx
2nd OLT - olt1-xxx
1st ONU attached to 1st OLT - onu0-0-xx (onu<olt>-<onu>)
2nd ONU attached to 1st OLT - onu0-1-xx
1st ONU attached to 2nd OLT - onu1-0-xx
2nd ONU attached to 2nd OLT - onu1-1-xx
RG also follows the same naming logic as ONU (rg0-0-xx, rg0-1-xx, rg1-0-xx, rg1-1-xx)
linux bridges interconnecting ONU and RG also follows the same naming logic as ONU (pon0.0, pon0.1 ..)
```

```bash
$ kubectl -n voltha get pod
NAME                                        READY   STATUS    RESTARTS   AGE
voltha        olt0-774f9cb5f7-9mwwg           1/1     Running     0          33m
voltha        olt1-5f7c44f554-n47mv           1/1     Running     0          33m
voltha        onu0-0-5768c4567c-tc2rt         1/1     Running     0          33m
voltha        onu0-1-859c87ccd9-sr9fq         1/1     Running     0          33m
voltha        onu1-0-6c58d9957f-6bbk4         1/1     Running     0          33m
voltha        onu1-1-8555c74487-6fzwb         1/1     Running     0          33m
voltha        rg0-0-77fcd5d6bc-55cxt          1/1     Running     0          33m
voltha        rg0-1-57cdc6956f-xm2gp          1/1     Running     0          33m
voltha        rg1-0-7d6689bd85-tgjcp          1/1     Running     0          33m
voltha        rg1-1-54994485c5-swnd2          1/1     Running     0          33m
```

Likewise `brctl show` will output:

```bash
$ brctl show
bridge name bridge id           STP enabled   interfaces
docker0         8000.02427dd2bfc4       no              veth0fbf0dd
nni0            8000.76030be9e97b       no              veth3c7ade40
                                                        vethc01838f1
nni1            8000.ae08243d745e       no              vethe0df415e
                                                        vetheef40c90
pon0.0          8000.2aa5060d44b7       no              vethaa880e65
                                                        vethae9c7b9d
pon0.1          8000.3602b50c2521       no              veth32a2f3d2
                                                        veth971b571b
pon1.0          8000.7efc437e91e4       no              veth1ea11fe3
                                                        veth51cbc451
pon1.1          8000.e2423416a798       no              veth3323ad21
                                                        veth3718d925
```

Above there are four separate datapath chains:
```
rg0-0 -> pon0.0 -> onu0-0 -> olt0 -> nni0
rg0-1 -> pon0.1 -> onu0-1 -> olt0 -> nni0
rg1-0 -> pon1.0 -> onu1-0 -> olt1 -> nni1
rg1-1 -> pon1.1 -> onu1-1 -> olt1 -> nni1
```
All of the `nniX` bridges connect to the agg switch in Mininet on different ports.
 
A subscriber is created for each RG `rg<olt>-<onu>` with S-tag of `222+<olt>` and C-tag of `111+<onu>`.
After `rg<olt>-<onu>` is authenticated, it will get an IP address on subnet `172.18+<olt>.<onu>.0/24` and ping
`172.18+<olt>.<onu>.10` as its BNG.

After a successful install, you will see the message:

```text
SEBA-in-a-Box installation finished!
```

If the install fails for some reason, you can re-run the make command and the install will try to resume where it left off.

To test basic SEBA functionality using the development code, you can run:

```bash
make run-tests-latest
```

Note that the tests currently assume a single OLT, so some tests will likely fail if you have configured multiple OLTs.

## Installation procedure

The rest of this page describes a manual method for installing SEBA-in-a-Box.

### Prerequisites

Before installing SiaB, you need a Kubernetes cluster (can be a single
node) with the Calico CNI plugin installed.  You also need Helm and a
few other software packages.

The server or VM on which you are installing SEBA-in-a-Box should have
at least two CPU cores, 8GB RAM, and 30GB disk space.

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
sudo apt-get install -y "docker-ce=17.06*"

echo "Installing kubeadm..."
sudo apt-get update
sudo apt-get install -y ebtables ethtool apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF >/tmp/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo cp /tmp/kubernetes.list /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt install -y "kubeadm=1.12.7-*" "kubelet=1.12.7-*" "kubectl=1.12.7-*"
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
  https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f \
  https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
```

### Helm

An example of installing Helm:

```bash
echo "Installing helm..."
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > install-helm.sh
bash install-helm.sh -v v2.12.1
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```

### Cordctl

Install the `cordctl` command line tool:

```bash
export CORDCTL_VERSION=1.0.0
export CORDCTL_PLATFORM=linux-amd64
curl -L -o /tmp/cordctl "https://github.com/opencord/cordctl/releases/download/$CORDCTL_VERSION/cordctl-$CORDCTL_PLATFORM"
sudo mv /tmp/cordctl /usr/local/bin/cordctl
sudo chmod a+x /usr/local/bin/cordctl
mkdir -p ~/.cord
printf "server: localhost:30011\nusername: admin@opencord.org\npassword: letmein\ngrpc:\n  timeout: 10s\n" > ~/.cord/config
```

### Other prerequisites

Install the `http` and `jq` commands.  Run: `sudo apt install -y httpie jq`

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
etcd-cluster-q9zhrwvllh                                       1/1       Running     0          20m
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
olt0-5455744678-hqbwh                       1/1       Running   0          6h
onu0-5df655b9c9-prfjz                       1/1       Running   0          6h
rg0-75845c54bc-fjgrf                        1/1       Running   0          6h
vcli-6875544cf-rfdrh                        1/1       Running   0          6h
vcore-0                                     1/1       Running   0          6h
voltha-546cb8fd7f-5n9x4                     1/1       Running   3          6h
```

If you see the olt pod in CrashLoopBackOff state, try deleting (`helm delete --purge`) and reinstalling the ponsimv2 chart.

Run `http GET http://127.0.0.1:30125/health|jq '.state'`.  It should return `"HEALTHY"`:

```bash
$ http GET http://127.0.0.1:30125/health|jq '.state'
"HEALTHY"
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

You should see all the NEM pods in Running state, except a number of `*-tosca-loader` pods which should eventually be in Completed state.  
To wait until this occurs you can run:

```bash
~/cord/helm-charts/scripts/wait_for_pods.sh
```

## Load TOSCA into NEM

Run these commands:

```bash
helm install -n ponsim-pod xos-profiles/ponsim-pod
~/cord/helm-charts/scripts/wait_for_pods.sh
```

**Before proceeding**

Log into the XOS GUI at `http://<hostname>:30001` (credentials: admin@opencord.org / letmein).  You should see an AttWorkflowDriver Service Instance with authentication state AWAITING.

To run the check from the command line:

```bash
cordctl model list AttWorkflowDriverServiceInstance -f "authentication_state=AWAITING"
```

This will show only the AttWorkflowDriver Service Instances in AWAITING state.  Wait until you see something like:

```bash
$ cordctl model list AttWorkflowDriverServiceInstance -f "authentication_state=AWAITING"
OWNER_ID    SERIAL_NUMBER    OF_DPID                UNI_PORT_ID    STATUS_MESSAGE                                      ID    NAME
2           PSMO12345678     of:0000aabbccddeeff    128            ONU has been validated - Awaiting Authentication    56
```

## Install Mininet

Ensure that the `openvswitch` kernel module is loaded:

```bash
sudo modprobe openvswitch
```

Wait for the `ofdpa-ovs` switch driver setting to be sync'ed to ONOS:

```bash
cordctl model sync Switch -f 'driver=ofdpa-ovs'
```

Next install the Mininet chart:

```bash
cd ~/cord/helm-charts
helm install -n mininet mininet
~/cord/helm-charts/scripts/wait_for_pods.sh
```

After the Mininet pod is running, you can get to the `mininet>` prompt using:

```bash
kubectl attach -ti deployment.apps/mininet
```

To detach press Ctrl-P Ctrl-Q.

**Before proceeding**

Run: `brctl show`

You should see two interfaces on each of the pon0 and nni0 Linux bridges.

```bash
$ brctl show
bridge name     bridge id               STP enabled     interfaces
docker0         8000.02429d07b4e2       no
pon0            8000.bec4912b1f6a       no              veth25c1f40b
                                                        veth2a4c914f
nni0            8000.0a580a170001       no              veth3cc603fe
                                                        vethb6820963
```

## Enable pon0 to forward EAPOL packets

This is necessary to enable the RG to authenticate.  Run these commands:

```bash
echo 8 > /tmp/pon0_group_fwd_mask
sudo cp /tmp/pon0_group_fwd_mask /sys/class/net/pon0/bridge/group_fwd_mask
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
RG_POD=$( kubectl -n voltha get pod -l "app=rg0" -o jsonpath='{.items[0].metadata.name}' )
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

In the XOS GUI, the AttDriverWorkflow Service Instance should now be in APPROVED state.  
You can check for this on the command line by running:

```bash
cordctl model list AttWorkflowDriverServiceInstance -f "authentication_state=APPROVED"
```

It should return output like this:

```bash
$ cordctl model list AttWorkflowDriverServiceInstance -f "authentication_state=APPROVED"
OF_DPID                UNI_PORT_ID    STATUS_MESSAGE                                       ID    NAME    OWNER_ID    SERIAL_NUMBER
of:0000aabbccddeeff    128            ONU has been validated - Authentication succeeded    56            2           PSMO12345678
```

The FabricCrossconnect Service Instance should have a check in the Backend status column in the GUI.
You can check for this on the command line by running:

```bash
cordctl model list FabricCrossconnectServiceInstance -f 'backend_status=OK'
```

Wait until it returns output like this:

```bash
$ cordctl model list FabricCrossconnectServiceInstance -f 'backend_status=OK'
SWITCH_DATAPATH_ID     SOURCE_PORT    ID    NAME    OWNER_ID    S_TAG
of:0000000000000001    2              59            5           222
```

### Obtain an IP address for the RG

On the host, remove the `dhclient` profile from `apparmor` if present:

```bash
sudo apparmor_parser -R /etc/apparmor.d/sbin.dhclient || true
```

Next run the following commands inside the RG pod.

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

## Restarting SEBA-in-a-Box after a reboot

After a reboot of a server running SiaB, some services (such as etcd) will likely come up in
a broken state.  The easiest thing to do in this situation is to teardown SiaB using
`make reset-kubeadm` and then rebuild it.

## Uninstall SEBA-in-a-Box

If you're done with your testing, or want to change the version you are installing,
the easiest way to remove a SiaB installation is to use the `make reset-kubeadm` target.

## Getting help

Report any problems to `acb` on the CORD Slack channel.
