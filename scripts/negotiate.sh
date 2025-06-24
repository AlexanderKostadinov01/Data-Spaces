CONSUMER=$1
WEBPORT=$2
PROVIDER=$3
POLICYID=$4

if [ -z "$CONSUMER" ] || [ -z "$WEBPORT" ] || [ -z "$PROVIDER" ] || [ -z "$POLICYID" ]; then
  echo "Usage: $0 <consumer> <webport> <provider> <policyid>"
  exit 1
fi
# change to the federated catalogue.
#echo "Fetching catalog for $CONSUMER on port $WEBPORT..."
#policy_id=$(curl -X POST "http://localhost:${WEBPORT}/management/v3/catalog/request" \ 
#  -H 'Content-Type: application/json' \
#  -d @transfer/transfer-01-negotiation/resources/fetch-catalog-${CONSUMER}.json \
#  -s | jq -r '.["dcat:dataset"]["odrl:hasPolicy"]["@id"]')
#
#echo "Policy ID found: $policy_id"
#
#if [ -z "$policy_id" ] || [ "$policy_id" == "null" ]; then
#  echo "Failed to extract policy ID"
#  exit 1
#fi

negotiate_template="transfer/transfer-01-negotiation/resources/negotiate-contract-${PROVIDER}-${CONSUMER}.json"
negotiate_tmp="negotiate-contract-${PROVIDER}-${CONSUMER}-tmp.json"
jq --arg pid "$POLICYID" '.policy["@id"] = $pid' "$negotiate_template" > "$negotiate_tmp"

negotiation_response=$(curl -d @"$negotiate_tmp" \
  -X POST -H 'content-type: application/json' \
  "http://localhost:${WEBPORT}/management/v3/contractnegotiations" \
  -s)

negotiation_id=$(echo "$negotiation_response" | jq -r '.["@id"]')
echo "Contract negotiation started with ID: $negotiation_id"


if [ -z "$negotiation_id" ] || [ "$negotiation_id" == "null" ]; then
  echo "Failed to start contract negotiation"
  exit 1
fi

sleep 10

status_response=$(curl -s -X GET "http://localhost:${WEBPORT}/management/v3/contractnegotiations/${negotiation_id}" \
  -H 'Content-Type: application/json')

echo "$status_response" | jq

{
  echo "$status_response"
} >> contract.txt

contract_agreement_id=$(echo "$status_response" | jq -r '.contractAgreementId // "null"')

if [ "$contract_agreement_id" != "null" ]; then
  echo "Contract Agreement ID: $contract_agreement_id"
  echo "$contract_agreement_id" > contract_agreements.txt
else
  echo "Contract Agreement ID not available yet."
fi

rm -f "$negotiate_tmp"