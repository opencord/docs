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

Second, the VTN app requires a fabric interface on the compute nodes.  VTN will not successfully initialize if this interface is not present. By default the name of this interface is expected to be named `fabric`. If there is not an actual fabric interface on the compute node, create a dummy interface as follows:

```shell
sudo modprobe dummy
sudo ip link set name fabric dev dummy0
sudo ifconfig fabric up
```

Finally, in order to be added to the VTN configuration, each compute node must
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
