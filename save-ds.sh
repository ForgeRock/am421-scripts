#!/bin/bash

BCKCMD="/opt/opendj/bin/backup"
BASE_DIR="${1:-/opt/forgerock/course/backups/ldap-backend}"
DSPWD="${2:-cangetindj}"

SCRIPT_DIR="$( dirname "$( which "$0" )" )"
source $SCRIPT_DIR/common.sh

function cleanDSBackup() {
  if [ -d ${BASE_DIR} ]; then
    read -p "Save existing Directory Server backup [y]? " saveDS
    case ${saveDS} in 
      ""|[Yy]*) saveDS=y ;;
      *) unset saveDS ;;
    esac
  fi
  if [ ${saveDS} ]; then
     backupFile=$(basename ${BASE_DIR})
     backupDir=$(dirname ${BASE_DIR})
     logf "Backing up existing DS backup files..."
     tar cjf ${backupDir}/${backupFile}-$(date +%Y%m%d-%H%M%S).tar.bz2 ${BASE_DIR}
     logstatus
  fi
  logf "Removing exiting DS backup files..."
  echo rm -rf ${BASE_DIR}/*
  logstatus
}

function backupDS() {
  backendId=$1
  if [ -z ${backendId} ]; then
     logf "Error: backupDS function needs the backendId as the argument."
     exit 1
  fi
  logf "Backup DS backendId=${backendId}..."
  ${BCKCMD} --hostname forgerock.example.com  --port 5444  --bindDN cn="Directory Manager"  --bindPassword ${DSPWD} --backendId ${backendId}  --backupDirectory ${BASE_DIR}/${backendId} --start 0 --trustAll
  logstatus
}


cleanDSBackup

logf "Backing up ForgeRock Directory Server"
ID_LIST="schema tasks userRoot"
for id in ${ID_LIST}; do
  backupDS ${id}
done
