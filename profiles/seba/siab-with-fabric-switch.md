# SEBA-in-a-Box with a fabric switch

The following procedure describes how to set up SEBA-in-a-Box with a physical fabric switch instead of an emulated switch.

This is the assumed topology:

```text
Kubernetes node running OLT [ens1d1]-------[2]fabric switch[1]-----------[ens1d1]BNG/DHCP-server
```

1. Perform all install procedures described in the [SEBA-in-a-Box installation instructions](siab.md) except sections **Install Mininet** and **Load TOSCA into NEM**.

1. Fabric switch bringup.  To bring up the fabric switch, follow the procedure [here](../../installation/fabric-setup.md) and verify the fabric switch is discovered by onos (`ssh -p 30115 onos@K8S_NODE_IP devices`).

1. Enable EAPOL on Linux bridge `pon0.0` and add the physical interface on the Kubernetes node running PONSIM-OLT to `nni0` bridge.

    ```bash
    $ sudo brctl addif nni0 ens1d1
    $ brctl show
    bridge name     bridge id               STP enabled     interfaces
    docker0         8000.02426df5adb1       no
    nni0            8000.0a580a170001       no              veth6abcdca3
                                                            ens1d1
    pon0.0          8000.52f6b00415e4       no              veth212f887a
                                                            veth84cbf365
    $ echo 8 > /tmp/group_fwd_mask
    $ sudo cp /tmp/group_fwd_mask /sys/class/net/pon0.0/bridge/group_fwd_mask
    ```

1. Modify `~/cord/helm-charts/xos-profiles/ponsim-pod/tosca/020-pod-olt.yaml`.  Update `switch_datapath_id` to your fabric-switch dpid and `switch_port` to the port number of Fabric-switch to which the Kubernetes node running OLT is connected.
    ```yaml
      olt_device:
        type: tosca.nodes.OLTDevice
        properties:
          ...
          switch_datapath_id: of:0000a82bb57111f8
          switch_port: "2"
          outer_tpid: "0x8100"
          dp_id: of:0000aabbccddeeff
          uplink: "2"
        ...
    ```

1. Modify `~/cord/helm-charts/xos-profiles/ponsim-pod/tosca/030-fabric.yaml`.  Update `driver` to "ofdpa3", `ofId` to Fabric-switch dpid, `olt_port:portId` to the port number of Fabric-switch to which the Kubernetes node running OLT is connected, and `bng_port:portId` and `bngmapping:switch_port` to the port number of Fabric-switch to which BNG/DHCP-server is connected.
    ```yaml
    ...
      switch#leaf_1:
        type: tosca.nodes.Switch
        properties:
          driver: ofdpa3
          ...
          name: leaf_1
          ofId: of:0000a82bb57111f8
          routerMac: a8:2b:b5:71:11:f9
      # Setup the OLT switch port
      port#olt_port:
        type: tosca.nodes.SwitchPort
        properties:
          portId: 2
          ...
      port#bng_port:
        type: tosca.nodes.SwitchPort
        properties:
          portId: 1
          ...
      # Setup the fabric switch port where the external
      # router is connected to
      bngmapping:
        type: tosca.nodes.BNGPortMapping
        properties:
          s_tag: "any"
          switch_port: 1
          ...
    ```

1. Configure Q-n-Q interface and enable DHCP services on the DHCP Server (BNG) interface connected to `Fabric-switch` (Change the interface names as per your setup).
    
    ```bash
    sudo ip link add link ens1d1 name ens1d1.222 type vlan id 222
    sudo ip link set ens1d1.222 up
    sudo ip link add link ens1d1.222 name ens1d1.222.111 type vlan id 111
    sudo ip link set ens1d1.222.111 up
    sudo ip addr add 172.18.0.10/24 dev ens1d1.222.111
    ```
    Choose any dhcp-server of your choice and run DHCP services on the Q-n-Q interface with range `172.18.0.50 - 172.18.0.100`.

1. Install the Modified TOSCA ponsim-pod charts and proceed to step [Validating the install](siab.md#validating-the-install).
