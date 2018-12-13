# Install SEBA Charts

This page walks through the sequence of Helm operations needed to
bring up the SEBA profile. It assumes the Platform has already been
installed.

## Install VOLTHA

Install [voltha](../../charts/voltha.md).
It will manage the OLT devices.

## Install Seba-Services

Install [seba-services](../../charts/seba-services.md).
This will run all the XOS services necessary to manage the data plane.
