# Emulated OLT/ONU

Support for emulating the OLT/ONU using `ponsim` is still a
work-in-progress, so it is not currently possible to bring up R-CORD
without the necessary access hardware. In the meantime, it is possible
to set up a development environment that includes just the R-CORD
control plane. Doing so involves installing the following helm charts:

- [xos-core](../../charts/xos-core.md)
- [cord-kafka](../../charts/kafka.md)
- [hippie-oss](../../charts/hippie-oss.md)

in addition to `rcord-lite`. This would typically be done
on a [single node platform](../../prereqs/k8s-single-node.md) in
support of a developer workflow that [emulates subscriber
provisioning](../../developer/configuration_rcord.md).

