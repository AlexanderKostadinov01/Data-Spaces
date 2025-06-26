#!/bin/bash

policy_id=$(curl -s -X POST "http://localhost:30193/management/v3/catalog/request" \
  -H 'Content-Type: application/json' \
  -d @transfer/transfer-01-negotiation/resources/fetch-catalog-lab.json \
  | jq -r '.["dcat:dataset"]["odrl:hasPolicy"]["@id"]')

echo "Policy ID: $policy_id"

template_file="transfer/transfer-01-negotiation/resources/negotiate-contract-lab-ministry.json"
output_file="transfer/transfer-01-negotiation/resources/negotiate-contract-lab-ministry_v1.json"

sed "s/{placeholder}/$policy_id/g" "$template_file" > "$output_file"

contract_negotiation_id=$(curl -d @transfer/transfer-01-negotiation/resources/negotiate-contract-lab-ministry_v1.json \
  -X POST -H 'content-type: application/json' http://localhost:30193/management/v3/contractnegotiations \
  -s | jq -r '.["@id"]')

echo "Contract Negotiation ID: $contract_negotiation_id"

sleep 10

contract=$(curl -X GET "http://localhost:30193/management/v3/contractnegotiations/${contract_negotiation_id}" \
    --header 'Content-Type: application/json' \
    -s | jq .)

echo "Contract ID: ${contract_id}"

echo "$contract" >> contract.txt

rm -f "${output_file}"
