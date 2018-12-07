#!/bin/bash
# AM421 Authenticate with AM6 (Authenticate with Accept-API-Version)
# authenticate.sh
# 2016-2018. Vrg
# 2018.05. Pal

SERVER_URI="http://login.example.com:18080/am"

USERNAME=$1
PASSWORD=$2

function captureTo { 
    printf -v "$1" "%s" "$(cat)"; declare -p "$1"; 
}

function log {
    (>&2 echo -e "$1")
}

function echo_usage {
    log
    log "Usage: $0 username password [chain name]"
    log "       Only those use cases are supported, where OpenAM"
    log "       returns immediately with the tokenId"
}

function log_output {
    log "$STDERR_OUT"
    log "$RESPONSE"    
}

if [[ $# -lt 2 ]]; then  # number of parameters < 2
    echo_usage
    exit 1
fi

if [ $# -ge 3 ]; then    # number of parameters >= 3
    CHAIN=$3
    AUTH_PARAMS="authIndexType=service&authIndexValue=$CHAIN"
else
    AUTH_PARAMS=""
fi

unset STDERR_OUT RESPONSE
eval "$((curl -v -X POST \
  --header "X-OpenAM-Username: $USERNAME" \
  --header "X-OpenAM-Password: $PASSWORD" \
  --header "Content-Type: application/json" \
  --data "{}" \
  --header "Accept-API-Version: resource=2.0, protocol=1.0" \
  "$SERVER_URI/json/realms/root/authenticate?$AUTH_PARAMS") 2> >(captureTo STDERR_OUT) > >(captureTo RESPONSE)
)"

if [[ $(echo "$RESPONSE" | jq -r ".authId != null") = "true" ]]; then
    log "Multi-step authentication is not supported, response was:"
    log
    log_output
    echo_usage
  else
    TOKEN=$(echo "$RESPONSE" | jq -r .tokenId)
    if [[ $TOKEN == null ]]; then
        log_output
        echo_usage
        exit -1
      else
        echo $TOKEN
    fi
fi