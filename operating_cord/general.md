# General Info

CORD's operations and management interface is primarily defined by 
its Northbound API. There is typically more than one variant of this 
interface, and they are auto-generated from the models loaded into 
CORD, as described [elsewhere](../xos/README.md). Most notably:

* A graphical interface is documented [here](gui.md).

* A RESTful version of this API is documented [here](rest_apis.md). 

* A TOSCA version is typically used to configure and provision a 
   POD. Later sections of this guide give examples of TOSCA workflows 
   used to provision and configure various [profiles](profiles.md)
   and [services](services.md).
