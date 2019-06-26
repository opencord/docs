# Developing ONOS Applications with SEBA in a Box

This tutorial will guide you through the development workflow for ONOS applications in SEBA.
The `aaa` application will be used as an example, but the same workflow is valid for any
ONOS application.

### Requirements

In order to follow this tutorial you need to:

- have a remote machine to run [SEBA-in-a-Box](../../profiles/seba/siab.md)
- have the Java SDK installed on your development machine
- have the CORD code (we suggest to download the code using [this guide](../getting_the_code.md#download-cord-repositories))

{% include "/partials/siab-short.md" %}

## Test applications on a running setup

We assume you already have done changes to your application code and that you need to build it and push it
to a running ONOS.

To build the application, just enter the appropriate folder and invoke the `maven` target:

```bash
cd ~/cord/onos-apps/apps/aaa/
mvn clean install
```

Once the application is built, you can push it to ONOS using the `onos-app` command:

```bash
onos-app -P 30120 -u karaf -p karaf <myregistrydomain.com> reinstall! org.opencord.aaa app/target/aaa-app-1.10.0-SNAPSHOT.oar
```

where `myregistrydomain.com` is the public `ip` of your `SiaB` machine.

If the commands succeed you should see an output similar to:

```bash
{"name":"org.opencord.aaa","id":173,"version":"1.10.0.SNAPSHOT","category":"Traffic Steering","description":"802.","readme":"802.1x authentication service.","origin":"ON.Lab","url":"http://onosproject.org","featuresRepo":"mvn:org.opencord/aaa-app/1.10.0-SNAPSHOT/xml/features","state":"ACTIVE","features":["aaa-app"],"permissions":[],"requiredApps":["org.opencord.sadis"]}
```

**Important!!**

Please remember that the application `.oar` can be generated in a different
location depending on the application structure and that the version included in the SNAPSHOT file name can differ.

> You can get the `onos-app` command you can get it [here](https://github.com/opennetworkinglab/onos/blob/onos-1.13/tools/package/runtime/bin/onos-app)
> and add it to your `$PATH`

## Deploy SiaB using development applications

In certain cases you want to deploy SEBA-in-a-box automatically including your development applications,
for example to verify that the end to end flow is correctly working.

In order to do that you need to:

- make your applications available somewhere for ONOS to download them
- customize the ONOS applications URL in the helm charts

We suggest to create a `nginx` container and deploy it on top of the kubernetes cluster, but if have a company
web-server that is reachable by ONOS that can be a viable option.

### Build the mavenrepo container

A `Dockerfile` to build a `nginx` web-server containing development `.oar`s is provided with the code.
You can build such container by:

```bash
cd ~/cord/onos-apps
docker build -t opencord/mavenrepo:candidate -f Dockerfile.apps .
...
Successfully built fda11faac37f
Successfully tagged opencord/mavenrepo:candidate
```

#### Deploy the mavenrepo container on top of your cluster

> NOTE that this step requires a `docker-registry` to be installed in the cluster.
> If you don't have it, you can follow [these instructions](./siab.md#deploy-a-docker-registry).

Once the container is build, you can push it to the remote `docker-registry` using these commands:

```bash
docker tag opencord/mavenrepo:candidate myregistrydomain.com:30500/opencord/mavenrepo:candidate
docker push myregistrydomain.com:30500/opencord/mavenrepo:candidate
The push refers to repository [myregistrydomain.com:30500/opencord/mavenrepo]
2781364a4526: Pushed
8a32ae098140: Pushed
7c9c7be9dce0: Pushed
9a6bd1609bff: Pushed
77e23640b533: Pushed
757d7bb101da: Pushed
3358360aedad: Pushed
candidate: digest: sha256:38788909e84ffb955a41fd14eea9c19f4596bb9b3b7f3181a1332499b7709b94 size: 1786
```

where `myregistrydomain.com` is the public `ip` of your `SiaB` machine.

Once the container is loaded in the `docker-registry` you can you `helm` to deploy it from the SiaB host machine:

```bash
cd ~/cord/helm-charts
helm install -n mavenrepo cord/mavenrepo --set image.tag=candidate \
--set image.repository=myregistrydomain.com:30500/opencord/mavenrepo
```

#### Customize the ONOS applications URL in the helm charts

In order to install custom versions of the application during the installation process, you need to create
a value file called `~/custom.yaml` (on the SiaB host machine) with the following values:


>If you already have a value file to specify other container images you can simply extend that one


```yaml
aaaAppUrl: "http://myregistrydomain.com:30160/repository/aaa-app-1.10.0-SNAPSHOT.oar"
aaaAppVersion: "1.10.0.SNAPSHOT"
```

where `myregistrydomain.com` is the public `ip` of your `SiaB` machine.

You can then install SEBA-in-a-box with:

```bash
SEBAVALUES=~/custom.yaml make
```

> You can find a full list of the application names and URLs here:
> - https://github.com/opencord/helm-charts/blob/master/xos-profiles/seba-services/values.yaml#L43-L53
> - https://github.com/opencord/helm-charts/blob/master/workflows/att-workflow/values.yaml#L40-L41
