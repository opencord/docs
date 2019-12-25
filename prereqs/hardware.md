# Hardware Requirements

A CORD POD is built using the following hardware components.

## Generic Hardware Guidelines

* **Compute Machines**: CORD canin principle be deployed on any x86
  machine, either physical or virtual. For development, demos or lab
  trials you may want to use only one machine (even your laptop could
  be fine, as long as it has enough resources). For more realistic
  deployments, we suggest using at least three machines (preferably
  all the same). The characteristics of these machines depends several
  factors. At the very minimum, each machine should have a 4 cores
  CPU, 32GB of RAM, and 100G of disk capacity. More sophisticated
  use-cases, for example COMAC, require more resources (see below).

* **Network Cards**: For whatever server use, it should have at the
  very minimum a 1G network interface for management.

* **Fabric Switches**: Fabric switches should be compatible with the
  ONOS Trellis application that controls them. We strongly recommend
  using one of the tested models suggested. 10G switches are usually
  preferred for initial functional tests and lab deployments since
  they are less expensive. Moreover, 10G ports can be usually
  downgraded to 1G speed, and it's possible to connect them using
  copper SFPs. The number of switches largely depends by your needs.
  For basic scenarios one may be enough. For more complete fabric
  tests, we recommend at least four switches. Developers sometimes
  emulate the fabric in software (e.g., using Mininet), but this applies
  only to specific use-cases.

* **Access Devices**: At the moment, SEBA and COMAC work
  with very specific access devices, as described below. We strongly
  recommend using these tested devices.

* **Optics and Cabling**: Some hardware may be picky about the optics.
  Both optics and cable models tested by the community are provided below.

* **Other**: In addition to the above, you will need a
  development/management machine and an L2 management swich to
  connect things together. Usually a laptop is enough for the former,
  and a legacy L2 switch is enough for the latter.

## Recommended Hardware

Following is a list of hardware that people from the ONF community
have tested over time in lab trials.


* **Compute Machines**
    * OCP Inspired&trade; QuantaGrid D51B-1U server. Each
    server is configured with 2x Intel E5-2630 v4 10C 2.2GHz 85W, 64GB of RAM 2133MHz DDR4, 2x 500GB HDD, and a 40 Gig adapter.

    * OCP Inspired&trade; MiTAC Tioga Pass_E7278 server. Each server is configured with 2x Intel Skylake SP 14 cores 2.2GHz, 64GB of RAM DDR4, 1x 1TB SSD, and OCP Mezzanine v2 25G.

