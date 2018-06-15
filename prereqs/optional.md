# Optional Packages

Although not required, you may want to install one or both of the following
packages:

* **Local Registry:** If your environment does not permit connecting your
  POD to ther public Internet, you may want to take advantage of a local Docker
  registery. The following [registry setup](docker-registry.md) will help.
  (Having a local registry is also useful when doing local development, as outlined
  in the [Developer Guide](../developer/workflows.md).)

* **OpenStack:** If you need to include OpenStack in your deployment,
  so you can bring up VMs on your POD, you will need to following the
  [OpenStack deployment](openstack-helm.md) guide.
