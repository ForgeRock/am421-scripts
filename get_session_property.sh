#!/bin/bash
#Gets the given session property of the queriedToken
SCRIPT_DIR="$( dirname "$( which "$0" )" )"

source $SCRIPT_DIR/common.sh

function echo_usage {
    log "Usage: $0 propertyName queriedToken [performerToken]"
    exit 1
}

if [[ $# -lt 2 ]]; then  # number of parameters < 2
    echo_usage
    exit 1
fi

PROPERTY=$1
QUERIED_TOKEN=$2
PERFORMER_TOKEN=$3

if [ $# -lt 3 ]; then
    PERFORMER_TOKEN=$($SCRIPT_DIR/authenticate.sh amadmin cangetinam)
fi

REQUEST_PAYLOAD='{
  "properties" : [ "'"$PROPERTY"'" ]
}'

eval "$((curl -v -X POST\
    --header "iPlanetDirectoryPro: $PERFORMER_TOKEN"\
    --header "Accept-API-Version: resource=1.2"\
    --header "Content-Type: application/json"\
    --data "${REQUEST_PAYLOAD}"\
    "$SERVER_URI/json/sessions/?_action=getProperty&tokenId=$QUERIED_TOKEN")2> >(captureTo STDERR_OUT) > >(captureTo RESPONSE)
)"

STATUS=$?

if [ $STATUS -eq 0 ]
then
    VALUE=$(echo "$RESPONSE" | jq -r -C ".$PROPERTY")
    if [ "$VALUE" != "null" ]
    then
        echo -e "$VALUE"
    else
        log "operation failed (token is invalid)"
        exit 1
    fi

else
    log "Operation Failed"
    log_output
    exit 1
fi
