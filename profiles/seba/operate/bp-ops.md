# Bandwidth Profile Operations

As mentioned in the configuration guide, from SEBA 2.0 release onwards it is necessary to configure upstream and downstream bandwidth profiles for subscribers. Unlike Tech profiles, bandwidth profiles do change over time in operation, due to subscribers upgrading or downgrading their service.

In this release, runtime changes to the bandwidth profile for a subscriber are supported by the following set of operations

- first delete the subscriber - this will cause the removal of subscriber flows in the PON
- (optional) you can choose to remove the bandwidth profile the subscriber was currently using, if no other subscriber is using that profile. Or you can simply leave it configured for future use.
- next, configure the new bandwidth profile
- finally, configure the subscriber again, but this time using the new bandwidth profile.

A couple of things to note:

- Admittedly the procedure outlined above is cumbersome. It should simply be possible to configure a new bandwidth profile, and *change* the subscriber configuration to use the new bandwidth profile, without requiring a removal and reprogramming of the subscribers flows. Under the hood, bandwidth profiles are implemented using meters, and so it should be possible to point the subscribers flows to different meters reflecting the new bandwidth profile without deleting the flows. However, this capability is not supported in the underlying OLT software (BAL) currently.
- Due to the current limitations specified in the Known Issues, changing a bandwidth profile at runtime may not be successful.

## Under the hood

The information in this section is not strictly necessary to use bandwidth profiles.
It is only provided to help understand the underlying implementation and commands that help debugging.

### Initial State

When ONU's are discovered and ranged by the OLT, VOLTHA creates a port (representing the UNI on the ONU) on the logical device that is reported to ONOS.

Consider the following from the ONOS cli

```shell
onos> devices
id=of:0000000000000001, available=true, local-status=connected 2d6h ago, role=MASTER, type=SWITCH, mfr=Accton Corp., hw=x86-64-accton-as6712-32x-r0, sw=ofdpa 3.0.5.5+accton1.7-1, serial=671232X1538033, chassis=1, driver=ofdpa3, channelId=192.168.100.1:48820, locType=none, managementAddress=192.168.100.1, name=AGG SWITCH, protocol=OF_13
id=of:00000000c0a8646f, available=true, local-status=connected 51s ago, role=MASTER, type=SWITCH, mfr=VOLTHA Project, hw=, sw=, serial=EC1904000654, chassis=c0a8646f, driver=voltha, channelId=10.233.90.246:56694, locType=none, managementAddress=10.233.90.246, name=EdgeCore OLT, protocol=OF_13
```

It shows two devices, one that represents the AGG switch (dpid: of:0000000000000001) and another that represents the PON (dpid of:00000000c0a8646f)
We can check the enabled ports on each device

```shell
onos> ports -e
id=of:0000000000000001, available=true, local-status=connected 2d6h ago, role=MASTER, type=SWITCH, mfr=Accton Corp., hw=x86-64-accton-as6712-32x-r0, sw=ofdpa 3.0.5.5+accton1.7-1, serial=671232X1538033, chassis=1, driver=ofdpa3, channelId=192.168.100.1:48820, locType=none, managementAddress=192.168.100.1, name=AGG SWITCH, protocol=OF_13
  port=1, state=enabled, type=fiber, speed=40000 , adminState=enabled, portMac=cc:37:ab:61:80:49, portName=port1
  port=153, state=enabled, type=fiber, speed=10000 , adminState=enabled, portMac=cc:37:ab:61:80:49, portName=port153
id=of:00000000c0a8646f, available=true, local-status=connected 29s ago, role=MASTER, type=SWITCH, mfr=VOLTHA Project, hw=, sw=, serial=EC1904000654, chassis=c0a8646f, driver=voltha, channelId=10.233.90.246:56694, locType=none, managementAddress=10.233.90.246, name=EdgeCore OLT, protocol=OF_13
  port=16, state=enabled, type=fiber, speed=0 , adminState=enabled, portMac=08:00:00:00:00:10, portName=BRCM22222222
  port=32, state=enabled, type=fiber, speed=0 , adminState=enabled, portMac=08:00:00:00:00:20, portName=ISKT71e801a0
  port=65536, state=enabled, type=fiber, speed=0 , adminState=enabled, portMac=00:00:00:01:00:00, portName=nni-65536
```

