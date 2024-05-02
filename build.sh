#!/usr/bin/env bash

set -e

if [[ $1 == "--help" ]]; then
    echo "Usage: $0 [os_name] [arch]"
    echo ""
    echo "  os_name: The name of the OS to build the image for."
    echo "           [debian, macos]"
    echo ""
    echo "  arch:    The architecture to build the image for."
    echo "           [amd64, arm64]"
    echo ""
    echo "  --help: Display this help message."
    exit 0
fi

OS_NAME=$1
ARCH=$2

PLATFORM_DIR="${OS_NAME}_${ARCH}"

# Check if the platform directory exists
if [[ ! -d $PLATFORM_DIR ]]; then
    echo "Error: platform ${PLATFORM_DIR} is not supported."
    exit 1
fi

source $PLATFORM_DIR/vars.sh


# Name of the image
IMAGE_NAME="${PLATFORM_DIR}-tmux-build"
CONTAINER_NAME=$IMAGE_NAME"_container"

function clean_container()
{
    set +e

    echo "Cleaning up container..."

    docker stop $CONTAINER_NAME > /dev/null 2>&1
    docker rm $CONTAINER_NAME   > /dev/null 2>&1

    set -e
}

if [[ $1 == "clean" ]]; then
    clean_container
    exit 0
fi

cd ../../

# Build the Docker image
docker buildx build         \
    --platform $PLATFORM    \
    --load                  \
    -t $IMAGE_NAME .

# Clean up any existing containers
clean_container

# Run the container in detached mode and remove it on exit
docker run                  \
    -d                      \
    --platform $PLATFORM    \
    --name $CONTAINER_NAME  \
    $IMAGE_NAME

# Attach to the container's shell, start in the home directory
set +e
docker exec -it $CONTAINER_NAME bash -c "cd ~/dotfiles2 && bash"
set -e
