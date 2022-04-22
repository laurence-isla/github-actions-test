#!/bin/bash

# This script builds PostgREST in a remote ARM server. It uses Docker to
# build for multiple platforms (aarch64 and armv7 on ubuntu).
# The Dockerfile is located in ./docker-env

[ -z "$1" ] && { echo "Missing 1st argument: PostgREST github commit SHA"; exit 1; }
[ -z "$2" ] && { echo "Missing 2nd argument: Build environment directory name"; exit 1; }

PGRST_GITHUB_COMMIT="$1"
SCRIPT_PATH="$2"

DOCKER_BUILD_PATH="$SCRIPT_PATH/docker-env"

# Move to the docker build environment
cd ~/$DOCKER_BUILD_PATH

sudo docker buildx build --build-arg PGRST_GITHUB_COMMIT=$PGRST_GITHUB_COMMIT \
                         --build-arg BUILDKIT_INLINE_CACHE=1 \
                         --platform linux/arm/v7,linux/arm64 \
                         --target=postgrest-build .

# Generate and copy binaries to the local filesystem
sudo docker buildx build --build-arg PGRST_GITHUB_COMMIT=$PGRST_GITHUB_COMMIT \
                         --build-arg BUILDKIT_INLINE_CACHE=1 \
                         --platform linux/arm/v7,linux/arm64 \
                         --target=postgrest-bin \
                         -o result .

# Compress binaries
sudo chown -R ubuntu:ubuntu ~/$DOCKER_BUILD_PATH/result
mv ~/$DOCKER_BUILD_PATH/result ~/$SCRIPT_PATH/result
cd ~/$SCRIPT_PATH
tar -cJf result.tar.xz result
