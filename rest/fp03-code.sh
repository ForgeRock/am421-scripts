#!/bin/bash
CODE_VAL=${1:-${code_value}}
if [ -z ${CODE_VAL} ];  then
  echo "Usage: $0 \"code-value-string\""
  echo " or" 
  echo "   export code_value=\"code-value-string\""
  echo "   $0"
  exit 1
fi
cat <<-END > ${PWD}/icode.json
{
  "input": {
    "code": "code-value"
  },
  "token": "token-data"
}
END
TOKEN_DATA=${token_data}
if [ -z ${token_data} ]; then
  TOKEN_DATA=$(cat ${PWD}/resp1.json | jq .token)
fi
set -x
cat ${PWD}/icode.json | jq ".input.code = \"${CODE_VAL}\" | .token=${TOKEN_DATA}" > ${PWD}/code.json
curl -X POST \
  -H 'Content-Type: application/json' \
  -H 'Accept-API-Version: resource=1.0' \
  --data @${PWD}/code.json \
http://login.example.com:18080/am/json/selfservice/forgottenPassword?_action=submitRequirements | tee ${PWD}/resp2.json | jq
set +x
