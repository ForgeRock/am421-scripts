#!/bin/bash
TMP_DIR=$HOME/temp
if [ ! -d ${TMP_DIR} ]; then
  mkdir -p ${TMP_DIR}
fi

CODE_VAL=${1:-${code_value}}
if [ -z ${CODE_VAL} ];  then
  echo "Usage: $0 \"code-value-string\""
  echo " or" 
  echo "   export code_value=\"code-value-string\""
  echo "   $0"
  exit 1
fi
cat <<-END > ${TMP_DIR}/icode.json
{
  "input": {
    "code": "code-value"
  },
  "token": "token-data"
}
END
TOKEN_DATA=${token_data}
if [ -z ${token_data} ]; then
  TOKEN_DATA=$(cat ${TMP_DIR}/resp1.json | jq .token)
fi
cat ${TMP_DIR}/icode.json | jq ".input.code = \"${CODE_VAL}\" | .token=${TOKEN_DATA}" > ${TMP_DIR}/code.json

curl -s -X POST \
  -H 'Content-Type: application/json' \
  -H 'Accept-API-Version: resource=1.0' \
  --data @${TMP_DIR}/code.json \
'http://login.example.com:18080/am/json/selfservice/forgottenPassword?_action=submitRequirements' | tee ${TMP_DIR}/resp2.json | jq
