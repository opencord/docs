# VTN Setup

The ONOS VTN app provides virtual networking between VMs on an OpenStack cluster.  Prior to installing the [base-openstack](../charts/base-openstack.md) chart that installs and configures VTN, make sure that the following requirements are satisfied.

First, VTN requires the ability to SSH to each compute node _using an account with passwordless `sudo` capability_.  Before installing this chart, first create an SSH keypair and copy it to the `authorized_keys` files of all nodes in the cluster:

Generate a keypair:

```bash
ssh-keygen -t rsa
```

Copy the public key for user `ubuntu` to `node1.opencord.org` (example):

```shell
ssh-copy-id ubuntu@node1.opencord.org
```

Copy the private key so that the [base-openstack](../charts/base-openstack.md) chart can publish it as a secret:

```shell
cp ~/.ssh/id_rsa xos-profiles/base-openstack/files/node_key
```

The VTN app requires a fabric interface on the compute nodes.  VTN will not successfully initialize if this interface is not present. By default the name of this interface is expected to be named `fabric`. If there is not an actual fabric interface on the compute node, create a dummy interface as follows:

```shell
sudo modprobe dummy
sudo ip link set name fabric dev dummy0
sudo ifconfig fabric up
```

Finally, on each compute node, Open vSwitch must be configured to listen for
remote connections so that it can be controlled by VTN.  Example:

```shell
PODS=$( kubectl get pod --namespace openstack|grep openvswitch-db|awk '{print $1}' )
for POD in $PODS
do
  kubectl --namespace openstack exec "$POD" \
      -- ovs-appctl -t ovsdb-server ovsdb-server/add-remote ptcp:6641
done
```
