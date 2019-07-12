# SEBA Configuration

Once all the components needed for the SEBA profile are up and
running on your POD, you will need to configure it. This is typically
done using TOSCA.

In this page we describe the process of configuring parts of the SEBA Pod which do not relate to the Access configuration.
This configuration should happen before the Access configuration and provisioning that involves the ONUs, OLTs, TechProfiles and Subscribers.

Note that we are showing this configuration as appearing in multiple files as that is what logically makes sense, but be aware that all the configuration can be unified in a single TOSCA file.

This configuration is environment specific, so you will need to create your own, but the following can serve as a reference:

## POD Setup

The basic idea is to configure the Aggregation Switch, and provide information regarding the ports on which it connects to the OLTs and the external BNG.
We also need to tell the dhcpl2relay app (in ONOS) about the dhcp server.
The POD Setup consists of

- AGG switch configuration (In this case a single aggregation switch, see [Fabric](../../fabric/README.md) for more information)
- `BNGPortMapping` configuration (see [Fabric-crossconnet](../../fabric-crossconnect/README.md) for more information)
- DHCP L2 Relay configuration (see [ONOS DHCP L2 RELAY Application](https://github.com/opencord/dhcpl2relay/#configuration) for more information)

For simplicity this is encapsulated in a single TOSCA recipe:

```yaml
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/switch.yaml
  - custom_types/switchport.yaml
  - custom_types/portinterface.yaml
  - custom_types/bngportmapping.yaml
  - custom_types/attworkflowdriverwhitelistentry.yaml
  - custom_types/attworkflowdriverservice.yaml
  - custom_types/serviceinstanceattribute.yaml
  - custom_types/onosapp.yaml

description: Configures a full SEBA POD

topology_template:
  node_templates:
    # AGG switch configuration (configuration for the segmentrouting app in ONOS that controls the AGG switch)
    switch#leaf_1:
      type: tosca.nodes.Switch
      properties:
        driver: ofdpa3 # the ONOS driver used to talk to the switch
        ipv4Loopback: 192.168.0.201 # use any private IP address - this functionality is not used in SEBA
        ipv4NodeSid: 17 # use any number greater than 15 - this functionality is not used in SEBA
        isEdgeRouter: True # used to identify a leaf, which is always the case in SEBA
        name: AGG_SWITCH
        ofId: of:0000000000000001 # the openflow switch id representing the AGG switch
        routerMac: 00:00:02:01:06:01 # use any MAC address - this functionality is not used in SEBA

    # Setup the AGG switch port that connects to the OLT (or multiple such OLTs each on a different port)
    port#olt_port:
      type: tosca.nodes.SwitchPort
      properties:
        portId: 1 # the port on the AGG switch that connects to the OLT's NNI port
        host_learning: false
      requirements:
        - switch:
            node: switch#leaf_1
            relationship: tosca.relationships.BelongsToOne

    # Port connected to the BNG
    port#bng_port:
      type: tosca.nodes.SwitchPort
      properties:
        portId: 31 # the port on the AGG switch that connects to the BNG
      requirements:
        - switch:
            node: switch#leaf_1
            relationship: tosca.relationships.BelongsToOne

    # Configure BNGPortMapping
    bngmapping:
      type: tosca.nodes.BNGPortMapping
      properties:
        s_tag: any # allow this mapping to apply to any vlan tag
        switch_port: 31 # the port on the AGG switch that connects to the BNG

    # DHCP L2 Relay config configures the onos dhcpl2relay app to use the AGG switch's
    # uplink port (that connects to the BNG) to reach the DHCP server. It uses the
    # ONOS ConnectPoint structure that represents an <ofId>/<portId>, both of which
    # are configured above
    onos_app#dhcpl2relay:
      type: tosca.nodes.ONOSApp
      properties:
        name: dhcpl2relay
        must-exist: true

    dhcpl2relay-config-attr:
      type: tosca.nodes.ServiceInstanceAttribute
      properties:
        name: /onos/v1/network/configuration/apps/org.opencord.dhcpl2relay
        value: >
          {
            "dhcpl2relay" : {
              "useOltUplinkForServerPktInOut" : false,
              "dhcpServerConnectPoints" : [ "of:0000000000000001/31" ]
            }
          }
      requirements:
        - service_instance:
            node: onos_app#dhcpl2relay
            relationship: tosca.relationships.BelongsToOne
```

For instructions on how to push TOSCA into a CORD POD, please
refer to this [guide](../../xos-tosca/README.md).
