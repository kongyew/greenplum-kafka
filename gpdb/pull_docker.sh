#!/bin/bash
set -e


# Including configurations
. config.sh

echo "docker pull $DOCKER_OSS_TAG"
docker pull $DOCKER_OSS_TAG > /dev/null 2>&1; rc=$?;
if [[ $rc != 0 ]]; then
	exit 1
fi
echo "docker pull is successfull"
