# Fabric Software Setup

CORD uses the Trellis fabric to connect the data plane components together.
This section describes how to setup the software for these switches.

The latest [Trellis Fabric](https://wiki.opencord.org/display/CORD/Trellis%3A+CORD+Network+Infrastructure) documentation can be found on the CORD wiki.

## Supported Switches

The list of supported hardware can be found in the [hardware requirements page](prereqs/hardware.md).

## Operating System

All CORD-compatible switches use
[Open Networking Linux (ONL)](https://opennetlinux.org/) as the operating system.
The [latest compatible ONL image](https://github.com/opencord/OpenNetworkLinux/releases/download/2017-10-19.2200-1211610/ONL-2.0.0_ONL-OS_2017-10-19.2200-1211610_AMD64_INSTALLED_INSTALLER) can be downloaded from [here](https://github.com/opencord/OpenNetworkLinux/releases/download/2017-10-19.2200-1211610/ONL-2.0.0_ONL-OS_2017-10-19.2200-1211610_AMD64_INSTALLED_INSTALLER).

**Checksum**: *sha256:2db316ea83f5dc761b9b11cc8542f153f092f3b49d82ffc0a36a2c41290f5421*

Guidelines on how to install ONL on top of an ONIE compatible device can be found directly on the [ONL website](https://opennetlinux.org/docs/deploy).

This specific version of ONL has been customized to accept an IP address through DHCP on the management interface, *ma0*. If you'd like to use a static IP, first give
it an IP address through DHCP, then login and change the configuration in
*/etc/network/interfaces*.

The default *username* and *password* are *root* / *onl*.

## OFDPA Drivers

Once ONL is installed, OFDPA drivers will need to be installed as well.
Each switch model requires a specific version of OFDPA. All driver packages are distributed as DEB packages, which makes the installation process straightforward.

First, copy the package to the switch. For example

```shell
scp your-ofdpa.deb root@fabric-switch-ip:
```

Then, install the DEB package

```shell
dpkg -i your-ofdpa.deb
```

Three OFDPA drivers are available:

* [EdgeCore 5712-54X / 5812-54X / 6712-32X](https://github.com/onfsdn/atrium-docs/blob/master/16A/ONOS/builds/ofdpa_3.0.5.5%2Baccton1.7-1_amd64.deb?raw=true) - *checksum: sha256:db228b6e79fb15f77497b59689235606b60abc157e72fc3356071bcc8dc4c01f*
* [QuantaMesh T3048-LY8](https://github.com/onfsdn/atrium-docs/blob/master/16A/ONOS/builds/ofdpa-ly8_0.3.0.5.0-EA5-qct-01.01_amd64.deb?raw=true) - *checksum: sha256:f8201530b1452145c1a0956ea1d3c0402c3568d090553d0d7b3c91a79137da9e*
* [QuantaMesh BMS T7032-IX1/IX1B](https://github.com/onfsdn/atrium-docs/blob/master/16A/ONOS/builds/ofdpa-ix1_0.3.0.5.0-EA5-qct-01.00_amd64.deb?raw=true) *checksum: sha256:278b8ffed8a8fc705a1b60d16f8e70377e78342a27a11568a1d80b1efd706a46*
