#!/bin/bash

PROVIDER_TYPE=$1

if [ -z "$PROVIDER_TYPE" ]; then
    echo "Error: use connetor provider as follows: ./run_connector_provider.sh {PROVIDER_TYPE}"
    exit 1
fi

java -Dedc.fs.config=transfer/transfer-00-prerequisites/resources/configuration/provider-${PROVIDER_TYPE}-configuration.properties \
     -jar transfer/transfer-00-prerequisites/connector/build/libs/connector.jar