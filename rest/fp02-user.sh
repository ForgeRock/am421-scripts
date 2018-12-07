#/bin/bash
UID_VALUE=${1:-demo}

cat <<-END > ${PWD}/qfilter.json
{
  "input": {
    "queryFilter": "uid eq \"${UID_VALUE}\""
  }
}
END
cat ${PWD}/qfilter.json | jq
set -x
curl -X POST \
  -H 'Content-Type: application/json' \
  -H 'Accept-Language: en' \
  -H 'Accept-API-Version: resource=1.0' \
  --data @${PWD}/qfilter.json \
http://login.example.com:18080/am/json/selfservice/forgottenPassword?_action=submitRequirements | tee ${PWD}/resp1.json | jq
set +x
