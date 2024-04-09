#!/bin/bash

set -o allexport
source .env
set +o allexport

if [ -f kafka/${KAFKA_ARCHIVE} ]; then
		echo "Kafka ${KAFKA_ARCHIVE} already downloaded."
else
		echo "Downloading Kafka ${KAFKA_ARCHIVE}..."
		wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -P kafka
fi
