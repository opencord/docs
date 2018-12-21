# Known Issues

## SEBA 1.0 Release

The only known major issues have to do with reboot of physical hardware, both
the OLT and the AGG switch. These issues are described in more detail in

* [SEBA-388](https://jira.opencord.org/browse/SEBA-388)
   With this issue, DHCP may not work after AGG switch reboot. A possible workaround is to use a different config for the DHCPl2Relay app that uses the OLT's uplink to reach the DHCP Server, instead of the Switch's uplink. More details are described [here](troubleshoot/no-dhcp.md)
* [SEBA-385](https://jira.opencord.org/browse/SEBA-385)
   With this issue, the OLT may not pass traffic anymore after reboot. Currently, the only workaround is to, enter the ONOS CLI and force a 'device-remove <&lt;device-id>' for the device from VOLTHA (in other words, force VOLTHA to reconnect to ONOS), and then perform the authentication/dhcp steps again for the subscribers

Fixes to these issues will be addressed soon after the release.

Another minor issue that does not affect functionality is related to the state of an ONU on the VOLTHA CLI, after disable/re-enable of the ONU.

```shell
(voltha) devices
Devices:
+------------------+-------------------+------+------------------+------------------+-------------+-------------+----------------+----------------+------------------+------------------------+-------------------------+--------------------------+----------------------+------------------------------+
|               id |              type | root |        parent_id |    serial_number | admin_state | oper_status | connect_status | parent_port_no |    host_and_port |                 reason | proxy_address.device_id | proxy_address.channel_id | proxy_address.onu_id | proxy_address.onu_session_id |
+------------------+-------------------+------+------------------+------------------+-------------+-------------+----------------+----------------+------------------+------------------------+-------------------------+--------------------------+----------------------+------------------------------+
| 0001a82d21249c28 |           openolt | True | 000100000a5a007a | 10.90.0.122:9191 |     ENABLED |      ACTIVE |      REACHABLE |                | 10.90.0.122:9191 |                        |                         |                          |                      |                              |
| 00014f81e9f21dbb | brcm_openomci_onu | True | 0001a82d21249c28 |     ALPHe3d1cf9d |     ENABLED |      ACTIVE |      REACHABLE |      536870912 |                  | initial-mib-downloaded |        0001a82d21249c28 |                          |                    1 |                            1 |
| 0001666321e17127 | brcm_openomci_onu | True | 0001a82d21249c28 |     ALPHe3d1ced5 |     ENABLED |      ACTIVE |      REACHABLE |      536870912 |                  | initial-mib-downloaded |        0001a82d21249c28 |                          |                    2 |                            2 |
| 000175a511654437 | brcm_openomci_onu | True | 0001a82d21249c28 |     ISKT71e80080 |     ENABLED |      ACTIVE |      REACHABLE |      536870927 |                  |      omci-flows-pushed |        0001a82d21249c28 |                       15 |                    1 |                            1 |
| 0001cb66a703449d | brcm_openomci_onu | True | 0001a82d21249c28 |     ALPHe3d1cfe3 |     ENABLED |      ACTIVE |      REACHABLE |      536870912 |                  | initial-mib-downloaded |        0001a82d21249c28 |                          |                    3 |                            3 |
| 0001246c72a99ddd | brcm_openomci_onu | True | 0001a82d21249c28 |     ALPHe3d1cf8e |     ENABLED |      ACTIVE |      REACHABLE |      536870912 |                  | initial-mib-downloaded |        0001a82d21249c28 |                          |                    4 |                            4 |
| 000192f54601ecb4 | brcm_openomci_onu | True | 0001a82d21249c28 |     ALPHe3d1cf70 |     ENABLED |      ACTIVE |      REACHABLE |      536870912 |                  | initial-mib-downloaded |        0001a82d21249c28 |                          |                    5 |                            5 |
+------------------+-------------------+------+------------------+------------------+-------------+-------------+----------------+----------------+------------------+------------------------+-------------------------+--------------------------+----------------------+------------------------------+
```

In the `reason` column of the devices table, the state of the ONU devices are displayed. Normally after an ONU is disabled, and then re-enabled, it should display the `initial-mib-downloaded` state, indicating that the RG behind the ONU should be ready to re-authenticate (as per the AT&T workflow). However, in this release, the state is incorrectly displayed as `omci-flows-pushed`. This does not affect authentication, dhcp or the subscribers.
