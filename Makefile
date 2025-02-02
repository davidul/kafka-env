
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