# Releasing CORD Software with Gerrit and Jenkins

The purpose of this document is to explain how individual software
projects that are a part of the CORD family are tested and
released using Gerrit and Jenkins.

It should help answer the following questions:

- How are projects versioned?
- Why did my patchset fail a job in Jenkins?
- How are binary artifacts created and published?

Gerrit has the concept of projects which map onto individual git repos.
*project* and *repo *may be used interchangeably in this document.

## Versioning Projects

The versioning model embraced by most projects is fully automated to
optimize for development velocity, and has these characteristics:

1. [Semantic Versioning](https://semver.org/) ("SemVer") is used as a
   versioning scheme.

2. There is a file in the git repo of a project that sets the version.
   Changing this file changes the version of the project.

   In this vast majority of projects this file is named `VERSION`, and contains
   only the version string.

   There is also support for reading the version out of  `package.json`, used
   with node.js projects.

   Other means of specifying the version could be supported, as long as
   they are derived from files committed in the repo.

3. The SemVer version in the file can be either a:

    - "Released Version", which strictly matches the `major.minor.patch` scheme
       (examples: 0.1.4, 1.0.0, 2.3.4)

    - "Non-Released Version", which additionally has a suffix that indicates
      they are somewhere in the development cycle (1.4.0-dev0, 2.1.1-rc3,
      etc.).

   Whether Released Version has additional connotations ("stable", "ready for
   deployment") is up to the individual projects.

4. It's required that **only a single commit on a repo may contain a unique
   Released Version.** This avoids a whole host of problems and confusion
   around versioning as it relates to source code management - nonsensical and
   hard to answer questions like "Which version of 1.0.0 is this?" are
   eliminated.

   This also means that there is no way to fix a broken release* using the
   same vanity version number*, as that breaks the one commit per version
   invariant. In cases like this, abandon vanity and create a new minor or
   patch version of the code.

   This requirement isn't enforced on Non-Released Versions - most of the
   time during development a Non-Released Version should be used and may
   apply across multiple patchsets.

   The `version-check` Jenkins jobs enforce this requirement, and prevent
   submission of patchsets that contain an already-Released Version.

   A common development pattern is to immediately create and commit another
   patchset that increments the version to a Non-Released Version after
   committing a Released Version.

   Rebasing of patchsets on top of Released Versions will need to change
   the version file to avoid being rejected in Jenkins. Additionally,
   automatic merge or rebase has to be disabled on the project repo so that
   the jobs that ensure a changed version file are run on each patchset.
   Reverting a patchsets has similar requirements - reversions must go to a
   Non-Released Version to avoid the pre- and post- revert patches from
   having the same Released Version.

5. On submission of a patchset, a version-tag job runs in Jenkins, and
   if it contains a Released Version number, a git tag with that same
   version is created on the project repo. Git tags are not created for
   Non-Released Versions.

There should be no manual tagging or moving of tags that use SemVer
versions. Various non-SemVer vanity tagging of jobs may have been
applied in the past, but future use is discouraged.

## Pre-Submit Testing Jobs

Before a patchset can be submitted on a project, various jobs are run to
validate the correctness and quality of the patchset. These result in a
Verified +1 or -1 to be added to the Gerrit patchset.

### License validation job: `*_licensed`

This job does a naive license validation test, checking for certain
words related to the software license in each file in the repo.

This job is implemented using the
[licensecheck.sh](https://gerrit.opencord.org/plugins/gitiles/ci-management/+/refs/heads/master/jjb/shell/licensecheck.sh)
script. It contains a list of file extensions that can't be checked for
licenses - if your patchset uses a new file extension that is both incompatible
with a license header (binary file type, or doesn't allow comments), the
extension may need to be added to this script.

The default license used on code on opencord.org is the [Apache
  2](https://www.apache.org/licenses/LICENSE-2.0) license contributions are
  expected to use that license.

### Tag Collision job: `*_tag-collision`

This job validates that no two patchsets use the same Released Version.

If your patchset fails this job, you likely need to change the contents
of the `VERSION` file that specifies the code version to add a `-dev0` or
other suffix.

### Helm Lint job: `*_helm-lint`

Validates helm charts with `helm lint --strict`, and that the version of
the chart has changed if the charts were modified.

Note that historically charts started from the helm create template
don't past the strict lint.

### Unit Test jobs: `*_unit-test*`

These run the unit tests included with the project. Usually these are
defined in a Makefile, and by default the make test target is run.

It's expected that unit tests will output Jenkins-consumable XML test
reports when this target is run. These are:

- Test results in JUnit XML format into a filename matching `*results.xml`
- Coverage results in Cobertura XML format, into a filename matching
  `*coverage.xml`

There may be multiple of these files generated during a test, and Jenkins will
search all subdirectories of the workspace for any matching files.

## Post-Submit Jobs

These jobs are run after code is submitted, and will tag/build/publish
various artifacts.

### Version tag job: `version-tag*`

This job creates git tags from the version file. The tag is frequently
used by other jobs, so it's a prerequisite to many of them.

### Helm Repo job: `publish-helm-repo*`

This job finds all helm charts in a repo (chart == presence of the
Charts.yaml file), and adds them to another git repo, which is published
on the public [charts.opencord.org](https://charts.opencord.org) site.

It supports pulling helm charts from multiple projects and combining
them into the single charts repo.

### Publish Python modules to PyPI job: `pypi-publish_*`

This job creates a python module and uploads it to the [Python Package Index
  (PyPI)](https://pypi.org/).

It does this using the standard python setup.py sdist process. The
target PyPI project must have the onfauto user assigned Owner
permissions for the publishing step to work.

Other targets such as building binary wheels aren't currently supported,
but could be in the future.

### Publish Docker container images to public DockerHub job: `docker-publish_*`

This job builds docker container images and publishes them to Docker
Hub. Building images via a Jenkins job instead of via an automated build
on DockerHub has a more consistent turnaround time - automated builds
may take anywhere from 10 minutes to 12 hours to start building.

To use this job, a project needs to have a Makefile in the root of the
git repo, which has two targets:

- `docker-build` - builds the Docker images
- `docker-push` - push the Docker images to a registry

It also depends on the following environmental variables being set, with
these default values:

- `DOCKER_REGISTRY` - Docker Registry DNS address/IP with port and trailing
  slash

  Default value is blank, example value: 10.0.0.1:5000/

- `DOCKER_REPOSITORY` - Docker Repository name, with trailing slash

  Default value to blank or the project name w/slash such as: `opencord/`,
  `xosproject/`, `voltha/`, etc.

- `DOCKER_TAG` - The tag (portion after the `:`) to apply to the image

  Default value is read from the contents of the `VERSION` file

An example that complies with these requirements these can be found in the
[alpine-grpc-base
  Makefile](https://gerrit.opencord.org/plugins/gitiles/alpine-grpc-base/+/refs/heads/master/Makefile).

The `docker-build` and `docker-push` may be invoked multiple times during
the job, setting the `DOCKER_TAG` variable with both the branch name and
with any git tags on the commit (must run after the version-tag job).

For the images to be pushed to DockerHub, the repository must already be
created on DockerHub, and the automation group must be given Read &
Write permission on the repo.

Currently the build process only creates amd64 images, but in the future
multiarch images may be built as well.

### Publish artifacts to a GitHub releases: `github-release_*`

This builds and publishes binary artifacts to the GitHub releases page under a
repository.

To use this functionality, your Makefile must have a `make release` target that
will build binary artifacts.

In the configuration of this job, you must specify the name of the
`github-organization` this repository is uploaded under, and specify a shell
glob as `artifact-glob` to identify the files that were created.

When a git tagged version is created, the Jenkins job will run `make release`
then upload all the artifacts matching `artifact-glob` as well as generating
and uploading a `checksum.SHA256` file containing hashes for the artifacts,
which should be used to validate downloaded artifacts.

## Making new Jenkins jobs

There may be tests written for a specific project. If you need another
job, ask about similar jobs on the mailing lists, or in the CORD Slack
QA channel.

Jobs are defined with [Jenkins Job Builder] and stored in the [ci-management
  project](https://gerrit.opencord.org/plugins/gitiles/ci-management/+/refs/heads/master).
  Pleasesee the `README.md` there for documentation on how to create jobs.

Most tests are implemented using shell scripts or as Jenkinsfiles
(groovy).
