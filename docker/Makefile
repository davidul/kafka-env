include .env

build-kafka: download-kafka
	docker build -t $(KAFKA_IMAGE) --build-arg="KAFKA_VERSION=$(KAFKA_VERSION)" --build-arg="SCALA_VERSION=$(SCALA_VERSION)" -f kafka/Dockerfile kafka

build-kafka-raft: download-kafka
	docker build -t $(KAFKA_RAFT_IMAGE) --build-arg="KAFKA_VERSION=$(KAFKA_VERSION)" --build-arg="SCALA_VERSION=$(SCALA_VERSION)" -f kafka-raft/Dockerfile kafka-raft

download-kafka:
	./download-kafka.sh

up: build-kafka
	docker compose up

up-raft: build-kafka-raft
	docker run -d --name kafka-raft -p 9092:9092 -p 9093:9093 $(KAFKA_RAFT_IMAGE)

down:
	docker compose down

cleanup:
	docker compose rm --force --stop

remove:
	docker rm zookeeper-1 zookeeper-2 kafka