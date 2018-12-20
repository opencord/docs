# AGG Switch Operations

## Creating special-purpose VLAN crossconnects

Sometimes it is necessary to create a special purpose VLAN crossconnect, such as to connect a specific VM to a BNG. To do this, it is necessary to manually create a `FabricCrossconnectServiceInstance`. First, assure that you have the necessary information:

- `s_tag`. The VLAN tag that you wish to crossconnect.
- `source_port`. Port number on the switch for one end of the crossconnect (typically where your VM is attached).
- `destination_port`. Port number on the switch for the other end of the crossconnect (typically where your BNG is attached).
- `switch_datapath_id`. Openflow ID of the switch where the crossconnect should be created.

Now, Navigate using the GUI to `Fabric 