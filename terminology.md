# GLOSSARY 

## CORD POD

A single physical deployment of CORD.

## Development (Dev) machine

This is the machine used to download, build and deploy CORD onto a POD.
Sometimes it is a dedicated server, and sometimes the developer's laptop. In
principle, it can be any machine that satisfies the hardware and software
requirements.

## Development (Dev) VM

Bootstrapping the CORD installation requires a lot of software to be installed and some non-trivial configurations to be applied.  All this should happen on the dev machine.  To help users with the process, CORD provides an easy way to create a VM on the dev machine with all the required software and configurations in place.

## Compute Node(s)

A server in a POD that run VMs or containers associated with one or more
tenant services. This terminology is borrowed from OpenStack.

## Head Node

A compute node of the POD that also runs management services. This includes
for example XOS (the orchestrator), two instances of ONOS (the SDN controller,
one to control the underlay fabric and one to control the overlay), MAAS and
all the services needed to automatically install and configure the rest of
the POD devices.

## Fabric Switch

A switch in a POD that interconnects other switches and servers inside the
POD.

