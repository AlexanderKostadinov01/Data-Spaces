#!/bin/bash

PROVIDER=$1
PORT=$2

if [ -z "$PROVIDER" ] || [ -z "$PORT" ]; then
    echo "Error: use create_asset_policy as follows: ./create_asset_policy.sh {PROVIDER} {PORT}"
    exit 1
fi

echo "Creating as asset for $PROVIDER on port $PORT..."
curl -d @transfer/transfer-01-negotiation/resources/create-asset-${PROVIDER}.json \
  -H 'content-type: application/json' http://localhost:${PORT}/management/v3/assets \
  -s | jq

echo "Creating a policy for $PROVIDER..."
curl -d @transfer/transfer-01-negotiation/resources/create-policy.json \
  -H 'content-type: application/json' http://localhost:${PORT}/management/v3/policydefinitions \
  -s | jq

echo "Creating a contract for $PROVIDER on port $PORT..."
curl -d @transfer/transfer-01-negotiation/resources/create-contract-definition-${PROVIDER}.json \
  -H 'content-type: application/json' http://localhost:${PORT}/management/v3/contractdefinitions \
  -s | jq
