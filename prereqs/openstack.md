# OpenStack Integration

CORD leverages ONOS to create virtual networks in OpenStack, and XOS to
create OpenStack objects like networks and VMs.  This section assumes
that an OpenStack cluster has been installed following the instructions
in the [OpenStack Helm](./openstack-helm.md) section. It describes
the steps to deploy and configure CORD's additional components.

## Deploying ONOS and VTN

On each compute node, Open vSwitch must be configured to listen for
remote connections so that it can be controlled by ONOS.  Example:

```bash
PODS=$( kubectl get pod --namespace openstack|grep openvswitch-db|awk '{print $1}' )
for POD in $PODS
do
  kubectl --namespace openstack exec "$POD" \
      -- ovs-appctl -t ovsdb-server ovsdb-server/add-remote ptcp:6641
done
```

The VTN app requires a fabric interface to be up and running on the compute
nodes.  VTN will not successfully initialize if this interface is not
present.  By default the name of this interface is expected to be named
`fabric`.  If you do not have an actual fabric interface on the compute
node, you can create a dummy interface as follows:

```bash
sudo modprobe dummy
sudo ip link set name fabric dev dummy0
sudo ifconfig fabric up
```

VTN also requires the ability to SSH to each compute node using an
account with passwordless `sudo` capability.  Create an SSH keypair on
the master node, and copy it to the `authorized_keys` files of all nodes
in the cluster, including the master node.

1. To generate the key:
```bash
ssh-keygen -t rsa
```
2. To copy the key for user `ubuntu` on `node1.opencord.org`:
```bash
ssh-copy-id ubuntu@node1.opencord.org
```

After the above steps you can [deploy onos-vtn](../charts/onos.md#onos-vtn).

## Deploying XOS

XOS can be configured to manage an existing OpenStack installation
(e.g., deployed using [openstack-helm](./openstack-helm.md)) by
installing the `xos-profiles/base-openstack` Helm chart in the
`helm-charts` repository.

Here is an example of deploying the `xos-profiles/base-openstack` chart
on a single-node OpenStack server set up by the `automation-tools
/openstack-helm/openstack-helm-dev-setup.sh` script:

```bash
helm dep update xos-core
helm upgrade --install xos-core xos-core
helm dep update xos-profiles/base-openstack
helm upgrade --install base-openstack xos-profiles/base-openstack \
    --set computeNodes.master.name=`hostname` \
    --set vtn-service.sshUser=`whoami`
```

If you are deploying on a multi-node OpenStack cluster, create a YAML
file containing information for each node, and pass it as an argument
when installing the `xos-profiles/base-openstack` chart using the `-f`
option.  An example `compute-nodes.yaml` file:

```yaml
computeNodes:
  master:
    name: node0.opencord.org
    bridgeId: of:00000000abcdef01
    dataPlaneIntf: fabric
    dataPlaneIp: 10.6.1.1/24
  node1:
    name: node1.opencord.org
    bridgeId: of:00000000abcdef02
    dataPlaneIntf: fabric
    dataPlaneIp: 10.6.1.2/24
  node2:
    name: node2.opencord.org
    bridgeId: of:00000000abcdef03
    dataPlaneIntf: fabric
    dataPlaneIp: 10.6.1.3/24
```

The master node in the cluster should be called `master`; the other
node labels can be anything.  For each node:

* `name` is the OpenStack hypervisor name of the node (often the FQDN)
* `bridgeId` is `of:` followed by a unique 16-digit hex string
* `dataPlaneIntf` is the name of the fabric interface on the node.  This could be a bridge or a bond interface.
* `dataPlaneIp` is the node's IP address and subnet mask on the fabric subnet

When installing the `xos-profiles/base-openstack` chart it is also
necessary to set the value of `vtn-service.sshUser` to the user account
for which the public key was added to `authorized_keys` earlier.

## Validating the ONOS and XOS Install

After the above steps you should have a functional OpenStack
installation that can be controlled via XOS.  Before creating any VMs,
check to see that VTN has initialized the nodes correctly.  On the
master node run:

```
# password: rocks
ssh -p 8101 onos@onos-cord-ssh.default.svc.cluster.local cordvtn-nodes
```

You should see the nodes in `COMPLETE` state.

## Next Steps

At this point you are ready to [install M-CORD](../profiles/mcord/install.md).