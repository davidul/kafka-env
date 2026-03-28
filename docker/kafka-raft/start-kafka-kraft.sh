#!/bin/bash
set -e

CLUSTER_ID=${KAFKA_CLUSTER_ID:-$($KAFKA_HOME/bin/kafka-storage.sh random-uuid)}
ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS:-PLAINTEXT://localhost:9092}

echo "Cluster ID          : $CLUSTER_ID"
echo "Advertised Listeners: $ADVERTISED_LISTENERS"

# Write KRaft server.properties
cat <<EOF > $KAFKA_HOME/config/kraft/server.properties
process.roles=broker,controller
node.id=${KAFKA_NODE_ID:-1}
controller.quorum.voters=${KAFKA_CONTROLLER_QUORUM_VOTERS:-1@localhost:9093}

listeners=${KAFKA_LISTENERS:-PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093}
advertised.listeners=${ADVERTISED_LISTENERS}
inter.broker.listener.name=${KAFKA_INTER_BROKER_LISTENER_NAME:-PLAINTEXT}
controller.listener.names=${KAFKA_CONTROLLER_LISTENER_NAMES:-CONTROLLER}
listener.security.protocol.map=${KAFKA_LISTENER_SECURITY_PROTOCOL_MAP:-CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT}

log.dirs=${KAFKA_LOG_DIRS:-/var/lib/kafka/data}
num.partitions=1
num.network.threads=3
num.io.threads=8

offsets.topic.replication.factor=${KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR:-1}
transaction.state.log.replication.factor=${KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR:-1}
transaction.state.log.min.isr=${KAFKA_TRANSACTION_STATE_LOG_MIN_ISR:-1}
min.insync.replicas=${KAFKA_MIN_INSYNC_REPLICAS:-1}

log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
group.initial.rebalance.delay.ms=0
EOF

# Format storage if not already formatted
if [ ! -f "$KAFKA_LOG_DIRS/meta.properties" ]; then
  echo "Formatting Kafka storage..."
  $KAFKA_HOME/bin/kafka-storage.sh format -t "$CLUSTER_ID" -c $KAFKA_HOME/config/kraft/server.properties
fi

echo "Starting Kafka in KRaft mode..."
exec $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/kraft/server.properties

