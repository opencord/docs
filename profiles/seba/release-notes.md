# SEBA 2.0-alpha Release Notes

Major new features to SEBA include the following:

## Technology Profiles

Technology profiles provide technology specific data to devices. The NEM and Voltha are
technology-agnostic and treat profiles as opaque data, which is passed through the system
to the appropriate devices. The NEM was extended with data modeling to allows these
opaque profiles to be attached to subscribers on a per-subscriber basis. Profiles may
be configured in the NEM via TOSCA, gRPC API, or the NEM's graphical user interface. Due
to the opaque nature of the data, configuration using TOSCA is likely the most
convenient mechanism.

## Speed (Bandwidth) Profiles

Bandwidth profiles allow upstream and downstream bandwidth specifications to be
created and attached to subscribers on a per-subscriber basis. Modeling to manage these
profiles was created in the NEM, the sadis server was extended to report these
profiles, and ONOS extended to retrieve the data using sadis. As with Technology
Profiles, Speed Profiles may also be configured through the NEM via TOSCA,
gRPC API, or the NEM GUI.

## Workflow Improvements

The workflow was modified to allow the administrator to persistently disable an ONU,
preventing the workflow from re-enabling that ONU automatically.

## CORD Platform Improvements

SEBA transitioned from the CORD 6.1 platform to the CORD 7.0 platform, which has
the following major changes:

### New command-line interface (cordctl)

A new command-line interface was created, `cordctl`, that administrators may use to manage
the NEM. This tool provides an alternate interface to many of the functions that
may also be done using the NEM GUI. `cordctl` is written in the go programming language
and installs to an administrator's computer as a single binary.

The NEM API was extended to provide additional data about versioning and database
operational status, which can be viewed using `cordctl`.

### Backup and Restore

Backup and Restore features have been added for the NEM data model. These features
may be invoked using the `cordctl` tool described above, or invoked by other third-party
tools using the NEM's gRPC API. Backup stores the contents to a file that is downloaded
to the administrator's computer, and restore uploads that file and uses it to replace the
current database contents.

### In Service Software Upgrade (ISSU)

In Service Software Upgrade of NEM services allows new services to be added or
existing services to be upgraded on a live deployment. The NEM is paused while this
upgrade occurs. Live data is migrated from the old version of the data model to the
new version. Unwanted services may be subsequently unloaded and their data discarded.

### NEM modeling cleanup and validation tools

Several obsolete models were removed from the NEM's core data model. Validation was
implemented in the `xproto` language that is used to describe models within the data
model to promote consistent use of fields and options. An analysis was performed on
the use of declarative and feedback state, and tools were created to make this
analysis easier for developers.

### Base image changes

The base image for several NEM-related components was changed from Ubuntu to
Alpine in order to promote smaller container sizes.

### TOSCA Loader improvements

The TOSCA loader was modified to retry internally rather than relying on
Kubernetes as a retry mechanism. This results in faster and more predictable
deployments.

### GUI Improvements

The following improvements were made to the GUI:

* Hidden fields such as backend_status and policy_status for
  models that do not require those fields.

* Resolved performance issues with Chrome browsers.

* Resolved broken navigation between related models.

## SEBA-in-a-Box Improvements

SEBA-in-a-Box has been extended to allow easy configuration of multiple Ponsim
OLTs, ONUs, and RGs.

## BBSim Improvements

A gRPC API was implemented for BBSIM that allows information about simulated devices
to be retrieved and updated, as well as to trigger simulated alarms.

## FCAPS Improvements

The following FCAPS improvements were made:

* Kafka-topic-exporter was updated to use a configuration file, and to use logging
  consistent with other SEBA components.

* The operational status of the RADIUS accounting server is collected, published to
  Kafka, and processed by kafka-topic-exporter, where it is then made available in
  Prometheus on the NEM.

* Field naming of various event payloads was made more consistent.

* Periodic ONU Test actions were enabled to collect optical data from ONUs and publish
  it to Kafka.

## Release Versions

The following component versions comprise the SEBA 2.0 Release:

### ONOS and NEM

```text
xosproject/att-workflow-driver-synchronizer:1.2.3
xosproject/tosca-loader:1.3.0
xosproject/kubernetes-synchronizer:1.2.1
xosproject/tosca-loader:1.3.0
confluentinc/cp-kafka:5.0.1
gcr.io/google_samples/k8szk:v3
registry:2.7.1
quay.io/coreos/etcd:v3.2.18
quay.io/coreos/etcd:v3.2.18
quay.io/coreos/etcd:v3.2.18
quay.io/coreos/etcd-operator:v0.9.3
quay.io/coreos/etcd-operator:v0.9.3
quay.io/coreos/etcd-operator:v0.9.3
onosproject/onos:1.13.9
docker.elastic.co/beats/filebeat-oss:6.4.2
opencord/sadis-server:1.1.0
xosproject/fabric-synchronizer:2.2.1
xosproject/fabric-crossconnect-synchronizer:1.2.1
xosproject/onos-synchronizer:2.1.1
xosproject/rcord-synchronizer:1.3.2
xosproject/tosca-loader:1.3.1
xosproject/volt-synchronizer:2.2.4
xosproject/chameleon:3.3.0
xosproject/xos-core:3.2.9
postgres:10.3-alpine
xosproject/xos-gui:1.0.6
xosproject/xos-tosca:1.3.0
xosproject/xos-rest-gw:2.0.2
```

### Voltha

```text
gcr.io/google_containers/defaultbackend:1.4
tpdock/freeradius:2.2.9
voltha/voltha-netconf:voltha-1.7
quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.10.2
voltha/voltha-ofagent:voltha-1.7
voltha/voltha-cli:voltha-1.7
voltha/voltha-voltha:voltha-1.7
voltha/voltha-envoy:voltha-1.7
```

### ONOS Applications

```text
aaa: 1.9.0
sadis: 3.1.0
olt: 3.0.1
dhcpl2relay: 1.6.0
Kafka: 1.1.0
```

### OpenOLT

```text
openolt: voltha-1.7.0 (use Debian package openolt-1_7_0.deb)
```

### BBSim

```text
voltha/voltha-bbsim: 2.0.1
```