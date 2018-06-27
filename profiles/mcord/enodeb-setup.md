# eNodeB and HSS Database Setup

## Supported eNodeBs

Mcord virtual epc works with any standard enodeb. We tested the Cavium enodeb
with model CNF7100-REF2-RF17. So in this section we introduce the enodeb
configurations according to this eNodeB.

## Connect the eNodeB to the pod

There are two logical connectivities for a eNodeB: (1) S1MME interface
connection, between eNodeB and MME for attaching process. (2) S1U interface
connection, between eNodeB and SPGWU (SGWU+PGWU) for user traffic.

For physical connectivity, there is only one, not two. For this enodeb the
connectivity is ethernet cable. If you use differnet eNodeB, the connectivity
cable may be different.

## eNodeB Configuration

The configuration file on Cavium enodeb is located at /mnt/app/startup.cfg.
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

u32enbipaddress is the eNodeB data plane IP address for S1U interface. The
default IP address in MCORD is 119.0.0.10/24. You can specify it for EPC in XOS
UI when create a new EPC, which will be introduced later.

Since u32enbipaddress and SPGWU IP on S1U address are in a same subnet and on a
same flat network inside OVS, so u32enbgwipaddress (gateway IP) does not matter
much. you can give any IP as long as it is not used by eNodeB or SPGWU.

u32mmeipaddress: MME IP address on S1MME interface.
36412: the default communication port number.
u32sgwipaddress: SPGWU IP address on S1U interface.

Where to get those IP addresses? As described at the end of [MCORD quick start
page](https://guide.opencord.org/profiles/mcord/install.html), with command
"openstack server list --all-projects", you can see a list of VNF and their IP
addresses, you can find the IP address here. For example, the
"flat_network_s1mme" of MME VM is the u32mmeipaddress. The "flat_network_s1u"
is the u32sgwipaddress.

Besides this, you should also config the S1U IP and S1MME interface IP address
on eNodeB by the following command lines. The default value of S1MME we use is
118.0.0.10/24, while the default value of S1U is 119.0.0.10/24.

```bash
sudo ifconfig eth0 119.0.0.10/24
sudo ip addr add 118.0.0.10/24 dev eth0
```

## Configure the VNFs on the pod for eNodeB

You can config the eNodeB IP addresses for EPC through XOS UI during creating a
new epc. After click "add" an EPC inside XOS UI, you can see:

```bash
Enodeb ip addr s1mme
118.0.0.10
external eNodeB IP address of S1-MME
119.0.0.10
```

118.0.0.10 is the default S1MME interface IP on eNodeB.
119.0.0.10 is the default S1U interface IP on eNodeB.
You can use those defalt IP addresses or you can change them to your own. Make
sure that the IP addresses here are exactly the same with the IP addresses you
configed on your eNodeB.

## Add subscribers infomation to HSS database

Prepare the three values of a SIM card: IMSI, key, and opc.
For apn value, we will use the default value "apn1".
Login the HSS-DB VM, with user name "c3po" and password "c3po", run:

```bash
~/c3po/db_docs/data_provisioning_users.sh <imsi> 1122334456 apn1 <key> 1 <ip>
```

Then login database:

```bash
cqlsh <ip>
```

Set the opc value:

```bash
cqlsh> use vhss;
cqlsh:vhss> update users_imsi set opc='<opc>' where imsi='<imsi>';
```

## Select a phone

You can use any phone, as long as it supports the same band with your eNodeB.

## Connect phone to eNodeB

Search mobile networks, you should be able to see your eNodeB relative name
show up as one of the choices.

## Setup Verification

Download a ping applicaiton on your phone, you can ping the SGI interface IP
address of SPGWU from the phone.

Another way to test is to use our InternetEmulator VM. The username and
password are also "c3po" and "c3po". You need to modify a route on this machine:

```bash
sudo route add -net 16.0.0.0/8 gw <SPGWU-SGI-IP> dev ens3
```

16.0.0.0/8 is the default subnet assigned for the phones, you can ignore it.
SPGWU-SGI-IP: the SGI interface IP address on SPGWU. You can find this IP
through the same method with u32mmeipaddress above.
























