# sh-realpath
NAME := sh-realpath
DESC := bsd realpath support
BUILDTIME := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILDDATE := $(shell date -u +"%B %d, %Y")

.PHONY: test
test: lint unit-test

.PHONY: lint
lint:
	-shellcheck realpath.sh
	-checkbashisms realpath.sh

.PHONY: unit-test
unit-test: t/*

t/%: force
	bash "$@"
	dash "$@"

.PHONY: force
force: ;
