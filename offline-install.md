# Offline installation

Often, CORD PODs' (management networks) don't have access to Internet.

This section of the guide provides guidelines, best-practices and examples to deploy the CORD/SEBA software without Internet connectivity.

> NOTE: The guide assumes that the Operating Systems (both on servers and on network devices) and Kubernetes are already installed and running.

The offline installation is useful

* When the CORD POD has no access to Internet, so artifacts used for the installation (i.e. Docker images) cannot be downloaded directly to the POD.

* While developing, you may want to test your changes pushing artifacts to the POD, before uploading them to the official docker repository.

## Target Infrastructure, requirements overview

Your target infrastructure (where the POD runs) needs

* A **local Docker Registry** where to push your Docker images (previously pulled from the web). If you don't have one, follow the notes below to deploy with helm a local Docker registry on top of your existing Kubernetes cluster.

> More informations about docker registries can be found at <https://docs.docker.com/registry/>.

* A **local webserver** to host the ONOS applications (.oar files), that are instead normally downloaded from Sonatype. If you don't have one, follow the notes below to quickly deploy a webserver on top of your existing Kubernetes cluster.

* **Kubernetes servers default gateway**: In order for kube-dns to work, a default route (even pointing to a non-exisiting/working gateway) needs to be set on the machines hosting Kubernetes. This is something related to Kubernetes, not to CORD.

## Prepare the offline installation

This should be done from a machine that has access to Internet.

* Clone the *helm-charts* repository

```shell
git clone https://gerrit.opencord.org/helm-charts
```

Next steps largely depend on the type of profile you want to install.

* Add external helm repositories and pull external dependencies.

* Fetch helm-charts not available locally.

* Modify the CORD helm charts to instruct kubernetes to pull the images from your local registry (where images will be pushed), instead of DockerHub. One option is to modify the *values.yaml* in each chart. A better option consists in extending the charts, rather than directly modifying them. This way, the original configuration can be kept as is, just overriding some values as needed. You can do this by writing your additional configuration yaml file, and parsing it as needed, adding `-f my-additional-config.yml` while using the helm install/upgrade commands. The full CORD helm charts reference documentation is available [here](../charts/helm.md).

* Download the ONOS applications (OAR files). Informations about the oar applications used can be found here: <https://github.com/opencord/onos-service/blob/master/xos/synchronizer/steps/sync_onos_app.py#L125-L130>

* Pull from DockerHub all the Docker images that need to be used on your POD. The *automation-tools* repository has a *images_from_charts.sh* utility inside the *developer* folder that can help you to get all the image names given the helm-chart repository and a list of chart names. More informations in the sections below.

* Override the default helm chart values for the ONOS applications download links, pointing them to the HTTP addresses of the files, once they'll be on your local web server.

* Optionally download the OpenOLT driver deb files from your vendor website (i.e. EdgeCore).

* Optionally, save as tar files the Docker images downloaded. This can be useful if you'll use a different machine to upload the images on the local registry running in your infrastructure. To do that, for each image use the Docker command.

```shell
docker save IMAGE_NAME:TAG > FILE_NAME.tar
```

* If the artifacts need to be deployed to the target infrastructure from a different machine, save the helm-charts directory, the ONOS applications, the docker images downloaded and the additional helm charts variable extension file.

## Deploy the artifacts to your infrastructure and install CORD/SEBA

This should not require any Internet connectivity. To deploy the artifacts to your POD, do the following from  machine that has access to your Kubernetes cluster:

* Optionally, if at the previous step you saved the Docker images on an external hard drive as .tar files, restore them in the deployment machine Docker registry. For each image (file), use the docker command

```shell
docker load < FILE_NAME.tar
```

* Tag and push your Docker images to the local Docker registry running in your infrastructure. More info on this can be found in the paragraph below.

* Copy the ONOS applications to your local web server. The procedure largely varies from the web server you run, its configuration, and what ONOS applications you need.

* Deploy CORD/SEBA using the helm charts. Remember to load with the *-f* option the additional configuration file to extend the helm charts, if any.

