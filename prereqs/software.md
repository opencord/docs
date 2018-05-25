# Software requirements

CORD is distributed as a set of containers that can potentially run on any Kubernetes environment.

As such, you can choose what operating system to use, how to configure it, and how to install Kubernetes on it.

**M-CORD is the exception**,
since its components still run on OpenStack. OpenStack is
deployed as a set of Kubernetes containers using the
[openstack-helm](https://github.com/openstack/openstack-helm)
project. Successfully installing the OpenStack Helm charts requires
some additional system configuration besides just installing Kubernetes
and Helm. You can find more informations about this in the [OpenStack
Support](./openstack-helm.md) installation section.

Following sections describe what specifically CORD containers require and some pointers to DEMO automated-installation scripts.
