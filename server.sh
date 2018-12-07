#!/bin/bash
CMD=${1}
SERVER=${2}

function error() {
  echo "Error: $1"
}

function usage() {
  echo "Usage: $(basename $0) {start|stop} {app|login|ds}"
  exit 1
}

case ${CMD} in
  start)
       case ${SERVER} in
       app|login)
	 if [ ! -d /opt/tomcats/${SERVER} ]; then
	   error "Server with name '${SERVER}' does not exist"
	   usage
	 fi
         /opt/tomcats/${SERVER}/bin/startup.sh ;;
       opendj|ds)
         /opt/opendj/bin/start-ds ;;
       *)
           error "Server name/id '${SERVER}' not supported."
           usage ;;
       esac ;;
  stop) 
       case ${SERVER} in
       app|login)
	 if [ ! -d /opt/tomcats/${SERVER} ]; then
	   error "Server with name '${SERVER}' does not exist"
	   usage
	 fi
         /opt/tomcats/${SERVER}/bin/shutdown.sh ;;
       opendj|ds)
         /opt/opendj/bin/stop-ds ;;
       *)
           error "Server name/id '${SERVER}' not supported."
           usage ;;
       esac ;;
  *)
     if [ ! -z "${CMD}" ]; then
       error "'${CMD}' - command not supported"
     fi
     usage ;;
esac
