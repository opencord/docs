# OLT Provisioning

OLT Provisioning consists of specifying the fields shown below to instruct NEM about the serial number of the OLT, and where it can be reached in the management network.
As soon as this config is pushed, NEM will load VOLTHA's etcd with the technology profile, and make the 'preprovision' and 'enable' calls to VOLTHA with the OLT information.

OLT provisioning can use the same yaml file where the Technology profile is configured.
For clarity it is shown separately below.

Learn more about the OLT service [here](../../../olt-service/README.md)


```yaml
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/oltdevice.yaml
  - custom_types/onudevice.yaml
  - custom_types/voltservice.yaml
  - custom_types/technologyprofile.yaml
description: Create an OLT Device in VOLTHA
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
        name: My OLT
        device_type: openolt
        host: 10.90.0.122 # the IP address where the OLT can be reached on the management network
        port: 9191
        switch_datapath_id: of:0000000000000001 # the openflow id of the switch to which the OLT is connected
        switch_port: "1" # the port on the switch on which the OLT is connected
        outer_tpid: "0x8100"
        uplink: "65536" # the NNI port on the OLT
        nas_id: "NAS_ID"
        serial_number: EC1721000208 # the serial number of the OLT device
      requirements:
        - volt_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne
```
