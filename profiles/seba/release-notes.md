# SEBA 2.0-alpha Release Notes

Major new features to the platform include the following:

## Technology Profiles

Technology profiles provide technology specific data to devices. The NEM and Voltha are
technology-agnostic and treat profiles as opaque data, which is passed through the system
to the appropriate devices. The NEM was extended with data modeling to allows these
opaque profiles to be attached to subscribers on a per-subscriber basis. Profiles may
be configured in the NEM via TOSCA, gRPC API, or the NEM's graphical user interface. Due
to the opaque nature of the data, configuration using TOSCA is likely the most 
convenient mechanism.  

## Speed Profiles

Bandwidth profiles allow upstream and downstream bandwidth specifications to be 
created and attached to subscribers on a per-subscriber basis. Modeling to manage these
profiles was created in the NEM, and ONOS retrieves the data using sadis. 

## CORD Platform Improvements

SEBA transitioned from the CORD 6.1 platform to the CORD 7.0 platform, which features
the following major changes:

### New command-line interface (cordctl)

A new command-line interface was created, `cordctl`, that operators may use to manage
the NEM. This tool provides an alternate interface to many of the functions that
may also be done using the NEM GUI. `corctl` is written in the go programming language
and installs to an operator's computer as a single binary.

### Backup and Restore

Backup and Restore features have been added for the NEM data model. These features
may be invoked using the `cordctl` tool described above, or invoked by other third-party
tools using the NEM's gRPC API. Backup stores the contents to a file that is downloaded
to the operator's computer, and restore uploads that file and uses it to replace the
current database contents.

### In Service Software Upgrade (ISSU)

In Service Software Upgrade of NEM services allows new services to be added or 
existing services to be upgraded on a live deployment. The NEM is paused while this
upgrade occurs. Live data is upgraded from one version of the data model to the
new version. Unwanted services may be subsequently unloaded and their data discarded.

## SEBA-in-a-Box Improvements

SEBA-in-a-Box has been extended to allow easy configuration of multiple ponsim
OLTs and ONUs.

## BBSIM Improvements

BBSIM was refactored 