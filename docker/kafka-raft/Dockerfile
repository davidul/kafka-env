# Use an official OpenJDK runtime as a parent image
FROM openjdk:26-slim-trixie

ARG KAFKA_VERSION=4.1.0
ARG SCALA_VERSION=2.13

# Set environment variables for Kafka
ENV KAFKA_HOME=/opt/kafka
ENV KAFKA_NODE_ID=1
ENV KAFKA_BROKER_ID=1
ENV KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
ENV KAFKA_LOG_DIRS=/var/lib/kafka/data
ENV KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
ENV KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1
ENV KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1
ENV KAFKA_MIN_INSYNC_REPLICAS=1
ENV KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093
ENV KAFKA_PROCESS_ROLES=broker,controller
ENV KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER
ENV KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
ENV KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT
ENV PATH=${PATH}:/opt/kafka/bin

# Download and extract Kafka
RUN apt-get update && apt-get install -y wget bash \
    && wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    && tar -xzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
    && mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
    && rm kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    && apt-get clean

# Create Kafka data directory
RUN mkdir -p /var/lib/kafka/data

# Copy and register startup script
COPY start-kafka-kraft.sh /usr/local/bin/start-kafka-kraft.sh
RUN chmod +x /usr/local/bin/start-kafka-kraft.sh

# Expose broker and controller ports
EXPOSE 9092 9093

CMD ["start-kafka-kraft.sh"]
