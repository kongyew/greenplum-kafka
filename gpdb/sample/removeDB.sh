#!/bin/bash


set -e

current=`pwd`

cd `dirname $0`

. ./setEnv.sh

cd $current


# Checks whether ${GREENPLUM_DB} db exists ?
if psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -lqt | cut -d \| -f 1 | grep -qw ${GREENPLUM_DB}; then
    # database exists
    # $? is 0
	psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d gpadmin -c "DROP DATABASE IF EXISTS ${GREENPLUM_DB}"

else
    echo "Database ${GREENPLUM_DB} does NOT exists"
fi
