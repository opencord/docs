# eNodeB Setup

## Supported eNodeBs

M-CORD's virtual EPC should work with any standard eNodeB. We tested the
Cavium eNodeB (model CNF7100-REF2-RF17). In this section we describe how
to configure this eNodeB to work with M-CORD.


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

`u32enbipaddress` is the eNodeB data plane IP address for S1U interface.

`u32mmeipaddress`: MME IP address on S1MME interface.

`36412`: the default communication port number.

`u32sgwipaddress`: SPGWU IP address on S1U interface.


























