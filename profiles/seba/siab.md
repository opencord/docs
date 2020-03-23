# SEBA-in-a-Box

This document describes how to set up SEBA-in-a-Box (SiaB).  SiaB is a
functional SEBA pod capable of running E2E tests. It takes about 10 minutes
to install on a physical server or VM.

Two configuration for deploying SiaB are available: default or SD-BNG.

The default configuration of SiaB incorporates an emulated OLT/ONU
provided by Ponsim and an emulated AGG switch provided by Mininet.
Mininet is also configured with a host that stands in as the BNG and
runs a DHCP server. The Ponsim setup installs a single OLT, ONU, and RG.
The RG is able to authenticate itself via 802.1x, run dhclient to get an
IP address from the DHCP server in Mininet, and finally ping the BNG.
This demonstrates end-to-end connectivity between the RG and BNG via the
ONU, OLT, and agg switch.

[This page](siab-with-fabric-switch.md) describes how to set up the default SiaB
configuration with a physical switch instead of an emulated Mininet topology.
An external server running DHCP services connected to the switch acts as the BNG.

The configuration of SiaB with SD-BNG, instead, incorporates an emulated OLT/ONU
provided by Ponsim as in the default configuration. This configuration incorporates
also an emulated Stratum BMv2 ASG (Aggregation and Service Gateway)
switch provided by Mininet. Mininet is also configured with two hosts that act as the upstream
router and the PPPoE server. The Ponsim setup installs a single OLT, ONU, and RG.
The RG is able to authenticate itself and retrieve an IP address via PPPoE protocols
instead of 802.1x and DHCP as in the default configuration. This demonstrates
end-to-end connectivity between the RG, the SD-BNG and the upstream router
via the ONU, OLT, and ASG switch. With this configuration, the ASG do not only
forward traffic, but it also implements the user plane BNG functionalities
(such as accounting, routing, and subscriber tunnel terminations - PPPoE, QinQ -).
This configuration deploys a disaggregated and embedded BNG. The BNG is separated
between control and user plane.
[Here](https://docs.google.com/document/d/1v5Dp-a3s183_1SKxMXcnpBPFWiJBHfGK5p7DNy7uPr0)
you can find more information about the SD-BNG design.
The user plane is offloaded to the aggregation switch, while the control plane
is implemented as an ONOS application with an external PPPoE server
(as described in the "BNG-c relay" option in the above mentioned document).
Note that SiaB with SD-BNG configuration is still in an experimentation stage.

## Quick start

A Makefile can be used to install SEBA-in-a-Box in an automated manner on an Ubuntu 16.04 system.

```bash
mkdir -p ~/cord
cd ~/cord
git clone https://gerrit.opencord.org/automation-tools
cd automation-tools/seba-in-a-box
```

The Makefile provides 3 different targets for deploying the different versions of
SiaB with the released service version (specified in the Helm charts), namely:

- `stable`: to deploy standard SiaB with the default configuration
  (Ponsim and Open vSwitch as AGG switch);

- `stratum-stable`: to deploy standard SiaB with Stratum BMv2 switch as the
  AGG switch (instead of Open vSwitch);

- `sdbng-stable`: to deploy SiaB with SD-BNG; Stratum BMv2 switch is used as the
  ASG switch and the BNG is disaggregated and embedded in the fabric.

The Makefile provides also 3 different targets for deploying the different versions of
SiaB with the latest development code), namely:

- `latest`
- `stratum-latest`
- `sdbng-latest`

*NOTE that `stratum-*` and `sdbng-*` targets are experimental.*

### Quick start: Build SiaB using released charts

To build a SiaB that uses the released service versions specified in the Helm charts:

```bash
make [stable|stratum-stable|sdbng-stable] [NUM_OLTS=n] [NUM_ONUS_PER_OLT=m]
```

> NOTE that `make` or `make stable` are the same and will install SEBA with the
> container versions that are defined in the helm charts.
> If you want to install SEBA 2.0 please use: `make siab-2.0-alpha1`

