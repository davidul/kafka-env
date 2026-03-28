# Confluent Platform — Components Explained

The `docker-compose-all-in-one.yml` runs the **Confluent Platform** (v7.9.0), which is Confluent's enterprise distribution built on top of Apache Kafka. It uses **KRaft mode** (no ZooKeeper).

---

## Architecture Overview

```
Clients (producers / consumers)
        │
        ▼
┌─────────────────────────────────────────────────────────────┐
│                        broker:9092                          │
│              confluentinc/cp-kafka  (KRaft)                 │
│  Internal: broker:29092   Controller: broker:29093          │
└──────────────┬──────────────────────────────────────────────┘
               │  broker:29092 (internal Docker network)
       ┌───────┼───────────────────────────────┐
       │       │                               │
       ▼       ▼                               ▼
 schema-    connect                       ksqldb-server
 registry   (Kafka Connect)               (stream SQL)
  :8081      :8083                          :8088
       │       │                               │
       └───────┴───────────────────────────────┘
                        │
                        ▼
               control-center :9021
               (Web UI — monitors everything)
                        │
             ┌──────────┴──────────┐
             ▼                     ▼
        ksql-datagen          rest-proxy
      (test data gen)          :8082
```

---

## Components

### 1. 🟦 `broker` — Kafka Broker (KRaft mode)
**Image:** `confluentinc/cp-kafka:7.9.0`

The core of the platform. Runs as **both broker and controller** (`KAFKA_PROCESS_ROLES: broker,controller`) in KRaft mode — no ZooKeeper needed.

| Listener | Address | Purpose |
|---|---|---|
| `PLAINTEXT` | `broker:29092` | Internal Docker-to-Docker traffic |
| `PLAINTEXT_HOST` | `localhost:9092` | External client access from your host |
| `CONTROLLER` | `broker:29093` | KRaft controller-to-controller/broker communication |

The `CLUSTER_ID` is hardcoded (`MkU3OEVBNTcwNTJENDM2Qk`), meaning storage is **pre-formatted** — no need to run `kafka-storage.sh format` manually.

---

### 2. 🟩 `schema-registry` — Confluent Schema Registry
**Image:** `confluentinc/cp-schema-registry:7.9.0`  **Port:** `8081`

Stores and validates **Avro / Protobuf / JSON Schema** definitions for messages. Producers register schemas; consumers fetch them by ID. Enforces schema compatibility (backward/forward/full).

```
Producer → serialize with schema → Kafka (stores schema ID in message)
Consumer → fetch schema by ID from registry → deserialize
```

---

### 3. 🟨 `connect` — Kafka Connect
**Image:** `cnfldemos/cp-server-connect-datagen:0.6.4-7.6.0`  **Port:** `8083`

A framework for **streaming data in/out of Kafka** without writing code. Connectors are configured via REST API.

- **Source connectors** — pull data _into_ Kafka (databases, files, APIs)
- **Sink connectors** — push data _out of_ Kafka (Elasticsearch, S3, JDBC)

This image includes the **Datagen** source connector, which generates synthetic test data.

Uses monitoring interceptors to report metrics to Control Center.

Internal management topics created automatically:
- `docker-connect-configs`
- `docker-connect-offsets`
- `docker-connect-status`

---

### 4. 🟪 `ksqldb-server` — ksqlDB
**Image:** `confluentinc/cp-ksqldb-server:7.9.0`  **Port:** `8088`

A **SQL engine for Kafka streams**. Lets you query, filter, join, and aggregate Kafka topics using familiar SQL syntax — in real time.

```sql
-- Example: count events per user in a 1-minute window
SELECT user_id, COUNT(*) FROM clicks
  WINDOW TUMBLING (SIZE 1 MINUTE)
  GROUP BY user_id EMIT CHANGES;
```

---

### 5. 🟫 `ksqldb-cli` — ksqlDB CLI
**Image:** `confluentinc/cp-ksqldb-cli:7.9.0`

An interactive **SQL shell** that connects to `ksqldb-server`. Use it with:
```bash
docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
```

---

### 6. 🔶 `ksql-datagen` — Test Data Generator
**Image:** `confluentinc/ksqldb-examples:7.9.0`

Generates **synthetic Kafka messages** (orders, pageviews, users etc.) for testing ksqlDB pipelines. Waits for broker and Schema Registry to be ready before starting (using `cub kafka-ready` / `cub sr-ready`).

---

### 7. 🔴 `control-center` — Confluent Control Center
**Image:** `confluentinc/cp-enterprise-control-center:7.9.0`  **Port:** `9021` → open http://localhost:9021

The **central web UI** for monitoring and managing the entire platform:
- Browse topics, messages, consumer groups, lag
- Manage Kafka Connect connectors
- Run ksqlDB queries
- View Schema Registry schemas
- Monitor broker health and throughput

> ⚠️ Requires a **Confluent enterprise license** for full features (30-day trial included).

---

### 8. 🔵 `rest-proxy` — Kafka REST Proxy
**Image:** `confluentinc/cp-kafka-rest:7.9.0`  **Port:** `8082`

An **HTTP REST API** for producing and consuming Kafka messages without a native Kafka client. Useful for languages/environments without a Kafka library.

```bash
# Produce a message via HTTP
curl -X POST http://localhost:8082/topics/my-topic \
  -H "Content-Type: application/vnd.kafka.json.v2+json" \
  -d '{"records":[{"value":{"name":"Alice"}}]}'
```

---

## Port Summary

| Port | Service | Description |
|---|---|---|
| `9092` | broker | Kafka (external client access) |
| `9101` | broker | JMX metrics |
| `8081` | schema-registry | Schema Registry API |
| `8082` | rest-proxy | Kafka REST API |
| `8083` | connect | Kafka Connect REST API |
| `8088` | ksqldb-server | ksqlDB REST API |
| `9021` | control-center | Web UI |

## Startup Order

```
broker → schema-registry, connect
connect → ksqldb-server, control-center
ksqldb-server → control-center, ksql-datagen, ksqldb-cli
```
