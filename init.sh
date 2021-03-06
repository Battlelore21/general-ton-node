#!/usr/bin/env bash
set -x
if [ -z "$PUBLIC_IP" ]; then
        export PUBLIC_IP=127.0.0.1
fi
if [ -z "$CONSOLE_PORT" ]; then
        export CONSOLE_PORT=50001
fi
if [ -z "$PUBLIC_PORT" ]; then
        export PUBLIC_PORT=50000
fi

if ( [ -d "state" ] && [ "$(ls -A ./state)" ]); then
  echo "Found non-empty state; Skip initialization";
else
  echo "Initializing network";
  ./prepare_network.sh
fi

if [[ "$SERVECONFIG" == 1 ]]; then
   echo "Serving config"
   python -m SimpleHTTPServer "$HTTPPORT" &
fi

if [[ "$DHT_SERVER" == 1 ]]; then
   echo "Start DHT server on $BIND_IP:$DHT_PORT"
   cd dht-server
   dht-server -C my-ton-global.config.json -D . -I "$BIND_IP:$DHT_PORT"&
   cd ..
fi

echo "Start validator on $BIND_IP:$PUBLIC_PORT"
validator-engine -C /var/ton-work/db/my-ton-global.config.json --db /var/ton-work/db --ip "$BIND_IP:$PUBLIC_PORT"
