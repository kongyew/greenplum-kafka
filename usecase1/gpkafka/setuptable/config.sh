#!/bin/bash
#
#
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export GPDB_HOSTS=/tmp/gpdb-hosts

echo "export HADOOP_USER_NAME=gpadmin"
