#!/bin/bash

[ -z "$1" ] && { echo "Missing 1st argument: PostgREST github commit SHA"; exit 1; }
[ -z "$2" ] && { echo "Missing 2nd argument: Docker repo"; exit 1; }
[ -z "$3" ] && { echo "Missing 3rd argument: Docker username"; exit 1; }
[ -z "$4" ] && { echo "Missing 4th argument: Docker password"; exit 1; }
[ -z "$5" ] && { echo "Missing 5th argument: Build environment directory name"; exit 1; }

PGRST_GITHUB_COMMIT="$1"
DOCKER_REPO="$2"
DOCKER_USER="$3"
DOCKER_PASS="$4"
DOCKER_BUILD_PATH="$5"

clean_env()
{
    sudo docker logout
}

# Login to Docker
sudo docker logout
{ echo $DOCKER_PASS | sudo docker login -u $DOCKER_USER --password-stdin; } || { echo "Couldn't login to docker"; exit 1; }

trap clean_env sigint sigterm exit

# Move to the docker build environment
cd ~/$DOCKER_BUILD_PATH

# Build ARM versions
sudo docker buildx build --build-arg PGRST_GITHUB_COMMIT=$PGRST_GITHUB_COMMIT \
                         --build-arg BUILDKIT_INLINE_CACHE=1 \
                         --platform linux/arm/v7,linux/arm64 \
                         --cache-from $DOCKER_REPO/postgrest:postgrest-build-arm \
                         --target=postgrest-build \
                         -t $DOCKER_REPO/postgrest:postgrest-build-arm \
                         --push .

sudo docker logout

# Generate and copy binaries to the server
sudo docker buildx build --build-arg PGRST_GITHUB_COMMIT=$PGRST_GITHUB_COMMIT \
                         --cache-from $DOCKER_REPO/postgrest:postgrest-build-arm \
                         --platform linux/arm/v7,linux/arm64 \
                         --target=postgrest-bin \
                         -o build .

# Compress binaries
sudo chown -R ubuntu:ubuntu ~/$DOCKER_BUILD_PATH/build
cd ~/$DOCKER_BUILD_PATH/build/linux_arm64
tar -cJf postgrest-ubuntu-aarch64.tar.xz postgrest
cd ~/$DOCKER_BUILD_PATH/build/linux_arm_v7
tar -cJf postgrest-ubuntu-armv7.tar.xz postgrest

cd ~/DOCKER_BUILD_PATH/..

mkdir -p result
mv ~/$DOCKER_BUILD_PATH/build/linux_arm64/*.tar.xz ~/result
mv ~/$DOCKER_BUILD_PATH/build/linux_arm_v7/*.tar.xz ~/result
rm -rf ~/$DOCKER_BUILD_PATH/build
tar -cJf result.tar.xz result
