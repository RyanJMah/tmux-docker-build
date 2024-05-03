#!/usr/bin/env bash

set -e

source vars.sh

##############################################################################
function display_help_msg()
{
    echo "Usage: $0 [os_dir] [arch]"
    echo ""
    echo "os_dir: The directory containing the Dockerfile for the os (e.g., debian, etc.)"
    echo "arch:   The architecture to build the image for (e.g., amd64, arm64)"
    echo ""
    echo "  --help: Display this help message."
    echo ""
    echo "Usage: $0 clean"
    echo ""
    echo "  Clean up the build directory and the container."
}

if [[ $1 == "--help" ]]; then
    display_help_msg
    exit 0
fi
##############################################################################

##############################################################################
OS_DIR=$1
ARCH=$2

OUTPUT_DIR="Build/${OS_DIR}-${ARCH}"
PLATFORM="linux/${ARCH}"

# Name of the image
IMAGE_NAME="${OS_DIR}-${ARCH}_tmux-build"
CONTAINER_NAME=$IMAGE_NAME"_container"

function clean_container()
{
    set +e

    echo "Cleaning up container..."

    docker stop $CONTAINER_NAME > /dev/null 2>&1
    docker rm $CONTAINER_NAME   > /dev/null 2>&1

    set -e
}

# Handle the clean option
if [[ $1 == "clean" ]]; then
    clean_container
    rm -rf Build

    echo "Cleaned up."
    exit 0
fi

# Check if the number of arguments is valid
if [[ $# -ne 2 ]]; then
    echo "Error: Invalid number of arguments."
    display_help_msg
    exit 1
fi

# Check if the platform directory exists
if [[ ! -d $OS_DIR ]]; then
    echo "Error: platform ${OS_DIR} is not supported."
    exit 1
fi
##############################################################################

##############################################################################
# Build the Docker image
docker buildx build             \
    -f $OS_DIR/Dockerfile \
    --platform $PLATFORM        \
    --load                      \
    -t $IMAGE_NAME .

# Clean up any existing containers
clean_container

# Run the container in detached mode and remove it on exit
docker run                  \
    -d                      \
    --platform $PLATFORM    \
    --name $CONTAINER_NAME  \
    $IMAGE_NAME
##############################################################################

##############################################################################
# Start following logs in the background
docker logs -f $CONTAINER_NAME &
LOGS_PID=$!

# Poll until the tarball is created
set +e
while true;
do
    docker exec $CONTAINER_NAME ls $INSTALL_DIR/tmux.tar.gz > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        break
    fi
    sleep 1
done
set -e

# Kill the logs process
kill $LOGS_PID
echo "Build complete."
##############################################################################

##############################################################################
# Copy the tarball from the container
mkdir -p $OUTPUT_DIR

docker cp $CONTAINER_NAME:$INSTALL_DIR/tmux.tar.gz $OUTPUT_DIR/tmux.tar.gz

# Clean up the container
clean_container
##############################################################################
