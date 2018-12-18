# Install AT&T Workflow

You can find a complete description of the SEBA workflow for At&t in [this document](https://docs.google.com/document/d/1nou2c8AsRzhaDJmA_eYvFgd0Y33KiCsioveU77AOVCI/edit#heading=h.x73smxj2xaib). This pages focus exclusively on the internals details of the workflow such as actions triggered by the environment and decisions taken by NEM.

## Install the `att-workflow` chart

```shell
helm install -n att-workflow cord/att-workflow --version=1.0.0
```

> NOTE: if you have installed the `cord-platform` chart as a sum of its components,
> then you need to specify `--set att-workflow-driver.kafkaService=cord-kafka`
> during the installation command to match the name of the kafka service.

## Workflow description

1. ONT discovered bottom-up
2. If ONT serial number is not allowed or unknown (i.e it has NOT been provisioned by OSS), disable the ONT; generate an event to external OSS that an ONU has been discovered but not yet provisioned.
3. When OSS provisions the ONT, re-enable it & program 802.1x flow - UNI port(s) will be UP
4. Ensure that DHCP fails here (because subscriber/service-binding has not been provisioned by OSS yet)
5. 802.1x EAPOL message happens from RG, and ONOS AAA app adds options and sends to radius server. Options are pulled from Sadis/NEM  - no subscriber information is required here
6. If RG authentication fails, allow it to keep trying (in the future consider redirection to captive / self-help portal). DHCP should not succeed since RG authentication has failed
7. If RG authentication succeeds, ONOS AAA app notifies via an event on the kafka bus that authentication has succeeded
8. NEM can listen for the event, and then check to see if subscriber/service-binding has happened on that port from OSS - if not, then nothing to be done
9. Must ensure that DHCP fails here even though RG has been authenticated (because subscriber/service-binding has not been provisioned by OSS yet)
10. When OSS provisions the subscriber/service-binding on the UNI port and gives the C and S vlan info, then DHCP trap will be programmed on the port, and DHCP process can start
11. If RG is disconnected from UNI port, force authentication again (even if subscriber/service-binding has been provisioned by OSS). Upon reconnection  to UNI port, RG must re-authenticate before DHCP/other-traffic can flow on the provisioned VLANs.
12. DHCP L2 relay -> add option 82, learn public IP address, forward via dataplane to external DHCP server


This schema summarizes the workflow, please note:

- in `light blue` are environment events (wether they are triggered from hardware or from an operator)
- in `yellow` are NEM configuration calls to ONOS or VOLTHA
- in `green` are decisions
- in `orange` event published on the kafka bus

![att-workflow](../../../images/att_workflow.png)

> NOTE: when we refer to `service chain` we are talking about the set of
subscriber specific service instances that will trigger the `add_subscriber`
call in ONOS-VOLTHA and provision the crossconnect in ONOS-FABRIC
