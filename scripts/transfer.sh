PROVIDER=$1
CONSUMER=$2
MGMT_PORT=$3
CONTRACT_AGREEMENT_ID=$4
PUBLIC_PORT=$5
SAVE_FILE=$6

if [ -z "$PROVIDER" ] || [ -z "$CONSUMER" ] || [ -z "$MGMT_PORT" ] || [ -z "$CONTRACT_AGREEMENT_ID" ] || [ -z "$PUBLIC_PORT" ]; then
  echo "Usage: $0 <provider> <consumer> <management_port> <contractId> <public_port> <save_file>"
  exit 1
fi

TRANSFER_TEMPLATE="transfer/transfer-02-provider-push/resources/start-transfer-${PROVIDER}-${CONSUMER}.json"
TRANSFER_TMP="start-transfer-${PROVIDER}-${CONSUMER}-tmp.json"

jq --arg cid "$CONTRACT_AGREEMENT_ID" '.contractId = $cid' "$TRANSFER_TEMPLATE" > "$TRANSFER_TMP"
echo "Injected contractId "$CONTRACT_AGREEMENT_ID" into start-transfer JSON."

echo "Starting transfer process..."
transfer_response=$(curl -X POST "http://localhost:${MGMT_PORT}/management/v3/transferprocesses" \
  -H "Content-Type: application/json" \
  -d @"$TRANSFER_TMP" -s)

transfer_process_id=$(echo "$transfer_response" | jq -r '."@id"')
echo "Transfer process started with ID: $transfer_process_id"

if [ -z "$transfer_process_id" ] || [ "$transfer_process_id" == "null" ]; then
  echo "Failed to start transfer process"
  exit 1
fi

echo "Getting transfer process status..."
curl "http://localhost:${MGMT_PORT}/management/v3/transferprocesses/${transfer_process_id}" -s | jq
sleep 10

echo "Getting EDR for transfer process..."
edr_response=$(curl "http://localhost:${MGMT_PORT}/management/v3/edrs/${transfer_process_id}/dataaddress" -s)
echo "$edr_response" | jq

auth_key=$(echo "$edr_response" | jq -r '.authorization // empty')

if [ -z "$auth_key" ]; then
  echo "authorization key not found in EDR."
  exit 1
fi

echo "Authorization key extracted."

echo "Accessing provider's public endpoint at http://localhost:${PUBLIC_PORT}/public/${PROVIDER}.json with Authorization header..."
response=$(curl --location --request GET "http://localhost:${PUBLIC_PORT}/public/${PROVIDER}.json" \
  --header "Authorization: $auth_key" -s)

echo "Raw response:"
echo "$response" > "$SAVE_FILE"
rm -f "$TRANSFER_TMP"
