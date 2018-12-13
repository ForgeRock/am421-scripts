#/bin/bash
TMP_DIR=${HOME}/temp
if [ ! -d ${TMP_DIR} ]; then
  mkdir -p ${TMP_DIR} 
fi

UID_VALUE=${1:-demo}
cat <<-END > ${TMP_DIR}/qfilter.json
{
  "input": {
    "queryFilter": "uid eq \"${UID_VALUE}\""
  }
}
END

curl -s -X POST \
  -H 'Content-Type: application/json' \
  -H 'Accept-Language: en' \
  -H 'Accept-API-Version: resource=1.0' \
  --data @${TMP_DIR}/qfilter.json \
'http://login.example.com:18080/am/json/selfservice/forgottenPassword?_action=submitRequirements' | tee ${TMP_DIR}/resp1.json | jq
