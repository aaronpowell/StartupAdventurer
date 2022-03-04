#/bin/sh

npm ci
cd api
npm ci
cd ..

if ping -c 1 cosmos &> /dev/null
then
  echo Cosmos emulator found
  echo Preping emulator

  if [ ! -f "./api/local.settings.json" ]
  then
    sleep 5s
    curl --insecure -k https://cosmos:8081/_explorer/emulator.pem > ~/emulatorcert.crt
    sudo cp ~/emulatorcert.crt /usr/local/share/ca-certificates/
    sudo update-ca-certificates
    ipaddr=$(ping -c 1 cosmos | grep -oP '\(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\)' | sed -n 's/(//p' | sed -n 's/)//p' | head -n 1)
    key=$(curl -s https://$ipaddr:8081/_explorer/quickstart.html | grep -Po 'value="(?![Account]|[https]|[mongo])(.*)"' | sed 's/value="//g' | sed 's/"//g')
    echo "{
    \"IsEncrypted\": false,
    \"Values\": {
      \"FUNCTIONS_WORKER_RUNTIME\": \"node\",
      \"AzureWebJobsStorage\": \"\",
      \"StartupAdventurer_COSMOSDB\": \"AccountEndpoint=https://$ipaddr:8081/;AccountKey=$key;\",
      \"SHORT_URL\": \"http://localhost:4820\"
    }
  }" >> ./api/local.settings.json
  fi
fi