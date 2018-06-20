# CORD Guide

This is a curated set of guides that describe how to install, operate, test,
and develop [CORD](https://opencord.org).

CORD is a community-based open source project. In addition to this guide, you
can find information about this community, its projects, and its governance on
the [CORD wiki](https://wiki.opencord.org). This includes early white papers
and design notes that have shaped [CORD's
architecture](https://wiki.opencord.org/display/CORD/Documentation).

## Navigating the Guide

The guide is organized around the major stages in the lifecycle of CORD:

* [Installation](README.md): Installing (and later upgrading) CORD.
* [Operations](operating_cord/operating_cord.md): Operating an already
  installed CORD deployment.
* [Development](developer/developer.md): Developing new functionality
  to be included in CORD.
* [Testing](cord-tester/README.md): Testing functionality to be
 included in CORD.

These are all fairly obvious. What's less obvious is the relationship among
these stages, which is helpful in [Navigating CORD](navigate.md).

## Making Changes to the Guide

The [http://guide.opencord.org](http://guide.opencord.org) website is built
using the [GitBook Toolchain](https://toolchain.gitbook.com/), with the
documentation root in
[docs](https://github.com/opencord/docs/blob/{{ book.branch }}) in a
checked out source tree.  It is build with `make`, and requires that `gitbook`,
`python`, and a few other tools are installed.

Source for individual guides is available in the [CORD code
repository](https://gerrit.opencord.org); look in the `docs` directory of each
project, with the documentation rooted in the top-level `/docs`
directory. Updates and improvements to this documentation can be
submitted through Gerrit.
