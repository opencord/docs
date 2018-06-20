# Software Requirements

CORD is distributed as a set of containers that can run on
pretty much any Kubernetes environment. It is your choice how
to install Kubernetes, although this section describes automation
scripts we have found useful.

> **Note:** M-CORD is the exception since its components still depend on
> OpenStack, which is in turn deployed as a set of Kubernetes containers
> using the [openstack-helm](https://github.com/openstack/openstack-helm)
> project. Successfully installing the OpenStack Helm charts requires
> some additional system configuration besides just installing Kubernetes
> and Helm. You can find more informations about this in the
> [OpenStack Support](./openstack-helm.md) installation section.
