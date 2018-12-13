#!/bin/bash
TMP_DIR=$HOME/temp
if [ -d ${TMP_DIR} ]; then
  rm  ${TMP_DIR}/*.json
else
  mkdir -p ${TMP_DIR}
fi

curl -s -H "Accept-API-Version: resource=1.0" \
 'http://login.example.com:18080/am/json/selfservice/forgottenPassword' | jq
