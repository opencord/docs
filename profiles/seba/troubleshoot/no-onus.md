# ONUs are not getting discovered

If ONUs are not getting discovered you can debug it following these steps.

## Check ONOS CLI

Check if the ONU is displayed in the ``ports`` command in the ONOS CLI. The portName corresponds to the serial number of the ONU.
```
onos> ports
id=of:0000626273696d62, available=true, local-status=connected 4m4s ago, role=MASTER, type=SWITCH, mfr=VOLTHA Project, hw=, sw=, serial=bbsim:50060, chassis=626273696d62, driver=voltha, channelId=172.17.0.16:43266, managementAddress=172.17.0.16, protocol=OF_13
  port=2064, state=enabled, type=fiber, speed=0 , adminState=enabled, portMac=08:00:00:01:08:10, portName=BBSM00000100
```

If the port corresponding to the ONU is not displayed or has ``adminState=disabled``, then check the VOLTHA CLI.

## Check VOLTHA CLI

Check if the ONU shows up in the ``ports`` of the ``logical_device`` in the VOLTHA CLI. The ``ofp_port.name`` column corresponds to the serial number of the ONU.

```
(voltha) logical_devices
Logical devices:
+------------------+------------------+------------------+-----------------+---------------------------+--------------------------+
|               id |      datapath_id |   root_device_id | desc.serial_num | switch_features.n_buffers | switch_features.n_tables |
+------------------+------------------+------------------+-----------------+---------------------------+--------------------------+
| 0001626273696d62 | 0000626273696d62 | 000129f21f7b4032 |     bbsim:50060 |                       256 |                        2 |
+------------------+------------------+------------------+-----------------+---------------------------+--------------------------+
(voltha) logical_device 0001626273696d62
(logical device 0001626273696d62) ports
Logical device ports:
+-----------+------------------+----------------+-----------+------------------+----------------------------+---------------+----------------+---------------+---------------------+------------------------+
|        id |        device_id | device_port_no | root_port | ofp_port.port_no |           ofp_port.hw_addr | ofp_port.name | ofp_port.state | ofp_port.curr | ofp_port.curr_speed | ofp_port_stats.port_no |
+-----------+------------------+----------------+-----------+------------------+----------------------------+---------------+----------------+---------------+---------------------+------------------------+
| nni-65536 | 000129f21f7b4032 |          65536 |      True |            65536 |   [0L, 0L, 0L, 1L, 0L, 0L] |     nni-65536 |              4 |          4128 |                  32 |                  65536 |
|  uni-2064 | 0001969090d72daf |           2064 |           |             2064 |  [8L, 0L, 0L, 1L, 8L, 16L] |  BBSM00000100 |              4 |          4160 |                  64 |                        |
+-----------+------------------+----------------+-----------+------------------+----------------------------+---------------+----------------+---------------+---------------------+------------------------+
```

If the port corresponding to the ONU is not displayed then [check physical OLT](#check-physical-olt). If the port corresponding to the UNI appears in the ``logical_device``, then check the port status:

```
(voltha) device 0001969090d72daf
(device 0001969090d72daf) ports
Device ports:
+---------+----------+--------------+-------------+-------------+------------------+-------------------------------------------------------+
| port_no |    label |         type | admin_state | oper_status |        device_id |                                                 peers |
+---------+----------+--------------+-------------+-------------+------------------+-------------------------------------------------------+
|     100 | PON port |      PON_ONU |     ENABLED |      ACTIVE | 0001969090d72daf | [{'port_no': 2064, 'device_id': u'000129f21f7b4032'}] |
|    2064 | uni-2064 | ETHERNET_UNI |     ENABLED |      ACTIVE | 0001969090d72daf |                                                       |
+---------+----------+--------------+-------------+-------------+------------------+-------------------------------------------------------+
```
If the ``oper_state`` of the port is not ``ACTIVE`` then check the following.

### ONU is in DISCOVERED state

### ONU is in DISABLED state

### ONU is in UNREACHABLE state

## Check physical OLT

## Check physical ONU

