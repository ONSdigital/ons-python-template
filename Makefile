.DEFAULT_GOAL := all

.PHONY: all
all: ## Show the available make targets.
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@fgrep "##" Makefile | fgrep -v fgrep

.PHONY: lint
lint:  ## Run Python linter
	poetry run ruff check .
	poetry run ruff format --check .

.PHONY: format
format:  ## Format and fix Python code.
	poetry run ruff check . --fix
	poetry run ruff format .

.PHONY: pre-commit
pre-commit:  ## Run all pre-commit hooks across the repository.
	poetry run pre-commit run --all-files

.PHONY: install-pre-commit
install-pre-commit:  ## Install the local git pre-commit hooks.
	poetry run pre-commit install

.PHONY: test
test:  ## Run the tests
	poetry run pytest -n auto tests

.PHONY: install
install:  ## Install the dependencies excluding dev.
	poetry install --only main

.PHONY: install-dev
install-dev:  ## Install the dependencies including dev.
	poetry install

.PHONY: megalint
megalint:  ## Run the mega-linter. Use LINTER=NAME to run only one.
	docker run --platform linux/amd64 --rm \
		-v /var/run/docker.sock:/var/run/docker.sock:rw \
		-v $(shell pwd):/tmp/lint:rw \
		$(if $(LINTER),-e ENABLE_LINTERS=$(LINTER),) \
		ghcr.io/oxsecurity/megalinter:v9

.PHONY: update-template-packages
update-template-packages:  ## Refresh package-manager template files and lockfiles.
	cd scripts/package_manager_helper && ./update_template_packages.sh && cd ../..

.PHONY: clean
clean: ## Clean the temporary files.
	rm -rf megalinter-reports
