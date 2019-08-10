# AT&T Workflow Driver Service Instances

In a running system, once OLTs have been configured and ONUs are in active/enabled/reachable state in VOLTHA, you should see instances of the AT&T Workflow Driver in the NEM GUI, as shown below.

[ATT Workflow Instances](./screenshots/att-si-0.png)

The graphic above shows two such workflow instances, one for each ONU. If you do not see any workflow instances, refresh your GUI. If you still don't see anything, consider the [troubleshooting guide](../troubleshoot/no-att-si.md).

The instance for the Broadcom ONU `BRCM22222222` shows that the ONU has been validated against the whitelist. If the ONU's serial number or location (OLT device/PON port) does not match the configured information in the whitelist, then the workflow would display the `Admin onu state` as disabled with the appropriate `Status message` (for why it was disabled). The screenshot also shows that the workflow is awaiting the authentication of the RG connected to the UNI port on this ONU. Finally it also shows that the `DHCP state` is AWAITING - note that the DHCP process will not succeed without the RG first authenticating, according to the AT&T workflow. In production, RG's should automatically start the authentication process by sending EAPOL_START messages. In a lab setting, if you are using a linux host as an emulated RG, you will have to manually start the `wpa_supplicant` process as described [here](../lab-setup.md).

For the Iskratel ONU `ISKT71e801a0`, it shows that the ONU has been validated against the whitelist, and the RG behind the ONU has authenticated successfully (`Authentication state` is APPROVED). In production, RG's should automatically start the DHCP process to get a valid IP address from the upstream BNG. In a lab setting, if you are using a linux host as an emulated RG, you will have to manually start the `dhclient` process as described [here](../lab-setup.md).

Once both authentication and dhcp processes have succeeded, the workflow instances should display the following information.

[ATT Workflow Instances](./screenshots/att-si-1.png)

Note that the DHCP state displays `DHCPACK` and the IP addresses assigned by the external BNG are also displayed, together with the RG's MAC addresses discovered by the system. At this point the subscriber should be able to reach the Internet with the configured bandwidthprofile for the subscriber, and the traffic priorities determined by the configured tech profile.

If authentication or dhcp does not succeed, or your pings are not getting through, consider their respective troubleshooting guides.
