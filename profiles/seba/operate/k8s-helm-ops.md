# Container Operations

CORD uses Helm to manage the lifecycles of its component micro-services.
This page describes how to perform some basic tasks using Helm commands.
It assumes that charts are being installed from CORD's online Helm chart
repository.  To add this repository to your local Helm installation:

```bash
helm repo add cord https://charts.opencord.org
helm repo update
```

If you have checked out the `helm-charts` repository locally and are installing
charts from that, replace `cord/` in the examples below with the path to the
chart.

## Upgrade a Chart

Upgrading a Helm chart will upgrade its services to the versions specified
in the chart.  For example, to upgrade the `seba-services` Helm chart to
v1.0.3, assuming that has been published to the online chart repository:

```bash
helm upgrade --version=1.0.3 --reuse-values \
    seba-services cord/seba-services
```

The `--reuse-values` flag instructs Helm to pass in the same values
used when installing the original chart.  If you want to specify a different
set of values, you can omit this and instead specify new values using
`-f myvalues.yaml`.

## Upgrade a Single XOS Service's Image

In order to upgrade a running micro-service to a new version, it's necessary to
update the Helm chart used to launch the service to specify the new Docker
image repository and/or tag.  One way to do this is by upgrading the
chart that was initially used to launch the service as mentioned above.
However some  charts (like `seba-services`) install multiple sub-charts,
each of which installs its own XOS service.  How can an operator upgrade a
single service?

An easy way to do this is with Helm's `--set` argument.  To do this it's
necessary to understand how the sub-chart specifies its image name and tag,
as well as how the charts are nested.  Using `seba-services` as an example,
suppose that we have installed `seba-services` v1.0.2, and we want to upgrade
the `fabric-crossconnect` service it installs from v1.1.4 to v1.1.5 without
upgrading the `seba-services` chart to a new version.  We can do so with this
command:

```bash
helm upgrade --version=1.0.2 --reuse-values \
    --set fabric-crossconnect.image.tag=1.1.5 \
    seba-services cord/seba-services
```

The `seba-services` chart specifies the `fabric-crossconnect` chart
as a requirement.  The `fabric-crossconnect` chart's `values.yaml`
file uses `image.tag` to specify the Docker image tag. So this command
will pull down the new image and re-launch the `fabric-crossconnect`
Kubernetes pod using this image.

As another example, v1.0.0 of the `att-workflow` chart runs
the `xosproject/att-workflow-driver:1.0.12` Docker image from Docker Hub.  Suppose that you want to install image `myrepo/att-workflow-driver:test-image` in its place.  To upgrade to this new image run:

```bash
helm upgrade --version=1.0.0 --reuse-values \
    --set att-workflow-driver.image.repository=myrepo/att-workflow-driver
    --set att-workflow-driver.image.tag=test-image \
    att-workflow cord/att-workflow
```

To verify that you're specifying the `--set` arguments correctly, you can
replace `helm upgrade` with `helm template` in the above commands.  This will
print out all the Kubernetes resources that Helm generates, and you can
check that the image has actually been updated in the resources.
