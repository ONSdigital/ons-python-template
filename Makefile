.DEFAULT_GOAL := all

.PHONY: all
all: ## Show the available make targets.
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@fgrep "##" Makefile | fgrep -v fgrep

.PHONY: lint
lint: lint-maintainer-config ## Run linters
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
update-template-packages: lint-maintainer-config  ## Refresh package-manager template files and lockfiles.
	cd scripts/package_manager_helper && ./update_template_packages.sh && cd ../..

.PHONY: clean
clean: ## Clean the temporary files.
	rm -rf megalinter-reports

.PHONY: lint-maintainer-config
lint-maintainer-config:  ## Check maintainer helper pins stay in sync with template CI and Python baseline.
	@helper_file="scripts/package_manager_helper/update_template_packages.sh"; \
	ci_file="project_template/.github/workflows/ci.yml.jinja"; \
	python_version_file="project_template/.python-version.jinja"; \
	poetry_version="$$(sed -n 's/^POETRY_VERSION="\([^"]*\)"/\1/p' "$$helper_file")"; \
	pipenv_version="$$(sed -n 's/^PIPENV_VERSION="\([^"]*\)"/\1/p' "$$helper_file")"; \
	uv_version="$$(sed -n 's/^UV_VERSION="\([^"]*\)"/\1/p' "$$helper_file")"; \
	min_template_python_version="$$(sed -n 's/^MIN_TEMPLATE_PYTHON_VERSION="\([^"]*\)"/\1/p' "$$helper_file")"; \
	template_python_minor="$$(tr -d '[:space:]' < "$$python_version_file")"; \
	[ -n "$$poetry_version" ] || { echo "Missing POETRY_VERSION in $$helper_file"; exit 1; }; \
	[ -n "$$pipenv_version" ] || { echo "Missing PIPENV_VERSION in $$helper_file"; exit 1; }; \
	[ -n "$$uv_version" ] || { echo "Missing UV_VERSION in $$helper_file"; exit 1; }; \
	[ -n "$$min_template_python_version" ] || { echo "Missing MIN_TEMPLATE_PYTHON_VERSION in $$helper_file"; exit 1; }; \
	grep -Fq "pipx install poetry==$$poetry_version" "$$ci_file" || { echo "Poetry version mismatch between $$helper_file and $$ci_file"; exit 1; }; \
	grep -Fq "pipx install pipenv==$$pipenv_version" "$$ci_file" || { echo "Pipenv version mismatch between $$helper_file and $$ci_file"; exit 1; }; \
	grep -Fq "pipx install uv==$$uv_version" "$$ci_file" || { echo "uv version mismatch between $$helper_file and $$ci_file"; exit 1; }; \
	[ "$${min_template_python_version%.*}" = "$$template_python_minor" ] || { echo "MIN_TEMPLATE_PYTHON_VERSION ($$min_template_python_version) must share the same major.minor version as $$python_version_file ($$template_python_minor)"; exit 1; }