The device representing the PON shows 1 NNI port (portnumber 65536) and 2 UNI ports (portnumbers 16 and 32).
We can also check the flows that have been programmed on each device. For clarity, we only show the flows sent to VOLTHA.

```shell
onos> flows -s
deviceId=of:0000000000000001, flowRuleCount=29
    -snip-
deviceId=of:00000000c0a8646f, flowRuleCount=5
    ADDED, bytes=0, packets=0, table=0, priority=10000, selector=[IN_PORT:32, ETH_TYPE:eapol, VLAN_VID:4091], treatment=[immediate=[OUTPUT:CONTROLLER], meter=METER:1, metadata=METADATA:ffb004000000000/0]
    ADDED, bytes=0, packets=0, table=0, priority=10000, selector=[IN_PORT:65536, ETH_TYPE:lldp], treatment=[immediate=[OUTPUT:CONTROLLER]]
    ADDED, bytes=0, packets=0, table=0, priority=10000, selector=[IN_PORT:65536, ETH_TYPE:ipv6, IP_PROTO:17, UDP_SRC:546, UDP_DST:547], treatment=[immediate=[OUTPUT:CONTROLLER]]
    ADDED, bytes=0, packets=0, table=0, priority=10000, selector=[IN_PORT:65536, ETH_TYPE:ipv4, IP_PROTO:17, UDP_SRC:67, UDP_DST:68], treatment=[immediate=[OUTPUT:CONTROLLER]]
    ADDED, bytes=0, packets=0, table=0, priority=10000, selector=[IN_PORT:16, ETH_TYPE:eapol, VLAN_VID:4091], treatment=[immediate=[OUTPUT:CONTROLLER], meter=METER:1, metadata=METADATA:ffb004000000000/0]
```

Note that there are 3 flows that are meant for packets entering from the NNI port (IN_PORT:65536). One is for LLDP packets and the other two are for DHCP v4 and DHCP v6. The latter is ignored by VOLTHA currently.
More importantly, we can see that there are two other flows meant for the packets from the UNI ports 32 and 16. Both are EAPOL matching flows (ETH_TYPE:eapol) that trap eapol packets to the controller. Also note that they use a default VLAN (4091) and point to a meter (METER:1).
We can check the meter using the following command.

```shell
onos> meters
 DefaultMeter{device=of:00000000c0a8646f, cellId=1, appId=org.opencord.olt, unit=KB_PER_SEC, isBurst=true, state=ADDED, bands=[DefaultBand{rate=600, burst-size=30, type=DROP, drop-precedence=null}, DefaultBand{rate=400, burst-size=30, type=DROP, drop-precedence=null}, DefaultBand{rate=100000, burst-size=0, type=DROP, drop-precedence=null}]}
```

Note that the `cellId=1` is the same as the meter id. We can also check the bandwidthProfile associated with this meter.

```shell
onos> volt-bpmeter-mappings
bpInfo=Default deviceId=of:00000000c0a8646f meterId=1
```

From the above, we see that `meterId=1` corresponds to bandwidthProfile `Default`, configured in SADIS. We can check the parameters of the configured bandwidthProfile with the following command.

```shell
onos> bandwidthprofile Default
BandwidthProfileInformation{id=Default, committedInformationRate=600, committedBurstSize=30, exceededInformationRate=400, exceededBurstSize=30, assuredInformationRate=100000}
```
Note how the configured bandwidth profile is mapped to a meter and its meter-bands.

In VOLTHA we can see the same flows in the logical device with the same meterId.

