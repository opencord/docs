# R-CORD Configuration 

Once all the components needed for RCORD-Lite are up and running on your POD,
you'll need to configure XOS with the proper configuration. 
Since this configuration is environment specific, you'll need to create your own,
but the following can serve as a reference for it:

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

_For instructions on how to push TOSCA, please refer to this [guide](../../xos-tosca/README.md)_

Once the POD has been configured, you can create a subscriber,
please refer to the [RCORD Service](../../rcord/README.md) guide for
more informations.

### Create a subscriber in RCORD

To create a subscriber in CORD you need to retrieve some informations:

- ONU Serial Number
- UNI Port ID
- Mac Address
- IP Address

We'll focus on the first two as the others are pretty self-explaining.

**Find the ONU Serial Number**

Once your POD is set up and the OLT has been pushed and activated in VOLTHA,
XOS will discover the ONUs available in the system.

You can find them trough:

- the XOS UI, on the left side click on `vOLT > ONUDevices`
- the rest APIs `http://<pod-id>:<chameleon-port|30006>/xosapi/v1/volt/onudevices`
- the VOLTHA [cli](../../charts/voltha.md#how-to-access-the-voltha-cli)

If you are connected to the VOLTHA CLI you can use the command:

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
to list all the existing devices, and locate the correct ONU, then:

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

**Find the UNI Port Id**

From the VOLTHA CLI, in the device command prompt execute:

```shell
(device 00015698e67dc060) ports
Device ports:
+---------+----------+--------------+-------------+-------------+------------------+-----------------------------------------------------+
| port_no |    label |         type | admin_state | oper_status |        device_id |                                               peers |
+---------+----------+--------------+-------------+-------------+------------------+-----------------------------------------------------+
|     100 | PON port |      PON_ONU |     ENABLED |      ACTIVE | 00015698e67dc060 | [{'port_no': 16, 'device_id': u'0001941bd45e71d8'}] |
|      16 |   uni-16 | ETHERNET_UNI |     ENABLED |      ACTIVE | 00015698e67dc060 |                                                     |
+---------+----------+--------------+-------------+-------------+------------------+-----------------------------------------------------+
```
and locate the `ETHERNET_UNI` port.
The `port_no` for that port is the value you are looking for.

**Push a subscriber into CORD**

Once you have the informations you need about your subscriber,
you can create it by customizing this TOSCA:

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
        uni_port_id: 16 # UNI PORT ID in VOLTHA
        mac_address: 00:AA:00:00:00:01 # subscriber mac address
        ip_address: 10.8.2.1 # subscriber IP
```

_For instructions on how to push TOSCA, please refer to this [guide](../../xos-tosca/README.md)_

### Zero-Touch Subscriber Provisioning

This feature, also referred to as "bottom-up provisioning" enables auto-discovery
of subscriber and their validation through an external OSS.

Here is the expected workflow:

- when an ONU is attached to the POD, VOLTHA will discover it and send an event to XOS
- XOS receive the ONU activated events and through an OSS-Service query the upstream OSS to validate wether that ONU has a valid serial number
- once the OSS has approved the ONU, XOS will create `ServiceInstance` chain for this particular subscriber and configure the POD to give him connectivity

If you want to enable the "Zero touch provisioning" feature you'll need
to deploy and configure some extra pieces in the system before attaching
subscribers:

**Kafka**

To enable this feature XOS needs to receive events from `onos-voltha`
so a kafka bus needs to be deployed.
To deploy it please follow [this instructions](../../charts/kafka.md)

**OSS Service**

This is the piece of code that is responsible to enable the communication
between CORD and you OSS Database.
For reference we are providing a sample implemetation, available here:
[hippie-oss](https://github.com/opencord/hippie-oss)

> **Note:** This implementation currently validates any subscriber that comes online.

To deploy the `hippie-oss` service you can look [here](../../charts/hippie-oss.md).

Once the chart has come online, you'll need to add it to your service graph,
and you can use this TOSCA for that:

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

_For instructions on how to push TOSCA, please refer to this [guide](../../xos-tosca/README.md)_

### Automatic creation of RCORD Subscriber without real OLT/ONU

This feature combines few steps from "bottom-up provisioning" and "top-down provisioning" resulting in XOS automatically creating an RCORD-Subscriber.
The Access device's (OLT/Ponport/ONU) are added to the model through "top-down provisioning" and the action of voltha publishing a newly discovered ONU to the kafka bus is simulated through a python script.

**Pre-Requisites:**

- all the components needed for RCORD-Lite are up and running on your POD (xos-core, rcord-lite, voltha, onos-voltha)
- configure 'OLT/PONPORT/ONU' devices as defined in the "R-CORD Configuration" section above.
- configure 'kafka' and 'hippie-oss' services as defined in the "Zero-Touch Subscriber Provisioning" section above.
- verify the services are running and the configured access devices are listed in the corresponding service-instances (through REST calls or GUI).

**Push "onu-event" to kafka bus**

The following event needs to be pushed.

```shell
event = json.dumps({
    'status': 'activated',
    'serial_number': 'BRCM1234',
    'uni_port_id': 16,
    'of_dpid': 'of:109299321'
})
```

Make sure that the 'serial_number' in the event above matches the 'serial_number' you configured when adding the ONU device. XOS uses the serial number to make sure the device is actually listed (volt/onudevices).

The script for pushing the onu-event to kafka "onu_activate_event.py" is already available in the container running volt-synchronizer and you may execute it as:

```shell

cordserver@cordserver:~/kubespray$ vagrant status
Current machine states:

k8s-01                    running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.

cordserver@cordserver:~/kubespray$ vagrant ssh k8s-01
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.4.0-87-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

55 packages can be updated.
25 updates are security updates.

Last login: Sun Jun 17 14:42:13 2018 from 10.0.2.2

vagrant@k8s-01:~$ sudo docker ps | grep volt-syn
c4ad2559021d        xosproject/volt-synchronizer@sha256:b9af8fbf1d43e5199e68039d6a952a8535544c51e265914fc2f0bec7a32cd4c1                                     "/usr/bin/python /..."   10 days ago         Up 10 days                              k8s_volt_rcord-lite-volt-dd98f78d6-rwwhz_default_48103970-6b3c-11e8-be33-080027ee1df7_0
vagrant@k8s-01:~$ sudo docker exec -it c4ad2559021d /bin/bash
root@rcord-lite-volt-dd98f78d6-rwwhz:/opt/xos/synchronizers/volt# pwd
/opt/xos/synchronizers/volt
root@rcord-lite-volt-dd98f78d6-rwwhz:/opt/xos/synchronizers/volt# python onu_activate_event.py

```

Or you can directly execute it through kubectl

```shell
cordserver@cordserver:~$ kubectl get pods | grep rcord-lite-volt
rcord-lite-volt-dd98f78d6-rwwhz                                   1/1       Running            0          10d

cordserver@cordserver:~$ kubectl exec rcord-lite-volt-dd98f78d6-rwwhz python /opt/xos/synchronizers/volt/onu_activate_event.py
cordserver@cordserver:~$
```

If you need to update the contents of event file, you have to do an "apt update" and "apt install vim" within the container.


**Verification**

- verify the hippie-oss service instance is created for the event (verify the serial number of ONU). hippie-oss service is intended to verify ONU (serial number) with an external OSS-db. This verification is now configured to always validate the ONU.
- verify a new rcord-subscriber service instance is created.
- Once the rcord-subscriber service instance is created service graph will make sure a new service instances are created for volt and vsg-hw models.

```shell
curl -X GET http://172.17.8.101:30006/xosapi/v1/hippie-oss/hippieossserviceinstances -u "admin@opencord.org:letmein"
curl -X GET http://172.17.8.101:30006/xosapi/v1/rcord/rcordsubscribers -u "admin@opencord.org:letmein"
curl -X GET http://172.17.8.101:30006/xosapi/v1/volt/voltserviceinstances -u "admin@opencord.org:letmein"
curl -X GET http://172.17.8.101:30006/xosapi/v1/vsg-hw/vsghwserviceinstances -u "admin@opencord.org:letmein"
```
