# Offline Install

In many cases, a CORD POD (specifically, its management network) does
not have access to Internet.

This section provides guidelines, best-practices, and examples to
deploy CORD software without Internet connectivity.

> NOTE: The guide assumes that the Operating Systems (both on servers and on network devices) and Kubernetes are already installed and running.

The offline installation is useful

* When the CORD POD has no access to Internet, so artifacts used for the installation (i.e. Docker images) cannot be downloaded directly to the POD.

* While developing, you may want to test your changes by pushing artifacts to the POD, before uploading them to the official docker repository.

## Target Infrastructure / Requirements Overview

Your target infrastructure (where the POD runs) needs

* **Local Docker Registry:** To push your Docker images
  (previously pulled from the web). If you don't have one, follow the
  notes below to use Helm to deploy a local Docker registry on top
  of your existing Kubernetes cluster.

> More informations about docker registries can be found at <https://docs.docker.com/registry/>.

* **Local Webserver:** To host the ONOS applications (.oar files),
  that are instead normally downloaded from Sonatype. If you don't
  have one, follow the notes below to quickly deploy a webserver on
  top of your existing Kubernetes cluster.
  
* **Kubernetes Servers Default Gateway:** For `kube-dns` to
  work, a default route (even pointing to a non-exisiting/working
  gateway) needs to be set on the machines hosting Kubernetes. This is
  something related to Kubernetes, not to CORD.

## Prepare the Offline Installation

This should be done from a machine that has access to Internet.

* Add the *cord* repository to the list of your local repositories and download the repository index.

```shell
helm repo add cord https://charts.opencord.org
helm repo update
```

* Add other third-party helm repositories used by CORD and pull external dependencies.

* Fetch locally all the charts from the remote repositories

```shell
helm fetch name-of-the-repo/name-of-the-chart --untar
```

* Fetch (where needed) the chart dependencies

```shell
helm dep update name-of-the-repo/name-of-the-chart
```

* Create a file to override the default values of the charts, in order to instruct Kubernetes to pull the Docker images from your local registry (where images will be pushed) instead of DockerHub, and the ONOS images from the local webserver. One option is to modify the *values.yaml* files of each chart. A better option consists in extending the charts, rather than directly modifying them. This way, the original configuration can be kept as is, and just some values can be override as needed. You can do this by writing your additional configuration yaml file, and parsing it adding `-f my-additional-config.yml` while using the helm install/upgrade commands. The full CORD helm charts reference documentation is available [here](../charts/helm.md).

* Download the ONOS applications (OAR files) used in your profile. For SEBA, this can be found here: <https://github.com/opencord/helm-charts/blob/master/xos-profiles/seba-services/values.yaml>

* Pull from DockerHub all the Docker images that need to be used on your POD. The *automation-tools* repository has a *images_from_charts.sh* utility inside the *developer* folder that can help you to get all the image names given the helm-chart repository and a list of chart names. More informations in the sections below.

* Override the default helm chart values for the ONOS applications download links, pointing them to the HTTP addresses of the files, once they'll be on your local web server.

* Optionally download the OpenOLT driver deb files from your vendor website (i.e. EdgeCore).

* Optionally, save the Docker images downloaded as tar files. This can be useful if you'll use a different machine to upload the images on the local registry running in your infrastructure. To do that, for each image use the Docker command.

```shell
docker save IMAGE_NAME:TAG > FILE_NAME.tar
```

* If the artifacts need to be deployed to the target infrastructure
  from a different machine, save the helm-charts directory, the ONOS
  applications, the docker images downloaded and the additional helm
  charts variable extension file.

## Deploy the Artifacts to Your Infrastructure

This should not require any Internet connectivity. To deploy the
artifacts to your POD, do the following from  machine that has access
to your Kubernetes cluster:

* Optionally, if at the previous step you saved the Docker images on
  an external hard drive as .tar files, restore them in the deployment
  machine Docker registry. For each image (file), use the Docker
  command:

```shell
docker load < FILE_NAME.tar
```

* Tag and push your Docker images to the local Docker registry running
  in your infrastructure. More info on this can be found in the
  paragraph below.

* Copy the ONOS applications to your local web server. The procedure
  largely varies from the web server you run, its configuration, and
  what ONOS applications you need.

* Deploy CORD using the helm charts. Remember to load with the
  *-f* option the additional configuration file to extend the helm
  charts, if any.

{% include "/partials/push-images-to-registry.md" %}

## Optional Packages

### Install a Docker Registry Using Helm

If you don't have a local Docker registry deployed in your
infrastructure, you can install an **insecure** one using the official
Kubernetes helm-chart.

Since this specific docker registry is packaged as a kubernetes pod, shipped with helm, you'll need Internet connectivity to install it.

> **Note:** *Insecure* registries can be used for development, POCs or lab trials. **You should not use this in production.** There are planty of documents online that guide you through secure registries setup.

