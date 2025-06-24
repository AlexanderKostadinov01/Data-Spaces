if (( $# % 2 != 0 )); then
  echo "Usage: $0 <name1> <port1> <name2> <port2> ..."
  exit 1
fi

OUTPUT="["

# Loop through arguments two at a time
for ((i=1; i<=$#; i+=2)); do
  NAME="${!i}"
  j=$((i+1))
  PORT="${!j}"
  URL="http://localhost:${PORT}/protocol"

  echo "Checking $NAME on port $PORT..."

  if curl --silent --max-time 2 "$URL" > /dev/null; then
    echo "  ➤ Active"
    ENTRY=$(cat <<EOF
{
  "name": "https://w3id.org/edc/v0.0.1/ns/",
  "id": "provider-${NAME}",
  "url": "${URL}",
  "supportedProtocols": ["dataspace-protocol-http"]
}
EOF
)
    if [[ "$OUTPUT" != "[" ]]; then
      OUTPUT+=","
    fi
    OUTPUT+="$ENTRY"
  else
    echo "Inactive"
  fi
done

OUTPUT+="]"

# Output the final JSON
echo "$OUTPUT" >  'federated-catalog\fc-03-static-node-directory\target-node-resolver\src\main\resources\participants.json'