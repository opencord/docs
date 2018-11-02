# API Interaction

This guide describes workflows for interacting with the API of the NEM. There
are several different API mechanisms that the NEM supports. Some of them are
used in a Northbound context, for services sitting on top the NEM to interact
with the NEM, and some are used internally for components to communicate with each other.

* [gRPC](/xos/dev/grpc_api.md). The gRPC API is used internally for synchronizers and for Chameleon to speak with the XOS core. It's also available as a Northbound API.

* REST. The REST API is implemented by the Chameleon container. In addition to being a popular Northbound API, it's also used by the XOS GUI.

* Tosca. TOSCA is implemented by the xos-tosca container. TOSCA is used extensively in bootstrapping the system, and can also be used as a general-purpose runtime API.
