#!/bin/bash

source .env

KAFKA_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${KAFKA_CONTAINER_NAME})

echo "Kafka container IP: ${KAFKA_IP}"
