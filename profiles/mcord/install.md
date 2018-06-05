# M-CORD

## Quick Start

A convenience script is provided that will install M-CORD on a single
node, suitable for evaluation or testing.  Requirements:

- An Ubuntu 16.04 node with at least 64GB of RAM and 32 virtual CPUs
- User invoking the script has passwordless `sudo` capability
- Hostname is resolvable in DNS, e.g., `dig +short $( hostname )` returns an IP address

```bash
git clone https://gerrit.opencord.org/automation-tools
automation-tools/mcord/mcord-in-a-box.sh
```

This script takes about an hour to complete.  If you run it, you can skip
directly to [Validating the Installation](#validating-the-installation) below.

## Prerequisites

M-CORD requires OpenStack to run VNFs.  The OpenStack installation
must be customized with the *onos_ml2* Neutron plugin.

- To install Kubernetes, Helm, and a customized Openstack-Helm on a single node or a multi-node cluster, follow [this guide](../../prereqs/openstack-helm.md)
- To configure the nodes so that VTN can provide virtual networking for OpenStack, follow [this guide](../../prereqs/vtn-setup.md)

## CORD Components

Bring up the M-CORD controller by installing the following charts in order:

- [xos-core](../../charts/xos-core.md)
- [base-openstack](../../charts/base-openstack.md)
- [onos-vtn](../../charts/onos.md#onos-vtn)
- [onos-fabric](../../charts/onos.md#onos-fabric)
- [mcord](../../charts/mcord.md)

## Validating the Installation

Before creating any VMs, check to see that VTN has initialized the nodes
correctly.  On the OpenStack Helm master node run:

```bash
# password: rocks
ssh -p 8101 onos@onos-cord-ssh.default.svc.cluster.local cordvtn-nodes
```

You should see all nodes in `COMPLETE` state.

Next, check that the VNF images are loaded into OpenStack (they are quite large
so this may take a while to complete):

```bash
export OS_CLOUD=openstack_helm
openstack image list
```

You should see output like the following:

```text
+--------------------------------------+-----------------------------+--------+
| ID                                   | Name                        | Status |
+--------------------------------------+-----------------------------+--------+
| b648f563-d9a2-4770-a6d8-b3044e623366 | Cirros 0.3.5 64-bit         | active |
| 4287e01f-93b5-497f-9099-f526cb2044ac | image_hss_v0.1              | active |
| e82e459c-27b4-417e-9f95-19ba3cc3fd9d | image_hssdb_v0.1            | active |
| c62ab4ce-b95b-4e68-a708-65097c7bbe46 | image_internetemulator_v0.1 | active |
| f2166c56-f772-4614-8bb5-cb848f9d23e3 | image_mme_v0.1              | active |
| 472b7f9a-f2be-4c61-8085-8b0d37182d32 | image_sdncontroller_v0.1    | active |
| 7784877f-e45c-4b1a-9eac-478efdb368cc | image_spgwc_v0.1            | active |
| b9e2ec93-3177-458b-b3b2-c5c917f2fbcd | image_spgwu_v0.1            | active |
+--------------------------------------+-----------------------------+--------+
```

To create a virtual EPC, on the master node run:

```bash
sudo apt install httpie
http -a admin@opencord.org:letmein POST http://xos-gui.default.svc.cluster.local:4000/xosapi/v1/vepc/vepcserviceinstances blueprint=mcord_5 site_id=1
```

Check that the networks are created:

```bash
export OS_CLOUD=openstack_helm
openstack network list
```

You should see output like the following:

```text
+--------------------------------------+--------------------+--------------------------------------+
| ID                                   | Name               | Subnets                              |
+--------------------------------------+--------------------+--------------------------------------+
| 0bc8cb20-b8c7-474c-a14d-22cc4c49cde7 | s11_network        | da782aac-137a-45ae-86ee-09a06c9f3e56 |
| 5491d2fe-dcab-4276-bc1a-9ab3c9ae5275 | management         | 4037798c-fd95-4c7b-baf2-320237b83cce |
| 65f16a5c-f1aa-45d9-a73f-9d25fe366ec6 | s6a_network        | f5804cba-7956-40d8-a015-da566604d0db |
| 6ce9c7e9-19b4-45fd-8e23-8c55ad84a7d7 | spgw_network       | 699829e1-4e67-46a7-af2d-c1fc72ba988e |
| 87ffaaa3-e2a9-4546-80fa-487a256781a4 | flat_network_s1u   | 288d6a8c-8737-4e0e-9472-c869ba3e7c92 |
| 8ec59660-4751-48de-b4a3-871f4ff34d81 | db_network         | 6f14b420-0952-4292-a9f2-cfc8b2d6938e |
| d63d3490-b527-4a99-ad43-d69412b315b9 | sgi_network        | b445d554-1a47-4f3b-a46d-1e15a01731c0 |
| dac99c3e-3374-4b02-93a8-994d025993eb | flat_network_s1mme | 32dd201c-8f7f-4e11-8c42-4f05734f716a |
+--------------------------------------+--------------------+--------------------------------------+
```

Check that the VMs are created (it will take a few minutes for them to come up):

```bash
export OS_CLOUD=openstack_helm
openstack server list --all-projects
```

You should see output like the following:

```text
+--------------------------------------+-----------------+--------+----------------------------------------------------------------------------------------------------+------------------+-----------+
| ID                                   | Name            | Status | Networks                                                                                           | Image            | Flavor    |
+--------------------------------------+-----------------+--------+----------------------------------------------------------------------------------------------------+------------------+-----------+
| 7e197142-afb1-459d-b421-cad91306d19f | mysite_vmme-2   | ACTIVE | s6a_network=120.0.0.9; flat_network_s1mme=118.0.0.5; management=172.27.0.15; s11_network=112.0.0.2 | image_mme_v0.1   | m1.large  |
| 9fe385f5-a064-40e0-94d3-17ea87b955fc | mysite_vspgwu-1 | ACTIVE | management=172.27.0.5; sgi_network=115.0.0.3; spgw_network=117.0.0.3; flat_network_s1u=119.0.0.10  | image_spgwu_v0.1 | m1.xlarge |
| aa6805fe-3d72-4f1e-a2eb-5546d7916073 | mysite_hssdb-5  | ACTIVE | management=172.27.0.13; db_network=121.0.0.12                                                      | image_hssdb_v0.1 | m1.large  |
| e53138ed-2893-4073-9c9a-6eb4aa1892f1 | mysite_vhss-4   | ACTIVE | s6a_network=120.0.0.2; management=172.27.0.4; db_network=121.0.0.5                                 | image_hss_v0.1   | m1.large  |
| 4a5960b5-b5e4-4777-8fe4-f257c244f198 | mysite_vspgwc-3 | ACTIVE | management=172.27.0.7; spgw_network=117.0.0.8; s11_network=112.0.0.4                               | image_spgwc_v0.1 | m1.large  |
+--------------------------------------+-----------------+--------+----------------------------------------------------------------------------------------------------+------------------+-----------+
```
