# Hardware Requirements

A CORD POD is built using the following hardware components.

## Generic Hardware Guidelines

* **Compute machines**: CORD can be in principle deployed both on any x86 machine, either physical or virtual. For development, demos or lab trials you may want to use only one machine (even your laptop could be fine, as long as it can provide enough hardware resources). For more realistic deployments it's anyway suggested to use at least three machines; better if all equals to one each other. The characteristics of these machines depends by lots of factors. At high level, at the very minimum, each machine should have a 4 cores CPU, 32GB of RAM and 100G of disk capacity. More sophisticated use-cases, for example M-CORD require more resources. Look at paragraphs below for more informations.

* **Network cards**: Whatever server you want to use, it should have at the very minimum a 1G network interface for management.

* **Fabric switches**: Fabric switches should be compatible with the ONOS Trellis application that controls them. In this case, it's strongly suggested to stick with one of the models suggested, depending on the requirements. 10G switches are usually preferred for initial functional tests / lab deployments, since cheaper. Moreover, 10G ports can be usually downgraded to 1G speed, and the user can connect copper SFPs to them. The number of switches largely depends by your needs. For basic scenarios one may be enough, for more complete fabric tests, it's suggested to use at least four switches. More for more complex deployments. Developers sometimes emulate the fabric in software (using Mininet), but this can only apply to specific use-cases.

* **Access equipment**: At the moment, both R-CORD and M-CORD work with very specific access equipment. It's strongly suggested to stick with the models suggested in the following paragraphs.

* **Optics and cabling**: Some hardware may be picky on the optics. Both optics and cable models tested by the community are provided below.

* **Other**: Besides all above, you will need a development/management machine and a L2 management swich to connect things together. Usually a laptop is enough for the former, and a legacy L2 switch is enough for the latter.

## Suggested Hardware

Following is a list of hardware that people from the ONF community
have tested over time in lab trials.

* **Compute machines**
    * OCP Inspired&trade; QuantaGrid D51B-1U server. Each
    server is configured with 2x Intel E5-2630 v4 10C 2.2GHz 85W, 64GB of RAM 2133MHz DDR4, 2x 500GB HDD, and a 40 Gig adapter.

* **Fabric Switches**
    * **1G/10G** models (with 40G uplinks)
        * OCP Accepted&trade; EdgeCore AS5712-54X
        * OCP Accepted&trade; EdgeCore AS5812-54X
        * QuantaMesh T3048-LY8
    * **40G** models
        * OCP Accepted&trade; EdgeCore AS6712-32X
    * **100G** models
        * OCP Accepted&trade; EdgeCore AS7712-32X
        * QuantaMesh BMS T7032-IX1/IX1B

* **Fabric optics and DACs**
    * **10G DACs**
        * Robofiber QSFP-10G-03C SFP+ 10G direct attach passive
        copper cable, 3m length - S/N: SFP-10G-03C
    * **40G DACs**
        * Robofiber QSFP-40G-03C QSFP+ 40G direct attach passive
        copper cable, 3m length - S/N: QSFP-40G-03C

* **R-CORD access equipment and optics**
    * **XGS-PON**
        * **OLT**: EdgeCore ASFVOLT16 (for more info <bartek_raszczyk@edge-core.com>)
        * Compatible **OLT optics**
            * Hisense/Ligent: LTH7226-PC, LTH7226-PC+
            ** Source Photonics: XPP-XG2-N1-CDFA
        * **ONU**: AlphaNetworks PON-34000B (for more info <ed-y_chen@alphanetworks.com>)
        * Compatible **ONU optics**
            * Hisense/Ligent: LTF7225-BC, LTF7225-BH+

* **M-CORD specific requirements**
    * **Servers**: Some components of CORD require at least a Intel XEON CPU with Haswell microarchitecture or better.
    * **eNodeBs**:
        * Cavium Octeon Fusion CNF7100 (for more info <kin-yip.liu@cavium.com>)

## BOM Examples

The following are some BOM examples you might wish to adopt.

### Basic Lab Tests

Sufficient to modify/develop basic software components, and
deploy locally in a lab.

* 1x x86 server (maybe with a 10G interface if need to support VNFs)
* 1x fabric switch (10G)
* 1 DAC cables (if need to support VNFs)
* Ethernet copper cables as needed
* Access equipment as needed
* 1x or more developers' workstations (i.e. laptop) to develop and deploy
* 1x L2 legacy management switch

### Complex Lab Tests

For a more realistic deployment, you can build a POD with the
following elements:

* 3x x86 server (maybe 10G/40G/100G interfaces if need to support VNFs)
* 4x fabric switches (10G/40G/100G)
* 7 DAC cables + 3 to connect servers (if need to support VNFs)
* Ethernet copper cables as needed
* Access equipment as needed
* 1 or more developers' workstations (i.e. laptop) to develop and deploy
* Alternatively a management/development server
* 1x L2 legacy management switch
