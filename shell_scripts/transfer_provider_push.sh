#!/bin/bash

contract_file="contract.txt"

template_file="transfer/transfer-02-provider-push/resources/start-transfer-lab-research.json"
output_file="transfer/transfer-02-provider-push/resources/start-transfer-lab-research-v1.json"

contract_id=$(jq -r '.contractAgreementId' "$contract_file")

echo "Contract ID: ${contract_id}"

jq --arg cid "$contract_id" '.contractId = $cid' "$template_file" > "$output_file"

curl -X GET "http://localhost:40193/management/v3/contractagreements/${contract_id}" \
    -s | jq
    

transfer_id=$(curl -X POST "http://localhost:40193/management/v3/transferprocesses" \
    -H "Content-Type: application/json" \
    -d @"$output_file" \
    -s | jq -r '.["@id"]')

echo "Transfer ID: ${transfer_id}"

curl "http://localhost:40193/management/v3/transferprocesses/${transfer_id}" -s | jq

