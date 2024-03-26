# .ONESHELL:
.SHELL := /usr/bin/bash
.DEFAULT_GOAL := install-hooks
TEMPLATE_REPO_URL := "https://github.com/narvar/terraform-module-template"

.PHONY: help install-hooks run-hooks documentation fmt init lint plan apply

ifeq (, $(shell which pre-commit))
	$(error "No pre-commit in $(PATH), get it from https://pre-commit.com")
endif

help:
	@echo 'TODO: Add Help'

install-hooks: ## Install pre-commit
	@pre-commit install --install-hooks


run-hooks: install-hooks
	@pre-commit run --all-files

init:
	@terraform init \
		-input=false \
		-force-copy \
		-upgrade=true

lint: init
	@tflint

plan: init
	@rm -rf planOutput
	@mkdir -p  planOutput
	@terraform plan \
		-lock=true \
		-input=false \
		-out=planOutput/tfplan

apply: init
	@terraform apply \
		-lock=true \
		-input=false \
		planOutput/tfplan

documentation: init ## Generate README.md for a module
	@terraform-docs \
		markdown table \
		--sort-by required  . > README.md

fmt: init
		@terraform fmt \
				-write=true \
				-recursive

clean:
	@rm -rf planOutput
