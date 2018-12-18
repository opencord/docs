# Scale testing using BBSim

Broadband Simulator (BBSim) is a control-plane only simulator that is used to
test a SEBA POD at scale. On the one hand, unlike ponsim which emulates both the
control and data plane, BBSim only does the former. On the other hand, BBsim can
potentially simulate tens of OLTs and thousands of ONUs, making it an ideal tool
for control plane scale testing. One additional benefit of BBSim is that it
uses the OpenOLT adaptor in VOLTHA, unlike ponsim which uses its own specialized
adaptor.

You can run BBSim on top of any SEBA installation, physical or virtual (SiaB).
For instructions on how to install it you can refer to the [bbsim](../../charts/bbsim.md) helm reference.

## System configurations that affects BBSim

The most important detail that determines how BBSim will behave is the L2-DHCP-relay
configuration of the SEBA installation.

There are two options:

- sending DHCP packets out of the AGG switch's uplink port
- sending DHCP packets out of the OLT's NNI port

### DHCP Packets through the aggregation switch

This is the way a physical POD is set up to work. If you decide to follow this
route no changes are required in the configuration but you'll need to make sure
your DHCP server is configured to assign IP Addresses to subscriber requesting
them with `S-Tag` set as `999` and `C-Tag` starting from `900` for the first
subscriber and increasing by one for each subscriber.

### DHCP Packets back to the OLT

If you don't have a DHCP server configured accordingly you can use the DHCP server
that runs inside BBSim itself. To do that you need to send the DHCP Packets
back to the OLT.

To do that you can use this TOSCA recipe: <https://github.com/opencord/helm-charts/blob/master/examples/bbsim-dhcp.yaml>
