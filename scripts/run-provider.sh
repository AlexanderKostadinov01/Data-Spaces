THING=$1

if [ -z "$THING" ]; then
  echo "Usage: ./run_provider.sh <thing>"
  exit 1
fi

java -Dedc.fs.config=transfer/transfer-00-prerequisites/resources/configuration/provider-${THING}-configuration.properties \
     -jar transfer/transfer-03-consumer-pull/provider-proxy-data-plane/build/libs/connector.jar
