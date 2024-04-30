.DEFAULT_GOAL := all

.PHONY: all
all: ## Show the available make targets.
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@fgrep "##" Makefile | fgrep -v fgrep

.PHONY: lint
lint:  ## Run Python linter
	echo "Not implemented yet"

.PHONY: test
test:  ## Run the tests
	echo "Not implemented yet"

.PHONY: install
install:  ## Install the dependencies excluding dev.
	poetry install --only main --no-root

.PHONY: install-dev
install-dev:  ## Install the dependencies including dev.
	poetry install --no-root

.PHONY: megalint
megalint:  ## Run the mega-linter.
	docker run --platform linux/amd64 --rm \
		-v /var/run/docker.sock:/var/run/docker.sock:rw \
		-v $(shell pwd):/tmp/lint:rw \
		oxsecurity/megalinter:v7

.PHONY: update-template-packages
update-template-packages:  ## Update the project using the initial copier template.
	cd scripts/package_manager_helper && ./update_template_packages.sh && cd ../..

.PHONY: clean
clean: ## Clean the temporary files.
	rm -rf megalinter-reports
