#!/bin/bash

CONSUMER_TYPE=$1

if [ -z "$CONSUMER_TYPE" ]; then
    echo "Error: use connetor consumer as follows: ./run_connector_consumer.sh {CONSUMER_TYPE}"
    exit 1
fi

java -Dedc.fs.config=transfer/transfer-00-prerequisites/resources/configuration/consumer-${CONSUMER_TYPE}-configuration.properties \
     -jar transfer/transfer-00-prerequisites/connector/build/libs/connector.jar