#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd
)
TEMPLATE_DIR="${SCRIPT_DIR}/../../project_template"
PYTHON_VERSION_FILE="${TEMPLATE_DIR}/.python-version.jinja"
POETRY_VENV_DIR="${SCRIPT_DIR}/.cache/poetry-venvs"
PIPENV_WORKON_HOME="${SCRIPT_DIR}/.cache/pipenv-venvs"
DEV_DEPENDENCIES=("pylint" "pytest" "pytest-xdist" "ruff" "pytest-cov" "mypy" "pre-commit")
# Keep these pinned maintainer tool versions in sync with project_template/.github/workflows/ci.yml.jinja.
POETRY_VERSION="2.4.1"
PIPENV_VERSION="2026.6.2"
UV_VERSION="0.11.29"
MIN_TEMPLATE_PYTHON_VERSION="3.14.6"

TARGET_PYTHON_VERSION=""
TARGET_PYTHON_BIN=""
RESOLVED_PYTHON_FULL_VERSION=""

# This helper intentionally does not activate or restore the caller's shell environment.
# Instead, it resolves the required interpreter up front and passes it explicitly to each
# package-manager command while clearing active virtualenv / Conda / pyenv overrides.
BASE_CLEAN_ENV=(
    env
    -u VIRTUAL_ENV
    -u CONDA_PREFIX
    -u CONDA_DEFAULT_ENV
    -u PYENV_VERSION
)

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    COLOR_RESET=$'\033[0m'
    COLOR_BLUE=$'\033[34m'
    COLOR_GREEN=$'\033[32m'
    COLOR_YELLOW=$'\033[33m'
    COLOR_RED=$'\033[31m'
else
    COLOR_RESET=""
    COLOR_BLUE=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_RED=""
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

log_error() {
    log "${COLOR_RED}$*${COLOR_RESET}" >&2
}