```shell
(voltha) logical_devices
Logical devices:
+------------------+------------------+------------------+-----------------+---------------------------+--------------------------+
|               id |      datapath_id |   root_device_id | desc.serial_num | switch_features.n_buffers | switch_features.n_tables |
+------------------+------------------+------------------+-----------------+---------------------------+--------------------------+
| 00010000c0a8646f | 00000000c0a8646f | 00010c6fb4ae4011 |    EC1904000654 |                       256 |                        2 |
+------------------+------------------+------------------+-----------------+---------------------------+--------------------------+
(voltha) logical_device 00010000c0a8646f
(logical device 00010000c0a8646f) flows
Logical Device 00010000c0a8646f (type: n/a)
Flows (5):
+----------+----------+-----------+---------+----------+----------+----------+---------+---------+------------+---------------------+-------+
| table_id | priority |    cookie | in_port | vlan_vid | eth_type | ip_proto | udp_src | udp_dst |     output |      write-metadata | meter |
+----------+----------+-----------+---------+----------+----------+----------+---------+---------+------------+---------------------+-------+
|        0 |    10000 | ~568a5a6b |   65536 |          |     88CC |          |         |         | CONTROLLER |                     |       |
|        0 |    10000 | ~b1626297 |   65536 |          |      800 |       17 |      67 |      68 | CONTROLLER |                     |       |
|        0 |    10000 | ~8564f89b |   65536 |          |     86DD |       17 |     546 |     547 | CONTROLLER |                     |       |
|        0 |    10000 | ~bccf83c4 |      16 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~16403fee |      32 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
+----------+----------+-----------+---------+----------+----------+----------+---------+---------+------------+---------------------+-------+
(logical device 00010000c0a8646f) ports
Logical device ports:
+-----------+------------------+----------------+-----------+------------------+---------------------------+---------------+----------------+---------------+---------------------+------------------------+
|        id |        device_id | device_port_no | root_port | ofp_port.port_no |          ofp_port.hw_addr | ofp_port.name | ofp_port.state | ofp_port.curr | ofp_port.curr_speed | ofp_port_stats.port_no |
+-----------+------------------+----------------+-----------+------------------+---------------------------+---------------+----------------+---------------+---------------------+------------------------+
| nni-65536 | 00010c6fb4ae4011 |          65536 |      True |            65536 |  [0L, 0L, 0L, 1L, 0L, 0L] |     nni-65536 |              4 |          4128 |                  32 |                  65536 |
|    uni-32 | 0001beddb8196807 |             32 |           |               32 | [8L, 0L, 0L, 0L, 0L, 32L] |  ISKT71e801a0 |              4 |          4160 |                  64 |                        |
|    uni-16 | 00019af6aa8c68c9 |             16 |           |               16 | [8L, 0L, 0L, 0L, 0L, 16L] |  BRCM22222222 |              4 |          4160 |                  64 |                        |
+-----------+------------------+----------------+-----------+------------------+---------------------------+---------------+----------------+---------------+---------------------+------------------------+
```

We can also check the physical device representing the OLT.

