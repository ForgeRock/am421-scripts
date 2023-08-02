#!/bin/bash
ADMINTOKEN=$1
USERTOKEN=$2
while [ -z ${ADMINTOKEN} ]; do
   read -p "Admin tokenId (iPlanetDirectoryPro value): " ADMINTOKEN
done
while [ -z ${USERTOKEN} ]; do
   read -p "User tokenId (iPlanetDirectoryPro value): " USERTOKEN
done
echo "Admin tokenId: ${ADMINTOKEN}"
echo "User tokenId: ${USERTOKEN}"
cat <<-END
curl -s -X POST \
  "http://login.example.com:18080/am/json/sessions?_action=getSessionProperties&tokenId=${USERTOKEN}" \
  -H 'Accept-API-Version: resource=2.1, protocol=1.0' \
  -H 'Cache-Control: no-cache' \
  -H "iPlanetDirectoryPro: ${ADMINTOKEN}"
END
curl -s -X POST \
  "http://login.example.com:18080/am/json/sessions?_action=getSessionProperties&tokenId=${USERTOKEN}" \
  -H 'Accept-API-Version: resource=2.1, protocol=1.0' \
  -H 'Cache-Control: no-cache' \
  -H "iPlanetDirectoryPro: ${ADMINTOKEN}" | jq .
