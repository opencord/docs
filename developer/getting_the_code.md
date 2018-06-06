# Getting the Source Code

## Install repo

We use the [repo](https://code.google.com/archive/p/git-repo/) tool
from Google, which works with Gerrit, to manage the multiple git repos
that make up the CORD code base.

If you don't already have `repo` installed, you may be able to install
it with your system package manager, or you can follow these
[instructions from the android source site](https://source.android.com/source/downloading#installing-repo):

```sh
curl -o /tmp/repo 'https://gerrit.opencord.org/gitweb?p=repo.git;a=blob_plain;f=repo;hb=refs/heads/stable'
echo '394d93ac7261d59db58afa49bb5f88386fea8518792491ee3db8baab49c3ecda  /tmp/repo' | sha256sum -c -
sudo mv /tmp/repo /usr/local/bin/repo
sudo chmod a+x /usr/local/bin/repo
```

> **Note:** As mentioned above, you may want to install *repo* using the official
> repository instead. We forked the original repository and host a copy of the
> file to make repo downloadable also by organizations that don't have access
> to Google servers.

## Download CORD Repositories

The `cord` repositories are usually checked out to `~/cord` in most of our
examples and deployments:

{% include "/partials/repo-download.md" %}

> **Note:** `-b` specifies the branch name. Development work goes on in `master`,
> and there are also specific stable branches such as `cord-6.0` that can be
> used.

When this is complete, a listing (`ls`) inside this directory should yield
output similar to:

```sh
$ ls
automation-tools        component               helm-charts             onos-apps               subscriber.yaml
build                   docs                    incubator               orchestration           test
```

## Download Patchsets

Once you've downloaded a CORD source tree, you can download patchsets from
Gerrit with the following command:

```shell
repo download orchestration/xos 1234/3
```

which downloads patchset number `1234` and version `3` for the `xos` git repo.

## Contributing Code to CORD

We use [Gerrit](https://gerrit.opencord.org) to manage the CORD code base. For
more information see [Working with
Gerrit](https://wiki.opencord.org/display/CORD/Working+with+Gerrit).

For a general introduction to ways you can participate and contribute to the
project, see [Contributing to
CORD](https://wiki.opencord.org/display/CORD/Contributing+to+CORD).

## Testing and QA Repositories

While not part of the standard process for deploying a CORD POD, the
repo manifest files and the infrastructure code used to configure our
test and QA systems, including Jenkins jobs created with [Jenkins Job
Builder](https://docs.openstack.org/infra/jenkins-job-builder/) can be
also be downloaded with repo.  The `ci-management` repo uses git
submodules, so those need to be checked out as well:

```shell
mkdir cordqa
cd cordqa
repo init -u https://gerrit.opencord.org/qa-manifest -b master
repo sync
cd ci-management
git submodule init
git submodule update
```

See `ci-management/README.md` for further instructions.

