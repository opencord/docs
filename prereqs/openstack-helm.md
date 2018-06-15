# OpenStack (Optional)

The [openstack-helm](https://github.com/openstack/openstack-helm)
project can be used to install a set of Kubernetes nodes as OpenStack
compute nodes, with the OpenStack control services (nova, neutron,
keystone, glance, etc.) running as containers on Kubernetes. This is
necessary, for example, to run the M-CORD profile.

Instructions for installing `openstack-helm` on a single node or a
multi-node cluster can be found at
[https://docs.openstack.org/openstack-helm/latest/index.html](https://docs.openstack.org/openstack-helm/latest/index.html).

The following describes steps for installing `openstack-helm`, including how to
customize the documented install procedure with specializations for CORD.
Specifically, CORD uses the VTN ONOS app to control Open vSwitch on
the compute nodes and configure virtual networks between VMs on the
OpenStack cluster. Neutron must be configured to pass control to ONOS
rather than using `openvswitch-agent` to manage OvS.

After the install process is complete, you won't yet have a
fully-working OpenStack system; you will need to install the
[base-openstack](../charts/base-openstack.md) chart first.

## Single-Node Quick Start

For convenience, a script to install Kubernetes, Helm, and `openstack-helm`
on a _single Ubuntu 16.04 node_ is provided in the `automation-tools`
repository.  This script also customizes the install as described
below.

```bash
git clone https://gerrit.opencord.org/automation-tools
automation-tools/openstack-helm/openstack-helm-dev-setup.sh
```

If you run this script you can skip the instructions on the rest of
this page.

## Customizing the openstack-helm Install for CORD

To enable the VTN app to control Open vSwitch on the compute
nodes, it is necessary to customize the `openstack-helm` installation.
The customization occurs through specifiying `values.yaml` files to use
when installing the Helm charts.

The `openstack-helm` installation process designates one node as the
master node; the Helm commands are run on this node.  The following
values files should be created on the master node prior to installing
the `openstack-helm` charts.

```bash
cat <<EOF > /tmp/glance-cord.yaml
---
network:
  api:
    ingress:
      annotations:
        nginx.ingress.kubernetes.io/proxy-body-size: "0"
EOF
export OSH_EXTRA_HELM_ARGS_GLANCE="-f /tmp/glance-cord.yaml"
```

```bash
cat <<EOF > /tmp/nova-cord.yaml
---
labels:
  api_metadata:
    node_selector_key: openstack-helm-node-class
    node_selector_value: primary
network:
  backend: []
pod:
  replicas:
    api_metadata: 1
    placement: 1
    osapi: 1
    conductor: 1
    consoleauth: 1
    scheduler: 1
    novncproxy: 1
EOF
export OSH_EXTRA_HELM_ARGS_NOVA="-f /tmp/nova-cord.yaml"
```

```bash
cat <<EOF > /tmp/neutron-cord.yaml
---
images:
  tags:
    neutron_server: xosproject/neutron-onos:newton
manifests:
  daemonset_dhcp_agent: false
  daemonset_l3_agent: false
  daemonset_lb_agent: false
  daemonset_metadata_agent: false
  daemonset_ovs_agent: false
  daemonset_sriov_agent: false
network:
  backend: []
  interface:
    tunnel: "eth0"
pod:
  replicas:
    server: 1
conf:
  plugins:
    ml2_conf:
      ml2:
        type_drivers: vxlan
        tenant_network_types: vxlan
        mechanism_drivers: onos_ml2
      ml2_type_vxlan:
        vni_ranges: 1001:2000
      onos:
        url_path: http://onos-cord-ui.default.svc.cluster.local:8181/onos/cordvtn
        username: onos
        password: rocks
EOF
export OSH_EXTRA_HELM_ARGS_NEUTRON="-f /tmp/neutron-cord.yaml"
```

It is also necessary to make a small change to `openstack-helm`'s
[openvswitch](https://github.com/openstack/openstack-helm/tree/master/openvswitch) chart: the `/usr/sbin/ovsdb-server` must be executed with
the `--remote=ptcp:6641` option to listen for the connection from VTN.
After the `openstack-helm` repository is checked out during the
[install process](#install-process-for-openstack-helm),
run the following command:

```bash
cd openstack-helm/openvswitch/templates/bin
sed -i 's/--remote=db:Open_vSwitch,Open_vSwitch,manager_options/--remote=db:Open_vSwitch,Open_vSwitch,manager_options --remote=ptcp:6641/' _openvswitch-db-server.sh.tpl
```

## Install Process for openstack-helm

Please see the `openstack-helm` documentation for instructions on how to
install openstack-helm on a single node (for development and testing) or
a multi-node cluster.

* [system requirements](https://docs.openstack.org/openstack-helm/latest/install/developer/requirements-and-host-config.html)
* [single-node installation](https://docs.openstack.org/openstack-helm/latest/install/developer/index.html)
* [multi-node cluster](https://docs.openstack.org/openstack-helm/latest/install/multinode.html)

The install process is flexible and fairly modular; see the links
above for more information.  At a high level, it involves running
scripts to:

* Install software like Kubernetes and Helm
* Build the Helm charts and install them in a local Helm repository
* Install requried packages
* Configure DNS on the nodes (_NOTE: The `openstack-helm` install overwrites `/etc/resolv.conf` on the compute hosts and points the upstream nameservers to Google DNS.  If a local upstream is required, [see this note](https://docs.openstack.org/openstack-helm/latest/install/developer/kubernetes-and-common-setup.html#clone-the-openstack-helm-repos)_.)
* Generate `values.yaml` files based on the environment and install Helm charts using these files
* Run post-install tests on the OpenStack services
