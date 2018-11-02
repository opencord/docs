# API Guide

This guide describes workflows for interacting with the API of the NEM. There
are several different API mechanisms that the NEM supports. Some of them are
used in a Northbound context, for services sitting on top the NEM to interact
with the NEM, and some are used internally for components to communicate with each other.

* [gRPC](/xos/dev/grpc_api.md). The gRPC API is used internally for synchronizers and for Chameleon to speak with the XOS core. It's also available as a Northbound API.

* [REST](/operating_cord/rest_apis.md). The REST API is implemented by the Chameleon container. In addition to being a popular Northbound API, it's also used by the XOS GUI.

* [TOSCA](/xos-tosca/README.md). TOSCA is implemented by the xos-tosca container and is typically used to configure and provision a
   POD. Later sections of this guide give examples of TOSCA workflows used to provision and configure various
   [profiles](/operating_cord/profiles.md) and [services](/operating_cord/services.md). TOSCA can also be used as a general-purpose runtime API.
