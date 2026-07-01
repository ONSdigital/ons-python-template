#!/bin/bash

set -euo pipefail

DEV_DEPENDENCIES=("pylint" "black" "pytest" "pytest-xdist" "ruff" "pytest-cov" "mypy")
TEMPLATE_DIR="../../project_template"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    COLOR_RESET=$'\033[0m'
    COLOR_BLUE=$'\033[34m'
    COLOR_GREEN=$'\033[32m'
    COLOR_YELLOW=$'\033[33m'
else
    COLOR_RESET=""
    COLOR_BLUE=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
fi

log() {
    echo "${COLOR_BLUE}[update-template-packages]${COLOR_RESET} $*"
}

log_green() {
    log "${COLOR_GREEN}$*${COLOR_RESET}"
}

log_yellow() {
    log "${COLOR_YELLOW}$*${COLOR_RESET}"
}

run_quiet() {
    local output

    if output="$("$@" 2>&1)"; then
        return 0
    fi

    log "Command failed: $*"
    printf "%s\n" "${output}" >&2
    return 1
}

prepare_uv_template_pyproject() {
    log_yellow "Rewriting uv pyproject metadata for template rendering"
    sed -i.bak \
        -e 's/name = "package-manager-helper"/name = "{{ repository_name }}"/' \
        -e 's/description = "Helper project for generating uv template files"/description = "{{ repository_description }}"/' \
        pyproject.toml
    rm -f pyproject.toml.bak
}

# Function to handle package installation and file copying
handle_package_manager() {
    local package_manager=$1
    local has_copier=$2
    local prefix
    local dev_deps

    log_green "Starting ${package_manager} refresh (copier=${has_copier})"
    log "Resetting helper workspace"
    git restore Pipfile
    rm -f Pipfile.lock poetry.lock uv.lock pyproject.toml

    # Determine prefix based on copier
    dev_deps=("${DEV_DEPENDENCIES[@]}")
    if [[ "${has_copier}" == "true" ]]; then
        dev_deps=("copier" "${DEV_DEPENDENCIES[@]}")
        prefix="${package_manager}_copier"
    else
        prefix="${package_manager}_no_copier"
    fi

    log_yellow "Using template prefix: ${prefix}"
    log "Installing dev dependencies: ${dev_deps[*]}"

    # Install development dependencies
    if [[ "${package_manager}" == "poetry" ]]; then
        log_yellow "Preparing Poetry helper manifest"
        cp pyproject.poetry.toml pyproject.toml
        run_quiet poetry add "${dev_deps[@]}" --group dev
    elif [[ "${package_manager}" == "pipenv" ]]; then
        run_quiet pipenv install "${dev_deps[@]}" --dev
    elif [[ "${package_manager}" == "uv" ]]; then
        log_yellow "Preparing uv helper manifest"
        cp pyproject.uv.toml pyproject.toml
        run_quiet uv add --dev --no-install-project "${dev_deps[@]}"
        prepare_uv_template_pyproject
        log_yellow "Rewriting uv lock root package name for template rendering"
        # uv.lock records the helper project's root package name, so rewrite it back to the template variable.
        sed -i.bak 's/name = "package-manager-helper"/name = "{{ repository_name }}"/g' uv.lock
        rm -f uv.lock.bak
    fi

    # Copy lock files to the project_template
    if [[ "${package_manager}" == "poetry" ]]; then
        log_yellow "Copying poetry.lock and pyproject.toml into the template"
        cp -p poetry.lock "${TEMPLATE_DIR}/{% if $prefix %}poetry.lock{% endif %}.jinja"
        cp -p pyproject.toml "${TEMPLATE_DIR}/{% if $prefix %}pyproject.toml{% endif %}.jinja"
    elif [[ "${package_manager}" == "pipenv" ]]; then
        log_yellow "Copying Pipfile and Pipfile.lock into the template"
        cp -p Pipfile.lock "${TEMPLATE_DIR}/{% if $prefix %}Pipfile.lock{% endif %}.jinja"
        cp -p Pipfile "${TEMPLATE_DIR}/{% if $prefix %}Pipfile{% endif %}.jinja"
    elif [[ "${package_manager}" == "uv" ]]; then
        log_yellow "Copying uv.lock into the template"
        cp -p uv.lock "${TEMPLATE_DIR}/{% if $prefix %}uv.lock{% endif %}.jinja"
        cp -p pyproject.toml "${TEMPLATE_DIR}/{% if $prefix %}pyproject.toml{% endif %}.jinja"
    fi

    log_green "Finished ${package_manager} refresh (copier=${has_copier})"
}

# Execute the function with different configurations
log "Refreshing package-manager template files"
#handle_package_manager poetry false
#handle_package_manager poetry true
#handle_package_manager pipenv false
#handle_package_manager pipenv true
handle_package_manager uv false
handle_package_manager uv true

# Undo git changes and remove the lock files
log "Cleaning helper workspace"
git restore Pipfile
rm -f Pipfile.lock poetry.lock uv.lock pyproject.toml
log "Done"
