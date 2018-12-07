#!/bin/bash
shutdownPort=${1:-8005}
httpPort=${2:-8080}
ajpPort=${3:-8009}
redirectPort=${4:-8443}
# Script to update the port and redirectPort entries shown in the following XML
# <Server port="8005" shutdown="SHUTDOWN">
# <Connector port="8080" protocol="HTTP/1.1" ... redirectPort="8443"/>
# <Connector port="8009" protocol="AJP/1.3" redirectPort="8443"/>bas
bckFile=server.xml.bck
i=0
while [ -f ${bckFile} ]; do
  bckFile=server.xml.bck.${i}
  i=$(($i + 1))
done
cp ${PWD}/server.xml ${bckFile}

xmllint --shell ${PWD}/server.xml <<-END
cd /Server/@port
cat .
set ${shutdownPort}
cat .

cd /Server/Service/Connector[@protocol='HTTP/1.1']/@port
set ${httpPort}
cd ../@redirectPort
set ${redirectPort}
cat ..

cd /Server/Service/Connector[@protocol='AJP/1.3']/@port
set ${ajpPort}
cd ../@redirectPort
set ${redirectPort}
cat ..

save
exit
END
echo -e "\n${PWD}/server.xml ports updated\n"
