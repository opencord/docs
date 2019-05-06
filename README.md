# Installation Guide

This guide describes how to install CORD on a physical POD. It identifies a set of [prerequisites](prereqs/README.md), and then walks through the steps involved in bringing up the [Platform](installation/platform.md). Once the Platform is installed, you are ready to bring up one of the available Profiles:

* [SEBA](./profiles/seba/install.md)
* [M-CORD](./profiles/mcord/install.md)

Alternatively if you just want to quickly bring up SEBA, try the [SEBA Quick Start](quickstart/seba_quickstart.md).

This installation procedure requires management-network connectivity to the Internet. If your installation does not have such connectivity, or you are behind a restrictive firewall, consider [Offline Install](installation/offline-install.md).

If you do not have the [prerequisite hardware](./prereqs/hardware.md) needed for a POD, consider running a complete system entirely emulated in software using [SEBA-in-a-Box](./profiles/seba/siab-overview.md).

If you prefer a gentle walkthrough of the process of bringing up a subset of the CORD platform running on your laptop (e.g., to get an introduction to all the moving parts in CORD) then jumping to the [ExampleService Quick Start](quickstart/example_service_quickstart.md) page is also an option.

Finally, if you want to get a broader lay-of-the-land, you might step back and read the [Overview](overview.md).
