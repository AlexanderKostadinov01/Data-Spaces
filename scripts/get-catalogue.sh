CATALOG_PORT=${1:-39195}
QUERY_FILE="federated-catalog/fc-01-embedded/resources/empty-query.json"
OUTPUT_FILE="extracted_policies.json"

echo "Querying catalog on port $CATALOG_PORT..."

curl -d @"$QUERY_FILE" \
     -H "Content-Type: application/json" \
     "http://localhost:${CATALOG_PORT}/api/catalog/v1alpha/catalog/query" \
     -s | jq '[.[] | .["dcat:dataset"]["odrl:hasPolicy"]]' | tee "$OUTPUT_FILE"

echo "Extracted policies saved to $OUTPUT_FILE"