die() {
    log_error "$*"
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_command_version() {
    local command_name=$1
    local expected_version=$2
    local version_output=""
    local actual_version=""

    version_output=$("${command_name}" --version 2>&1) || die "Failed to determine ${command_name} version."
    actual_version=$(grep -Eo '[0-9]+(\.[0-9]+)+' <<<"${version_output}" | head -n1 || true)

    if [[ -z "${actual_version}" ]]; then
        die "Could not parse ${command_name} version from: ${version_output}"
    fi

    if [[ "${actual_version}" != "${expected_version}" ]]; then
        die "Expected ${command_name} ${expected_version}, found: ${version_output}. Install the pinned maintainer version before running make update-template-packages."
    fi
}

run_quiet() {
    local output

    if output="$("$@" 2>&1)"; then
        return 0
    fi

    log_error "Command failed: $*"
    printf "%s\n" "${output}" >&2
    return 1
}

run_quiet_clean_env() {
    run_quiet "${BASE_CLEAN_ENV[@]}" "$@"
}

cleanup_workspace() {
    rm -f Pipfile Pipfile.lock poetry.lock uv.lock pyproject.toml pyproject.toml.bak uv.lock.bak
}

cleanup_on_exit() {
    local status=$?
    cleanup_workspace
    exit "${status}"
}

read_target_python_version() {
    [[ -f "${PYTHON_VERSION_FILE}" ]] || die "Template Python version file not found: ${PYTHON_VERSION_FILE}"

    TARGET_PYTHON_VERSION=$(tr -d '[:space:]' <"${PYTHON_VERSION_FILE}")

    if [[ "${TARGET_PYTHON_VERSION}" == *"{{"* || "${TARGET_PYTHON_VERSION}" == *"}}"* ]]; then
        die "Expected a static Python version in ${PYTHON_VERSION_FILE}, found template syntax: ${TARGET_PYTHON_VERSION}"
    fi

    if [[ ! "${TARGET_PYTHON_VERSION}" =~ ^[0-9]+\.[0-9]+$ ]]; then
        die "Expected ${PYTHON_VERSION_FILE} to contain a Python minor version like 3.14, found: ${TARGET_PYTHON_VERSION}"
    fi

    if [[ "${MIN_TEMPLATE_PYTHON_VERSION%.*}" != "${TARGET_PYTHON_VERSION}" ]]; then
        die "MIN_TEMPLATE_PYTHON_VERSION (${MIN_TEMPLATE_PYTHON_VERSION}) must share the same major.minor version as ${PYTHON_VERSION_FILE} (${TARGET_PYTHON_VERSION})."
    fi
}

python_matches_target_minor() {
    local python_bin=$1
    local detected_version

    detected_version=$("${python_bin}" -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")' 2>/dev/null) || return 1
    [[ "${detected_version}" == "${TARGET_PYTHON_VERSION}" ]]
}

read_python_full_version() {
    local python_bin=$1
    "${python_bin}" -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}.{sys.version_info[2]}")' 2>/dev/null
}

version_sort_key() {
    local version=$1
    local major minor patch

    IFS=. read -r major minor patch <<<"${version}"
    printf "%04d%04d%04d\n" "${major}" "${minor}" "${patch}"
}

python_meets_minimum_patch() {
    local full_version=$1
    local candidate_key minimum_key

    candidate_key=$(version_sort_key "${full_version}")
    minimum_key=$(version_sort_key "${MIN_TEMPLATE_PYTHON_VERSION}")

    [[ "${candidate_key}" == "${minimum_key}" || "${candidate_key}" > "${minimum_key}" ]]
}

try_python_candidate() {
    local candidate=$1
    local full_version=""

    [[ -n "${candidate}" ]] || return 1
    [[ -x "${candidate}" ]] || return 1
    python_matches_target_minor "${candidate}" || return 1
    full_version=$(read_python_full_version "${candidate}") || return 1
    python_meets_minimum_patch "${full_version}" || return 1
    TARGET_PYTHON_BIN=${candidate}
    RESOLVED_PYTHON_FULL_VERSION=${full_version}
    return 0
}

resolve_target_python() {
    local candidate=""

    if command_exists "python${TARGET_PYTHON_VERSION}"; then
        candidate=$(command -v "python${TARGET_PYTHON_VERSION}")
        try_python_candidate "${candidate}" && return 0
    fi

    if command_exists python3; then
        candidate=$(command -v python3)
        try_python_candidate "${candidate}" && return 0
    fi

    if command_exists python; then
        candidate=$(command -v python)
        try_python_candidate "${candidate}" && return 0
    fi

    if command_exists pyenv; then
        candidate=$(PYENV_VERSION="${TARGET_PYTHON_VERSION}" pyenv which python 2>/dev/null || true)
        try_python_candidate "${candidate}" && return 0
    fi

    if command_exists uv; then
        candidate=$(uv python find --system --no-python-downloads "${TARGET_PYTHON_VERSION}" 2>/dev/null || true)
        try_python_candidate "${candidate}" && return 0
    fi

    die "Python ${MIN_TEMPLATE_PYTHON_VERSION}+ is required to refresh template packages, but no matching ${TARGET_PYTHON_VERSION}.x interpreter was found. Install it first (for example via pyenv or 'uv python install ${MIN_TEMPLATE_PYTHON_VERSION}') and re-run this script."
}

check_prerequisites() {
    local missing_commands=()
    local required_command

    for required_command in poetry pipenv uv; do
        if ! command_exists "${required_command}"; then
            missing_commands+=("${required_command}")
        fi
    done

    if ((${#missing_commands[@]} > 0)); then
        die "Missing required CLI(s): ${missing_commands[*]}. Install them before running make update-template-packages."
    fi

    check_command_version poetry "${POETRY_VERSION}"
    check_command_version pipenv "${PIPENV_VERSION}"
    check_command_version uv "${UV_VERSION}"
}

prepare_template_pyproject_metadata() {
    local package_manager=$1
    log_yellow "Rewriting ${package_manager} pyproject metadata for template rendering"
    sed -i.bak \
        -e 's/name = "package-manager-helper"/name = "{{ repository_name }}"/' \
        -e 's/description = "Helper project for generating template files"/description = "{{ repository_description }}"/' \
        -e 's/authors = \[{ name = "Template Helper" }\]/authors = [{ name = "{{ repository_owner }}" }]/' \
        pyproject.toml
    rm -f pyproject.toml.bak
}

rewrite_helper_python_version() {
    local file_path=$1

    sed -i.bak \
        -e "s/requires-python = \">=[^\"]*\"/requires-python = \">=${TARGET_PYTHON_VERSION}\"/" \
        -e "s/python = \"\\^[^\"]*\"/python = \"^${TARGET_PYTHON_VERSION}\"/" \
        -e "s/python_version = \"[^\"]*\"/python_version = \"${TARGET_PYTHON_VERSION}\"/" \
        "${file_path}"
    rm -f "${file_path}.bak"
}

reset_pipenv_virtualenv() {
    "${BASE_CLEAN_ENV[@]}" \
        PIPENV_IGNORE_VIRTUALENVS=1 \
        PIPENV_NOSPIN=1 \
        PIPENV_YES=1 \
        WORKON_HOME="${PIPENV_WORKON_HOME}" \
        pipenv --rm >/dev/null 2>&1 || true
}

handle_package_manager() {
    local package_manager=$1
    local has_copier=$2
    local prefix=""
    local dev_deps=()

    log_green "Starting ${package_manager} refresh (copier=${has_copier})"
    log "Resetting helper workspace"
    cleanup_workspace

    dev_deps=("${DEV_DEPENDENCIES[@]}")
    if [[ "${has_copier}" == "true" ]]; then
        dev_deps=("copier" "${DEV_DEPENDENCIES[@]}")
        prefix="${package_manager}_copier"
    else
        prefix="${package_manager}_no_copier"
    fi

    log_yellow "Using template prefix: ${prefix}"
    log "Using Python interpreter: ${TARGET_PYTHON_BIN}"
    log "Installing dev dependencies: ${dev_deps[*]}"

    if [[ "${package_manager}" == "poetry" ]]; then
        log_yellow "Preparing Poetry helper manifest"
        cp pyproject.poetry.toml pyproject.toml
        rewrite_helper_python_version pyproject.toml
        run_quiet_clean_env POETRY_VIRTUALENVS_PATH="${POETRY_VENV_DIR}" poetry env use "${TARGET_PYTHON_BIN}"
        run_quiet_clean_env POETRY_VIRTUALENVS_PATH="${POETRY_VENV_DIR}" poetry add "${dev_deps[@]}" --group dev
        prepare_template_pyproject_metadata "Poetry"
    elif [[ "${package_manager}" == "pipenv" ]]; then
        cp Pipfile.template Pipfile
        rewrite_helper_python_version Pipfile
        reset_pipenv_virtualenv
        run_quiet_clean_env \
            PIPENV_IGNORE_VIRTUALENVS=1 \
            PIPENV_NOSPIN=1 \
            PIPENV_YES=1 \
            WORKON_HOME="${PIPENV_WORKON_HOME}" \
            pipenv install --python "${TARGET_PYTHON_BIN}" "${dev_deps[@]}" --dev
    elif [[ "${package_manager}" == "uv" ]]; then
        log_yellow "Preparing uv helper manifest"
        cp pyproject.uv.toml pyproject.toml
        rewrite_helper_python_version pyproject.toml
        run_quiet_clean_env UV_PYTHON_DOWNLOADS=never uv add --python "${TARGET_PYTHON_BIN}" --dev --no-install-project "${dev_deps[@]}"
        prepare_template_pyproject_metadata "uv"
        log_yellow "Rewriting uv lock root package name for template rendering"
        sed -i.bak 's/name = "package-manager-helper"/name = "{{ repository_name }}"/g' uv.lock
        rm -f uv.lock.bak
    fi

    if [[ "${package_manager}" == "poetry" ]]; then
        log_yellow "Copying poetry.lock and pyproject.toml into the template"
        cp -p poetry.lock "${TEMPLATE_DIR}/{% if $prefix %}poetry.lock{% endif %}.jinja"
        cp -p pyproject.toml "${TEMPLATE_DIR}/{% if $prefix %}pyproject.toml{% endif %}.jinja"
    elif [[ "${package_manager}" == "pipenv" ]]; then
        log_yellow "Copying Pipfile and Pipfile.lock into the template"
        cp -p Pipfile.lock "${TEMPLATE_DIR}/{% if $prefix %}Pipfile.lock{% endif %}.jinja"
        cp -p Pipfile "${TEMPLATE_DIR}/{% if $prefix %}Pipfile{% endif %}.jinja"
    elif [[ "${package_manager}" == "uv" ]]; then
        log_yellow "Copying uv.lock and pyproject.toml into the template"
        cp -p uv.lock "${TEMPLATE_DIR}/{% if $prefix %}uv.lock{% endif %}.jinja"
        cp -p pyproject.toml "${TEMPLATE_DIR}/{% if $prefix %}pyproject.toml{% endif %}.jinja"
    fi

    log_green "Finished ${package_manager} refresh (copier=${has_copier})"
}

main() {
    cd "${SCRIPT_DIR}"
    trap cleanup_on_exit EXIT
    mkdir -p "${POETRY_VENV_DIR}" "${PIPENV_WORKON_HOME}"

    read_target_python_version
    check_prerequisites
    resolve_target_python

    log "Refreshing package-manager template files for Python ${RESOLVED_PYTHON_FULL_VERSION} (template target ${TARGET_PYTHON_VERSION}, minimum ${MIN_TEMPLATE_PYTHON_VERSION})"
    handle_package_manager poetry false
    handle_package_manager poetry true
    handle_package_manager pipenv false
    handle_package_manager pipenv true
    handle_package_manager uv false
    handle_package_manager uv true

    log "Done"
}

main "$@"
