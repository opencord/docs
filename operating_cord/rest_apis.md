# RESTful APIs

A RESTful interface is available for configuring and controlling CORD. It is
auto-generated from the set of [models](/xos/README.md) configured
into the POD manifest, and includes both core and service-specific models.

* [Core](https://guide.opencord.org/{{ book.branch }}/api/xos/#/core)
* [Address Manager](https://guide.opencord.org/{{ book.branch }}/api/xos/#/addressmanager)
* [vTR](https://guide.opencord.org/{{ book.branch }}/api/xos/#/vtr)
* [vSG](https://guide.opencord.org/{{ book.branch }}/api/xos/#/vsg)
* [vNoD Local](https://guide.opencord.org/{{ book.branch }}/api/xos/#/vnodlocal)
* [vRouter](https://guide.opencord.org/{{ book.branch }}/api/xos/#/vrouter)
* [ONOS Service](https://guide.opencord.org/{{ book.branch }}/api/xos/#/onos)
* [Fabric Service](https://guide.opencord.org/{{ book.branch }}/api/xos/#/fabric)
* [Example Service](https://guide.opencord.org/{{ book.branch }}/api/xos/#/exampleservice)
* [vEE](https://guide.opencord.org/{{ book.branch }}/api/xos/#/vee)
* [vEG](https://guide.opencord.org/{{ book.branch }}/api/xos/#/veg)
* [vnaas](https://guide.opencord.org/{{ book.branch }}/api/xos/#/vnaas)

You can access the Swagger docs for the REST APIs on a running POD by going to
the `/apidocs/` URL on the the Chameleon REST endpoint (exposed at port 30006
by default): <http://pod-ip-or-dns-address:30006/apidocs/>.