```shell
(voltha) devices
Devices:
+------------------+-------------------+------+------------------+---------------+-------------+-------------+----------------+----------------+----------------------+--------------------------------------+-------------------------+----------------------+------------------------------+
|               id |              type | root |        parent_id | serial_number | admin_state | oper_status | connect_status | parent_port_no |        host_and_port |                               reason | proxy_address.device_id | proxy_address.onu_id | proxy_address.onu_session_id |
+------------------+-------------------+------+------------------+---------------+-------------+-------------+----------------+----------------+----------------------+--------------------------------------+-------------------------+----------------------+------------------------------+
| 00010c6fb4ae4011 |           openolt | True | 00010000c0a8646f |  EC1904000654 |     ENABLED |      ACTIVE |      REACHABLE |                | 192.168.100.111:9191 |                                      |                         |                      |                              |
| 00019af6aa8c68c9 | brcm_openomci_onu |      | 00010c6fb4ae4011 |  BRCM22222222 |     ENABLED |      ACTIVE |      REACHABLE |      536870912 |                      | tech-profile-config-download-success |        00010c6fb4ae4011 |                    1 |                            1 |
| 0001beddb8196807 | brcm_openomci_onu |      | 00010c6fb4ae4011 |  ISKT71e801a0 |     ENABLED |      ACTIVE |      REACHABLE |      536870912 |                      | tech-profile-config-download-success |        00010c6fb4ae4011 |                    2 |                            2 |
+------------------+-------------------+------+------------------+---------------+-------------+-------------+----------------+----------------+----------------------+--------------------------------------+-------------------------+----------------------+------------------------------+
(voltha) device 00010c6fb4ae4011
(device 00010c6fb4ae4011) flows
Device 00010c6fb4ae4011 (type: openolt)
Flows (26):
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+------------+---------------------+-------+
| table_id | priority |    cookie |    in_port | vlan_vid | eth_type | ip_proto | udp_src | udp_dst |     output |      write-metadata | meter |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+------------+---------------------+-------+
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~c3fcfed2 | CONTROLLER |     4090 |          |          |         |         |         16 |                     |       |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~c3fcfed2 | CONTROLLER |     4090 |          |          |         |         |         16 |                     |       |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~c3fcfed2 | CONTROLLER |     4090 |          |          |         |         |         16 |                     |       |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+------------+---------------------+-------+
|        0 |    10000 | ~c3fcfed2 | CONTROLLER |     4090 |          |          |         |         |         16 |                     |       |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~3dd97249 |      65536 |          |     88CC |          |         |         | CONTROLLER |                     |       |
|        0 |    10000 | ~74cd6437 |      65536 |          |      800 |       17 |      67 |      68 | CONTROLLER |                     |       |
|        0 |    10000 | ~47a868a3 |         32 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~47a868a3 | CONTROLLER |     4090 |          |          |         |         |         32 |                     |       |
|        0 |    10000 | ~47a868a3 |         32 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~47a868a3 |         32 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~47a868a3 | CONTROLLER |     4090 |          |          |         |         |         32 |                     |       |
|        0 |    10000 | ~47a868a3 |         32 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+------------+---------------------+-------+
|        0 |    10000 | ~47a868a3 |         32 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~47a868a3 |         32 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~47a868a3 | CONTROLLER |     4090 |          |          |         |         |         32 |                     |       |
|        0 |    10000 | ~47a868a3 |         32 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
|        0 |    10000 | ~47a868a3 | CONTROLLER |     4090 |          |          |         |         |         32 |                     |       |
|        0 |    10000 | ~47a868a3 |         32 |     4091 |     888E |          |         |         | CONTROLLER | 1151514404601200640 |     1 |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+------------+---------------------+-------+
```

Note that the each flow for the UNI ports 16 and 32 become 8 flows in the physical device.


### After Successful Authentication

When the RG behind one ONU (port 32) successfully authenticates, ONOS programs the subscriber's configured bandwidth profile (`BRONZE`), replacing the default bandwidth profile.
In this case, we can check the flows and meters again

