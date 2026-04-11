#!/bin/bash
# Initialize a new convergio crate repo from this template.
#
# Usage:
#   ./scripts/init-repo.sh billing "Billing, evidence tracking, and cost management"
#
# This will:
# 1. Replace all CRATE_NAME placeholders with the crate name
# 2. Replace CRATE_DESCRIPTION with the description
# 3. Generate Cargo.lock
# 4. Initialize git repo
# 5. Optionally create GitHub repo and push

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <crate-name> <description>"
    echo "Example: $0 billing \"Billing, evidence tracking, and cost management\""
    exit 1
fi

CRATE_NAME="$1"
DESCRIPTION="$2"
REPO_DIR="/Users/Roberdan/GitHub/Convergio-Repos/convergio-${CRATE_NAME}"

if [ -d "$REPO_DIR" ]; then
    echo "Error: $REPO_DIR already exists"
    exit 1
fi

TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Creating convergio-${CRATE_NAME} ==="
echo "From template: $TEMPLATE_DIR"
echo "Target: $REPO_DIR"
echo ""

# 1. Copy template (excluding .git, target, scripts)
mkdir -p "$REPO_DIR"
rsync -a --exclude='.git' --exclude='target' --exclude='scripts' "$TEMPLATE_DIR/" "$REPO_DIR/"

# 2. Rename crate directory
mv "$REPO_DIR/crates/convergio-CRATE_NAME" "$REPO_DIR/crates/convergio-${CRATE_NAME}"

# 3. Replace placeholders in all files
find "$REPO_DIR" -type f \( -name '*.toml' -o -name '*.rs' -o -name '*.md' -o -name '*.json' -o -name '*.yml' -o -name '*.yaml' \) -exec sed -i '' \
    -e "s/CRATE_NAME/${CRATE_NAME}/g" \
    -e "s/CRATE_DESCRIPTION_LONG/${DESCRIPTION}/g" \
    -e "s/CRATE_DESCRIPTION/${DESCRIPTION}/g" \
    {} +

# 4. Generate Cargo.lock
echo "-> Generating Cargo.lock..."
cd "$REPO_DIR"
cargo generate-lockfile 2>/dev/null || cargo check 2>/dev/null || true

# 5. Initialize git
echo "-> Initializing git..."
git init
git add -A
git commit -m "feat: initial convergio-${CRATE_NAME} from template

Extracted from convergio monorepo.
${DESCRIPTION}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"

echo ""
echo "=== Local repo ready at $REPO_DIR ==="
echo ""

# 6. Optionally create GitHub repo
read -p "Create GitHub repo and push? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "-> Creating GitHub repo..."
    gh repo create "Roberdan/convergio-${CRATE_NAME}" --public --source=. --push

    echo "-> Tagging v0.1.0..."
    git tag v0.1.0
    git push origin v0.1.0

    echo "-> Setting up repo..."
    gh api "repos/Roberdan/convergio-${CRATE_NAME}" -X PATCH --input - <<'APIEOF'
{
  "allow_auto_merge": true,
  "delete_branch_on_merge": true
}
APIEOF

    echo "-> Applying branch protection..."
    gh api "repos/Roberdan/convergio-${CRATE_NAME}/branches/main/protection" -X PUT --input - <<'PROTEOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Check & Test"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
PROTEOF

    echo "-> Enabling GH Actions PR permissions..."
    gh api "repos/Roberdan/convergio-${CRATE_NAME}/actions/permissions/workflow" -X PUT --input - <<'ACTEOF'
{
  "can_approve_pull_request_reviews": true,
  "default_workflow_permissions": "write"
}
ACTEOF

    echo "-> Setting PAT secret for release-please..."
    gh secret set PAT --repo "Roberdan/convergio-${CRATE_NAME}" --body "$(gh auth token)"

    echo ""
    echo "=== Done! ==="
    echo "Repo: https://github.com/Roberdan/convergio-${CRATE_NAME}"
    echo "Clone: $REPO_DIR"
else
    echo ""
    echo "Local only. To push later:"
    echo "  gh repo create Roberdan/convergio-${CRATE_NAME} --public --source=. --push"
    echo "  git tag v0.1.0 && git push origin v0.1.0"
fi
