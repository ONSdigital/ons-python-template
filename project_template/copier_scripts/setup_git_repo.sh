#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
# https://www.shellcheck.net/wiki/SC1091
# The set_up_git_repo.sh script is expected to be run from the root of the project directory hence this is sourced correctly
# but shellcheck does not understand this.
source copier_scripts/helpers.sh

# Gracefully attempt to create a GitHub repository using GitHub CLI (gh)
# The script does not throw errors but warns the users if it cannot proceed.
# Branch protection repo settings are only added if they do not exist as this runs on Copier updates as well
# and branch protection or repo setting may have been added or modified manually.

# Check if GitHub CLI is installed
if ! command -v gh &>/dev/null; then
    warn "GitHub CLI (gh) is not installed https://cli.github.com/. Skipping repository creation and setup."
    info "If you do not wish to use the GitHub CLI, you can manually create a repository and push up the contents. https://github.com/ONSdigital/ons-python-template#initialising-a-git-repository-and-pushing-to-github"
    exit 0
fi

# Check if GitHub CLI is authenticated
if ! gh_authenticated; then
    error "GitHub CLI (gh) is installed but is not authenticated. Please authenticate using 'gh auth login' first. Skipping repository creation and setup."
    exit 0
fi

################################
# Create & set up the repository
################################

# Check if branch protection is set up, if so create a pull request
branch_protection_exists=$(
    gh api "repos/$REPO_OWNER/$REPO_NAME/branches/$DEFAULT_BRANCH/protection" &>/dev/null
    echo $?
)

# Initialise the repository gracefully
git init >/dev/null

# Set the remote URL
set_remote_url

# Update the repository contents if there are any changes and repo setup is successful
if [[ $(git status --porcelain) ]] && create_repo; then
    git branch -M "$DEFAULT_BRANCH"
    git add .

    if ! commit_status=$(
        git commit -m "Update contents from base template" 2>&1
    ); then
        error "Commit Failure: $commit_status"
    fi

    if [ "$branch_protection_exists" -ne 0 ]; then
        # Branch protection is not set up, push directly for the first time

        if ! push_status=$(
            git push -u origin "$DEFAULT_BRANCH" -f 2>&1
        ); then
            error "Push Failure: $push_status"
        else
            success "Repository Contents Pushed"
        fi

    else
        # Branch protection is set up, create a pull request
        git checkout -b "update-contents-from-base-template" >/dev/null 2>&1

        if ! push_status=$(
            git push -u origin "update-contents-from-base-template" -f 2>&1
        ); then
            error "Push Failure: $push_status"
        else
            success "Repository contents pushed to branch update-contents-from-base-template"
        fi

        if ! status=$(
            gh pr create \
                --base "$DEFAULT_BRANCH" \
                --title "Update contents from base template" \
                --body "Automated pull request to update repo contents from https://github.com/ONSdigital/ons-python-template" \
                2>&1
        ); then
            warn "$status"
            warn "Updated existing PR with the new contents."
        else
            success "A pull request has been created with the updated contents since branch protection is enabled. $status"
        fi
    fi
fi

# Update repository settings and branch protection if they do not exist
if [ "$branch_protection_exists" -ne 0 ]; then
    update_repo_settings
    enable_automated_security_fixes
    update_branch_protection
fi
