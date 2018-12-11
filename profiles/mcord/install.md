# Install  M-CORD Charts

> **Note**: Currently the M-CORD is under maintenance.
> Check the link below for more information:
> [https://wiki.opencord.org/display/CORD/GPL+Issue+August+2018](https://wiki.opencord.org/display/CORD/GPL+Issue+August+2018)

## Quick Start

A convenience script is provided that will install M-CORD on a single
node, suitable for evaluation or testing.  Requirements:

- An _Ubuntu 16.04.4 LTS_ server with at least 64GB of RAM and 32 virtual CPUs
- Latest versions of released software installed on the server: `sudo apt update`
- User invoking the script has passwordless `sudo` capability
- Open access to the Internet (not behind a proxy)
- Public DNS servers (e.g., 8.8.8.8) are accessible

### Target server on CloudLab (optional)

If you do not have a target server available that meets the above
requirements, you can borrow one on [CloudLab](https://www.cloudlab.us). Sign
up for an account using your organization's email address and choose "Join
Existing Project"; for "Project Name" enter `cord-testdrive`.

> NOTE: CloudLab is supporting CORD as a courtesy.
It is expected that you will not use CloudLab resources for purposes other than evaluating CORD.
If, after a week or two, you wish to continue using CloudLab to experiment with or develop CORD, then you must apply for your own separate CloudLab project.

Once your account is approved, start an experiment using the
`OnePC-Ubuntu16.04-HWE` profile on the Wisconsin cluster. This will provide
you with a temporary target server meeting the above requirements.

Refer to the [CloudLab documentation](http://docs.cloudlab.us/) for more information.

### Convenience Script

This script takes about an hour to complete.  If you run it, you can jump
directly to the [Validating the Installation](#validating-the-installation) section.

```bash
mkdir ~/cord
cd ~/cord
git clone https://gerrit.opencord.org/automation-tools
automation-tools/mcord/mcord-in-a-box.sh
```

## Prerequisites

- Kubernetes: 1.10.0
- Helm: v2.10.0

## CORD Components

Bring up M-CORD installing the following helm charts in order:

- [base-kubernetes](../../charts/helm.md)
- [xos-core](../../charts/xos-core.md)

> **Note:** Install xos-core with `--set xos_projectName="M-CORD"` to get correct
> name on XOS web UI.

- [onos-fabric](../../charts/onos.md#onos-fabric)
- [mcord](../../charts/mcord.md)

## Validating the Installation

Verify all components are installed by Helm:
```
cord@mcord:~$ helm list
NAME                    REVISION    UPDATED                     STATUS      CHART                     APP VERSION    NAMESPACE
base-kubernetes         1           Mon Sep 10 19:27:45 2018    DEPLOYED    base-kubernetes-0.1.0     1.0            default
mcord                   1           Mon Sep 10 19:32:21 2018    DEPLOYED    mcord-subscriber-2.0.0                   default
onos-fabric             1           Mon Sep 10 19:47:05 2018    DEPLOYED    onos-mwc-0.1.0            1.0            default
vepcservice             1           Mon Sep 10 19:30:29 2018    DEPLOYED    vepcservice-1.0.0                        default
xos-core                1           Mon Sep 10 19:25:19 2018    DEPLOYED    xos-core-2.1.0-dev                       default
```
