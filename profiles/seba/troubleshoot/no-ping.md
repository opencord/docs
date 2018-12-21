# I can't ping

A successful ping is all about the flows in the hardware. In a SEBA pod, dataplane
traffic does not leave the hardware. But in order to get to this point, the RG
should have successfully authenticated, and it should have received an IP address
from the DHCP server.

In the future, we will add troubleshooting probes to understand where the datapath
may be broken. For now, it is instructive to understand the flows in the dataplane
and what they represent.

## Flows in the PON

Lets look at what the flows look like in ONOS for the PON.

### ONOS flows

Connect to the [ONOS CLI](../../../charts/onos.md#accessing-the-onos-cli)
and check the flows on the device that represents the PON.

```shell
onos> flows -s any of:000000000a5a007a
deviceId=of:000000000a5a007a, flowRuleCount=11
-snip-
    ADDED, bytes=0, packets=0, table=0, priority=1000, selector=[IN_PORT:65536, METADATA:de00007810, VLAN_VID:222], treatment=[immediate=[VLAN_POP], transition=TABLE:1]
    ADDED, bytes=0, packets=0, table=1, priority=1000, selector=[IN_PORT:65536, VLAN_VID:222], treatment=[immediate=[VLAN_POP, OUTPUT:30736]]
    ADDED, bytes=0, packets=0, table=0, priority=1000, selector=[IN_PORT:30736, VLAN_VID:0], treatment=[immediate=[VLAN_ID:222], transition=TABLE:1]
    ADDED, bytes=0, packets=0, table=1, priority=1000, selector=[IN_PORT:30736, VLAN_VID:222], treatment=[immediate=[VLAN_PUSH:vlan, VLAN_ID:222, OUTPUT:65536]]
```

The first two flows above represent the downstream traffic from `IN_PORT` 65536 (the NNI port)
for S-VLAN tag 222, which gets popped and transitioned to table 1, where the inner VLAN (also
222 in this example) is popped and sent to UNI port 30736.

The last two flows represent the upstream traffic, where the reverse happens. In table 0,
untagged traffic input from UNI port 30736, has C-VLAN 222 pushed on and transitioned
to table 2 where the outer S-VLAN tag is pushed on and then sent out of NNI port 65536.

### VOLTHA flows

Now lets see what those flows look like in the logical device representing the PON in VOLTHA.
Connect to the [VOLTHA CLI](../../../charts/voltha.md#accessing-the-voltha-cli)

```shell
(voltha) logical_device 000100000a5a007a
(logical device 000100000a5a007a) flows
Logical Device 000100000a5a007a (type: n/a)
Flows (12):
+----------+----------+-----------+---------+----------+----------+----------+---------+---------+--------------+--------------+----------+-----------+------------+------------+
| table_id | priority |    cookie | in_port | vlan_vid | eth_type | ip_proto | udp_src | udp_dst |     metadata | set_vlan_vid | pop_vlan | push_vlan |     output | goto-table |
+----------+----------+-----------+---------+----------+----------+----------+---------+---------+--------------+--------------+----------+-----------+------------+------------+
-snip-
|        0 |     1000 | ~6a971a41 |   30736 |        0 |          |          |         |         |              |          222 |          |           |            |          1 |
|        1 |     1000 | ~fd1c22e3 |   30736 |      222 |          |          |         |         |              |          222 |          |      8100 |      65536 |            |
+----------+----------+-----------+---------+----------+----------+----------+---------+---------+--------------+--------------+----------+-----------+------------+------------+
|        0 |     1000 | ~569b8514 |   65536 |      222 |          |          |         |         | 953482770448 |              |      Yes |           |            |          1 |
|        1 |     1000 | ~c587bdac |   65536 |      222 |          |          |         |         |              |              |      Yes |           |      30736 |            |
+----------+----------+-----------+---------+----------+----------+----------+---------+---------+--------------+--------------+----------+-----------+------------+------------+
```

We see the same patterns are repeated in the logical device, where the first two
flows above are for upstream traffic, and the bottom two are for downstream traffic.

These flows from the logical device get decomposed into flows that are meant for
the OLT as well as for the ONU.

Now if we look at the device object representing the OLT below, we see there is
one flow each for downstream and upstream in the OLT device object.

```shell
(voltha) device 0001a82d21249c28
(device 0001a82d21249c28) flows
Device 0001a82d21249c28 (type: openolt)
Flows (16):
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+--------------+--------------+----------+-----------+------------+------------+
| table_id | priority |    cookie |    in_port | vlan_vid | eth_type | ip_proto | udp_src | udp_dst |     metadata | set_vlan_vid | pop_vlan | push_vlan |     output | goto-table |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+--------------+--------------+----------+-----------+------------+------------+
-snip-
|        1 |     1000 | ~829ee130 |      30736 |      222 |          |          |         |         |              |          222 |          |      8100 |      65536 |            |
|        0 |     1000 | ~c4babfb5 |      65536 |      222 |          |          |         |         | 953482770448 |              |      Yes |           |            |          1 |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+--------------+--------------+----------+-----------+------------+------------+
```

The first flow above represents upstream traffic, and the second one represents
downstream traffic.
The upstream flow appears to come from a UNI port `30736`, which is not a port
on the OLT device (it's a port on the ONU). But this information is necessary
to figure out the PON port on the OLT, from which the traffic ingresses the OLT.

The downstream flow appears to not have an output port but actually
the output is encoded in the metadata (which also includes the C-VLAN id).

Ignore the `table_id` and `goto-table` fields in this table - they are meaningless.

If these flows look good, lets check the flows in the device object representing the ONU:

```shell
(voltha) device 000175a511654437
(device 000175a511654437) flows
Device 000175a511654437 (type: brcm_openomci_onu)
Flows (5):
+----------+----------+-----------+---------+----------+--------------+----------+-----------+--------+
| table_id | priority |    cookie | in_port | vlan_vid | set_vlan_vid | pop_vlan | push_vlan | output |
+----------+----------+-----------+---------+----------+--------------+----------+-----------+--------+
-snip-
|        0 |     1000 | ~c587bdac |     100 |      222 |              |      Yes |           |  30736 |
|        0 |     1000 | ~6a971a41 |   30736 |        0 |          222 |          |           |    100 |
+----------+----------+-----------+---------+----------+--------------+----------+-----------+--------+
```

Again, there is only 1 upstream flow and 1 downstream flow for this subscriber. The
first flow shown above represents the downstream direction from the ANI port on the
ONU (designated as port number 100) that matches on the VLAN tag 222, and pops it off
before sending the packet out of the UNI port 30736.

The 2nd flow represents the upstream direction, receiving untagged packets from the
UNI port 30736, and pushing on the C-VLAN tag 222, before sending the packet out
of the ANI port 100 towards the OLT.

## Flows in the AGG switch

If all the flows in the PON appear to be correct, then the problem may lie in the
AGG switch.

From the ONOS CLI

```shell
onos> flows -s any of:0000000000000002
deviceId=of:0000000000000002, flowRuleCount=33
-snip-
    ADDED, bytes=0, packets=0, table=10, priority=32768, selector=[IN_PORT:1, VLAN_VID:222], treatment=[transition=TABLE:20]
    ADDED, bytes=0, packets=0, table=10, priority=32768, selector=[IN_PORT:32, VLAN_VID:222], treatment=[transition=TABLE:20]
-snip-
    ADDED, bytes=0, packets=0, table=50, priority=1000, selector=[VLAN_VID:222], treatment=[deferred=[GROUP:0x40de0000], transition=TABLE:60]
-snip-
    ADDED, bytes=1948, packets=22, table=60, priority=60000, selector=[VLAN_VID:222], treatment=[immediate=[NOACTION]]
-snip-
```

There are a number of default flows in the AGG switch for features that are not
currently used in SEBA. We have highlighted only the meaningful flows above. In SEBA,
for the AT&T workflow, packets are forwarded only on the basis of the S-tag.

In `table=10`, packets with S-VLAN tag 222 are allowed into the the switch from
`IN_PORT:1` (connected to the OLT) and `IN_PORT:32` (connected to the BNG).
In `table=50` packets in the S-VLAN 222 are bridged together in the `GROUP:0x40de0000`
In `table=60` we add an ACL flow for S-VLAN 222 to ensure that none of the other
ACL flows (not shown above) get triggered for packets on this VLAN.

Below we show details of the flooding group `GROUP:0x40de0000` which points to
two other groups which in turn represent the two ports 1 and 32, which have been
cross-connected together on this vlan (222).

```shell
onos> groups
deviceId=of:0000000000000002, groupCount=3
   id=0xde0001, state=ADDED, type=INDIRECT, bytes=0, packets=0, appId=org.onosproject.xconnect, referenceCount=1
       id=0xde0001, bucket=1, bytes=0, packets=0, actions=[OUTPUT:1]
   id=0xde0020, state=ADDED, type=INDIRECT, bytes=0, packets=0, appId=org.onosproject.xconnect, referenceCount=1
       id=0xde0020, bucket=1, bytes=0, packets=0, actions=[OUTPUT:32]
   id=0x40de0000, state=ADDED, type=ALL, bytes=0, packets=0, appId=org.onosproject.xconnect, referenceCount=1
       id=0x40de0000, bucket=1, bytes=0, packets=0, actions=[GROUP:0xde0020]
       id=0x40de0000, bucket=2, bytes=0, packets=0, actions=[GROUP:0xde0001]
```

You should also verify the output of the command below which should show the cross-connected ports on the VLAN.

```shell
onos> sr-xconnect
XconnectDesc{key=XconnectKey{deviceId=of:0000000000000002, vlanId=222}, ports=[32, 1]}
```

## Using Port Statistics

You can check the port stats on the AGG switch to see if the port counters
on the switch are increasing or not. For example, with a live ping in progress, try

```shell
onos> watch portstats -nz -d  of:0000000000000002
deviceId=of:0000000000000002
   port=1, pktRx=36, pktTx=36, bytesRx=3866, bytesTx=3842, rateRx=Infinity, rateTx=Infinity, pktRxDrp=4, pktTxDrp=0, interval=0.000
   port=32, pktRx=31, pktTx=35, bytesRx=3364, bytesTx=3744, rateRx=Infinity, rateTx=Infinity, pktRxDrp=0, pktTxDrp=0, interval=0.000
```

Note that the port counters are increasing on both ports 1 and 32 for both
transmitted (`pktTx`) and received packets (`pktRx`).

We recommend a fast ping (with option -i 0.2) to increase the number of ping packets
sent out per second. This will cause a significant change in the port counters.

The -nz option in the command above displays only ports that have non-zero port counters.
The -d option automatically displays the delta of the port counters from the previous collection
point. Stats collection intervals are 5 secs by default.

These stats are not currently exported to the CORD monitoring stack by ONOS. However portstats
from the OLT are exported to Kafka by VOLTHA, and can be displayed in Grafana. Portstats
from the ONU can similarly be exported, but is currently work-in-progress.