* **Fabric Switches** - see also the [Trellis Documentation Supported
  Hardware](https://docs.trellisfabric.org/supported-hardware.html)
    * **1G/10G** models (with 40G uplinks)
        * OCP Accepted&trade; EdgeCore AS5712-54X
        * OCP Accepted&trade; EdgeCore AS5812-54X
        * QuantaMesh T3048-LY8
        * Delta AG7648
        * Inventec D6254 (verified by Inventec)
    * **25G** models (with 100G uplinks)
        * QuantaMesh BMS T7032-IX1/IX1B (with 25G breakout cable)
        * Inventec D7054Q28B (verified by Inventec)
    * **40G** models
        * OCP Accepted&trade; EdgeCore AS6712-32X
    * **100G** models
        * OCP Accepted&trade; EdgeCore AS7712-32X
        * QuantaMesh BMS T7032-IX1/IX1B
        * OCP Accepted&trade; Inventec D7032Q28B (verified by Inventec)

* **Fabric Optics and DACs**
    * **10G DACs**
        * Robofiber QSFP-10G-03C SFP+ 10G direct attach passive
        copper cable, 3m length - S/N: SFP-10G-03C
    * **40G DACs**
        * Robofiber QSFP-40G-03C QSFP+ 40G direct attach passive
        copper cable, 3m length - S/N: QSFP-40G-03C

* **SEBA Access Devices and Optics**
    * **GPON**
        * **OLT**: Celestica CLS Ruby S1010 (experimental, only top-down provisioning is supported - through manual customizations)
            * Compatible **OLT optics**
                * OptoWiz LSP4343-CKSA-R GPON SFP OLT Transceiver
        * **ONUs**:
            * Celestica Tellion GP-1204
            * Movistar ONU (with CPE included) (manifactured by Telefonica: <http://www.movistar.es/particulares/movil/moviles/hgu>)
    * **XGS-PON**
        * **OLT**: Edgecore ASXvOLT16 (for more info <bartek_raszczyk@edge-core.com>)
            * Compatible **OLT optics**
                * Hisense/Ligent: LTH7226-PC, LTH7226-PC+
                * Source Photonics: XPP-XG2-N1-CDFA
        * **ONUs**:
            * AlphaNetworks PON-34000B (for more info <ed-y_chen@alphanetworks.com>)
                * Compatible **ONU optics**
                    * Hisense/Ligent: LTF7225-BC, LTF7225-BH+
            * Iskratel Innbox G108 (for more info <info@innbox.net>)
                * Compatible **ONU optics**
                    * SUNSTAR D22799-STCC, EZconn ETP69966-7TB4-I2

* **COMAC Specific Requirements**
    * **Compute Machines**:
        * Intel Haswell CPUs or newer with VT-d support
        * SR-IOV capable network card (for a list of Intel NICs with SR-IOV support, see [here](https://www.intel.com/content/www/us/en/support/articles/000005722/network-and-i-o/ethernet-products.html))
    * **eNodeB**:
        * Accelleran E1000
    * **UE**:
        * Sumsang J5 with Andriod v7.1.1

## BOM Examples

The following are some BOM examples you might wish to adopt.

### Basic Lab Tests

Sufficient to modify/develop basic software components, and
deploy locally in a lab.

* 1x x86 server (maybe with a 10G interface if needed to support VNFs)
* 1x fabric switch (10G)
* 1 DAC cables (if need to support VNFs)
* Ethernet copper cables as needed
* Access equipment as needed
* 1x or more developers' workstations (i.e. laptop) to develop and deploy
* 1x L2 legacy management switch

### Complex Lab Tests

For a more realistic deployment, you can build a POD with the
following elements:

* 3x x86 server (maybe 10G/25G/40G/100G interfaces if need to support VNFs)
* 4x fabric switches (10G/25G/40G/100G)
* 7 DAC cables + 3 to connect servers (if need to support VNFs)
* Ethernet copper cables as needed
* Access equipment as needed
* 1 or more developers' workstations (i.e. laptop) to develop and deploy
* Alternatively a management/development server
* 1x L2 legacy management switch

### SEBA BOM

Refer to hardware listed above for tested and recommended hardware for the BOM

* 3x x86 server (maybe 10G/25G/40G/100G)
* 1x fabric switch (10G/25G/40G/100G) - port speeds depend on OLT NNI uplink speeds and server NICs
* 4 DAC cables (connection to servers and OLT)
* Ethernet copper cables as needed
* 1x OLT
* 1x OLT Transceiver
* 1x ONT/ONU
* 1x ONT Transceiver (Required only if ONT does not have onboard ‘BOSA’ port)
* 1x OLT Splitter (typically 32 or 64 way split with SC/APC connectors)
* 1 or more developers' workstations to develop and deploy
* A workstation/server to simulate BNG
* 1x L2 legacy management switch

### COMAC BOM

**Single Cluster**

* 3x x86 server (1G managment and 10G/25G/40G/100G data with SR-IOV enabled)
* 1x fabric switch (10G/25G/40G/100G)
* 1x L2 legacy management switch
* DAC breakout cables as needed
* Ethernet copper cables as needed
* 1x eNB
* 1x or more UEs
* A workstation/server to develop and deploy

**Multi-Cluster**

* A workstation/server with an access to both clusters to develop and deploy
* **Central**
    * 3x x86 server (1G managment)
    * 1x L2 legacy management switch
    * Ethernet copper cables as needed
* **Edge**
    * 3x x86 server (1G managment and 10G/25G/40G/100G data)
    * 1x fabric switch (10G/25G/40G/100G)
    * 1x L2 legacy management switch
    * DAC breakout cables as needed
    * Ethernet copper cables as needed
    * 1x eNB
    * 1x or more UEs
