# eNodeB and HSS Database Setup

## Supported eNodeBs

Mcord virtual epc works with any standard enodeb. We tested the Cavium enodeb with model CNF7100-REF2-RF17. So in this section we introduce the enodeb configurations according to this eNodeB.

##  Connect the eNodeB to the pod

There are two logical connectivities for a eNodeB: (1) S1MME interface connection, between eNodeB and MME for attaching process. (2) S1U interface connection, between eNodeB and SPGWU (SGWU+PGWU) for user traffic.

For physical connectivity, there is only one, not two. For this enodeb the connectivity is ethernet cable. If you use differnet eNodeB, the connectivity may be different. 

## eNodeB Configuration
The configuration file on Cavium enodeb is located at /var/app/startup.cfg. Find the following lines and change the values:

```bash
configure net net u32enbipaddress 119.0.0.10
configure net net u32enbsubnetmask 255.255.255.0
configure net net u32enbgwipaddress 119.0.0.254
...
configure net mme u32mmeipaddress 0 118.0.0.5
configure net mme u16mmesctpportnumber 0 36412
...
configure net sgw u32sgwipaddress 0 140.0.0.2
```

u32enbipaddress is the eNodeB data plane IP address for S1U interface.
Since u32enbipaddress and SPGWU IP on S1U address are in a same subnet and on a same flat network inside OVS, so u32enbgwipaddress (gateway IP) does not matter much. you can give any IP as long as it is not used by eNodeB or SPGWU.

u32mmeipaddress: MME IP address on S1MME interface.
36412: the default communication port number.
u32sgwipaddress: SPGWU IP address on S1U interface.

Besides this, you should also config the S1MME interface IP address on eNodeB. The default value we use is 118.0.0.10/24.

## Configure the VNFs on the pod for eNodeB

You can config the eNodeB IP addresses for EPC through XOS UI during creating a new epc. After click "add" an EPC inside XOS UI, you can see:

```bash
Enodeb ip addr s1mme
118.0.0.10
external eNodeB IP address of S1-MME 
119.0.0.10
```
118.0.0.10 is the default S1MME interface IP on eNodeB.
119.0.0.10 is the default S1U interface IP on eNodeB.
You can use those defalt IP addresses or you can change them to your own. Make sure that the IP addresses here are exactly the same with the IP addresses you configed on your eNodeB.


## Add subscribers infomation to HSS database
Prepare the three values of a SIM card: IMSI, key, and opc.
For apn value, we will use the default value "apn1".
Login the HSS-DB VM, with user name "c3po" and password "c3po", run:

```bash
$ ~/c3po/db_docs/data_provisioning_users.sh <imsi> 1122334456 apn1 <key> 1 <ip>
```

Then login database:

```bash
$ cqlsh <ip>
```

Set the opc value:

```bash
cqlsh> use vhss;
cqlsh:vhss> update users_imsi set opc='<opc>' where imsi='<imsi>';
```

## Select a phone
You can use any phone, as long as it supports the same band with your eNodeB.

## Connect phone to eNodeB
Search mobile networks, you should be able to see your eNodeB relative name show up as one of the choices.

## Setup Verification

Download a ping applicaiton on your phone, you can ping the SGI interface IP address of SPGWU from the phone.























