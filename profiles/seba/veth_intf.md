# Attach Container to a NIC

Sometimes you may need to attach some container's virtual network
interface to the NIC of the machine hosting it, for example, to run
some data plane traffic through the container.

Although CORD doesn't fully support this natively, there are some
(hackish) ways to do this manually.

## Create a bridge and a veth

The easiest way to do this is to skip Kubernetes and directly attach
the Docker container link it to the host network interface through a
Virtual Ethernet Interface Pair (veth pair).

Let's see how.

Let's assume you're running a three node Kubernetes deployment, and
that you're trying to attach a container *already deployed* called
*vcore-5b4c5478f-lxrpb* to a physical interface *eth1* (already
existing on one of the three hosts, running your container). The
virtual interface inside the container will be called *eth2*.

You get the name of the container by running:

```shell
$ kubectl get pods [-n NAMESPACE]
NAME                      READY     STATUS    RESTARTS   AGE
vcore-5b4c5478f-lxrpb     1/1       Running   1          7d
```

To find out on which of the three nodes the container has been
deployed on, type:

```shell
$ kubectl describe pod  vcore-5b4c5478f-lxrpb | grep Node
Node:           node3/10.90.0.103
Node-Selectors:  <none>
```

As you can see from the first line, the container has been deployed by
Kubernetes on the Docker daemon running on node 3 (this is just an
example), in this case, with IP *10.90.0.103*.

Next, SSH into the node and look for the specific Docker container ID:

```shell
$ container_id=$(sudo docker ps | grep vcore-5b4c5478f-lxrpb | head -n 1 | awk '{print $1}')
85fed7deea7b
```

The interface on the hosting machine should be turned off first

```shell
sudo ip link set eth1 down
```

Create a veth called *veth0* and add to it the new virtual interface *eth2*:

```shell
sudo ip link add veth0 type veth peer name eth2
```

Now add the virtual network interface *eth2* to the container namespace:

```shell
sudo ip link set eth2 netns ${container_id}
```

Bring up the virtual interface:

```shell
sudo ip netns exec ${container_id} ip link set eth2 up
```

Bring up *veth0*:

```shell
sudo ip link set veth0 up
```

Create a bridge named *br1*, and add *veth0* to it and the host
interface *eth1*:

```shell
sudo ip link add br1 type bridge
sudo ip link set veth0 master br1
sudo ip link set eth1 master br1

```

Bring up again the host interface and the bridge:

```shell
sudo ip link set eth1 up
sudo ip link set br1 up
```

At this point, you should see an additional interface *eth2* inside
the container:

```shell
$ kubectl exec -it vcore-5b4c5478f-lxrpb /bin/bash
$ ip link show
$ node3:~$ ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether c4:54:44:8f:b7:74 brd ff:ff:ff:ff:ff:ff
3: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether d6:84:33:2f:8c:92 brd ff:ff:ff:ff:ff:ff
```

## Cleanup (remove bridge and veth)

To delete the connection and bring the system back to the original
state, execute the following:

```shell
ip link set veth0 down
ip link delete veth0
ip netns exec ${container_id} ip link set eth2 down
ip netns exec ${container_id} ip link delete eth2
ip link set eth1 down
ip link set br1 down
brctl delbr br1
ip link set eth1 up
```
