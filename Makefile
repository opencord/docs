# Makefile for building CORD docs site, guide.opencord.org
# Building docs requires the following tools:
#  - Gitbook toolchain: https://toolchain.gitbook.com/setup.html
#  - NPM (for Gitbook and Swagger)
#  - Python (for build glossary script)
#  - linkchecker (for test target) http://wummel.github.io/linkchecker/

default: serve

# use bash for pushd/popd, and to fail if commands within  a pipe fail
SHELL = bash -o pipefail

GENERATED_DOCS =

LINT_STYLE ?= mdl_relaxed.rb

serve: setup
	gitbook serve --port 4040

build: setup
	gitbook build

setup: automation-tools cord-tester xos xos-gui xos-tosca swagger $(GENERATED_DOCS)
	gitbook init
	gitbook install

test: linkcheck lint

linkcheck: build
	linkchecker --check-extern -a _book/

lint:
	@echo "markdownlint(mdl) version: `mdl --version`"
	@echo "style config:"
	@echo "---"
	@cat $(LINT_STYLE)
	@echo "---"
	mdl -s $(LINT_STYLE) `find -L . ! -path "./partials/*" ! -path "./_book/*" ! -path "./node_modules/*" ! -path "./cord-tester/modules/*" -name "*.md"`

# link directories that contain other documentation
automation-tools:
	ln -s ../automation-tools automation-tools

cord-tester:
	ln -s ../test/cord-tester/docs cord-tester

xos:
	ln -s ../orchestration/xos/docs xos

xos-gui:
	ln -s ../orchestration/xos-gui/docs xos-gui

xos-tosca:
	ln -s ../orchestration/xos-tosca/docs xos-tosca

swagger: xos
	pushd ../orchestration/xos/docs/; make swagger_docs; popd;

clean:
	rm -rf $(GENERATED_DOCS)
	rm -rf _book
	rm -rf node_modules
	rm -rf automation-tools cord-tester test xos xos-gui xos-tosca

