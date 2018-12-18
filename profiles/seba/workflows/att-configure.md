# Configure AT&T Workflow

We assume your POD is already configured as per[this instructions](../configuration.md)
(you need to complete only the first section)

## Whitelist population

To configure the ONU whitelist, you can use this TOSCA:

```yaml
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/attworkflowdriverwhitelistentry.yaml
  - custom_types/attworkflowdriverservice.yaml
description: Create an entry in the whitelist
topology_template:
  node_templates:

    service#att:
      type: tosca.nodes.AttWorkflowDriverService
      properties:
        name: att-workflow-driver
        must-exist: true

    whitelist:
      type: tosca.nodes.AttWorkflowDriverWhiteListEntry
      properties:
        serial_number: BRCM22222222
        pon_port_id: 536870912
        device_id: of:000000000a5a0072
      requirements:
        - owner:
            node: service#att
            relationship: tosca.relationships.BelongsToOne
```

For instructions on how to push TOSCA into a CORD POD, please
refer to this [guide](../../../xos-tosca/README.md).

## Pre-provision subscribers

You can `pre-provision` subscribers using this TOSCA:

```yaml
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/rcordsubscriber.yaml

description: Pre-provsion a subscriber

topology_template:
  node_templates:

    # Pre-provision the subscriber the subscriber
    my_house:
      type: tosca.nodes.RCORDSubscriber
      properties:
        name: My House
        status: pre-provisioned
        c_tag: 111
        onu_device: BRCM22222222
        nas_port_id : "PON 1/1/03/1:1.1.1"
        circuit_id: foo
```

For instructions on how to push TOSCA into a CORD POD, please
refer to this [guide](../../../xos-tosca/README.md).

## OLT Activation

Once the system knows about whitelisted ONUs and subscribers,
you can activate the OLT:

```yaml
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/oltdevice.yaml
  - custom_types/voltservice.yaml
description: Create a simulated OLT Device in VOLTHA
topology_template:
  node_templates:

    service#volt:
      type: tosca.nodes.VOLTService
      properties:
        name: volt
        must-exist: true

    olt_device:
      type: tosca.nodes.OLTDevice
      properties:
        name: ONF OLT
        device_type: openolt
        host: 10.90.0.114
        port: 9191
        switch_datapath_id: of:0000000000000001
        switch_port: "1"
        outer_tpid: "0x8100"
        uplink: "128"
      requirements:
        - volt_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne
```

For instructions on how to push TOSCA into a CORD POD, please
refer to this [guide](../../../xos-tosca/README.md).

## Device monitoring

Please refer to the [monitoring](../../../charts/logging-monitoring.md) chart.
