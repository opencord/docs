# VTN Setup

The ONOS VTN app provides virtual networking between VMs on an OpenStack cluster.  Prior to installing the [base-openstack](../charts/base-openstack.md) chart that installs and configures VTN, make sure that the following requirements are satisfied.

## SSH access to hosts

VTN requires the ability to SSH to each compute node _using an account with
passwordless `sudo` capability_.  Before installing this chart, first create
an SSH keypair and copy it to the `authorized_keys` files of all nodes in the
cluster:

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

## Fabric interface

The VTN app requires a fabric interface on the compute nodes.  VTN will not
successfully initialize if this interface is not present. By default the name
of this interface is expected to be `fabric`.

### Interface not named 'fabric'

If you have a fabric interface on the compute node but it is not named
`fabric`, create a bridge named `fabric` and add the interface to it.
Assuming the fabric interface is named `eth2`:

```shell
sudo brctl addbr fabric
sudo brctl addif fabric eth2
sudo ifconfig fabric up
sudo ifconfig eth2 up
```

To make this configuration persistent, add the following to
`/etc/network/interfaces`:

```text
auto fabric
iface fabric inet manual
  bridge_ports eth2
```

### Dummy interface

If there is not an actual fabric
interface on the compute node, create a dummy interface as follows:

```shell
sudo modprobe dummy
sudo ip link set name fabric dev dummy0
sudo ifconfig fabric up
```

## DNS setup

In order to be added to the VTN configuration, each compute node must
be resolvable in DNS.  If a server's hostname is not resolvable, it can be
added to the local `kube-dns` server (substitute _HOSTNAME_ with the output of
the `hostname` command, and _HOST-IP-ADDRESS_ with the node's primary IP
address):

```shell
cat <<EOF > /tmp/HOSTNAME-dns.yaml
kind: Service
apiVersion: v1
metadata:
  name: HOSTNAME
  namespace: default
spec:
  type: ExternalName
  externalName: HOST-IP-ADDRESS
EOF
kubectl create -f /tmp/HOSTNAME-dns.yaml
```
