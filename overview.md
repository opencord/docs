# Overview

This is a curated set of documents that describe how to install, operate, test, and develop [CORD](https://www.opennetworking.org/cord/). The material is organized in two parts:

* _Guides:_ Outlines the process of installing, operating, testing and developing for CORD as a whole.
* _References:_ Definitions and specifications about individual components that make up CORD.

CORD is a community-based open source project. In addition to this guide, you can find information about this community, its projects, and its governance on the [CORD wiki](https://wiki.opencord.org). This includes early white papers and design notes that have shaped [CORD's architecture](https://wiki.opencord.org/display/CORD/Documentation).

## Navigating the Guides

The guides are organized around the major stages in the lifecycle of CORD:

* [Installation](guides/readme/): Installing \(and later upgrading\) CORD.
* [Operations](guides/operating_cord/): Operating an already

  installed CORD deployment.

* [Development](guides/developer/): Developing new functionality

  to be included in CORD.

* [Testing](https://github.com/hyunsun/docs/tree/a7c57608e40a8306309625802fa069c38c3d1d8a/cord-tester/README.md): Testing functionality to be

  included in CORD.

These are all fairly obvious. What's less obvious is the relationship among these stages, which is explained in [Navigating CORD](navigate.md).

## Navigating the References

CORD is built from disaggregated components that are assembled into a composite solution. The References are organized accordingly:

* [Profile Reference](references/intro/): Installation and

  configuation details for specific solutions built using CORD

  components.

* [Service Reference](references/services/): Configuration

   \(TOSCA\) and modeling \(xproto\) definitions for individual CORD

   components.

* [Helm Refernce](references/helm/): Helm charts used to install

   individual CORD components.

For more information on the relationship between Profiles and Services, see [Navigating CORD](navigate.md).

## Making Changes to this Document

The [http://guide.opencord.org](http://guide.opencord.org) website is built using the [GitBook Toolchain](https://toolchain.gitbook.com/), with the documentation root in [docs](https://github.com/opencord/docs/blob/{{%20book.branch%20}}) in a checked out source tree. It is build with `make`, and requires that `gitbook`, `python`, and a few other tools are installed.

Source for individual guides is available in the [CORD code repository](https://gerrit.opencord.org); look in the `docs` directory of each project, with the documentation rooted in the top-level `/docs` directory. Updates and improvements to this documentation can be submitted through Gerrit.

