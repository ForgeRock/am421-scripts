#!/bin/bash
# AM421 Environment setter script. Used by other scripts
# common.sh
# Parameters
# 2016-2018. Vrg
# 2018.05. Pal

#NOW=$(date +"%Y.%m.%d. %H:%M:%S")
#$LOGGER_DIR/LabScriptLogger.sh "-- $0 started ($NOW )"

SCRIPT_DIR="$( dirname "$( which "$0" )" )"
COURSE_DIR=/opt/forgerock/course
TOMCATS_HOME=/opt/tomcats
AM_TOMCAT_NAME=login
APP_TOMCAT_NAME=app
TOOLS_DIR=~/ssoadmintools
PROJECTS_DIR=~/AMProjects
SELECT_ROLE_NODE_PROJECT_DIR=$PROJECTS_DIR/select-role-node
EXTENSIONS_PROJECT_DIR=$PROJECTS_DIR/am-extensions
APP_PROJECT_DIR=$PROJECTS_DIR/contactlist
AM_LIB_DIR="${TOMCATS_HOME}/${AM_TOMCAT_NAME}/webapps/am/WEB-INF/lib"
AM_CONFIG_DIR=~/ams/login

SSOADM=$TOOLS_DIR/am/bin/ssoadm
PASSFILE=$TOOLS_DIR/.password.am
SERVER_URI="http://login.example.com:18080/am"

base64Encode='base64 --wrap=0'

AMSTER=/home/forgerock/amster/amster
AMSTER_CONNECT="connect --private-key /home/forgerock/ams/login/amster_rsa $SERVER_URI"

test -f ~/fr_scripts.config && source ~/fr_scripts.config

function base64Encode {
    $base64Encode $1
}

function log {
    (>&2 echo -e "$1")
}

function logf {
    (>&2 printf "$1")
}

function log_error {
    (>&2 echo -e "$1")
}

function captureTo { 
    printf -v "$1" "%s" "$(cat)"; declare -p "$1"; 
}

function log_output {
    log "$STDERR_OUT"
    log "$RESPONSE"    
}

function logsuccess {
    log "$(tput bold)$(tput setaf 2)SUCCESS$(tput sgr0)"
}

function logfailed {
    log "$(tput bold)$(tput setaf 1)FAILED$(tput sgr0)"
}

function logstatus {
  local status=$?
  if [ $status -eq 0 ]
  then
    logsuccess
  else
    logfailed
  fi
  return $status
}

function setCatalinaHomeOrFail {
  TOMCAT_NAME="$1"
  CATALINA_HOME="$TOMCATS_HOME/$TOMCAT_NAME"

  if [ ! -d "$CATALINA_HOME" ]; then
      log "Tomcat home does not exist: $CATALINA_HOME"
      return -1
  fi
}

function isTomcatAlive() {
  TOMCAT_NAME="$1"
  CATALINA_HOME="$TOMCATS_HOME/$TOMCAT_NAME"
  PORT=$(xmllint $CATALINA_HOME/conf/server.xml --xpath "string(/Server/Service/Connector[@protocol='HTTP/1.1']/@port)")
  logf "Checking if $TOMCAT_NAME Tomcat is accessible with curl..."
  curl -s -f -o /dev/null -m 1 http://localhost:$PORT
  return $?
}

function waitForTomcatStartup {

  TOMCAT_NAME="$1"
  TIMEOUT_SECS=${2:-180} # After a default of 3 minutes check if the Tomcat root page is accessible, if not fail
  CATALINA_HOME="$TOMCATS_HOME/$TOMCAT_NAME"
  setCatalinaHomeOrFail "$TOMCAT_NAME"

  EXIT_STATUS=1
  let cnt=0
  LOGMSG=$(tail -1 $CATALINA_HOME/logs/catalina.out)
  while  [[ ! "$LOGMSG" =~ .+Server\ startup\ in\ \[[0-9]+\]\ m.+ ]]; do
    logf "."
    sleep 1
    LOGMSG=$(tail -1 $CATALINA_HOME/logs/catalina.out)
    let cnt++
    # If the number of seconds has exceeded the TIMEOUT_SECS value then
    # use curl to check if the Tomcat server is running, and if it fails immediately
    # then consider startup failed for some reason and exit
    if [ $cnt -ge $TIMEOUT_SECS ]; then
      isTomcatAlive $TOMCAT_NAME
      logstatus
      return
    fi
  done
  EXIT_STATUS=0
  logsuccess
  return $EXIT_STATUS
}

function tomcat_start {

  TOMCAT_NAME="$1"
  setCatalinaHomeOrFail "$TOMCAT_NAME"

  PID=$(jps -v | grep $CATALINA_HOME | cut -d " " -f 1)
  if [[ "$PID" != "" ]];
    then
      log "Could not start Tomcat named '$TOMCAT_NAME'. It is already running."
      return 0
    else
      logf "Starting Tomcat named '$TOMCAT_NAME'"
      $CATALINA_HOME/bin/catalina.sh jpda start >/dev/null
      waitForTomcatStartup "$TOMCAT_NAME"
      return $?
  fi
}

function tomcat_stop {
  TOMCAT_NAME="$1"
  setCatalinaHomeOrFail "$TOMCAT_NAME"
  PID=$(jps -v | grep $CATALINA_HOME | cut -d " " -f 1)
  if [[ "$PID" = "" ]];
    then
      log "Could not stop Tomcat named '$TOMCAT_NAME'. It is not running."
      return 0
    else
      logf "Stopping Tomcat named '$TOMCAT_NAME'... "
      $CATALINA_HOME/bin/shutdown.sh -force >/dev/null 2>/dev/null
      while kill -0 "$PID" 2>/dev/null; do
        sleep .2
      done
      logstatus 0
      return 0
  fi
}

function build_project {

  local PROJECT_NAME=$1

  local PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME"

  if ! [ -f "$PROJECT_DIR/pom.xml" ]
  then
    log "  ${PROJECT_NAME} is not a valid maven project!"
    return 1
  fi

  cd "$PROJECT_DIR"
  logf "  Building ${PROJECT_NAME}.jar... "
  mvn -q clean install -DskipTests > /dev/null
  logstatus
  return $?
}

function obtain_admin_token {
  ADMIN_TOKEN=$($SCRIPT_DIR/authenticate.sh amadmin $(cat $PASSFILE))
  export ADMIN_TOKEN
   echo $ADMIN_TOKEN > /tmp/am6token
}
