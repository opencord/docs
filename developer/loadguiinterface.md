#Loading Up GUI Interface
This tutorial below allows users to open and use the GUI Interface of the Cord Project. The guide is split up into three sections, Downloads/Pre-requisites, Tutorial, and Troubleshooting. If you happen to find any other difficulties, please refer to different parts of the guide.

##Downloads/Pre-requisites
Below are a few programs and applications that are crucial to this tutorial and using the GUI of the CORD project.

- Docker
- Minikube(Recommended for this tutorial)
- Kubectl
- Clone helm-charts
```shell
	git clone https://gerrit.opencord.org/helm-charts
```
- Duplicate the below code into your own .yaml file. Add it to the recently cloned helm-charts folder.
```shell
# curl -H "xos-username: admin@opencord.org" -H "xos-password: letmein" -X POST --data-binary @service_graph.yaml http://192.168.99.100:30007/run
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/service.yaml
  - custom_types/servicedependency.yaml
  - custom_types/servicegraphconstraint.yaml
description: rcord-lite service graph
topology_template:
  node_templates:

    service#foo:
      type: tosca.nodes.Service
      properties:
        name: Foo

    service#bar:
      type: tosca.nodes.Service
      properties:
        name: Bar

    service_dependency#onos-fabric_fabric:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#foo
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#bar
            relationship: tosca.relationships.BelongsToOne

    constraints:
      type: tosca.nodes.ServiceGraphConstraint
      properties:
        constraints: '["foo", "bar"]'
```

##Tutorial
Below are the ten steps that will allow you to open the GUI Interface for the CORD project. Any common errors are noted in the Troubleshooting section below.

1. Open and run Docker

2. Delete any existing minikube clusters you may have
```shell
	minikube delete
```
3. Start a new minikube cluster
```shell
	minikube start
```
4. Navigate to the helm-charts folder and initialize Tiller.
```shell
	cd helm-charts
	helm init
```
5. Install XOS-CORE and any needed containers in the helm-charts folder
```shell
	helm install -n xos-core cord/xos-core
```
6. Verify that the cluster is working normally
```shell
	kubectl get pods
```
7. Find your minikube cluster's unique IP address. This will be used in the next step.
```shell
	minikube ip
```
8.  Run the following command and install 2 classes to the Service Graph on the User Interface. Replace the '192.168.99.100' with your unique cluster ip from Step 7.
```shell
	curl -H "xos-username: admin@opencord.org" -H "xos-password: letmein" -X POST --data-binary @service_graph.yaml http://192.168.99.100:30007/run
```
9. Load up the User Interface domain with the following command.
```shell
	minikube service xos-gui
```
10. Sign in to the Login page on the User Interface.
	Username: admin@opencord.org
	Password: letmein

If you have completed the above steps correctly, you will be greeted by a service-graph that has two classes 'foo' and 'bar'. If you have not reached this graph, refer to the troubleshooting section below. 

##Troubleshooting
Below are a few common errors you may encounter in the duration of completing this tutorial.

1.
Issue: Step 4 results in the below error message and does not allow you to download the xos-core folder.
```shell
	Could not find a ready tiller pod
```
Solution: This error will once occur if you haven't initialized Tiller inside the installed helm-charts folder. Re-initialize Tiller and try again.

2. 
Issue: Step 6 returns the below error message and does not allow you to open the service-graph.
```shell
	No resources found
```
Solution: Make sure you have downloaded the xos-core and containers folder inside the existing helm-charts folder. Re-download the xos-core folder (Step 5) and make sure you are in the helm-charts folder.

3. 
Issue: Step 9 results in the below error message and does not open the User Interface.
```shell
	Error message: Could not find finalized endpoint
```
Solution: Delete the currently installed helm-charts folder and download it again. Make sure you are navigating everything after Step 4 from the newly installed helm-charts folder.

