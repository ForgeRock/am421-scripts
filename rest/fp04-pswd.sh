#!/bin/bash
NEW_PWD=$1
if [ -z ${NEW_PWD} ];  then
  echo "Usage: $0 \"new-password\""
  exit 1
fi
cat <<-END > ${PWD}/ipswd.json
{
  "input": {
    "password": "new-password"
  },
  "token": "token-value"
}
END
TOKEN_DATA=${token_data}
if [ -z ${token_data} ]; then
  TOKEN_DATA=$(cat ${PWD}/resp2.json | jq .token)
fi
cat ${PWD}/ipswd.json | jq ".input.password=\"${NEW_PWD}\" | .token=${TOKEN_DATA}" > ${PWD}/pswd.json
set -x
curl -X POST \
  -H 'Content-Type: application/json' \
  -H 'Accept-API-Version: resource=1.0' \
  --data @${PWD}/pswd.json \
http://login.example.com:18080/am/json/selfservice/forgottenPassword?_action=submitRequirements | jq
set +x