The following command deploys the registry and exposes the port
*30500*. (You may want to change it with any value that fit your
deployment needs).

```shell
helm install stable/docker-registry --set service.nodePort=30500,service.type=NodePort -n docker-registry
```

The registry can be queried at any time, for example:

```shell
curl -X GET http://KUBERNETES_IP:30500/v2/_catalog
```

### Install a Local Webserver Using Helm (optional)

If you don't have a local web server that can be accessed from the
POD, you can easily install one on top of your existing Kubernetes
cluster.

```shell
# From the helm-charts directory, while preparing the offline install
helm repo add bitnami https://charts.bitnami.com/bitnami
helm fetch bitnami/nginx --untar

# Then, while deploying offline
helm install -n mavenrepo --set service.type=NodePort --set service.nodePorts.http=30160 bitnami/nginx
```

The webserver will be up in few seconds and you'll be able to reach
the root web page using the IP of one of your Kubernetes nodes, port
*30160*. For example, you can do:

```shell
wget KUBERNETES_IP:30160
```

OAR images can be copied to the document root of the web server using
the *kubectl cp* command. For example:

```shell
kubectl cp my-onos-app.oar `kubectl get pods | grep mavenrepo | awk '{print $1;}'`:/opt/bitnami/nginx/html
```

#### Pre-loaded maven-repo

If you are installing a released version of a profile you can take advantage of
a Maven repo container that already includes all the necessary applications.