You can specify the number of OLTs (up to 4) and number of ONUs per OLT (up to 4) that you want to
create.

After a successful install, you will see the message:

```text
SEBA-in-a-Box installation finished!
```

If the install fails for some reason, you can re-run the make command and the install will try to resume where it left off.

You can optionally install the logging and nem-monitoring charts during the installation by passing one or both of them (space delimited) via the INFRA\_CHARTS variable.  E.g.:

```bash
make INFRA_CHARTS='logging nem-monitoring' stable
```

To test basic SEBA functionality with the default configuration of SiaB
(`stable` and `stratum-stable` targets), you can run:

```bash
make run-tests
```

Note that the tests currently assume a single OLT/ONU, so some tests will
likely fail if you have configured multiple OLTs and ONUs.
Note also that the SD-BNG configuration currently does not support tests,
thus `run-tests` target does not work with the `sdbng-stable` target.

### Quick start: Build SiaB using latest development code

To build a SiaB that uses the latest development code:

```bash
make [latest|stratum-latest|sdbng-latest] [NUM_OLTS=n] [NUM_ONUS_PER_OLT=m]
```
You can specify the number of OLTs (up to 4) and number of ONUs per OLT (up to 4) that you want to
create.

After a successful install, you will see the message:

```text
SEBA-in-a-Box installation finished!
```

If the install fails for some reason, you can re-run the make command and the install will try to resume where it left off.

To test basic SEBA functionality with the default configuration of SiaB using
the development code (`latest` and `stratum-latest` targets), you can run:

```bash
make run-tests-latest
```

Note that the tests currently assume a single OLT/ONU, so some tests will
likely fail if you have configured multiple OLTs and ONUs.
Note also that the SD-BNG configuration currently does not support tests,
thus `run-tests` target does not work with the `sdbng-latest` target.

## Installation procedure

The rest of this page describes a manual method for installing SEBA-in-a-Box.
It also provides an overview of what is installed by each chart.

