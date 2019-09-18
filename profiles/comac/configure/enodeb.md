# eNodeB Setup

## Supported eNodeBs

COMAC's virtual EPC (OMEC) should work with any standard eNodeB. In this release, we tested the Accelleran E1000 and we will use this commercial enodeb to describe how
to setup it in the COMAC environment.

The Accelleran E1000 is a splitted enodeb, which include a RRU, and 3 containers:
![COMAC connectivity](../images/enodeb.png)

## Connect the RRU to the pod

For physical connectivity, the RRU hardware box has a single 1G Ethernet interface. We need to connect it to the fabric. Since our breakout cable for fabric is 10G, so we connect the RRU to a Layer2 switch (as a converter) and then conenct it to the fabric. The layer2 switch should support both 1G interface and 10G interface.

There are two logical connectivities for the RRU: (1) Control interface
connection, between RRU and BBU for attaching process. (2) S1U interface
connection, between RRU and SPGWU (SGWU+PGWU) for user traffic.  

## RRU configuration

RRU need to talk to RAN-CU containers for 3GPP control plane and SPGWU for 3GPP data plane.

The configuration file on RRU is located at /mnt/app/bootstrap.txt.
find the "redis.hostname" line, and change the IP address value here.

```bash
redis.hostname:<redis IP>
```
where to get the redis IP? (1) in COMAC multicluster setup, you can use any node management IP of the remote cluster since the RAN-CU of RRU is running on remotely cluster; (2) in single cluster case, you use any node management IP in the cluster.


## Configure the VNFs on the pod for the eNodeB

This part will be introduced in the RAN-CU helm charts.


## Connect a phone to the eNodeB

We tested Samsung J5, with android system version 7.1.1. 
After EPC and RAN up, turn on the phone, the phone will automatically search and attach to COMAC EPC.

## Setup verification

Download a ping applicaiton on your phone. You can ping the SGI interface IP
address of CDN container from the phone.

The CDN service and containers will be introduced in other sections.























