# APIs

This section describes workflows for interacting with the API of the CORD. There are multiple APIs. Some of them are used in a Northbound context, for services sitting on top the CORD, and some are used internally for components to communicate with each other.

* [gRPC](https://github.com/hyunsun/docs/tree/a7c57608e40a8306309625802fa069c38c3d1d8a/xos/dev/grpc_api.md). The gRPC API is used internally for synchronizers and for Chameleon to speak with the XOS core. It's also available as a Northbound API.
* [REST](rest_apis.md). The REST API is implemented by the Chameleon container. In addition to being a popular Northbound API, it's also used by the XOS GUI.
* [TOSCA](https://github.com/hyunsun/docs/tree/a7c57608e40a8306309625802fa069c38c3d1d8a/xos-tosca/README.md). TOSCA is implemented by the xos-tosca container and is typically used to configure and provision a POD. The following two references describe how to use TOSCA to configure Profiles and Services, respectively:
  * [Configuring Profiles](../../../references/intro/)
  * [Configuring Services](../../../references/services/)

