# RCORD Subscriber without real OLT/ONU

This procedure combines few steps from "bottom-up provisioning" and "top-down provisioning" resulting in XOS automatically creating an RCORD-Subscriber.
The Access device's (OLT/Ponport/ONU) are added to the model through "top-down provisioning" and the action of voltha publishing a newly discovered ONU to the kafka bus is simulated through a python script.

**Pre-Requisites:**

- all the components needed for RCORD-Lite are up and running on your POD (xos-core, rcord-lite, voltha, onos-voltha)
- configure 'OLT/PONPORT/ONU' devices.
  Sample TOSCA config given below:

```shell
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/oltdevice.yaml
  - custom_types/onudevice.yaml
  - custom_types/ponport.yaml
  - custom_types/voltservice.yaml
description: Create a simulated OLT Device in VOLTHA
topology_template:
  node_templates:

    device#olt:
      type: tosca.nodes.OLTDevice
      properties:
        device_type: simulated_olt
        host: 172.17.0.1
        port: 50060
        must-exist: true

    pon_port:
      type: tosca.nodes.PONPort
      properties:
        name: test_pon_port_1
        port_no: 2
        s_tag: 222
      requirements:
        - olt_device:
            node: device#olt
            relationship: tosca.relationships.BelongsToOne

    onu:
      type: tosca.nodes.ONUDevice
      properties:
        serial_number: BRCM1234
        vendor: Broadcom
      requirements:
        - pon_port:
            node: pon_port
            relationship: tosca.relationships.BelongsToOne
~
```

- configure 'kafka' 
  To deploy it please follow [this instruction.](../charts/kafka.md).

- configure 'hippie-oss' services
  To deploy the `hippie-oss` service follow [this instruction](../charts/hippie-oss.md).

**Push "onu-event" to kafka bus**

The following event needs to be pushed manually.

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
cordserver@cordserver:~$ kubectl get pods | grep rcord-lite-volt
rcord-lite-volt-dd98f78d6-rwwhz                                   1/1       Running            0          10d

cordserver@cordserver:~$ kubectl exec rcord-lite-volt-dd98f78d6-rwwhz python /opt/xos/synchronizers/volt/onu_activate_event.py
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
