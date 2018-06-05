# Installation Guide

This guide describes how to install CORD.

## Prerequisites

Start by satisfying the following prerequisites:

* [Hardware Requirements](./prereqs/hardware.md)
* [Connectivity Requirements](./prereqs/networking.md)
* [Software Requirements](./prereqs/software.md)

## Deploy CORD

The next step is select the configuration (profile) you want to
install:

* [R-CORD](./profiles/rcord/install.md)
* [M-CORD](./profiles/mcord/install.md)

## Additional Information

The following are optional steps you may want to take

### Offline Installation

If your environment does not permit connecin your POD to ther public
Internet, you may want to take advantage of a local Docker registery.
The following [registry setup](./prereqs/docker-registry.md) will help.

### OpenStack Installation

If you need OpenStack included in your deployment, so you can bring up
VMs on your POD, you will need to following the following
[OpenStack deployment](./prereqs/openstack-helm.md) guide.
