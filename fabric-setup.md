# Fabric switches software setup

CORD uses the Trellis fabric to connect the data plane components together.

The full [latest Trellis fabric documentation](https://wiki.opencord.org/display/CORD/Trellis%3A+CORD+Network+Infrastructure) can still be found on the old CORD wiki.

## Supported switches

The list of supported hardware can be found in the [hardware requirements page](prereqs/hardware.html#generic-hardware-guidelines).

## Operating system

At today, all compatible switches use [Open Networking Linux (ONL)](https://opennetlinux.org/) as operating system.

The [latest compatible ONL image](https://github.com/opencord/OpenNetworkLinux/releases/download/2017-10-19.2200-1211610/ONL-2.0.0_ONL-OS_2017-10-19.2200-1211610_AMD64_INSTALLED_INSTALLER) can be downloaded from [here](https://github.com/opencord/OpenNetworkLinux/releases/download/2017-10-19.2200-1211610/ONL-2.0.0_ONL-OS_2017-10-19.2200-1211610_AMD64_INSTALLED_INSTALLER).

**Checksum**: *sha256:2db316ea83f5dc761b9b11cc8542f153f092f3b49d82ffc0a36a2c41290f5421*

Deployment guidelines on how to install ONL on top of an ONIE compatible device can be found directly on the [ONL website](https://opennetlinux.org/docs/deploy).

This specific version of ONL has been already customized to accept an IP address through DHCP on the management interface, *ma0*. If you'd like to use a static IP, give it first an IP through DHCP, login and change the configuration in */etc/network/interfaces*.

The default *username* and *password* are *root* / *onl*.

## OFDPA drivers

Once ONL is installed OFDPA drivers will need to be installed as well.
Each switch model requires a specific version of OFDPA. All driver packages are distributed as DEB packages. This makes the installation process very easy.

First, copy the package to the switch. For example

```shell
scp your-ofdpa.deb root@fabric-switch-ip:
```

Then, install the deb package

```shell
dpkg -i your-ofdpa.deb
```

## OFDPA drivers download

* [EdgeCore 5712-54X / 5812-54X / 6712-32X](https://github.com/onfsdn/atrium-docs/blob/master/16A/ONOS/builds/ofdpa_3.0.5.5%2Baccton1.7-1_amd64.deb?raw=true) - *checksum: sha256:db228b6e79fb15f77497b59689235606b60abc157e72fc3356071bcc8dc4c01f*
* [QuantaMesh T3048-LY8](https://github.com/onfsdn/atrium-docs/blob/master/16A/ONOS/builds/ofdpa-ly8_0.3.0.5.0-EA5-qct-01.01_amd64.deb?raw=true) - *checksum: sha256:f8201530b1452145c1a0956ea1d3c0402c3568d090553d0d7b3c91a79137da9e*