Note that this section is equivalent to install SiaB with the `stable` target.
If you want to install the `stratum-*` or `sdbng-*` targets you should modify
the helm commands to set the values as described in the values file available in the `helm-charts` repository.
For reference, take a look at
[seba-ponsim-stratum.yaml](https://github.com/opencord/helm-charts/blob/master/configs/seba-ponsim-stratum.yaml) and
[seba-ponsim-sdbng.yaml](https://github.com/opencord/helm-charts/blob/master/configs/seba-ponsim-sdbng.yaml) files.

### Prerequisites

Before installing SiaB, you need a Kubernetes cluster (can be a single
node) with the Calico CNI plugin installed.  You also need Helm and a
few other software packages.

The server or VM on which you are installing SEBA-in-a-Box should have
at least two CPU cores, 8GB RAM, and 30GB disk space.

#### Kubernetes

You need to have Kubernetes with CNI enabled.  An easy way to set up a
single-node Kubernetes that meets the requirements is with kubeadm.
Instructions for installing kubeadm on various platforms can be found
[here](https://www.google.com/url?q=https://kubernetes.io/docs/setup/independent/install-kubeadm/&sa=D&ust=1542238113244000).

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

#### Calico CNI Plugin

Install the Calico CNI plugin in Kubernetes:

```bash
kubectl apply -f \
  https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f \
  https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
```

#### Helm

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

#### Cordctl

Install the `cordctl` command line tool:

```bash
export CORDCTL_VERSION=1.1.2
export CORDCTL_PLATFORM=linux-amd64
curl -L -o /tmp/cordctl "https://github.com/opencord/cordctl/releases/download/$CORDCTL_VERSION/cordctl-$CORDCTL_PLATFORM"
sudo mv /tmp/cordctl /usr/local/bin/cordctl
sudo chmod a+x /usr/local/bin/cordctl
mkdir -p ~/.cord
printf "server: 127.0.0.1:30011\nusername: admin@opencord.org\npassword: letmein\ngrpc:\n  timeout: 10s\n" > ~/.cord/config
```

### Other prerequisites

Install the `http` and `jq` commands.  Run: `sudo apt install -y httpie jq`

### Get the Helm charts

Before we can start installing SEBA components, we need to get the charts.

```bash
mkdir -p cord
cd cord
git clone https://gerrit.opencord.org/helm-charts
```

### Install Kafka and ONOS

Run these commands:

```bash
cd ~/cord/helm-charts
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm install -n cord-kafka --version=0.13.3 -f examples/kafka-single.yaml incubator/kafka
# Wait for Kafka to come up
kubectl wait pod/cord-kafka-0 --for condition=Ready --timeout=180s
helm install -n onos onos
```

You should see the following pods running:

```bash
$ kubectl get pod
NAME                     READY   STATUS    RESTARTS   AGE
cord-kafka-0             1/1     Running   1          14h
cord-kafka-zookeeper-0   1/1     Running   0          14h
onos-558445d9bc-c2cd5    2/2     Running   0          14h
```

### Install VOLTHA charts

Run these commands to install VOLTHA:

```bash
cd ~/cord/helm-charts
# Install the etcd-operator helm chart:
helm install -n etcd-operator stable/etcd-operator --version 0.8.3
# Allow etcd-operator enough time to create the EtdcCluster
# CustomResourceDefinitions. This should only be a couple of seconds after the
# etcd-operator pods are running. Wait for the CRD to be ready by running the following:
until kubectl get crd | grep etcdclusters; \
do \
    echo 'Waiting for etcdclusters CRD to be available'; \
    sleep 5; \
done
# After EtcdCluster CRD is in place
helm dep up voltha
helm install -n voltha voltha  --set etcd-cluster.clusterSize=1
```

**Before proceeding**

Run: `kubectl get pod -l app=etcd`

You should see the etcd-cluster pod up and running.

```bash
$ kubectl get pod -l app=etcd
NAME                      READY   STATUS    RESTARTS   AGE
etcd-cluster-jcjk2x97w6   1/1     Running   0          14h
```

You should see the VOLTHA pods created:

```bash
$ kubectl get pod -n voltha
NAME                                        READY   STATUS    RESTARTS   AGE
default-http-backend-798fb4f44c-fb696       1/1     Running   0          14h
freeradius-754bc76b5-22lcm                  1/1     Running   0          14h
netconf-66b767bddc-hbsgr                    1/1     Running   0          14h
nginx-ingress-controller-5fc7b87c86-bd55x   1/1     Running   0          14h
ofagent-556cd6c978-lknd4                    1/1     Running   0          14h
vcli-67c996f87d-vw4pk                       1/1     Running   0          14h
vcore-0                                     1/1     Running   0          14h
voltha-6f8d7bf7b-4gkkj                      1/1     Running   1          14h
```


### Install Ponsim charts

Run these commands to install Ponsim (after installing VOLTHA):

```bash
cd ~/cord/helm-charts
NUM_OLTS=1          # can be between 1 and 4
NUM_ONUS_PER_OLT=1  # can be between 1 and 4
helm install -n ponnet ponnet --set numOlts=$NUM_OLTS --set numOnus=$NUM_ONUS_PER_OLT
# Wait for CNI changes
~/cord/helm-charts/scripts/wait_for_pods.sh kube-system
helm install -n ponsimv2 ponsimv2 --set numOlts=$NUM_OLTS --set numOnus=$NUM_ONUS_PER_OLT
# Iptables setup
sudo iptables -P FORWARD ACCEPT
```

Setting `numOlts` and `numOnus` is optional; the default is 1.

**Before proceeding**

Run: `kubectl -n voltha get pod -l app=ponsim`


```bash
$ kubectl -n voltha get pod -l app=ponsim
NAME                      READY   STATUS    RESTARTS   AGE
olt0-f4744dc5-xdrjb       1/1     Running   0          15h
onu0-0-6bf67bf6c6-76gn7   1/1     Running   0          15h
rg0-0-7b9d5cdb5c-jc8p5    1/1     Running   0          14h
```

Make sure that all of the pods in the voltha namespace are in Running state.
If you see the `olt0` pod in CrashLoopBackOff state, try deleting (`helm delete --purge`) and reinstalling the ponsimv2 chart.

If you install more than one OLT/ONU then you will see more containers above.  The naming convention:
```
1st OLT - olt0-xxx
2nd OLT - olt1-xxx
1st ONU attached to 1st OLT - onu0-0-xx (onu<olt>-<onu>)
2nd ONU attached to 1st OLT - onu0-1-xx
1st ONU attached to 2nd OLT - onu1-0-xx
2nd ONU attached to 2nd OLT - onu1-1-xx
RG follows the same naming logic as ONU (rg0-0-xx, rg0-1-xx, rg1-0-xx, rg1-1-xx)
Linux bridges interconnecting ONU and RG follow the same naming logic as ONU (pon0.0, pon0.1 ...)
Linux bridges interconnecting OLT and Mininet follow same naming logic as OLT (nni0, nni1, ...)
```

Run `http GET http://127.0.0.1:30125/health|jq '.state'`.  It should return `"HEALTHY"`:

```bash
$ http GET http://127.0.0.1:30125/health|jq '.state'
"HEALTHY"
```

### Install Logging and Monitoring charts (optional)

This step installs Kibana for log aggregation and querying, and Prometheus/Grafana for graphing SEBA metrics.
They are not necessary for the correct operation of SEBA so this step can be skipped if desired.
[This page](../../operating_cord/diag.md) goes into more detail on these components.

To install logging and monitoring services:
```bash
cd ~/cord/helm-charts
helm dep update nem-monitoring
helm install -n nem-monitoring nem-monitoring
helm dep update logging
helm install -n logging logging -f examples/logging-single.yaml
```

**Before proceeding**

Run: `kubectl get pod`

You should see all the pods in Running state.  To wait until this occurs you can run:

```bash
~/cord/helm-charts/scripts/wait_for_pods.sh
```

### Install NEM charts

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

Run: `kubectl get pod`

You should see all the NEM pods in Running state, except a number of `*-tosca-loader` pods which should eventually be in Completed state.  
To wait until this occurs you can run:

```bash
~/cord/helm-charts/scripts/wait_for_pods.sh
```

### Load TOSCA into NEM

Run these commands:

```bash
helm install -n ponsim-pod xos-profiles/ponsim-pod --set numOlts=$NUM_OLTS --set numOnus=$NUM_ONUS_PER_OLT
~/cord/helm-charts/scripts/wait_for_pods.sh
```

The TOSCA creates a subscriber for each RG `rg<olt>-<onu>` with S-tag of `222+<olt>` and C-tag of `111+<onu>`.

**Before proceeding**

Log into the XOS GUI at `http://<hostname>:30001` (credentials: admin@opencord.org / letmein).  You should see an AttWorkflowDriver Service Instance with authentication state AWAITING.  To check this from the command line:

```bash
cordctl model list AttWorkflowDriverServiceInstance -f "authentication_state=AWAITING"
```

This will show only the AttWorkflowDriver Service Instances in AWAITING state.  Wait until you see a line for each ONU:

```bash
$ cordctl model list AttWorkflowDriverServiceInstance -f "authentication_state=AWAITING"
ID    NAME    OF_DPID                OWNER_ID    SERIAL_NUMBER    STATUS_MESSAGE                                      UNI_PORT_ID
56            of:0000d0d3e158fede    2           PSMO00000000     ONU has been validated - Awaiting Authentication    128
```

### Install Mininet

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
helm install -n mininet mininet --set numOlts=$NUM_OLTS --set numOnus=$NUM_ONUS_PER_OLT
~/cord/helm-charts/scripts/wait_for_pods.sh
```

> Note: After Mininet is running, `kubectl attach -ti deployment.apps/mininet` will take you to the `mininet>` prompt.
> To detach press Ctrl-P Ctrl-Q.

**Before proceeding**

Run: `brctl show`

You should see two interfaces on the `ponX.Y` and `nniX` Linux bridges.

```bash
$ brctl show
bridge name     bridge id               STP enabled     interfaces
docker0         8000.02429d07b4e2       no
pon0.0          8000.bec4912b1f6a       no              veth25c1f40b
                                                        veth2a4c914f
nni0            8000.0a580a170001       no              veth3cc603fe
                                                        vethb6820963
```

You will see more bridges if you've configured multiple OLTs and ONUs.  All of the `nniX` Linux bridges connect to the agg switch in Mininet on different ports.

### Enable pon bridges to forward EAPOL packets

This is necessary to enable the RG to authenticate:

```bash
echo 8 > /tmp/group_fwd_mask
for BRIDGE in /sys/class/net/pon*; \
do \
    sudo cp /tmp/group_fwd_mask $BRIDGE/bridge/group_fwd_mask; \
done
```

### ONOS customizations

It’s necessary to install some custom configuration to ONOS directly.  Run this command:

```bash
http -a karaf:karaf POST \
    http://127.0.0.1:30120/onos/v1/configuration/org.opencord.olt.impl.Olt defaultVlan=65535
```

The above command instructs the ONU to exchange untagged packets with the RG, rather than packets tagged with VLAN 0.

At this point the system should be fully installed and functional.

## Validating the install (w/o SD-BNG)

This section explains how to validate the install when installing the standard
configuration of SiaB (i.e., `stable`, `stratum-stable` targets).
If you installed the SD-BNG configuration go to the section [Validating the install with the SD-BNG](#Validating-the-install-with-the-SD-BNG).

### Authenticate the RG

Enter the RG pod in the voltha namespace:

```bash
RG_POD=$( kubectl -n voltha get pod | grep rg0-0 | awk '{print $1}' )
kubectl -n voltha exec -ti $RG_POD bash
```

If you built SiaB with multiple OLTs and ONUs, you can choose any RG to authenticate.
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

In the XOS GUI, the AttDriverWorkflow Service Instance should now be in APPROVED state.  You can check for this on the command line by running:

```bash
cordctl model list AttWorkflowDriverServiceInstance -f "authentication_state=APPROVED"
```

It should return output like this:

```bash
$ cordctl model list AttWorkflowDriverServiceInstance -f "authentication_state=APPROVED"
ID    NAME    OF_DPID                OWNER_ID    SERIAL_NUMBER    STATUS_MESSAGE                                       UNI_PORT_ID
56            of:0000d0d3e158fede    2           PSMO00000000     ONU has been validated - Authentication succeeded    128
```

The FabricCrossconnect Service Instance should have a check in the Backend status column in the GUI.  You can check for this on the command line by running:

```bash
cordctl model list FabricCrossconnectServiceInstance -f 'backend_status=OK'
```

Wait until it returns output like this:

```bash
$ cordctl model list FabricCrossconnectServiceInstance -f 'backend_status=OK'
ID    NAME    OWNER_ID    S_TAG    SOURCE_PORT    SWITCH_DATAPATH_ID
59            4           222      2              of:0000000000000001
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

`rg<olt>-<onu>` will get an IP address on subnet `172.18+<olt>.<onu>.0/24`.  Make sure that eth0 inside the RG container has an IP address on the proper subnet:

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

`rg<olt>-<onu>` pings `172.18+<olt>.<onu>.10` as its BNG.

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

## Validating the install with the SD-BNG

If you deployed SiaB with SD-BNG you can follow this process to validate the install.
This case is different because in this validation process PPPoE protocol is used
for authentication and IP address assignment (instead of 802.1x and DHCP as in
the standard configuration).

### PPPoE RG authentication and IP address assignment

Enter the RG pod in the voltha namespace:

```bash
RG_POD=$( kubectl -n voltha get pod | grep rg0-0 | awk '{print $1}' )
kubectl -n voltha exec -ti $RG_POD bash
```

If you built SiaB with multiple OLTs and ONUs, you can choose any RG to authenticate.
Inside the pod, run this command:

```bash
pon seba
```
You won't see any output, but you can verify that the process has been completed successfully.
Running `ifconfig` you should see an output similar to the following:

```bash
$ ifconfig
eth0      Link encap:Ethernet  HWaddr de:c3:66:8d:0c:7d
          inet addr:10.22.0.193  Bcast:0.0.0.0  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:610 errors:0 dropped:403 overruns:0 frame:0
          TX packets:211 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:71489 (71.4 KB)  TX bytes:6400 (6.4 KB)
...
ppp0      Link encap:Point-to-Point Protocol
          inet addr:10.255.255.100  P-t-P:10.255.255.1  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1492  Metric:1
          RX packets:3 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3
          RX bytes:30 (30.0 B)  TX bytes:30 (30.0 B)
```

The `ppp0` interface is the interface that terminates the PPPoE tunnel on the RG.
The IP address assigned to the `ppp0` interface is the IP assigned by the
PPPoE server. You should receive an IP in the subnet 10.255.255.0/24.
The assignment of IP addresses is managed by the PPPoE server running as host
in the Mininet topology.

**Before proceeding**

In the XOS GUI, the DtDriverWorkflow Service Instance should track all the state changes.
You can check for this on the command line by running:

```bash
cordctl model list DtWorkflowDriverServiceInstance -f "authentication_state=APPROVED"
```

It should return output like this:

```bash
$ cordctl model list DtWorkflowDriverServiceInstance -f "authentication_state=APPROVED"
ID    NAME    OF_DPID                OWNER_ID    SERIAL_NUMBER    STATUS_MESSAGE                                  UNI_PORT_ID
60            of:0000d0d3e158fede    2           PSMO00000000     ONU has been validated - IP address assigned    128
```

In ONOS, the BNG app should contain the authenticated attachment.
To check the BNG app state, SSH into ONOS (Password=rocks):

```bash
ssh -q -p 30115 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null onos@127.0.0.1
```

and then check the registered attachment list in the BNG app by running:

```bash
bng:attachments
```

It should return an output like the following:

```bash
onos@root > bng:attachments
Registered attachments (size: 1):
{PSMO00000000/111/222/of:0000d0d3e158fede/128/DE:C3:66:8D:0C:7D=PppoeBngAttachment{
appId=DefaultApplicationId{id=197, name=org.opencord.bng}, sTag=222, cTag=111,
macAddress=DE:C3:66:8D:0C:7D, ipAddress=10.255.255.100, lineActivated=true,
oltConnectPoint=of:0000d0d3e158fede/128, onuSerial=PSMO00000000, qinqTpid=0, pppoeSessionId=1}}
```
The MAC address should correspond to the MAC address of the `eth0` interface of the RG,
while the IP address should correspond to the one assigned to the `ppp0` interface in the RG pod.

### Ping the emulated upstream router

Ping the address `10.10.10.1` to ping the emulated upstream router that is running in Mininet.

```bash
$ ping -c 3 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=63 time=30.3 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=63 time=27.0 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=63 time=21.5 ms

--- 10.10.10.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 21.583/26.333/30.320/3.609 ms
```
The traffic leaves the RG via the `ppp0` interface as encapsulated in a PPPoE header
and reaches the upstream router as standard IP traffic.
The PPPoE tunnel termination is performed entirely in the data plane by the ASG switch.

Currently it’s not possible to send traffic to destinations on the Internet.

### PPPoE RG close PPPoE connection

Finally, run:
```bash
poff seba
```
This command will close the PPPoE connection sending a termination request to the PPPoE server.

## Restarting SEBA-in-a-Box after a reboot

After a reboot of a server running SiaB, some services (such as etcd) will likely come up in
a broken state.  The easiest thing to do in this situation is to teardown SiaB using
`make reset-kubeadm` and then rebuild it.

## Uninstall SEBA-in-a-Box

If you're done with your testing, or want to change the version you are installing,
the easiest way to remove a SiaB installation is to use the `make reset-kubeadm` target.

## Getting help

Report any problems to `acb` on the CORD Slack channel.
Report any problems related to Stratum or SD-BNG to `Daniele` or `carmelo` on the CORD Slack channel.
