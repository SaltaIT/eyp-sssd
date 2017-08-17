#!/bin/bash

# parse options
while getopts 'u:' OPT; do
  case $OPT in
    u)  SSSD_USER="${OPTARG}";;
    *)  JELP="yes";;
  esac
done 2>/dev/null

shift $(($OPTIND - 1))

# validate options
if [ ! -z "${JELP}" ];
then
  echo "ERROR: unrecognized options"
  exit 2
fi

if [ -z "${SSSD_USER}" ];
then
  echo -e "ERROR: user unspecified"
  echo -e "\tusage: $0 -u <user>"
  exit 2
fi

#validate sssd is in use
grep passwd /etc/nsswitch.conf  | grep sss >/dev/null 2>&1
if [ "$?" -ne 0 ];
then
  echo "CRITICAL: sss not currently in use, please check nsswitch"
fi

# check sss_cache
SSS_CACHE_BIN=$(which sss_cache 2>/dev/null)
if [ -z "${SSS_CACHE_BIN}" ];
then
  echo "ERROR: sss_cache not found"
  exit 2
fi

# check getent
GETENT_BIN=$(which getent 2>/dev/null)
if [ -z "${GETENT_BIN}" ];
then
  echo "ERROR: getent not found"
  exit 2
fi

# drop cache for $SSSD_USER
${SSS_CACHE_BIN} -u ${SSSD_USER} >/dev/null 2>&1
SSS_CACHE_RC=$?

# get item
USER_PASSWD=$(${GETENT_BIN} passwd ${SSSD_USER} 2>/dev/null)
GETENT_RC=$?

#validate results
if [ "${GETENT_RC}" -eq 0 ];
then
  echo "${USER_PASSWD}" | grep "${SSSD_USER}"  >/dev/null 2>&1
  if [ "$?" -eq 0 ];
  then
    if [ "${SSS_CACHE_RC}" -ne 0 ];
    then
      echo "WARNING: unable to drop ${SSSD_USER}'s cache"
      exit 1
    else
      echo "OK: ${SSSD_USER} found"
      exit 0
    fi
  else
    echo "ERROR inconsistent user info for ${SSSD_USER}"
    exit 2
  fi
else
  echo "CRITICAL: unable to fetch user info"
  exit 2
fi
