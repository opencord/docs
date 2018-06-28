# Makefile for building CORD docs site, guide.opencord.org
# Building docs requires the following tools:
#  - Gitbook toolchain: https://toolchain.gitbook.com/setup.html
#  - git
#  - NPM (for Gitbook and Swagger)
#  - linkchecker (for test target) http://wummel.github.io/linkchecker/
#  - markdownlint (for lint target) https://github.com/markdownlint/markdownlint

default: serve

# use bash for pushd/popd, and to fail if commands within a pipe fail
SHELL = bash -o pipefail

serve: | $(ALL_DOCS) gitbook-setup
	npm start

build: _book

test: lint linkcheck

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

# linting with markdownlint
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

# Other repos with documentation that's included in the gitbook
# edit the `git_refs` file with the commit/tag/branch that you want to use
OTHER_REPO_DOCS ?= cord-tester fabric hippie-oss kubernetes-service olt-service onos-service openstack rcord simpleexampleservice vrouter xos xos-gui xos-tosca

GENERATED_DOCS ?= swagger

ALL_DOCS ?= $(OTHER_REPO_DOCS) $(GENERATED_DOCS)

repos:
	mkdir repos

CHECKOUT_REPOS=$(foreach repo,$(OTHER_REPO_DOCS),repos/$(repo))

$(CHECKOUT_REPOS): repos git_refs
	GIT_REF=`grep '^$(@F) ' git_refs | awk '{print $$2}'` ;\
	git clone $(GIT_HOST)/$(@F) $@ ;\
	pushd $@ ;\
	git checkout $$GIT_REF ;\
	popd

$(OTHER_REPO_DOCS): | $(CHECKOUT_REPOS)
	ln -s repos/$@/docs $@

# swagger generates docs
swagger: xos
	pushd repos/xos/docs; make swagger_docs; popd;

