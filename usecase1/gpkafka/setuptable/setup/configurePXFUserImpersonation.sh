#!/bin/bash
set -e
[[ ${DEBUG} == true ]] && set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Including configurations
. "${DIR}"/../config.sh

if [[ ! "$(whoami)" =~ ^(gpadmin|root)$ ]]
then
    echo "Please run the script as gpadmin or root" >&2
    exit 1
fi



###############################################################################
function usage(){
  me=$(basename "$0")
    echo "Usage: $me "
    echo "   " >&2
    echo "Options:   " >&2
    echo "-h \\thelp  " >&2
    echo "  " >&2
    echo "To disable user impersonation, use -o 'false' " >&2
    echo "To enable user impersonation, use -o 'true'" >&2
}

function DisableUserImpersonation(){
  sed "s/$PXF_USER_IMPERSONATION=true/$PXF_USER_IMPERSONATION=false/" < $GPHOME/pxf/conf/pxf-env.sh > outfile
  mv outfile  $GPHOME/pxf/conf/pxf-env.sh
  echo "Successfull updated $GPHOME/pxf/conf/pxf-env.sh"
}
function EnableUserImpersonation(){
  sed "s/$PXF_USER_IMPERSONATION=false/$PXF_USER_IMPERSONATION=true/" < $GPHOME/pxf/conf/pxf-env.sh > outfile
  mv outfile  $GPHOME/pxf/conf/pxf-env.sh
  echo "Successfull updated $GPHOME/pxf/conf/pxf-env.sh"
}

################################################################################
while getopts ":ho:" opt; do
  case $opt in
    o)
      #echo "Type for Parameter: $OPTARG" >&2
      export PXF_USER_IMPERSONATION=$OPTARG
      ;;

    h)
      usage
      exit 0;
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$PXF_USER_IMPERSONATION" ]  # Is parameter #1 zero length?
  then
    usage
  else
    if [ -n "$PXF_USER_IMPERSONATION" ]
    then
    if [ "$PXF_USER_IMPERSONATION" == "true" ]
    then
        EnableUserImpersonation
    elif [ "$PXF_USER_IMPERSONATION" == "false" ]
    then
        DisableUserImpersonation
    else #
       echo "Unknown option"
    fi

    else
      usage
    fi


  fi
