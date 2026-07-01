#!/bin/bash

set -euo pipefail

if [[ "${REPO_VISIBILITY}" == "public" ]]; then
    rm -f PIRR.md
else
    rm -f LICENSE .github/workflows/codeql.yml
fi
