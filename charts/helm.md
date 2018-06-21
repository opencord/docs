# Helm Reference

{% include "/partials/helm/description.md" %}

For information on how to install `helm` please refer to
[Installing Helm](../prereqs/helm.md).

## CORD Helm Charts

All helm charts used to install CORD can be found in the `helm-chart`
repository. Most of the top-level directories in that repository
(e.g., `onos`, `voltha`, `xos-core`) correspond to components of
CORD that can be installed independently. For example, it is possible
to bring up `onos` without `voltha`, and vice versa. You can also
bring up XOS by itself (`xos-core`) or XOS with its GUI (`xos-core`
and `xos-gui`). This can be useful if you want to work on just the
CORD data models, without any backend components.

The `xos-services` and `xos-profiles` directories contain helm
charts for individual services and profiles (a mesh of services),
respectively. While it is possible to use Helm to bring up an
individual service, collections of related services are typically
installed as a unit; we call this unit a *profile.* Looking in the
`xos-profiles` directory, `rcord-lite` is an example profile. It
corresponds to R-CORD, and inspecting its `requirements.yaml`
file shows that it, in turn, depends on the `volt` and `vrouter`
services, among several others.

Some of the profiles bring up sub-systems that other profiles then
build upon. For example, `base-openstack` brings up three platform
related services (`onos-service`, `openstack`, and `vtn-service`),
which effectively provisions CORD to support OpenStack-based VNFs.
Once the services in the `base-openstack` profile are running, it
is then possible to bring up the `mcord` profile, which corresponds
to ~10 other services. It is also possible to bring up an individual
service by executing its helm chart; for example
`xos-services/simpleexampleservice`.

> **Note:** Sometimes we install Individual services by first
> "wrapping" them in a profile. For example,
> `SimpleExampleService` is deployed from the
> `xos-profiles/demo-simpleexampleservice` profile, rather
> than directly from `xos-services/simpleexampleservice`.
> The latter is included by reference from the former.
> This is not a fundamental limitation, but we do it when we
> want to run the `tosca-loader` that loads a TOSCA workflow
> into CORD. This feature is currently available at only
> the profile level.

Similarly, the `base-kubernetes` profile brings up Kubernetes in
support of container-based VNFs. This corresponds to the
`kubernetes-service`, not to be confused with CORD's use of
Kubernetes to deploy the CORD control plane. Once this profile is
running, it is possible to bring up an example VNF in a container
by executing its helm chart; for example
`xos-profiles/demo-simpleexampleservice`.

> **Note:** The `base-kubernetes` configuration does not yet
> incorporate VTN. Doing so is work-in-progress.

Finally, note that the `templates` sub-directory in both the
`xos-services` and `xos-profiles` directories includes one or
more TOSCA-related files. These play a role in configuring the
service graph and provisioning the individual services contained
in that service graph. This happens once the helm charts have
done their job, and is technically a post-install operation, as
discussed in the [Operations Guide](../operating_cord/operating_cord.md).

### Download the helm-charts Repository

You can get the CORD helm charts by cloning the `helm-charts` repository:

```shell
git clone https://gerrit.opencord.org/helm-charts
```

> **Note:** If you have downloaded the CORD code following the [Getting the Source
> Code](../developer/getting_the_code.md) guide, you'll find it in
> `~/cord/helm-charts`.

**IMPORTANT: All the helm commands needs to be executed from within this directory**

### Add the CORD Repository to Helm

If you don't want to download the repository, you can just add the OPENCord charts to your helm repo:

```shell
helm repo add cord https://charts.opencord.org/master
helm repo update
```

If you decide to follow this route, the `cord/` prefix needs to be
added to specify the repo to use. For example:

```shell
helm install -n xos-core xos-core
```

will become

```shell
helm install -n xos-core cord/xos-core
```

## CORD Example Values

There is an `example` directory in the `helm-chart` repository.
The files contained in that directory are examples of possible overrides
to obtain a custom deployment.

For example, it is possible to deploy a single instance of `kafka`,
for development purposes, by using this value file:

```shell
helm install --name cord-kafka incubator/kafka -f examples/kafka-single.yaml
```
