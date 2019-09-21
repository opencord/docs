# COMAC Release Note

This is the first release of [COMAC (Converged Multi-Access and Core)](https://www.opennetworking.org/comac/). 
After many years work, this project is graduating from demo quality to field trial quality towards production readiness.

Release v1.0 achitecture overview:
![release-overview](./images/release-overview.png)

Highlights:

* The EPC of COMAC is [OMEC](https://github.com/omec-project).
* COMAC added a new feature: Mobile Subscriber State.
* COMAC also has it own Grafana dashboard for monitoring.
* COMAC leverages the latest SEBA platform which is hardened for deployment.
* COMAC is based on Kubernetes and containers, no VMs.
* The underlay fabric is based on [Trellis](https://docs.trellisfabric.org/).
* The RAN part in green boxes will not be part of v1.0 release, but subsequent releases.







