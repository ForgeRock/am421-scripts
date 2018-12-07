#!/bin/bash
# FR-421 - Tomcat manager, can be used to start, stop or restart tomcats
SCRIPT_DIR="$( dirname "$( which "$0" )" )"
source $SCRIPT_DIR/common.sh
RESTART_TOMCAT=true

function print_usage {
      log "Usage: $0 [--no-tomcat-restart] project_name"
      log "  Undeploys the given project's built jar file from AM's lib directory."
      exit 1
}

if [[ $# -lt 1 ]] 
then  # number of parameters < 1
    print_usage
fi

if [ $# -eq 1 ]
then
    PROJECT_NAME=$1
elif [ $# -eq 2 ] && [ $1 = "--no-tomcat-restart" ]
then
    PROJECT_NAME=$2
    RESTART_TOMCAT=false
else
    log "Unrecognized option."
    print_usage
fi


if ! [[ $PROJECT_NAME =~ ^[a-z-]{1,}$ ]]
then
    log "The provided project name is invalid"
    print_usage
fi

logf "  Removing ${PROJECT_NAME}.jar from AM's lib folder ..."

find "${AM_LIB_DIR}" -name "${PROJECT_NAME}*.jar" | xargs rm -f

logstatus

exit $?