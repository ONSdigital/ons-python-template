#!/bin/bash

set -euo pipefail

DEV_DEPENDENCIES=("pylint" "black" "pytest" "pytest-xdist" "ruff" "pytest-cov" "mypy")
TEMPLATE_DIR="../../project_template"

# Function to handle package installation and file copying
handle_package_manager() {
    git restore Pipfile pyproject.toml
    rm -f Pipfile.lock poetry.lock

    local package_manager=$1
    local has_copier=$2

    # Determine prefix based on copier
    dev_deps=("${DEV_DEPENDENCIES[@]}")
    if [[ "${has_copier}" == "true" ]]; then
        dev_deps=("copier" "${DEV_DEPENDENCIES[@]}")
        prefix="${package_manager}_copier"
    else
        prefix="not_${package_manager}_copier"
    fi

    # Install development dependencies
    if [[ "${package_manager}" == "poetry" ]]; then
        poetry add "${dev_deps[@]}" --group dev
    elif [[ "${package_manager}" == "pipenv" ]]; then
        pipenv install "${dev_deps[@]}" --dev
    fi

    # Copy lock files to the project_template
    if [[ "${package_manager}" == "poetry" ]]; then
        cp -p poetry.lock "${TEMPLATE_DIR}/{% if $prefix %}poetry.lock{% endif %}.jinja"
        cp -p pyproject.toml "${TEMPLATE_DIR}/{% if $prefix %}pyproject.toml{% endif %}.jinja"
    elif [[ "${package_manager}" == "pipenv" ]]; then
        cp -p Pipfile.lock "${TEMPLATE_DIR}/{% if $prefix %}Pipfile.lock{% endif %}.jinja"
        cp -p Pipfile "${TEMPLATE_DIR}/{% if $prefix %}Pipfile{% endif %}.jinja"
    fi

    echo "Copied lock files for ${package_manager}"
}

# Execute the function with different configurations
handle_package_manager poetry false
handle_package_manager poetry true
handle_package_manager pipenv false
handle_package_manager pipenv true

# Undo git changes and remove the lock files
git restore Pipfile pyproject.toml
rm -f Pipfile.lock poetry.lock
