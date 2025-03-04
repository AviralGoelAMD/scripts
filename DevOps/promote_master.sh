#!/bin/bash

# Set Docker Hub image name
DOCKER_IMAGE="avirgoel/ck_ub22.04_automate_staging:latest"

# Pull the latest image from Docker Hub
echo "Pulling the latest Docker image: $DOCKER_IMAGE..."
docker pull $DOCKER_IMAGE

# Get Git user details
GIT_USER_NAME=$(git config --global user.name)
GIT_USER_EMAIL=$(git config --global user.email)

# Ensure Git user details are set
if [[ -z "$GIT_USER_NAME" || -z "$GIT_USER_EMAIL" ]]; then
    echo "Error: Git user name or email is not set. Configure Git first using:"
    echo "  git config --global user.name 'Your Name'"
    echo "  git config --global user.email 'your.email@example.com'"
    exit 1
fi

# Run Docker container and execute "promote" inside an interactive shell
echo "Running the Docker container..."
docker run --rm -it \
    -e GIT_USER_NAME="$GIT_USER_NAME" \
    -e GIT_USER_EMAIL="$GIT_USER_EMAIL" \
    $DOCKER_IMAGE \
    /bin/bash -ic "promote"
