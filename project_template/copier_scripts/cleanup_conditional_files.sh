#!/bin/bash

set -euo pipefail

if [[ "${REPO_VISIBILITY}" == "public" ]]; then
    rm -f PIRR.md
else
    rm -f LICENSE .github/workflows/codeql.yml
fi

if [[ "${PACKAGE_MANAGER}" == "poetry" ]]; then
    rm -f Pipfile Pipfile.lock uv.lock
elif [[ "${PACKAGE_MANAGER}" == "pipenv" ]]; then
    rm -f poetry.lock uv.lock
elif [[ "${PACKAGE_MANAGER}" == "uv" ]]; then
    rm -f Pipfile Pipfile.lock poetry.lock
fi
