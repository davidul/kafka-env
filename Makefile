include docker/.env

up:
	$(MAKE) -C docker up

up-raft:
	$(MAKE) -C docker up-raft

down:
	$(MAKE) -C docker down

cleanup:
	$(MAKE) -C docker cleanup

download-kafka:
	$(MAKE) -C docker download-kafka

list-queues:
	docker exec -it ${KAFKA_CONTAINER_NAME} /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server 172.18.0.3:9092


confluent:
	$(MAKE) -C docker/confluent up