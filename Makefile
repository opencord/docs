# Makefile for building CORD docs site, guide.opencord.org
# Building docs requires the following tools:
#  - Gitbook toolchain: https://toolchain.gitbook.com/setup.html
#  - git
#  - NPM (for Gitbook and Swagger)
#  - linkchecker (for test target) http://wummel.github.io/linkchecker/
#  - markdownlint (for lint target) https://github.com/markdownlint/markdownlint

default: serve

# use bash for pushd/popd, and to fail quickly
SHELL = bash -eu -o pipefail

# Other repos with documentation that's included in the gitbook
# edit the `git_refs` file with the commit/tag/branch that you want to use
OTHER_REPO_DOCS ?= cord-tester fabric hippie-oss kubernetes-service olt-service onos-service openolt openstack rcord simpleexampleservice vrouter xos xos-gui xos-tosca
GENERATED_DOCS  ?= # should be 'swagger', but currently broken
ALL_DOCS        ?= $(OTHER_REPO_DOCS) $(GENERATED_DOCS)

# build targets
serve: | $(ALL_DOCS) gitbook-setup
	npm start

build: _book

_book: | $(ALL_DOCS) gitbook-setup
	gitbook build

gitbook-setup:
	gitbook init
	gitbook install

clean:
	rm -rf _book
	rm -rf node_modules
	rm -rf repos/*
	rm -rf $(ALL_DOCS)

# testing targets
test: lint linkcheck
LINT_STYLE ?= mdl_relaxed.rb

lint: | $(OTHER_REPO_DOCS)
	@echo "markdownlint(mdl) version: `mdl --version`"
	@echo "style config:"
	@echo "---"
	@cat $(LINT_STYLE)
	@echo "---"
	mdl -s $(LINT_STYLE) `find -L . ! -path "./partials/*" ! -path "./_book/*" ! -path "./repos/*"  ! -path "./node_modules/*" ! -path "./cord-tester/modules/*" -name "*.md"`

linkcheck: $(ALL_DOCS) _book
	linkchecker -a _book/

# Host holding the git server
REPO_HOST   ?= https://gerrit.opencord.org

# checkout the repos inside repos/ dir
repos:
	mkdir repos

# build directory paths in repos/* to perform 'git clone <repo>' into
CHECKOUT_REPOS=$(foreach repo,$(OTHER_REPO_DOCS),repos/$(repo))

# For QA patchset validation - set SKIP_CHECKOUT to the repo name and
# pre-populate it under epos with the specific commit to being validated
SKIP_CHECKOUT ?=

# clone (only if doesn't exist), then checkout ref in repos/*
$(CHECKOUT_REPOS):  git_refs | repos
	GIT_REF=`grep '^$(@F) ' git_refs | awk '{print $$3}'` ;\
	if [ ! -d '$@' ] ;\
	  then git clone $(REPO_HOST)/$(@F) $@ ;\
	fi ;\
	if [ "$(SKIP_CHECKOUT)" = "$(@F)" ] ;\
	  then echo "Skipping checkout of repo $(SKIP_CHECKOUT) as it's being tested" ;\
	else pushd $@ ;\
	  git checkout $$GIT_REF ;\
	  popd ;\
	fi

# link subdirectories (if applicable) into main docs dir
$(OTHER_REPO_DOCS): | $(CHECKOUT_REPOS)
	GIT_SUBDIR=`grep '^$@ ' git_refs | awk '{print $$2}'` ;\
	ln -s repos/$(@)$$GIT_SUBDIR $@

# swagger docs generation
swagger: xos
	pushd repos/xos/docs; make swagger_docs; popd;

