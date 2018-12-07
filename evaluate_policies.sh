#!/bin/bash
#Evaluate policies in the given application (policy set)
SCRIPT_DIR="$( dirname "$( which "$0" )" )"
source $SCRIPT_DIR/common.sh

function echo_usage {
    (>&2 echo "Usage: $0 application resource evaluatorToken [subjectToken]"
    )
    exit 1
}

APPLICATION=$1
RESOURCE=$2
EVALUATOR_TOKEN=$3
SUBJECT=""

if [[ $# -lt 3 ]]; then
    echo_usage
fi

if [ -n "$4" ]; then
    SUBJECT_TOKEN=$4
    SUBJECT='"subject" : { "ssoToken" : "'"$SUBJECT_TOKEN"'"},'
else
    SUBJECT=''
fi

REQUEST_PAYLOAD='{
    "application" : "'"$APPLICATION"'",
    '"$SUBJECT"'
    "resources" : [ "'"$RESOURCE"'" ]
}'

eval "$((curl -s -X POST\
    --header "iPlanetDirectoryPro: $EVALUATOR_TOKEN"\
    --header "Accept-API-Version: resource=2.0"\
    --header "Content-Type: application/json"\
    --data "${REQUEST_PAYLOAD}"\
    "$SERVER_URI/json/policies?_action=evaluate")2> >(captureTo STDERR_OUT) > >(captureTo RESPONSE)
)"

STATUS=$?

if [ $STATUS -eq 0 ]
then
    VALUE=$(echo "$RESPONSE" | jq -C -r .)
    echo -e "$VALUE"
else
    log "Operation Failed"
    log_output
    exit 1
fi