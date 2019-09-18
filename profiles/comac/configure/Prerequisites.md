# Prerequisites
##Hardware Requirements
Based on the description of "Generic Hardware Guidelines" <https://guide.opencord.org/prereqs/hardware.html#generic-hardware-guidelines>, we are going to introduce the specific requirements for COMAC in this page.


* **Compute Machines**: Same as described in "Generic Hardware Guidelines" page. But you want to use multi-cluster COMAC, then you can prepare two same setups. Also, COMAC requires at least Intel XEON CPU with Haswell microarchitecture or better.

* **Network Cards**: For 3GPP data plane, COMAC supports high performance with SR-IOV interfaces. So besides the first 1G NIC for management, COMAC also need another 10G NIC on computer machines for user data traffic.

* **Access Devices**: In COMAC, the access devices here refer to Enodebs. The enodeb for this release we use Accelleran E1000.

The rest of the hardware are same with "Hardware Requirements" section on "Generic Hardware Guidelines" page.

