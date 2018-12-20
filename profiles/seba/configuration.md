# SEBA Configuration

Once all the components needed for the SEBA profile are up and
running on your POD, you will need to configure it. This is typically
done using TOSCA.

In this page we are describing the process as a three steps process:

- [Fabric Setup](./configuration.md#fabric-setup)
- [OLT Provisioning](./configuration.md#olt-provisioning)
- [Subscriber Provisioning](./configuration.md#subscriber-provisioning)

as that is what logically makes sense, but be aware that all the configurations
can be unified in a single TOSCA file.

This configuration is environment specific, so
you will need to create your own, but the following can serve as a
reference:

## Fabric Setup

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
    # Fabric configuration
    switch#leaf_1:
      type: tosca.nodes.Switch
      properties:
        driver: ofdpa3
        ipv4Loopback: 192.168.0.201
        ipv4NodeSid: 17
        isEdgeRouter: True
        name: AGG_SWITCH
        ofId: of:0000000000000001
        routerMac: 00:00:02:01:06:01

    # Setup the OLT switch port
    port#olt_port:
      type: tosca.nodes.SwitchPort
      properties:
        portId: 1
        host_learning: false
      requirements:
        - switch:
            node: switch#leaf_1
            relationship: tosca.relationships.BelongsToOne

    # Port connected to the BNG
    port#bng_port:
      type: tosca.nodes.SwitchPort
      properties:
        portId: 31
      requirements:
        - switch:
            node: switch#leaf_1
            relationship: tosca.relationships.BelongsToOne

    # Setup the fabric switch port where the external
    # router is connected to
    bngmapping:
      type: tosca.nodes.BNGPortMapping
      properties:
        s_tag: any
        switch_port: 31

    # DHCP L2 Relay config
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

## OLT Provisioning

```yaml
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/oltdevice.yaml
  - custom_types/onudevice.yaml
  - custom_types/voltservice.yaml
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
        host: 10.90.0.122
        port: 9191
        switch_datapath_id: of:0000000000000002 # the openflow switch to which the OLT is connected
        switch_port: "1" # the port on the switch on which the OLT is connected
        outer_tpid: "0x8100"
        uplink: "65536"
        nas_id: "NAS_ID"
        serial_number: "10.90.0.122:9191"
      requirements:
        - volt_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne
```

For instructions on how to push TOSCA into a CORD POD, please
refer to this [guide](../../xos-tosca/README.md).

## Subscriber Provisioning

Once the POD has been configured, you can create a subscriber.

To create a subscriber, you'll need to know the serial number of the ONU it is
attached to.

### Find ONU Serial Number

Once your POD is set up and the OLT has been pushed and activated in VOLTHA,
XOS will discover the ONUs available in the system.

You can find them through:

- XOS GUI: on the left side click on `vOLT > ONUDevices`
- XOS Rest API: `http://<pod-id>:<chameleon-port|30006>/xosapi/v1/volt/onudevices`
- VOLTHA CLI: [Command Line Interface](../../charts/voltha.md#how-to-access-the-voltha-cli)

If you are connected to the VOLTHA CLI you can use the following
command to list all the existing devices:

```shell
(voltha) devices
Devices:
+------------------+--------------+------+------------------+-------------+-------------+----------------+----------------+------------------+----------+-------------------------+----------------------+------------------------------+
|               id |         type | root |        parent_id | admin_state | oper_status | connect_status | parent_port_no |    host_and_port | vendor_id| proxy_address.device_id | proxy_address.onu_id | proxy_address.onu_session_id |
+------------------+--------------+------+------------------+-------------+-------------+----------------+----------------+------------------+----------+-------------------------+----------------------+------------------------------+
| 0001941bd45e71d8 |      openolt | True | 000100000a5a0072 |     ENABLED |      ACTIVE |      REACHABLE |                | 10.90.0.114:9191 |          |                         |                      |                              |
| 00015698e67dc060 | broadcom_onu | True | 0001941bd45e71d8 |     ENABLED |      ACTIVE |      REACHABLE |      536870912 |                  |      BRCM|        0001941bd45e71d8 |                    1 |                            1 |
+------------------+--------------+------+------------------+-------------+-------------+----------------+----------------+------------------+----------+-------------------------+----------------------+------------------------------+
```

Locate the correct ONU, then:

```shell
(voltha) device 00015698e67dc060
(device 00015698e67dc060) show
Device 00015698e67dc060
+------------------------------+------------------+
|                        field |            value |
+------------------------------+------------------+
|                           id | 00015698e67dc060 |
|                         type |     broadcom_onu |
|                         root |             True |
|                    parent_id | 0001941bd45e71d8 |
|                       vendor |         Broadcom |
|                        model |              n/a |
|             hardware_version |     to be filled |
|             firmware_version |     to be filled |
|                 images.image |        1 item(s) |
|                serial_number |     BRCM22222222 |
+------------------------------+------------------+
|                      adapter |     broadcom_onu |
|                  admin_state |                3 |
|                  oper_status |                4 |
|               connect_status |                2 |
|      proxy_address.device_id | 0001941bd45e71d8 |
|         proxy_address.onu_id |                1 |
| proxy_address.onu_session_id |                1 |
|               parent_port_no |        536870912 |
|                    vendor_id |             BRCM |
|                        ports |        2 item(s) |
+------------------------------+------------------+
|                  flows.items |        5 item(s) |
+------------------------------+------------------+
```

to find the correct serial number.

### Push a Subscriber into CORD

Once you have this information, you can create the subscriber by
customizing the following TOSCA and passing it into the POD:

```yaml
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/rcordsubscriber.yaml
description: Create a test subscriber
topology_template:
  node_templates:
    # A subscriber
    my_house:
      type: tosca.nodes.RCORDSubscriber
      properties:
        name: My House
        c_tag: 111
        s_tag: 222
        onu_device: BRCM1234 # Serial Number of the ONU Device to which this subscriber is connected
```

For instructions on how to push TOSCA into a CORD POD, please
refer to this [guide](../../xos-tosca/README.md).
