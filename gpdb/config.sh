#!/bin/bash
#
#
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


export CONTAINER_NAME="gpdb5oss"

export DOCKER_OSS_LABEL="GPDB 5 OSS"
export DOCKER_OSS_TAG="kochanpivotal/gpdb5oss"
export DOCKER_LATEST_OSS_TAG="kochanpivotal/gpdb5oss:latest"
