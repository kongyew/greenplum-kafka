#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Customize this settings for custom Greenplum
export GREENPLUM_HOST=localhost
export GREENPLUM_USER=gpadmin
export GREENPLUM_DB=basic_db
export GREENPLUM_DB_PWD=gpadmin
export PGPASSWORD=${GREENPLUM_DB_PWD}
