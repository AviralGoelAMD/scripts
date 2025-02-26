#!/bin/bash

set -e  # Exit immediately if any command fails

# Set repo URLs and branch names
CK_REPO_URL="https://github.com/ROCm/composable_kernel"
CK_REPO_DIR="composable_kernel"
CK_BRANCH_MAIN="develop"
CK_BRANCH_TARGET="amd-develop"

MIOPEN_REPO_URL="https://github.com/ROCm/MIOpen"
MIOPEN_REPO_DIR="MIOpen"
MIOPEN_BRANCH_MAIN="develop"
MIOPEN_BRANCH_PR="promote_ck"

# Clone or update composable_kernel repository
if [ -d "$CK_REPO_DIR" ]; then
    echo "Repository $CK_REPO_DIR already exists. Pulling latest changes..."
    cd "$CK_REPO_DIR" || exit
    git fetch origin
else
    git clone "$CK_REPO_URL"
    cd "$CK_REPO_DIR" || exit
fi

# Checkout amd-develop and pull latest changes
git checkout "$CK_BRANCH_TARGET" || { echo "Failed to checkout $CK_BRANCH_TARGET"; exit 1; }
git pull origin "$CK_BRANCH_TARGET"

# Merge develop into amd-develop
git merge "$CK_BRANCH_MAIN" || { echo "Merge conflict detected. Resolve manually."; exit 1; }

# Push the updated amd-develop branch
git push origin "$CK_BRANCH_TARGET"

# Get the latest commit hash of amd-develop
LATEST_COMMIT_CK=$(git rev-parse HEAD)
echo "Latest commit hash in CK: $LATEST_COMMIT_CK"

# Navigate back and clone or update the MIOpen repository
cd ..
if [ -d "$MIOPEN_REPO_DIR" ]; then
    echo "Repository $MIOPEN_REPO_DIR already exists. Pulling latest changes..."
    cd "$MIOPEN_REPO_DIR" || exit
    git fetch origin
else
    git clone "$MIOPEN_REPO_URL"
    cd "$MIOPEN_REPO_DIR" || exit
fi

# Checkout promote_ck branch
git checkout "$MIOPEN_BRANCH_PR" || { echo "Failed to checkout $MIOPEN_BRANCH_PR"; exit 1; }

# Modify requirements.txt if it exists
REQ_FILE="requirements.txt"
if [ -f "$REQ_FILE" ]; then
    sed -i "s|ROCm/composable_kernel@[^ ]*|ROCm/composable_kernel@$LATEST_COMMIT_CK|" "$REQ_FILE"
    echo "Updated requirements.txt with latest CK commit hash."
else
    echo "requirements.txt not found!"
fi

# Modify Dockerfile if it exists
DOCKER_FILE="Dockerfile"
if [ -f "$DOCKER_FILE" ]; then
    sed -i "s|ARG CK_COMMIT=[^ ]*|ARG CK_COMMIT=$LATEST_COMMIT_CK|" "$DOCKER_FILE"
    echo "Updated Dockerfile with latest CK commit hash."
else
    echo "Dockerfile not found!"
fi

# Check for changes before committing
if git diff --quiet; then
    echo "No changes detected. Skipping commit."
else
    git add "$REQ_FILE" "$DOCKER_FILE"
    git commit -m "Update CK commit hash in requirements.txt and Dockerfile"
    git push origin "$MIOPEN_BRANCH_PR"
fi

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) not installed. Please install it to create a PR."
    exit 1
fi

# Create a pull request
gh pr create --base "$MIOPEN_BRANCH_MAIN" --head "$MIOPEN_BRANCH_PR" \
    --title "Update CK commit hash for staging" \
    --body "This PR updates the CK commit hash in requirements.txt and Dockerfile."
