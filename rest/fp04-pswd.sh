#!/bin/bash
TMP_DIR=$HOME/temp
if [ ! -d ${TMP_DIR} ]; then
  mkdir -p ${TMP_DIR}
fi

NEW_PWD=$1
if [ -z ${NEW_PWD} ];  then
  echo "Usage: $0 \"new-password\""
  exit 1
fi
cat <<-END > ${TMP_DIR}/ipswd.json
{
  "input": {
    "password": "new-password"
  },
  "code": "code-value",
  "token": "token-value"
}
END
TOKEN_DATA=${token_data}
if [ -z ${token_data} ]; then
  TOKEN_DATA=$(cat ${TMP_DIR}/resp2.json | jq .token)
fi
CODE_VALUE=$(jq .requirements.code ${TMP_DIR}/resp2.json)
cat ${TMP_DIR}/ipswd.json | jq ".input.password=\"${NEW_PWD}\" | .token=${TOKEN_DATA} | .code=${CODE_VALUE}" > ${TMP_DIR}/pswd.json

curl -s -X POST \
  -H 'Content-Type: application/json' \
  -H 'Accept-API-Version: resource=1.0' \
  --data @${TMP_DIR}/pswd.json \
'http://login.example.com:18080/am/json/selfservice/forgottenPassword?_action=submitRequirements' | jq

# clean up
if [ -d ${TMP_DIR} ]; then
  rm ${TMP_DIR}/*.json
  rmdir ${TMP_DIR}
fi
