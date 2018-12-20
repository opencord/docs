# I can't authenticate my RGs

If the RG cannot authenticate, there can be a number of issues with the system.
On the one hand, it could truly be an authentication issue. For that it is best
to check your RADIUS server's logs. On the other hand, it could be an issue with
how authentication packets are flowing through the system.

To quickly recap, EAPOL packets from the RG reach the RADIUS server using this path:

RG --> ONU --> OLT --> trapped to VOLTHA --> packet-in to ONOS AAA app --> RADIUS server

## Check VOLTHA and the PON

The first thing to check - is VOLTHA receiving trapped EAPOL packets at all?
Unfortunately, the only way to do this currently is to check VOLTHA logs, by streaming
it using kubectl and grepping for EAPOL ethertype 0x888e.

From a terminal where you have kubectl client, try

```shell
cord@node1:~$ kubectl logs -f -n voltha vcore-0 | grep -E "packet_indication|packet-in" | grep 888e

20180912T003237.453 DEBUG    MainThread adapter_agent.send_packet_in {adapter_name: openolt, logical_port_no: 16, logical_device_id: 000100000a5a0097, packet: 0180c200000390e2ba82fa8281000ffb888e01000009020100090175736572000000000000000000000000000000000000000000000000000000000000000000, event: send-packet-in, instance_id: compose_voltha_1_1536712228, vcore_id: 0001}
```

Notice that the packet is displayed in hex, and includes the ethertype right after
the VLAN tag (with ethertype 0x8100 and VLAN id 0x0ffb)

If you don't see this packet, there is something wrong with the EAPOL trap flow in the OLT
or the PON setup itself (i.e. OLT + ONU). Check the state of the devices on the
VOLTHA cli.

