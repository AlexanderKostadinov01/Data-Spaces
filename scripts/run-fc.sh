set -e

echo "Building standalone federated catalog with node resolver..."
./gradlew federated-catalog:fc-03-static-node-directory:standalone-fc-with-node-resolver:build

echo "Starting the federated catalog with config from fc-02-standalone..."
java -Dedc.fs.config=federated-catalog/fc-02-standalone/standalone-fc/config.properties \
     -jar federated-catalog/fc-03-static-node-directory/standalone-fc-with-node-resolver/build/libs/standalone-fc-with-node-resolver.jar