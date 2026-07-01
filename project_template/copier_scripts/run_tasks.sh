#!/bin/bash

set -euo pipefail

# Set up package manager
./copier_scripts/setup_package_manager.sh

# Remove files from the previous visibility choice when regenerating into an existing directory
./copier_scripts/cleanup_conditional_files.sh

# Set up git repo
if ${SET_UP_GIT_REPO}; then
    ./copier_scripts/setup_git_repo.sh
fi

# Delete the copier scripts
rm -rf copier_scripts