```shell
onos> flows -s
deviceId=of:0000000000000001, flowRuleCount=33
    -snip-
deviceId=of:00000000c0a8646f, flowRuleCount=11
    ADDED, bytes=0, packets=0, table=0, priority=10000, selector=[IN_PORT:32, ETH_TYPE:eapol, VLAN_VID:12], treatment=[immediate=[OUTPUT:CONTROLLER], meter=METER:2, metadata=METADATA:c004000000000/0]
    ADDED, bytes=0, packets=0, table=0, priority=10000, selector=[IN_PORT:65536, ETH_TYPE:lldp], treatment=[immediate=[OUTPUT:CONTROLLER]]
    ADDED, bytes=0, packets=0, table=0, priority=10000, selector=[IN_PORT:65536, ETH_TYPE:ipv6, IP_PROTO:17, UDP_SRC:546, UDP_DST:547], treatment=[immediate=[OUTPUT:CONTROLLER]]
    ADDED, bytes=0, packets=0, table=0, priority=10000, selector=[IN_PORT:65536, ETH_TYPE:ipv4, IP_PROTO:17, UDP_SRC:67, UDP_DST:68], treatment=[immediate=[OUTPUT:CONTROLLER]]
    ADDED, bytes=0, packets=0, table=0, priority=10000, selector=[IN_PORT:16, ETH_TYPE:eapol, VLAN_VID:4091], treatment=[immediate=[OUTPUT:CONTROLLER], meter=METER:1, metadata=METADATA:ffb004000000000/0]
    ADDED, bytes=0, packets=0, table=0, priority=10000, selector=[IN_PORT:32, ETH_TYPE:ipv4, IP_PROTO:17, UDP_SRC:68, UDP_DST:67], treatment=[immediate=[OUTPUT:CONTROLLER], meter=METER:2, metadata=METADATA:4000000000/0]
    ADDED, bytes=0, packets=0, table=0, priority=10000, selector=[IN_PORT:32, ETH_TYPE:ipv6, IP_PROTO:17, UDP_SRC:547, UDP_DST:546], treatment=[immediate=[OUTPUT:CONTROLLER], meter=METER:2, metadata=METADATA:4000000000/0]
    ADDED, bytes=0, packets=0, table=0, priority=1000, selector=[IN_PORT:32, VLAN_VID:0], treatment=[immediate=[VLAN_ID:12], transition=TABLE:1, meter=METER:2, metadata=METADATA:6f004000010000/0]
    ADDED, bytes=0, packets=0, table=0, priority=1000, selector=[IN_PORT:65536, METADATA:c, VLAN_VID:111], treatment=[immediate=[VLAN_POP], transition=TABLE:1, meter=METER:2, metadata=METADATA:c004000000020/0]
    ADDED, bytes=0, packets=0, table=1, priority=1000, selector=[IN_PORT:32, VLAN_VID:12], treatment=[immediate=[VLAN_PUSH:vlan, VLAN_ID:111, OUTPUT:65536], meter=METER:2, metadata=METADATA:4000000000/0]
    ADDED, bytes=0, packets=0, table=1, priority=1000, selector=[IN_PORT:65536, VLAN_VID:12], treatment=[immediate=[VLAN_POP, VLAN_ID:0, OUTPUT:32], meter=METER:2, metadata=METADATA:4000000000/0]

onos> meters
 DefaultMeter{device=of:00000000c0a8646f, cellId=1, appId=org.opencord.olt, unit=KB_PER_SEC, isBurst=true, state=ADDED, bands=[DefaultBand{rate=600, burst-size=30, type=DROP, drop-precedence=null}, DefaultBand{rate=400, burst-size=30, type=DROP, drop-precedence=null}, DefaultBand{rate=100000, burst-size=0, type=DROP, drop-precedence=null}]}
 DefaultMeter{device=of:00000000c0a8646f, cellId=2, appId=org.opencord.olt, unit=KB_PER_SEC, isBurst=true, state=ADDED, bands=[DefaultBand{rate=5000, burst-size=2000, type=DROP, drop-precedence=null}, DefaultBand{rate=3000, burst-size=2000, type=DROP, drop-precedence=null}, DefaultBand{rate=100000, burst-size=0, type=DROP, drop-precedence=null}]}
```

Note that we now have UNI port 32 with a lot more flows which use the subscriber's VLANs (C-Vlan=12 and S-VLAN=111). We also have these flows pointing to a different meter (METER:2), which maps to the subscriber's configured bandwidth profile `BRONZE`.

```shell
onos> volt-bpmeter-mappings
bpInfo=Bronze deviceId=of:00000000c0a8646f meterId=2
bpInfo=Default deviceId=of:00000000c0a8646f meterId=1

onos> bandwidthprofile Bronze
BandwidthProfileInformation{id=Bronze, committedInformationRate=5000, committedBurstSize=2000, exceededInformationRate=3000, exceededBurstSize=2000, assuredInformationRate=100000}
```

The UNI port 16 based flow is still the initial eapol flow mapped to METER:1 as the RG behind the ONU has not authenticated yet.

The flows in VOLTHA for the OLT show similar information.