{% include "/partials/push-images-to-registry.md" %}

## Optional packages

### Install a Docker Registry using helm

If you don't have a local Docker registry deployed in your infrastructure, you can install an **insecure** one using the official Kubernetes helm-chart.

> **Note:** *Insecure* registries can be used for development, POCs or lab trials. **You should not use this in production.** There are planty of documents online that guide you through secure registries setup.

The following command deploys the registry and exposes the port *30500*. (You may want to change it with any value that fit your deployment needs).

```shell
helm install stable/docker-registry --set service.nodePort=30500,service.type=NodePort -n docker-registry
```

The registry can be queried at any time, for example:

```shell
curl -X GET http://KUBERNETES_IP:30500/v2/_catalog
```

### Install a local web server using helm (optional)

If you don't have a local web server that can be accessed from the POD, you can easily install one on top of your existing Kubernetes cluster.

```shell
# From the helm-charts directory, while preparing the offline install
helm repo add bitnami https://charts.bitnami.com/bitnami
helm fetch bitnami/nginx --untar

# Then, while deploying offline
helm install -n maven-repo bitnami/nginx
```

The webserver will be up in few seconds and you'll be able to reach the root web page using the IP of one of your Kubernetes nodes, port *30278*. For example, you can do:

```shell
wget KUBERNETES_IP:30278
```

OAR images can be copied to the document root of the web server using the *kubectl cp* command. For example:

```shell
kubectl cp my-onos-app.oar `kubectl get pods | grep maven-repo | awk '{print $1;}'`:/opt/bitnami/nginx/html
```

## Example: offline SEBA install

The following section provides an exemplary list of commands to perform an offline SEBA POD installation. Please, note that some command details (i.e. chart names, image names, tools) may have changed over time.

### Assumptions

* The Operating Systems (both on servers and network devices) is already installed and running.

* The EdgeCore asfvolt16 OLT is used as access device. The device has an IP address 192.168.0.200.

* For convenience, the example makes also use of some automation tools, also described in paragraphs above.

* The same machine used to prepare the installation files (while still connected to Internet) is also used to perform the offline install.

* The infrastructure doesn't have a local Docker registry. As such, a dedicated local Docker registry is deployed on top of the existing Kubernetes cluster, while the Kubernetes cluster can still access Internet.

* The infrastructure doesn't have a local web server. As such, an additional web server (to host ONOS applications) is deployed on top of the existing Kubernetes cluster.

* Configuration files for SEBA have been already created. They live in the root directory and they are called fabric.yaml, olt.yaml, subscriber.yaml.

* The IP address of the machine hosting Kubernetes is 192.168.0.100.

### Prepare the installation

