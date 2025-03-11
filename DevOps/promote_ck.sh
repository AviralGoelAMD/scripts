#!/bin/bash

set -e  # Exit immediately if any command fails

# Checking for dependencies
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) not installed. Please install it to create a PR."
    exit 1
fi

# Prompt user for Git configuration
echo "Setting up Git user configuration..."

# Check if environment variables are set
if [[ -z "$GIT_USER_NAME" || -z "$GIT_USER_EMAIL" ]]; then
    echo "Error: GIT_USER_NAME or GIT_USER_EMAIL is not set."
    exit 1
fi

git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

echo "Git user configuration set:"
git config --global --list

# Check if the user is already authenticated with GitHub CLI
if ! gh auth status &> /dev/null; then
    echo "You are not logged into GitHub. Please log in first."
    gh auth login
else
    echo "GitHub authentication detected. Proceeding..."
fi

# Default branch values
CK_BRANCH_MAIN="develop"
CK_BRANCH_TARGET_DEFAULT="amd-develop"
MIOPEN_BRANCH_MAIN="develop"
MIOPEN_BRANCH_PR_DEFAULT="promote_ck_staging"

# Allow overriding defaults with command-line arguments
CK_BRANCH_TARGET="${1:-$CK_BRANCH_TARGET_DEFAULT}"
MIOPEN_BRANCH_PR="${2:-$MIOPEN_BRANCH_PR_DEFAULT}"

# Set repo URLs and branch names
CK_REPO_URL="https://github.com/ROCm/composable_kernel"
CK_REPO_DIR="composable_kernel"

MIOPEN_REPO_URL="https://github.com/ROCm/MIOpen"
MIOPEN_REPO_DIR="MIOpen"

# Clone or update composable_kernel repository
if [ -d "$CK_REPO_DIR" ]; then
    echo "Repository $CK_REPO_DIR already exists. Pulling latest changes..."
    cd "$CK_REPO_DIR" || exit
    git reset --hard
    git fetch origin
else
    git clone "$CK_REPO_URL"
    cd "$CK_REPO_DIR" || exit
fi

# Checkout CK_BRANCH_TARGET_DEFAULT and pull latest changes
git checkout "$CK_BRANCH_TARGET" || { echo "Failed to checkout $CK_BRANCH_TARGET"; exit 1; }
git pull origin "$CK_BRANCH_TARGET"

# Merge develop into target branch
if ! git merge --no-edit "$CK_BRANCH_MAIN"; then
    echo "Merge conflict detected. Please resolve manually."
    exit 1
fi

git push origin "$CK_BRANCH_TARGET"

# Get the latest commit hash of target branch
LATEST_COMMIT_CK=$(git rev-parse HEAD)
echo "Latest commit hash in CK: $LATEST_COMMIT_CK"

# Navigate back and clone or update the MIOpen repository
cd ..
if [ -d "$MIOPEN_REPO_DIR" ]; then
    echo "Repository $MIOPEN_REPO_DIR already exists. Pulling latest changes..."
    cd "$MIOPEN_REPO_DIR" || exit
    git reset --hard
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

# Check for changes before committing
if git diff --quiet; then
    echo "No changes detected. Skipping commit."
else
    git add "$REQ_FILE" "$DOCKER_FILE"
    git commit -m "Update CK commit hash in requirements.txt"
    git push origin "$MIOPEN_BRANCH_PR"
fi

# Create a pull request
gh pr create --base "$MIOPEN_BRANCH_MAIN" --head "$MIOPEN_BRANCH_PR" \
    --title "Update CK commit hash for staging" \
    --body "This PR updates the CK commit hash in requirements.txt."
