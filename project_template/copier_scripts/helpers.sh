#!/bin/bash

set -euo pipefail

# Define ANSI color codes
NC='\033[0m' # No Color
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'

# Functions for colored logging
success() {
    printf "✅  ${GREEN}%s${NC}\n" "$1"
}

info() {
    printf "ℹ️ ${CYAN}%s${NC}\n" "$1"
}

warn() {
    printf "⚠️ ${YELLOW}%s${NC}\n" "$1"
}

error() {
    printf "❌  ${RED}%s${NC}\n" "$1"
}

gh_authenticated() {
    gh auth status &>/dev/null
}

repo_exists() {
    gh repo view "$REPO_OWNER/$REPO_NAME" &>/dev/null
}

create_repo() {
    if [ -z "$REPO_NAME" ]; then
        error "Repository name (REPO_NAME) is not set. Please set it first. Skipping repository creation."
        return 1
    fi

    if [ -z "$REPO_OWNER" ]; then
        error "Repository owner (REPO_OWNER) is not set. Please set it first. Skipping repository creation."
        return 1
    fi

    REPO_DESCRIPTION="${REPO_DESCRIPTION:-}"     # Default to empty string if not provided
    REPO_VISIBILITY="${REPO_VISIBILITY:-public}" # Default to public if not provided

    if [[ "$REPO_VISIBILITY" != "public" && "$REPO_VISIBILITY" != "private" && "$REPO_VISIBILITY" != "internal" ]]; then
        error "Invalid visibility. Use 'public', 'private', or 'internal'. Skipping repository creation."
        return 1
    fi

    if repo_exists; then
        warn "Repository $REPO_OWNER/$REPO_NAME already exists. Skipping repository creation."
        # We don't want to throw an error if the repository already exists as the next steps are graceful
        return 0
    fi

    # Create the repository
    if ! push_status=$(
        gh repo create "$REPO_OWNER/$REPO_NAME" --description "$REPO_DESCRIPTION" "--$REPO_VISIBILITY" 2>&1
    ); then
        error "Repo Creation Failure: $push_status"
    else
        success "Created Repo: $push_status"
    fi
}

set_remote_url() {
    if git remote get-url origin &>/dev/null; then
        return 0
    fi

    if ssh -T git@github.com &>/dev/null; then
        git remote add origin "https://github.com/$REPO_OWNER/$REPO_NAME.git"
    else
        git remote add origin "git@github.com:$REPO_OWNER/$REPO_NAME.git"
    fi
}

# Function to check whether secret scanning should be enabled
enable_secret_scanning() {
    # if repo not public, secret scanning is not available without GitHub Advanced Security
    if [[ "$REPO_VISIBILITY" != "public" ]]; then
        return 1
    fi
}

update_repo_settings() {
    if ! repo_setting_status=$(gh api -X PATCH "/repos/$REPO_OWNER/$REPO_NAME" \
        --input=<(echo "$JSON_REPO_CONFIG") 2>&1); then
        error "Repository Configuration Failure: $repo_setting_status"
    else
        success "Repository Configuration Updated"
    fi
}

enable_vulnerability_alerts() {
    if ! vulnerability_alerts_status=$(gh api \
        --method PUT \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/repos/$REPO_OWNER/$REPO_NAME/vulnerability-alerts" 2>&1); then
        error "Vulnerability Alerts Failure: $vulnerability_alerts_status"
    else
        success "Vulnerability Alerts Enabled"
    fi
}

enable_automated_security_fixes() {
    enable_vulnerability_alerts

    if ! security_fixes_status=$(gh api \
        --method PUT \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/repos/$REPO_OWNER/$REPO_NAME/automated-security-fixes" 2>&1); then
        error "Dependabot Security Fixes Failure: $security_fixes_status"
    else
        success "Automated Dependabot Security Fixes Enabled"
    fi
}

update_branch_protection() {
    if ! branch_protection_status=$(gh api -X PUT "/repos/$REPO_OWNER/$REPO_NAME/branches/${DEFAULT_BRANCH}/protection" \
        --input=<(echo "$JSON_BRANCH_PROTECTION_CONFIG") 2>&1); then
        error "Branch Protection Failure: $branch_protection_status"
    else
        success "Branch Protection Enabled"
    fi
}

JSON_REPO_CONFIG=$(
    cat <<EOL
{
    "visibility": "$REPO_VISIBILITY",
    "has_issues": true,
    "has_projects": false,
    "has_wiki": false,
    "allow_auto_merge": false,
    "allow_merge_commit": false,
    "allow_rebase_merge": false,
    "allow_squash_merge": true,
    "allow_update_branch": true,
    "delete_branch_on_merge": true
EOL
)

if enable_secret_scanning; then
    JSON_REPO_CONFIG+=$(
        cat <<EOL
,
    "security_and_analysis": {
        "secret_scanning": {
            "status": "enabled"
        },
        "secret_scanning_push_protection": {
            "status": "enabled"
        }
    }
}
EOL
    )

fi

JSON_BRANCH_PROTECTION_CONFIG=$(
    cat <<EOL
{
    "required_status_checks": {
        "strict": true,
        "checks": [
            {
                "context": "Lint and Test"
            },
            {
                "context": "MegaLinter"
            },
            {
                "context": "Analyze (python)"
            }
        ]
    },
    "enforce_admins": true,
    "required_pull_request_reviews": {
        "dismiss_stale_reviews": $DISMISS_STALE_REVIEWS,
        "require_code_owner_reviews": true,
        "required_approving_review_count": $REQUIRED_APPROVING_REVIEW_COUNT,
        "require_last_push_approval": $REQUIRE_LAST_PUSH_APPROVAL
    },
    "restrictions": null,
    "required_linear_history": true,
    "allow_force_pushes": false,
    "allow_deletions": false,
    "block_creations": false,
    "required_conversation_resolution": $REQUIRE_CONVERSATION_RESOLUTION,
    "required_signatures": true
}
EOL
)
