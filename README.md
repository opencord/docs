# Install CORD

The following section describes how to deploy CORD. To install, follow either the side menu or the links below in the page.

## Hardware requirements

Start putting together the [hardware](./prereqs/hardware.md) you need to deploy CORD.

## Networking Connectivity

[Connect](./prereqs/networking.md) together the hardware components. Discover what the [connectivity requirements](./prereqs/networking.md) are.

## Software Requirements

You'll need to satisfy a very minimum set of [software requirements](./prereqs/software.md) before proceeding with the installation. The section provides useful pointers and scripts to help you installing Kubernetes and more.

## Deploy CORD

You're finally ready to install the CORD components. Choose the component you'd like to install.

- [RCORD-lite](./profiles/rcord/install.md)
- [MCORD](./profiles/mcord/install.md)

## More

Here is a list of optional secitons you may want to follow.

### Offline Installation / local docker registry support

Can't have your POD connected to Internet? Want to deploy your own containers to the POD? The [docker registry](./prereqs/docker-registry.md) will help.

### OpenStack-helm integration

Need OpenStack support to deploy VMs on your POD? Follow [this seciton](./prereqs/openstack-helm.md).
