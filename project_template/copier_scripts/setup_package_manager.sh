#!/bin/bash

set -euo pipefail

if [[ "$PACKAGE_MANAGER" == "poetry" ]]; then
    rm -f Pipfile Pipfile.lock

    # Add content of linter-configs.toml into pyproject.toml at the end of the file
    echo "" >>pyproject.toml
    cat copier_scripts/linter-configs.toml >>pyproject.toml

elif [[ "$PACKAGE_MANAGER" == "pipenv" ]]; then
    rm -f poetry.lock pyproject.toml

    # Add content of linter-configs.toml into pyproject.toml
    cat copier_scripts/linter-configs.toml >pyproject.toml

fi