```shell
# Clone repos
git clone https://gerrit.opencord.org/automation-tools
git clone https://gerrit.opencord.org/helm-charts

# Copy automation scripts in the right place
cp automation-tools/developer/images_from_charts.sh helm-charts
cp automation-tools/developer/pull_images.sh helm-charts
cp automation-tools/developer/tag_and_push.sh helm-charts

cd helm-charts

# Add online helm repositories and update dependencies
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
helm repo add rook-beta https://charts.rook.io/beta
helm repo add bitnami https://charts.bitnami.com/bitnami
helm dep update voltha
helm dep update xos-core
helm dep update xos-profiles/att-workflow
xos-profiles/base-kubernetes
helm dep update nem-monitoring
helm dep update logging
helm dep update storage/rook-operator

# Fetch helm-charts not available locally
helm fetch stable/docker-registry --untar
helm fetch --version 0.8.0 stable/etcd-operator --untar
helm fetch --version 0.8.8 incubator/kafka --untar
helm fetch bitnami/nginx --untar

# Update Kafka dependencies
helm dep update kafka

# For demo, install the local, helm-based Docker Registry on the remote POD (this will require POD connectivity to download the docker registry image)
helm install stable/docker-registry --set service.nodePort=30500,service.type=NodePort -n docker-registry

# For demo, install the local web-server to host ONOS images
helm install -n maven-repo bitnami/nginx

# Identify images form the official helm charts and pull images from DockerHub. If you see some "skipped value for filters" warning that's fine
bash images_from_charts.sh kafka etcd-cluster etcd-operator voltha onos xos-core xos-profiles/att-workflow xos-profiles/base-kubernetes nem-monitoring logging storage/rook-operator | bash pull_images.sh > images

# Download ONOS apps
wget https://oss.sonatype.org/service/local/repositories/snapshots/content/org/opencord/olt-app/2.1.0-SNAPSHOT/olt-app-2.1.0-20181030.071543-35.oar
wget https://oss.sonatype.org/service/local/repositories/snapshots/content/org/opencord/sadis-app/2.2.0-SNAPSHOT/sadis-app-2.2.0-20181030.071559-154.oar
wget https://oss.sonatype.org/service/local/repositories/snapshots/content/org/opencord/dhcpl2relay/1.5.0-SNAPSHOT/dhcpl2relay-1.5.0-20181030.071500-154.oar
wget https://oss.sonatype.org/service/local/repositories/snapshots/content/org/opencord/aaa/1.8.0-SNAPSHOT/aaa-1.8.0-20181113.081456-110.oar
wget https://oss.sonatype.org/service/local/repositories/snapshots/content/org/opencord/kafka/1.0.0-SNAPSHOT/kafka-1.0.0-20181030.071524-104.oar

# Create file to extend the helm charts (call it extend.yaml)
global:
  registry: 192.168.0.100:30500/

image: 192.168.0.100:30500/confluentinc/cp-kafka
imageTag: 4.1.2-2

zookeeper:
  image:
    repository: 192.168.0.100:30500/gcr.io/google_samples/k8szk

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

oltAppUrl: http://192.168.0.100:30278/olt-app-2.1.0-20181030.071543-35.oar
sadisAppUrl: http://192.168.0.100:30278/sadis-app-2.2.0-20181030.071559-154.oar
dhcpL2RelayAppUrl: http://192.168.0.100:30278/dhcpl2relay-1.5.0-20181030.071500-154.oar
aaaAppUrl: http://192.168.0.100:30278/aaa-1.8.0-20181113.081456-110.oar
kafkaAppUrl: http://192.168.0.100:30278/kafka-1.0.0-20181030.071524-104.oar

# Download the openolt.deb driver installation file from the vendor website (command varies)
scp/wget... openolt.deb
```

### Offline deployment

```shell
cd helm-charts

# Tag and push the images to the local Docker registry
cat images | bash tag_and_push.sh -r 192.168.0.100:30500

# Copy the ONOS applications to the local web server
MAVEN_REPO=$(kubectl get pods | grep maven-repo | awk '{print $1;}')
kubectl cp olt-app-2.1.0-20181030.071543-35.oar $MAVEN_REPO:/opt/bitnami/nginx/html
kubectl cp sadis-app-2.2.0-20181030.071559-154.oar $MAVEN_REPO:/opt/bitnami/nginx/html
kubectl cp dhcpl2relay-1.5.0-20181030.071500-154.oar $MAVEN_REPO:/opt/bitnami/nginx/html
kubectl cp aaa-1.8.0-20181113.081456-110.oar $MAVEN_REPO:/opt/bitnami/nginx/html
kubectl cp kafka-1.0.0-20181030.071524-104.oar $MAVEN_REPO:/opt/bitnami/nginx/html

# Install SEBA
helm install -n etcd-operator -f extend.yaml --version 0.8.0 etcd-operator
helm install -n cord-kafka -f examples/kafka-single.yaml -f extend.yaml --version 0.8.8 kafka
helm install -n voltha -f extend.yaml voltha
helm install -n onos -f configs/onos.yaml -f extend.yaml onos
helm install -n xos-core -f extend.yaml xos-core
helm install -n att-workflow -f extend.yaml xos-profiles/att-workflow
helm install -n base-kubernetes -f extend.yaml xos-profiles/base-kubernetes
helm install -n nem-monitoring -f extend.yaml nem-monitoring
helm install -n logging -f extend.yaml logging

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
