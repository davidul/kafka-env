include .env

build-kafka: download-kafka
	docker build -t $(KAFKA_IMAGE) --build-arg="KAFKA_VERSION=$(KAFKA_VERSION)" --build-arg="SCALA_VERSION=$(SCALA_VERSION)" -f kafka/Dockerfile kafka

download-kafka:
	./download-kafka.sh

up: build-kafka
	docker-compose up

down:
	docker-compose down

cleanup:
	docker-compose rm --force --stop

remove:
	docker rm zookeeper-1 zookeeper-2 kafka