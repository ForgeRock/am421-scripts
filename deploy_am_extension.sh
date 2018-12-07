#!/bin/bash
# FR-421 - Tomcat manager, can be used to start, stop or restart tomcats
SCRIPT_DIR="$( dirname "$( which "$0" )" )"
source $SCRIPT_DIR/common.sh
RESTART_TOMCAT=true

function print_usage {
      log "Usage: $0 [--no-tomcat-restart] path_to_jarfile"
      log "  Deploys the given jar file into AM's lib directory."
      exit 1
}

if [[ $# -lt 1 ]] 
then  # number of parameters < 1
    print_usage
fi

if [ $# -eq 1 ]
then
    JAR_PATH=$(realpath "$1")
elif [ $# -eq 2 ] && [ $1 = "--no-tomcat-restart" ]
then
    JAR_PATH=$(realpath "$2")
    RESTART_TOMCAT=false
else
    log "Unrecognized option."
    print_usage
fi

JAR_NAME=$(basename "$JAR_PATH")

if ! [[ $JAR_NAME =~ .jar$ ]]
then
    log "The provided path does not point to a jar file."
    print_usage
fi

unzip -l "$JAR_PATH" > /dev/null 2>&1

if ! [[ $? -eq 0 ]]
then
    log "The provided path points to an invalid jar file."
    print_usage
fi

if [[ $RESTART_TOMCAT = true ]]
then
    "$SCRIPT_DIR/manage_tomcats.sh" login stop
fi

logf "  Deleting the old version of ${JAR_NAME}..."
rm -f "${AM_LIB_DIR}/${JAR_NAME}"
logstatus

logf "  Copying ${JAR_NAME} into AM's lib folder ..."
cp "$JAR_PATH" "${AM_LIB_DIR}/${JAR_NAME}"
logstatus

if [[ $RESTART_TOMCAT = true ]]
then
    "$SCRIPT_DIR/manage_tomcats.sh" login start
fi
