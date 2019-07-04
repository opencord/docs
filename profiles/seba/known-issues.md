# Known Issues

## SEBA 2.0-alpha Release

This release of SEBA is qualified as 'alpha' due to known major issues related to the use of OLT software from Broadcom referred to as BAL - Broadband Adaptation Layer. The SEBA 2.0-alpha release uses [BAL 2.6](https://github.com/balapi/bal-api-2.6), which is no longer supported by Broadcom.

These issues are described in more detail in below:

* [SEBA-670](https://jira.opencord.org/browse/SEBA-670)
   This issue can be triggered by disable and subsequent re-enable of the ONU via NEM (or VOLTHA). In the SEBA pod, using the AT&T workflow, these actions are accompanied by the removal of subscriber flows upon disable of the ONU, and the reprogramming of eapol flows upon re-enable of the ONU. An irrecoverable error is seen in BAL (specifically bal_core_dist) which does not allow flows to be added to the OLT. As a result authentication of RG's fail.
* [SEBA-775](https://jira.opencord.org/browse/SEBA-775)
   This issue is closely related to SEBA-670. The fundamental issue is the removal of flows in the OLT which possibly leaves behind state in BAL 2.6 that does not allow the subsequent reprogramming of flows. It can be triggered by the disable/re-enable of ONUs (as in SEBA-670) or by the remove-subscriber followed by the add-subscriber calls (without change of ONU state). It can be triggered in systems with a single-ONU, as well as in multi-ONU cases. Empirically the issue is more easily reproduced in multi-ONU scenarios. It is observed with single gem ports as well as when multiple gem ports are used for a subscriber in the technology profile.
* [SEBA-777](https://jira.opencord.org/browse/SEBA-777)
   Due to the issues mentioned above, subscriber speed profiles cannot be updated reliably, as the update requires the removal of subscriber flows that point to a bandwidth meter, and the reprogramming of flows that point to a new meter.
* [SEBA-776](https://jira.opencord.org/browse/SEBA-776)
   This issue is seen sometimes with the use of multiple gem ports in a technology profile. Packet duplication appears to mirror the number of gem ports - using 4 gem ports results in 4 packets for every packet transmitted.

Fixes to these issues will be addressed in a future release  as we upgrade the OLT software to BAL 3.0.

In addition, OLT-reboot [SEBA-385](https://jira.opencord.org/browse/SEBA-385) can result in some ONUs not returning to ACTIVE state in VOLTHA.
