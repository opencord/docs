# Deploy Base OpenStack

XOS can be configured to manage an existing OpenStack installation
(e.g., deployed using [openstack-helm](../prereqs/openstack-helm.md)) by
installing the `xos-profiles/base-openstack` Helm chart in the
`helm-charts` repository.  This chart requires that the
[xos-core](xos-core.md) chart has already been installed.

## System Prerequisites for VTN

This chart causes XOS to load the VTN app into ONOS and configure it.
Prior to installing the chart, make sure that VTN's requirements are
satisfied by following [this guide](../prereqs/vtn-setup.md)

## Single-Node Configuration

Here is an example of deploying the `xos-profiles/base-openstack` chart
on a single-node OpenStack server set up by the
`automation-tools/openstack-helm/openstack-helm-dev-setup.sh` script:

```bash
helm dep update xos-profiles/base-openstack
helm install -n base-openstack xos-profiles/base-openstack \
    --set computeNodes.master.name=`hostname` \
    --set vtn-service.sshUser=`whoami`
```

## Multi-Node Configuration

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