You can find the Dockerfiles to build those containers in the [automation-tools](https://github.com/opencord/automation-tools/tree/master/developer/containers)
repository.

## Example: Offline SEBA Install

The following section provides an exemplary list of commands to
perform an offline SEBA POD installation. Please, note that some
command details (i.e. chart names, image names, tools) may have
changed over time.

### Assumptions

* The Operating Systems (both on servers and network devices) is already installed and running.

* The EdgeCore asfvolt16 OLT is used as access device. The device has an IP address 192.168.0.200.

* For convenience, the example makes also use of some automation tools, also described in paragraphs above.

* The same machine used to prepare the installation files (while still connected to Internet) is also used to perform the offline install.

* The infrastructure doesn't have a local Docker registry. As such, a dedicated local Docker registry is deployed on top of the existing Kubernetes cluster, while the Kubernetes cluster can still access Internet.

* The infrastructure doesn't have a local web server. As such, an additional web server (to host ONOS applications) is deployed on top of the existing Kubernetes cluster.

* Configuration files for SEBA have been already created. They live in the root directory and they are called fabric.yaml, olt.yaml, subscriber.yaml.

* The IP address of the machine hosting Kubernetes is 192.168.0.100.

### Prepare the Installation

```shell
# Clone the automation-tools repo
git clone https://gerrit.opencord.org/automation-tools

# Add the online helm repositories and update indexes
helm repo add cord https://charts.opencord.org
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Fetch helm charts
helm fetch cord/cord-platform --version 6.1.0 --untar
helm fetch cord/seba --version 1.0.0 --untar
helm fetch cord/att-workflow --version 1.0.0 --untar
helm fetch stable/docker-registry --untar
helm fetch bitnami/nginx --untar

# Update chart dependencies
helm dep update cord-platform
helm dep update seba

# For demo, install the local, helm-based Docker Registry on the remote POD (this will require POD connectivity to download the docker registry image)
helm install stable/docker-registry --set service.nodePort=30500,service.type=NodePort -n docker-registry

# For demo, install the local web-server to host ONOS images
helm install -n mavenrepo --set service.type=NodePort --set service.nodePorts.http=30160 bitnami/nginx

# Identify images form the official helm charts and pull images from DockerHub. If you see some "skipped value for filters" warning that's fine
bash automation-tools/developer/images_from_charts.sh cord-platform seba seba/charts/voltha/charts/etcd-cluster att-workflow | automation-tools/developer/bash pull_images.sh > images

# Download ONOS apps
curl -L "https://oss.sonatype.org/service/local/repositories/releases/content/org/opencord/olt-app/2.1.0/olt-app-2.1.0.oar" > olt.oar
curl -L "https://oss.sonatype.org/service/local/repositories/releases/content/org/opencord/sadis-app/2.2.0/sadis-app-2.2.0.oar" > sadis.oar
curl -L "https://oss.sonatype.org/service/local/repositories/releases/content/org/opencord/dhcpl2relay/1.5.0/dhcpl2relay-1.5.0.oar" > dhcpl2relay.oar
curl -L "https://oss.sonatype.org/service/local/repositories/releases/content/org/opencord/aaa/1.8.0/aaa-1.8.0.oar" > aaa.oar
curl -L "https://oss.sonatype.org/service/local/repositories/releases/content/org/opencord/kafka/1.0.0/kafka-1.0.0.oar" > kafka.oar

# Create file to override the default helm charts values (call it extend.yaml)
global:
  registry: 192.168.0.100:30500/

# CORD platform overrides
kafka:
  image: 192.168.0.100:30500/confluentinc/cp-kafka
  imageTag: 4.1.2-2
  configurationOverrides:
    zookeeper.connection.timeout.ms: 60000
    zookeeper.session.timeout.ms: 60000

  zookeeper:
    image:
      repository: 192.168.0.100:30500/gcr.io/google_samples/k8szk

logging:
  elasticsearch:
    image:
      repository: 192.168.0.100:30500/docker.elastic.co/elasticsearch/elasticsearch-oss
    initImage:
      repository: 192.168.0.100:30500/busybox

  kibana:
    image:
      repository: 192.168.0.100:30500/docker.elastic.co/kibana/kibana-oss

  logstash:
    image:
      repository: 192.168.0.100:30500/docker.elastic.co/logstash/logstash-oss

nem-monitoring:
  grafana:
    image:
      repository: 192.168.0.100:30500/grafana/grafana
    sidecar:
      image: 192.168.0.100:30500/kiwigrid/k8s-sidecar:0.0.3

  prometheus:
    server:
      image:
        repository: 192.168.0.100:30500/prom/prometheus
    alertmanager:
      image:
        repository: 192.168.0.100:30500/prom/alertmanager
    configmapReload:
      image:
        repository: 192.168.0.100:30500/jimmidyson/configmap-reload
    kubeStateMetrics:
      image:
        repository: 192.168.0.100:30500/quay.io/coreos/kube-state-metrics
    nodeExporter:
      image:
        repository: 192.168.0.100:30500/prom/node-exporter
    pushgateway:
      image:
        repository: 192.168.0.100:30500/prom/pushgateway
    initChownData:
      image:
        repository: 192.168.0.100:30500/busybox

# SEBA specific overrides
voltha:
  etcd-cluster:
    spec:
      repository: 192.168.0.100:30500/quay.io/coreos/etcd
    pod:
      busyboxImage: 192.168.0.100:30500/busybox:1.28.1-glibc

  etcdOperator:
    image:
      repository: 192.168.0.100:30500/quay.io/coreos/etcd-operator
  backupOperator:
    image:
      repository: 192.168.0.100:30500/quay.io/coreos/etcd-operator
  restoreOperator:
    image:
      repository: 192.168.0.100:30500/quay.io/coreos/etcd-operator

seba-services:
  oltAppUrl: http://192.168.0.100:30160/olt.oar
  sadisAppUrl: http://192.168.0.100:30160/sadis.oar
  dhcpL2RelayAppUrl: http://192.168.0.100:30160/dhcpl2relay.oar
  aaaAppUrl: http://192.168.0.100:30160/aaa.oar
  kafkaAppUrl: http://192.168.0.100:30160/kafka.oar

# Download the openolt.deb driver installation file from the vendor website (command varies)
scp/wget... openolt.deb
```

### Offline Deployment

```shell
# Tag and push the images to the local Docker registry
cat images | bash automation-tools/developer/tag_and_push.sh -r 192.168.0.100:30500

# Copy the ONOS applications to the local web server
MAVEN_REPO=$(kubectl get pods | grep mavenrepo | awk '{print $1;}')
kubectl cp olt.oar $MAVEN_REPO:/opt/bitnami/nginx/html
kubectl cp sadis.oar $MAVEN_REPO:/opt/bitnami/nginx/html
kubectl cp dhcpl2relay.oar $MAVEN_REPO:/opt/bitnami/nginx/html
kubectl cp aaa.oar $MAVEN_REPO:/opt/bitnami/nginx/html
kubectl cp kafka.oar $MAVEN_REPO:/opt/bitnami/nginx/html

# Install the CORD platform, the SEBA profile and the ATT workflow
helm install -n cord-platform -f extend.yaml cord-platform
helm install -n seba -f extend.yaml seba
helm install -n att-workflow -f extend.yaml att-workflow

# On the OLT, copy, install and run openolt.deb
scp openolt.deb root@192.168.0.200:
ssh root@192.168.0.200 'dpkg -i openolt.deb'
ssh root@192.168.0.200 'service bal_core_dist start'
ssh root@192.168.0.200 'service openolt start'

# Configure SEBA
curl -H "xos-username: admin@opencord.org" -H "xos-password: letmein" -X POST --data-binary @fabric.yaml http://192.168.0.100:30007/run
curl -H "xos-username: admin@opencord.org" -H "xos-password: letmein" -X POST --data-binary @olt.yaml http://192.168.0.100:30007/run
curl -H "xos-username: admin@opencord.org" -H "xos-password: letmein" -X POST --data-binary @subscriber.yaml http://192.168.0.100:30007/run
```
