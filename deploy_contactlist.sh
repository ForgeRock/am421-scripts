#!/bin/bash
# FR-421 - Tomcat manager, can be used to start, stop or restart tomcats
SCRIPT_DIR="$( dirname "$( which "$0" )" )"
source $SCRIPT_DIR/common.sh

function print_usage {
      log "Usage: $0"
      log "  Deploys the contactlist application to the app tomcat and restarts it."
      exit 1
}

cd "$APP_PROJECT_DIR"
logf "  Building contactlist.war... "
mvn -q clean install > /dev/null
logstatus
"$SCRIPT_DIR/manage_tomcats.sh" app stop
logf "  Copying contactlist.war into app tomcat... "
cp "$APP_PROJECT_DIR/target/contactlist-1.0-SNAPSHOT.war" "${TOMCATS_HOME}/${APP_TOMCAT_NAME}/webapps/contactlist.war"
logstatus
"$SCRIPT_DIR/manage_tomcats.sh" app start

