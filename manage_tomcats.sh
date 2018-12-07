#!/bin/bash
# FR-421 - Tomcat manager, can be used to start, stop or restart tomcats
SCRIPT_DIR="$( dirname "$( which "$0" )" )"
source $SCRIPT_DIR/common.sh

function print_usage {
      log "Usage: $0 tomcatName command "
      log "where tomcatName = login|app"
      log "         command = start|stop|restart"
      log "~/fr_scripts.config can override configuration variables"
      exit 1
}

TOMCAT_NAME="$1"
COMMAND="$2"

trap ctrl_c INT

function ctrl_c() {
    log "** Trapped CTRL-C"
    log "killing all child processes of pid $$"
    log "kill $TAIL_PID, $GREP_PID, $CATALINA_FAILED_TO_START_DETECTOR_PID"

    PID=$$
    
    kill $TAIL_PID $GREP_PID $CATALINA_FAILED_TO_START_DETECTOR_PID
    {
        sleep .2
        kill PID
    } &
}

case $TOMCAT_NAME in
    "login"|"app")
        case $COMMAND in
            "start" )
                tomcat_start $TOMCAT_NAME
                exit $?
                ;;
            "stop" )
                tomcat_stop $TOMCAT_NAME
                exit $?
                ;;
            "restart" )
                tomcat_stop $TOMCAT_NAME
                tomcat_start $TOMCAT_NAME
                exit $?
                ;;
            *)
                print_usage
        esac
    ;;
    *)
    log "Invalid tomcat name."
    print_usage
esac

