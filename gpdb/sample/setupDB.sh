#!/bin/bash


set -e

current=`pwd`

cd `dirname $0`

. ./setEnv.sh

# Checks whether ${GREENPLUM_DB} db exists ?
if psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -lqt | cut -d \| -f 1 | grep -qw ${GREENPLUM_DB}; then
    # database exists
    # $? is 0
    echo "Database ${GREENPLUM_DB} exists"
else
	#psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${GREENPLUM_DB} -c "DROP DATABASE IF EXISTS  ${GREENPLUM_DB}"
	createdb -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} ${GREENPLUM_DB}
fi

# generates data for demo
psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${GREENPLUM_DB} -f  ./sample_table.sql


cd $current
