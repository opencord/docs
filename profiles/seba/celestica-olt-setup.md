# Celestica OLT setup

Celestica provides a GPON based OLT device that can work with Voltha and CORD.
The OLT (also known as Microsemi OLT) model is called *CLS Ruby S1010*. For more info on the hardware models and the supported optics, look at the [recommended hardware page](../../prereqs/hardware.md#recommended-hardware).

The following guide explains how to integrate the Celestica OLT with Voltha, and more in general with CORD.

## OLT hardware notes and ports configuration

The OLT has two lines of ports. Upper ports are master ports and should be used first. Lower ports act as backup ports for the upper ports.
The OLT has 48 UNI ports (24 master, and 24 backups) and 6 NNI ports (3 master, and 3 backups).
The UNI ports are divided in three PON groups. Each PON group is associated to an NNI port. The most right NNI port group is used for the most left PON group, and so on.
Each PON group is divided in 4 PONs (each with four PON ports - the two upper, master, and the two lower, backup). Each port can support up to 32 connections.
Each PON (each couple of vertically grouped ports, one master, one backup) will appear as a different OLT device in Voltha.

## How to manage the OLT (access the CLI)

As far as we know, the out-of-band OLT management port is disabled by default, and the OLT can be managed -including by Voltha- only in-band.
Also, the OLT is managed as a L2 device by Voltha. As such, no IP addresses can be assigned to the OLT. The OLT doesn't need any specific configuration. Anyway, you may need to access the CLI for debug purposes. The CLI can be accessed from the console port for debugging.

## OLT pre-installed software notes

The Celestica box should come with ONIE and its own OS pre-installed. No additional configurations are required.

## Get the OLTs MAC addresses

The MAC addresses of the OLTs are needed to perform a successful Voltha configuration. To get the OLT MAC address, from the OLT CLI type:

```shell
/voltapp/onie-syseeprom
```

The command will only show the MAC address of the first OLT (first couple of ports from the left). To know the MAC addresses of the other OLTs, add 1 to the first MAC address, for each couple of next ports. For example, the MAC address of the second OLT (the second couple of vertical ports from the left) will be the MAC address returned by the command above plus 1.

## Discover the OLT in Voltha

Once the MAC address is known, pre-provision the OLT from Voltha

```shell
preprovision_olt --device-type=microsemi_olt --mac-address=11:22:33:44:55:66
```

where *11:22:33:44:55:66* is the MAC address of your OLT device.

Then, enable the OLT, typing

```shell
enable
```

Voltha will start to send L2 packets to the OLT, until it gets discovered.

> **NOTE:** at the moment, the microsemi_olt adapter sends only few packets to the OLT box after the *enable* command has been input. Recently, a *reboot* command has been added for this adapter. The command restarts the provisioning process.

## Celestica OLT and R-CORD

As said, the Celestica OLT can be used with Voltha, so in principle with R-CORD as well. At the moment, this requires some additional configuration to allow the in-band management communication between Voltha and the OLT.

As in-band communication is done by L2 MAC address, the NNI port of OLT needs to have a L2 connection with Voltha.

More specifically, in a typical CORD deployment Voltha runs as a set of container managed by k8s, which in turn runs on a (physical or virtual) machine. This machine is usually connected to the management network only. In a deployment using Celestica boxes instead, the server running Voltha will need to have an extra connection to the data plane (usually the CORD fabric switches).

Of course, also the OLT NNI port needs to be connected as well to the same fabric switch.
If both the OLT and the server running Voltha are connected to the same fabric switch, a path needs to be provisioned between the two. This can be achieved -for example- in the CORD fabric using Trellis, through the configuration of a VLAN cross-connect or a pseudo-wire.

Further more, the Voltha vcore container (called voltha in the Kubernetes based deployment) should be connected to the data plane port, connected to the OLT, which is a quite trivial but manual operation. The steps to connect containers and server ports can be found in the [veth interface configuration guide](../../profiles/seba/veth_intf.md).

> **NOTE:** the Celestica OLT is known to work *only* with the top-down R-CORD configuration workflow.