Connect to the [VOLTHA CLI](../../../charts/voltha.md#accessing-the-voltha-cli)
and check the devices:

```shell
(voltha) devices
Devices:
+------------------+-------------------+------+------------------+------------------+-------------+-------------+----------------+----------------+------------------+------------------------+-------------------------+--------------------------+----------------------+------------------------------+
|               id |              type | root |        parent_id |    serial_number | admin_state | oper_status | connect_status | parent_port_no |    host_and_port |                 reason | proxy_address.device_id | proxy_address.channel_id | proxy_address.onu_id | proxy_address.onu_session_id |
+------------------+-------------------+------+------------------+------------------+-------------+-------------+----------------+----------------+------------------+------------------------+-------------------------+--------------------------+----------------------+------------------------------+
| 00012d28315ddb79 |           openolt | True | 000100000a5a007a | 10.90.0.122:9191 |     ENABLED |      ACTIVE |      REACHABLE |                | 10.90.0.122:9191 |                        |                         |                          |                      |                              |
| 0001d18bedd13517 | brcm_openomci_onu | True | 00012d28315ddb79 |     ALPHe3d1cfe3 |     ENABLED |      ACTIVE |      REACHABLE |      536870912 |                  | initial-mib-downloaded |        00012d28315ddb79 |                          |                    1 |                            1 |
| 00011c399faa957d | brcm_openomci_onu | True | 00012d28315ddb79 |     ALPHe3d1cf9d |     ENABLED |  DISCOVERED |      REACHABLE |      536870912 |                  |          starting-omci |        00012d28315ddb79 |                          |                    2 |                            2 |
+------------------+-------------------+------+------------------+------------------+-------------+-------------+----------------+----------------+------------------+------------------------+-------------------------+--------------------------+----------------------+------------------------------+
```
Both your OLT and ONU should be enabled, active and reachable.
Next check the flows in the logical device that represents the pon.

```shell
(voltha) logical_device 000100000a5a007a
(logical device 000100000a5a007a) flows
Logical Device 000100000a5a007a (type: n/a)
Flows (12):
+----------+----------+-----------+---------+----------+----------+----------+---------+---------+--------------+--------------+----------+-----------+------------+------------+
| table_id | priority |    cookie | in_port | vlan_vid | eth_type | ip_proto | udp_src | udp_dst |     metadata | set_vlan_vid | pop_vlan | push_vlan |     output | goto-table |
+----------+----------+-----------+---------+----------+----------+----------+---------+---------+--------------+--------------+----------+-----------+------------+------------+
|        0 |    10000 | ~1b322a1e |   65536 |          |     88CC |          |         |         |              |              |          |           | CONTROLLER |            |
|        0 |    10000 | ~1ec4282a |   65536 |          |      800 |       17 |      67 |      68 |              |              |          |           | CONTROLLER |            |
|        0 |    10000 | ~e863949e |   30736 |          |     888E |          |         |         |              |              |          |           | CONTROLLER |            |
-snip-
```
Notice that the EAPOL flow 0x888e corresponds to the UNI port 30736 and has a
directive to send to CONTROLLER. Check 'ports' on the logical device to ensure
that the UNI port corresponds to the correct ONU (via Serial Number) that connects
to your RG.

```shell
(voltha) logical_device 000100000a5a007a
(logical device 000100000a5a007a) ports
Logical device ports:
+-----------+------------------+----------------+-----------+------------------+------------------------------+---------------+----------------+---------------+---------------------+------------------------+
|        id |        device_id | device_port_no | root_port | ofp_port.port_no |             ofp_port.hw_addr | ofp_port.name | ofp_port.state | ofp_port.curr | ofp_port.curr_speed | ofp_port_stats.port_no |
+-----------+------------------+----------------+-----------+------------------+------------------------------+---------------+----------------+---------------+---------------------+------------------------+
| nni-65536 | 00012d28315ddb79 |          65536 |      True |            65536 |     [0L, 0L, 0L, 1L, 0L, 0L] |     nni-65536 |              4 |          4128 |                  32 |                  65536 |
| uni-30736 | 0001867d6f014a8d |          30736 |           |            30736 | [8L, 0L, 0L, 15L, 120L, 16L] |  ISKT71e80080 |              4 |          4160 |                  64 |                        |
|    uni-64 | 0001a331b09f048b |             64 |           |               64 |    [8L, 0L, 0L, 0L, 0L, 64L] |  ALPHe3d1ced5 |              4 |          4160 |                  64 |                        |
|    uni-32 | 00011c399faa957d |             32 |           |               32 |    [8L, 0L, 0L, 0L, 0L, 32L] |  ALPHe3d1cf9d |              4 |          4160 |                  64 |                        |
-snip-
```
You should also check the flows in the corresponding physical device object that
represents the OLT

```shell
(voltha) device 00012d28315ddb79
(device 00012d28315ddb79) flows
Device 00012d28315ddb79 (type: openolt)
Flows (15):
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+--------------+--------------+----------+-----------+------------+------------+
| table_id | priority |    cookie |    in_port | vlan_vid | eth_type | ip_proto | udp_src | udp_dst |     metadata | set_vlan_vid | pop_vlan | push_vlan |     output | goto-table |
+----------+----------+-----------+------------+----------+----------+----------+---------+---------+--------------+--------------+----------+-----------+------------+------------+
|        0 |    10000 | ~7e524bb2 |      30736 |     4091 |     888E |          |         |         |              |              |          |           | CONTROLLER |            |
|        0 |    10000 | ~7e524bb2 | CONTROLLER |     3999 |          |          |         |         |              |              |          |           |      30736 |            |
-snip-
```

Notice that the 1 EAPOL flow in the logical device, becomes 2 flows in the physical device,
one from UNI port to CONTROLLER and the other from CONTROLLER to UNI port. The former
shows the ethertype 0x888e, and the latter does not, but both are necessary. Furthermore,
the VLANs in the display are default VLANs used by the openolt adaptor - don't worry
about them.

If all this looks good, there is a possibility that your RG is connected to the
ONU on the wrong LAN port. On the ONU there are typically 4 LAN ports marked LAN 1
through LAN 4. Your RG should be connected to LAN 1. Sometimes the internal
naming could be reversed, so you could try switching the RG to LAN 4.

For more low level ONU debugging consider:
<https://guide.opencord.org/openolt/#why-does-the-broadcom-onu-not-forward-eapol-packets>


## Check ONOS AAA app state

If EAPOL packets are indeed making their way through VOLTHA, then check what's
happening in ONOS. At this time we do not have counters for AAA state machine transactions.

Connect to the [ONOS CLI](../../../charts/onos.md#accessing-the-onos-cli)
and check the logs

```shell
onos> log:tail
-snip-
2018-12-19 23:01:36,788 | INFO  | 33.102.179:59154 | StateMachine$Authorized          | 185 - org.opencord.aaa - 1.8.0 | Moving from AUTHORIZED state to STARTED state.
2018-12-19 23:01:36,789 | INFO  | 33.102.179:59154 | AaaManager                       | 185 - org.opencord.aaa - 1.8.0 | Auth event STARTED for of:000000000a5a007a/30736
2018-12-19 23:01:36,789 | INFO  | 33.102.179:59154 | StateMachine                     | 185 - org.opencord.aaa - 1.8.0 | Current State 1
2018-12-19 23:01:36,906 | INFO  | 33.102.179:59154 | StateMachine$Started             | 185 - org.opencord.aaa - 1.8.0 | Moving from STARTED state to PENDING state.
2018-12-19 23:01:36,906 | INFO  | 33.102.179:59154 | AaaManager                       | 185 - org.opencord.aaa - 1.8.0 | Auth event REQUESTED for of:000000000a5a007a/30736
2018-12-19 23:01:36,906 | INFO  | 33.102.179:59154 | StateMachine                     | 185 - org.opencord.aaa - 1.8.0 | Current State 2
2018-12-19 23:01:37,017 | INFO  | AAA-radius-0     | AaaManager                       | 185 - org.opencord.aaa - 1.8.0 | Send EAP success message to supplicant 90:E2:BA:82:F9:75
2018-12-19 23:01:37,017 | INFO  | AAA-radius-0     | StateMachine$Pending             | 185 - org.opencord.aaa - 1.8.0 | Moving from PENDING state to AUTHORIZED state.
2018-12-19 23:01:37,018 | INFO  | AAA-radius-0     | StateMachine                     | 185 - org.opencord.aaa - 1.8.0 | Current State 3
2018-12-19 23:01:37,018 | INFO  | AAA-radius-0     | AaaManager                       | 185 - org.opencord.aaa - 1.8.0 | Auth event APPROVED for of:000000000a5a007a/30736
-snip-
```

In a working authentication transaction, you should see the logs above for the RG
on the UNI port `of:000000000a5a007a/30736` where the `of:000000000a5a007a` is the
logical device representation of the PON provided by VOLTHA to ONOS, and `30736`
is the UNI port. You can also check the state in the 'aaa-users' command

```shell
nos> aaa-users
UserName=user,CurrentState=AUTHORIZED,DeviceId=of:000000000a5a007a,MAC=90:E2:BA:82:F9:75,PortNumber=30736,SubscriberId=PON 1/1/04/1:1.1.1
```

In the non-working case, you should see WARNINGs or ERRORs. There is one possibility
where you may not see any errors - this typically happens in State 1 of the AAA
state machine. Essentially, the RG (supplicant) sends an EAPOL_START message to the
Authenticator (ONOS), and the AAA app sends an EAPOL_IDENTITY_REQUEST back to the
RG. If this packet never reaches the RG, then the state machine will not proceed.

Go back to VOLTHA and ensure that the packet is making its way back to the OLT.

```shell
cord@node1:~$ kubectl logs -f -n voltha vcore-0 | grep -E "sending-packet-to-ONU" | grep 888e

20180912T003238.392 DEBUG    MainThread openolt_device.packet_out {ip: 10.90.0.151:9191, id: 00018e736871ac1c, packet: 90e2ba82fa8200000000100181000ffb888e010000040302000400000000000000000000000000000000000000000000000000000000000000000000, egress_port: 16, onu_id: 1, intf_id: 0, event: sending-packet-to-ONU, instance_id: compose_voltha_1_1536712228, vcore_id: 0001}
```

You should see an EAPOL packet (0x888e) being sent to the ONU in the logs. If you do see this,
consider doing a tcpdump in your RG to ensure that this packet is making it all the
way to the RG.

## Connectivity to RADIUS server

If instead you see in the ONOS logs that the state machine is stuck in State 2, it means
that the EAPOL_IDENTITY_REQUEST successfully reached the RG, and the RG responded with
an EAPOL_IDENTITY_REPLY which reached ONOS, causing the state machine to move on from
STARTED to PENDING state. At this point, the identity reply is packaged into a
RADIUS packet and sent to the RADIUS server by the AAA app.

The last hop from the AAA app in ONOS to the RADIUS server happens over the
management network. In a deployment it is entirely possible that the RADIUS server is
outside the SEBA pod, which means that you need to ensure that the POD has connectivity
to the server and that you have correctly configured details of the server in the pod.
