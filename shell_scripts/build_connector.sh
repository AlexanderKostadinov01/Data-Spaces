#!/bin/bash

echo "Building connector..."
./gradlew transfer:transfer-00-prerequisites:connector:build
echo "Connector successfully created in directory /connector/build/lib/connector.jar"