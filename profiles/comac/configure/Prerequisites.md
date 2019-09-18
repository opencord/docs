# Prerequisites

## Hardware Requirements

Based on the description of "Generic Hardware Guidelines" <https://guide.opencord.org/prereqs/hardware.html#generic-hardware-guidelines>, we are going to introduce the specific requirements for COMAC in this page.


* **Compute Machines**: Same as described in "Generic Hardware Guidelines" page. But you want to use multi-cluster COMAC, then you can prepare two same setups. Also, COMAC requires at least Intel XEON CPU with Haswell microarchitecture or better.

* **Network Cards**: For 3GPP data plane, COMAC supports high performance with SR-IOV interfaces. So besides the first 1G NIC for management, COMAC also need another 10G NIC on computer machines for user data traffic.

* **Access Devices**: In COMAC, the access devices here refer to Enodebs. The enodeb for this release we use Accelleran E1000.

The rest of the hardware are same with "Hardware Requirements" section on "Generic Hardware Guidelines" page.

## COMAC BOM Example

One cluster with one OpenFlow switch setup example:  
![](../images/3nodes-hardware-setup.png)

3x x86 server (10G NIC)  
1x OpenFlow switch (40G NIC)  
1x DAC breakout cable     
5x Ethernet copper cables 
2x layer 2 switches, one is for management, another is as converter between 1G and 10G NICs  

## Software Requirements

* **Kernel Modules**:  
  (1) “*nf_conntrack_proto_sctp*” for SCTP protocol;  
  (2) “*vfio-pci*" for SR-IOV.
  
* **Software List**:  
   Download kubespray, automation-tools, configurations and the helm charts:

  `git clone https://github.com/kubernetes-incubator/kubespray.git -b release-2.11`
  `git clone https://gerrit.opencord.org/automation-tools`
  `git clone https://gerrit.opencord.org/pod-configs`
  `git clone https://gerrit.opencord.org/helm-charts`



  