```shell
(device 00010c6fb4ae4011) flows
Device 00010c6fb4ae4011 (type: openolt)
Flows (50):
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+----------+--------------+----------+-----------+------------+------------+---------------------+-------+
| table_id | priority |    cookie |    in_port | vlan_vid | eth_type | ip_proto | udp_src | udp_dst | metadata | set_vlan_vid | pop_vlan | push_vlan |     output | goto-table |      write-metadata | meter |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+----------+--------------+----------+-----------+------------+------------+---------------------+-------+
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         |          |              |          |           | CONTROLLER |            | 1151514404601200640 |     1 |
|        0 |    10000 | ~c3fcfed2 | CONTROLLER |     4090 |          |          |         |         |          |              |          |           |         16 |            |                     |       |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         |          |              |          |           | CONTROLLER |            | 1151514404601200640 |     1 |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         |          |              |          |           | CONTROLLER |            | 1151514404601200640 |     1 |
|        0 |    10000 | ~c3fcfed2 | CONTROLLER |     4090 |          |          |         |         |          |              |          |           |         16 |            |                     |       |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         |          |              |          |           | CONTROLLER |            | 1151514404601200640 |     1 |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         |          |              |          |           | CONTROLLER |            | 1151514404601200640 |     1 |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         |          |              |          |           | CONTROLLER |            | 1151514404601200640 |     1 |
|        0 |    10000 | ~c3fcfed2 | CONTROLLER |     4090 |          |          |         |         |          |              |          |           |         16 |            |                     |       |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         |          |              |          |           | CONTROLLER |            | 1151514404601200640 |     1 |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+----------+--------------+----------+-----------+------------+------------+---------------------+-------+
|        0 |    10000 | ~c3fcfed2 | CONTROLLER |     4090 |          |          |         |         |          |              |          |           |         16 |            |                     |       |
|        0 |    10000 | ~c3fcfed2 |         16 |     4091 |     888E |          |         |         |          |              |          |           | CONTROLLER |            | 1151514404601200640 |     1 |
|        0 |    10000 | ~3dd97249 |      65536 |          |     88CC |          |         |         |          |              |          |           | CONTROLLER |            |                     |       |
|        0 |    10000 | ~74cd6437 |      65536 |          |      800 |       17 |      67 |      68 |          |              |          |           | CONTROLLER |            |                     |       |
|        0 |     1000 | ~cfd16aad |      65536 |      111 |          |          |         |         |       12 |              |      Yes |           |            |          1 |    3377974598434848 |     2 |
|        0 |     1000 | ~cfd16aad |      65536 |      111 |          |          |         |         |       12 |              |      Yes |           |            |          1 |    3377974598434848 |     2 |
|        0 |     1000 | ~cfd16aad |      65536 |      111 |          |          |         |         |       12 |              |      Yes |           |            |          1 |    3377974598434848 |     2 |
|        0 |     1000 | ~cfd16aad |      65536 |      111 |          |          |         |         |       12 |              |      Yes |           |            |          1 |    3377974598434848 |     2 |
|        0 |     1000 | ~cfd16aad |      65536 |      111 |          |          |         |         |       12 |              |      Yes |           |            |          1 |    3377974598434848 |     2 |
|        0 |     1000 | ~cfd16aad |      65536 |      111 |          |          |         |         |       12 |              |      Yes |           |            |          1 |    3377974598434848 |     2 |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+----------+--------------+----------+-----------+------------+------------+---------------------+-------+
|        0 |     1000 | ~cfd16aad |      65536 |      111 |          |          |         |         |       12 |              |      Yes |           |            |          1 |    3377974598434848 |     2 |
|        0 |     1000 | ~cfd16aad |      65536 |      111 |          |          |         |         |       12 |              |      Yes |           |            |          1 |    3377974598434848 |     2 |
|        1 |     1000 | ~0048130f |         32 |       12 |          |          |         |         |          |          111 |          |      8100 |      65536 |            |        274877906944 |     2 |
|        1 |     1000 | ~0048130f |         32 |       12 |          |          |         |         |          |          111 |          |      8100 |      65536 |            |        274877906944 |     2 |
|        1 |     1000 | ~0048130f |         32 |       12 |          |          |         |         |          |          111 |          |      8100 |      65536 |            |        274877906944 |     2 |
|        1 |     1000 | ~0048130f |         32 |       12 |          |          |         |         |          |          111 |          |      8100 |      65536 |            |        274877906944 |     2 |
|        1 |     1000 | ~0048130f |         32 |       12 |          |          |         |         |          |          111 |          |      8100 |      65536 |            |        274877906944 |     2 |
|        1 |     1000 | ~0048130f |         32 |       12 |          |          |         |         |          |          111 |          |      8100 |      65536 |            |        274877906944 |     2 |
|        1 |     1000 | ~0048130f |         32 |       12 |          |          |         |         |          |          111 |          |      8100 |      65536 |            |        274877906944 |     2 |
|        1 |     1000 | ~0048130f |         32 |       12 |          |          |         |         |          |          111 |          |      8100 |      65536 |            |        274877906944 |     2 |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+----------+--------------+----------+-----------+------------+------------+---------------------+-------+
|        0 |    10000 | ~0019466f |         32 |          |      800 |       17 |      68 |      67 |          |              |          |           | CONTROLLER |            |        274877906944 |     2 |
|        0 |    10000 | ~0019466f |         32 |          |      800 |       17 |      68 |      67 |          |              |          |           | CONTROLLER |            |        274877906944 |     2 |
|        0 |    10000 | ~0019466f |         32 |          |      800 |       17 |      68 |      67 |          |              |          |           | CONTROLLER |            |        274877906944 |     2 |
|        0 |    10000 | ~0019466f |         32 |          |      800 |       17 |      68 |      67 |          |              |          |           | CONTROLLER |            |        274877906944 |     2 |
|        0 |    10000 | ~0019466f |         32 |          |      800 |       17 |      68 |      67 |          |              |          |           | CONTROLLER |            |        274877906944 |     2 |
|        0 |    10000 | ~0019466f |         32 |          |      800 |       17 |      68 |      67 |          |              |          |           | CONTROLLER |            |        274877906944 |     2 |
|        0 |    10000 | ~0019466f |         32 |          |      800 |       17 |      68 |      67 |          |              |          |           | CONTROLLER |            |        274877906944 |     2 |
|        0 |    10000 | ~0019466f |         32 |          |      800 |       17 |      68 |      67 |          |              |          |           | CONTROLLER |            |        274877906944 |     2 |
|        0 |    10000 | ~e5f8ecc9 |         32 |       12 |     888E |          |         |         |          |              |          |           | CONTROLLER |            |    3377974598434816 |     2 |
|        0 |    10000 | ~e5f8ecc9 | CONTROLLER |     4090 |          |          |         |         |          |              |          |           |         32 |            |                     |       |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+----------+--------------+----------+-----------+------------+------------+---------------------+-------+
|        0 |    10000 | ~e5f8ecc9 |         32 |       12 |     888E |          |         |         |          |              |          |           | CONTROLLER |            |    3377974598434816 |     2 |
|        0 |    10000 | ~e5f8ecc9 |         32 |       12 |     888E |          |         |         |          |              |          |           | CONTROLLER |            |    3377974598434816 |     2 |
|        0 |    10000 | ~e5f8ecc9 | CONTROLLER |     4090 |          |          |         |         |          |              |          |           |         32 |            |                     |       |
|        0 |    10000 | ~e5f8ecc9 |         32 |       12 |     888E |          |         |         |          |              |          |           | CONTROLLER |            |    3377974598434816 |     2 |
|        0 |    10000 | ~e5f8ecc9 |         32 |       12 |     888E |          |         |         |          |              |          |           | CONTROLLER |            |    3377974598434816 |     2 |
|        0 |    10000 | ~e5f8ecc9 |         32 |       12 |     888E |          |         |         |          |              |          |           | CONTROLLER |            |    3377974598434816 |     2 |
|        0 |    10000 | ~e5f8ecc9 | CONTROLLER |     4090 |          |          |         |         |          |              |          |           |         32 |            |                     |       |
|        0 |    10000 | ~e5f8ecc9 |         32 |       12 |     888E |          |         |         |          |              |          |           | CONTROLLER |            |    3377974598434816 |     2 |
|        0 |    10000 | ~e5f8ecc9 | CONTROLLER |     4090 |          |          |         |         |          |              |          |           |         32 |            |                     |       |
|        0 |    10000 | ~e5f8ecc9 |         32 |       12 |     888E |          |         |         |          |              |          |           | CONTROLLER |            |    3377974598434816 |     2 |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+----------+--------------+----------+-----------+------------+------------+---------------------+-------+
```
