# R-CORD Configuration

Once all the components needed for the R-CORD profile are up and
running on your POD, you will need to configure it. This is typically
done using TOSCA. This configuration is environment specific, so
you will need to create your own, but the following can serve as a
reference:

```yaml
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/oltdevice.yaml
  - custom_types/switch.yaml
  - custom_types/switchport.yaml
  - custom_types/portinterface.yaml
  - custom_types/voltservice.yaml
  - custom_types/vrouterserviceinstance.yaml
  - custom_types/vrouterstaticroute.yaml

description: Configures a full R-CORD POD

topology_template:
  node_templates:
    # Fabric configuration
    switch#my_fabric_switch:
      type: tosca.nodes.Switch
      properties:
        driver: ofdpa3
        ipv4Loopback: 192.168.0.201
        ipv4NodeSid: 17
        isEdgeRouter: True
        name: my_fabric_switch
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
            node: switch#my_fabric_switch
            relationship: tosca.relationships.BelongsToOne

    # Setup the OLT switch port interface
    interface#olt_interface:
      type: tosca.nodes.PortInterface
      properties:
        ips: 192.168.0.254/24
        name: olt_interface
      requirements:
        - port:
            node: port#olt_port
            relationship: tosca.relationships.BelongsToOne

    # Setup the fabric switch port where the external
    # router is connected to
    port#vrouter_port:
      type: tosca.nodes.SwitchPort
      properties:
        portId: 31
      requirements:
        - switch:
            node: switch#my_fabric_switch
            relationship: tosca.relationships.BelongsToOne

    # Setup the fabric switch port interface where the
    # external router is connected to
    interface#vrouter_interface:
      type: tosca.nodes.PortInterface
      properties:
        name: vrouter_interface
        vlanUntagged: 40
        ips: 10.231.254.2/29
      requirements:
        - port:
            node: port#vrouter_port
            relationship: tosca.relationships.BelongsToOne

    # Add a vRouter (ONOS)
    vrouter#my_vrouter:
      type: tosca.nodes.VRouterServiceInstance
      properties:
        name: my_vrouter

    # Add a static route to the vRouter (ONOS)
    route#my_route:
      type: tosca.nodes.VRouterStaticRoute
      properties:
        prefix: "0.0.0.0/0"
        next_hop: "10.231.254.1"
      requirements:
        - vrouter:
            node: vrouter#my_vrouter
            relationship: tosca.relationships.BelongsToOne

    # Setup the OLT service
    service#volt:
      type: tosca.nodes.VOLTService
      properties:
        name: volt
        must-exist: true

    # Setup the OLT device
    olt_device:
      type: tosca.nodes.OLTDevice
      properties:
        name: volt-1
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
refer to this [guide](../../xos-tosca/README.md).

## Top-Down Subscriber Provisioning

Once the POD has been configured, you can create a subscriber. This
section describes a "top-down" approach for doing that. (The following
section describes an alternative, "bottom up" approach.)

To create a subscriber, you need to retrieve some information:

- ONU Serial Number
- Mac Address
- IP Address

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
        onu_device: BRCM1234 # Serial Number of the ONU Device to which this subscriber is connected
        mac_address: 00:AA:00:00:00:01 # subscriber mac address
        ip_address: 10.8.2.1 # subscriber IP
```

For instructions on how to push TOSCA into a CORD POD, please
refer to this [guide](../../xos-tosca/README.md).

## Zero-Touch Subscriber Provisioning

This feature, also referred to as "bottom-up" provisioning,
enables auto-discovery of subscribers and validates them
using an external OSS.

The expected workflow is as follows:

- When an ONU is attached to the POD, VOLTHA will discover it and send
   an event to XOS
- XOS receives the ONU activation event and through an OSS proxy
   queries the upstream OSS to validate wether that ONU has a valid serial number
- Once the OSS has approved the ONU, XOS will create `ServiceInstance`
  chain for this particular subscriber and configure the POD to enable connectivity

To enable the zero-touch provisioning feature, you will need to deploy
and configure some extra pieces into the system before attaching
subscribers:

### Deploy Kafka

To enable this feature XOS needs to receive events from `onos-voltha`,
so a kafka bus needs to be deployed.
To deploy Kafka, please follow these [instructions](../../charts/kafka.md)

### Deploy OSS Proxy

This is the piece of code that is responsible to connecting CORD to an
external OSS Database. As a simple reference, we provide a sample
implemetation, available here:
[hippie-oss](https://github.com/opencord/hippie-oss)

> **Note:** This implementation currently validates any subscriber that comes online.

To deploy the `hippie-oss` service you can look [here](../../charts/hippie-oss.md).

Once the chart has come online, you will need to add the Hippie-OSS service
to your service graph. You can use the following TOSCA to do that:

```yaml
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/hippieossservice.yaml
  - custom_types/servicedependency.yaml
  - custom_types/voltservice.yaml
description: Create an instance of the OSS Service and connect it to the vOLT Service
topology_template:
  node_templates:

    # Reference the VOLTService
    service#volt:
      type: tosca.nodes.VOLTService
      properties:
        name: volt
        must-exist: true

    # Reference the HippieOSSService
    service#oss:
      type: tosca.nodes.HippieOSSService
      properties:
        name: hippie-oss
        kind: oss
        # blacklist: BRCM1234, BRCM4321 # this is an optional list of ONUs that you don't want to validate

    # Create a ServiceDependency between the two
    service_dependency#oss_volt:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#oss
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne
```

For instructions on how to push TOSCA into a CORD POD, please
refer to this [guide](../../xos-tosca/README.md).
