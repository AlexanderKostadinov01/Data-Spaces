PROVIDER=$1
WEBPORT=$2

if [ -z "$PROVIDER" ] || [ -z "$WEBPORT" ]; then
  echo "Usage: $0 <PROVIDER> <WEBPORT>"
  exit 1
fi

echo "Registering asset for $PROVIDER on port $WEBPORT..."
curl -d @transfer/transfer-01-negotiation/resources/create-asset-${PROVIDER}.json \
     -H 'content-type: application/json' \
     http://localhost:${WEBPORT}/management/v3/assets \
     -s | jq

echo "Registering policy..."
curl -d @transfer/transfer-01-negotiation/resources/create-policy.json \
     -H 'content-type: application/json' \
     http://localhost:${WEBPORT}/management/v3/policydefinitions \
     -s | jq

echo "Registering contract definition for $PROVIDER on port $WEBPORT..."
curl -d @transfer/transfer-01-negotiation/resources/create-contract-definition-${PROVIDER}.json \
     -H 'content-type: application/json' \
     http://localhost:${WEBPORT}/management/v3/contractdefinitions \
     -s | jq