# Contribute to the documentation

> This tutorial assumes you already have [cloned the code](./getting_the_code.md),
> [NodeJs](https://nodejs.org/en/) and the [Gitbook Toolchain](https://toolchain.gitbook.com/)
> are installed.

From a terminal window navigate to the documentation root:

```shell
cd ~/cord/docs
```

To serve a development copy run:

```shell
make serve
```

This command will print a bunch of debugging information, but once completed you
should see:

```shell
Starting server ...
Serving book on http://localhost:4040
```

Just open that URL in your browser and you'll be able to see the documentation.

## Prepare to make changes

The documentation is stored in a `git` repository together with the rest of the code,
so the process to submit a patch is the same as described [here](https://wiki.opencord.org/display/CORD/Working+with+Gerrit).

Let's get started by creating a new `branch` to keep our changes:

```shell
repo start feature/my-amazing-doc-changes
```

_You're now ready to start making changes!_

## Making changes to an existing page

To make changes to an existing page, just locate the correct `.md` file.

> An easy way to do this is to navigate to the page you want to look at and look
> at the URL. A URL like `http://localhost:4040/developer/getting_the_code.html`
> will translate to a file located in `~/cord/docs/developer/getting_the_code.md`.

Note that the files are written in `markdown`, if you are not familiar with it
please take a look at this [cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet).

Most IDEs and Editors have plugins to format `markdown` that will give you a good preview,
but remember that you have a development server running, so you can always go back in the
browser and see how your changes look like.

So just go ahead and make the changes you want!

## Adding a new page

If you want to add a new page create a new `.md` file in the appropriate location.
We are trying to group together files by topic, so just try to find the most meaningful
folder for your new guide. That will make it easier for others to consume and improve it.

For this example we are going to create a new page in `developer/test_page.md`
and we will insert some dummy content:

```shell
touch ~/cord/docs/developer/test_page.md
echo "# Test Page" > ~/cord/docs/developer/test_page.md
```

The last operation we need to do is to add the page to the navigation. To do that
open `~/cord/docs/SUMMARY.md` and insert the new link, such as:

```yaml
...

* [Development Guide](developer/developer.md)
    * [Getting the Source Code](developer/getting_the_code.md)
    * [Modeling Services](developer/xos-intro.md)
    * [Developer Workflows](developer/workflows.md)
        * [Service Migrations](xos/dev/xosmigrate.md)
    * [Building Docker Images](developer/imagebuilder.md)
    * [GUI Development](xos-gui/developer/README.md)
        * [Quickstart](xos-gui/developer/quickstart.md)
        * [GUI Extensions](xos-gui/developer/gui_extensions.md)
        * [GUI Internals](xos-gui/architecture/README.md)
            * [Module Strucure](xos-gui/architecture/gui-modules.md)
            * [Data Sources](xos-gui/architecture/data-sources.md)
        * [Tests](xos-gui/developer/tests.md)
    * [Unit Tests](xos/dev/unittest.md)
    * [Versions and Releases](developer/versioning.md)
    * [Test Page](developer/test_page.md)

...
```

## Submitting your changes for review

Regardless wether you created a new page or improved a new one the process to
submit a patch is the same.

Start by verifying that your changes are passing the validation.
This happens automatically on Jenkins, but it's always better to check before
uploading a path, so execute:

```shell
make lint
```

Then check what has changed in the source tree by running `git status`,
here is a typical output:

```shell
On branch feature/contribute_to_the_docs
Your branch is up-to-date with 'opencord/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

  modified:   SUMMARY.md

Untracked files:
  (use "git add <file>..." to include in what will be committed)

  .idea/
  att-workflow-driver
  automation-tools
  cord-tester
  developer/contribute_to_the_docs.md
  exampleservice
  fabric
  fabric-crossconnect
  hippie-oss
  kubernetes-service
  olt-service
  onos-service
  openolt
  openstack
  rcord
  simpleexampleservice
  vrouter
  vtn-service
  xos
  xos-gui
  xos-tosca
```

Note that there a bunch of files not included in `git`. Those files can't be added to
the `.gitignore` as otherwise `gitbook` will ignore them too, so please be careful
in including only the file you changed/created:

```shell
git add SUMMARY.md
git add developer/contribute_to_the_docs.md
```

Then commit and upload the changes:

```shell
git commit -m "documentation changes"
repo upload . -t
```
