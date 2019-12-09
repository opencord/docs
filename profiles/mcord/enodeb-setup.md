# eNodeB and HSS Database Setup

## Supported eNodeBs

M-CORD's virtual EPC should work with any standard eNodeB. We tested the
Cavium eNodeB (model CNF7100-REF2-RF17). In this section we describe how
to configure this eNodeB to work with M-CORD.

## Connect the eNodeB to the pod

For physical connectivity, this eNodeB has a single Ethernet interface. Our
test setup uses a single physical compute node for hosting the VNFs.  We
connect the eNodeB to one of the NICs on the compute node.

There are two logical connectivities for a eNodeB: (1) S1MME interface
connection, between eNodeB and MME for attaching process. (2) S1U interface
connection, between eNodeB and SPGWU (SGWU+PGWU) for user traffic.  To enable
this connectivity, on the compute node we add the NIC connected to the eNodeB
to the `fabric` bridge.

## eNodeB configuration

The configuration file on Cavium eNodeB is located at /mnt/app/startup.cfg.
Find the following lines and change the values:

```bash
configure net net u32enbipaddress 119.0.0.10
configure net net u32enbsubnetmask 255.255.255.0
configure net net u32enbgwipaddress 119.0.0.254
...
configure net mme u32mmeipaddress 0 118.0.0.5
configure net mme u16mmesctpportnumber 0 36412
...
configure net sgw u32sgwipaddress 0 119.0.0.2
```

`u32enbipaddress` is the eNodeB data plane IP address for S1U interface. The
default IP address in M-CORD is 119.0.0.10/24. You will need to specify it
when you create the EPC in XOS; see below.

Since `u32enbipaddress` and SPGWU IP on S1U address are on the
same flat network inside OVS, `u32enbgwipaddress` (gateway IP) does not matter.
You can give any IP as long as it is not used by eNodeB or SPGWU.

`u32mmeipaddress`: MME IP address on S1MME interface.

`36412`: the default communication port number.

`u32sgwipaddress`: SPGWU IP address on S1U interface.

Where to get those IP addresses? As described at the end of the [M-CORD quick
start page](install.html), the command `openstack server list --all-projects`
will list the VNFs and their IP addresses. For example, the
`flat_network_s1mme` of MME VM is the `u32mmeipaddress`. The `flat_network_s1u`
is the `u32sgwipaddress`.

Besides this, you should also config the S1U IP and S1MME interface IP address
on eNodeB by the following command lines. The default value of S1MME we use is
118.0.0.10/24, while the default value of S1U is 119.0.0.10/24.

```bash
sudo ifconfig eth0 119.0.0.10/24
sudo ip addr add 118.0.0.10/24 dev eth0
```

## Configure the VNFs on the pod for the eNodeB

Specify the eNodeB IP addresses when creating the EPC in the XOS UI.
To create one, click on `Add` on the `Virtual Evolved Packet Core ServiceInstances` page.  You will see:

```bash
Enodeb ip addr s1mme
118.0.0.10
external eNodeB IP address of S1-MME
119.0.0.10
```

118.0.0.10 is the default S1MME interface IP on the eNodeB.

119.0.0.10 is the default S1U interface IP on the eNodeB.

Make sure that the IP addresses here are the same as the IP addresses you
configed on your eNodeB.

## Add subscriber infomation to the HSS database

Prepare the three values of a SIM card: IMSI, key, and opc.
For apn value, we will use the default value "apn1".
Login to the HSS-DB VM, with user name "c3po" and password "c3po", and run:

```bash
~/c3po/db_docs/data_provisioning_users.sh <imsi> 1122334456 apn1 <key> 1 <ip>
```

Then login to the database:

```bash
cqlsh <ip>
```

Set the opc value:

```bash
cqlsh> use vhss;
cqlsh:vhss> update users_imsi set opc='<opc>' where imsi='<imsi>';
```

## Connect a phone to the eNodeB

You can use any phone, as long as it supports the same band as your eNodeB.
Search the mobile networks.  You should see your eNodeB relative name
as one of the choices.

## Setup verification

Download a ping applicaiton on your phone.  You can ping the SGI interface IP
address of SPGWU from the phone.

Another way to test is to use our InternetEmulator VM. The username and
password are also "c3po" and "c3po". You need to modify a route on this machine:

```bash
sudo route add -net 16.0.0.0/8 gw <SPGWU-SGI-IP> dev ens3
```

16.0.0.0/8 is the default subnet assigned for the phones, you can ignore it.
SPGWU-SGI-IP is the SGI interface IP address on SPGWU. You can find this IP
through the same method as with the `u32mmeipaddress` above.
























