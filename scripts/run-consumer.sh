THING=$1

if [ -z "$THING" ]; then
  echo "Usage: ./run_consumer.sh <thing>"
  exit 1
fi

java -Dedc.fs.config=transfer/transfer-00-prerequisites/resources/configuration/consumer-${THING}-configuration.properties \
     -jar transfer/transfer-00-prerequisites/connector/build/libs/connector.jar
