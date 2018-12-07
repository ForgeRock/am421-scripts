#!/bin/bash

rm -rf ${PWD}/*.json
set -x
curl -H "Accept-API-Version: resource=1.0" \
 http://login.example.com:18080/am/json/selfservice/forgottenPassword | jq
set +x
