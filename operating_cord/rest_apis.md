# RESTful APIs

A RESTful interface is available for configuring and controlling CORD. It is
auto-generated from the set of [models](/xos/intro.md) configured
into a POD, and includes both core and service-specific models. Click
[here](https://guide.opencord.org/master/api/xos/) to see API defined
for the full set of services checked into [Gerrit](https://gerrit.opencord.org).

You can access the REST API specification on a running POD by going to
the `/apidocs/` URL on the Chameleon REST endpoint (exposed at
port 30006 by default): `http://pod-ip-or-dns-address:30006/apidocs/`.
