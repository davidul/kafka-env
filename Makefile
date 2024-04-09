
up:
	$(MAKE) -C docker up

down:
	$(MAKE) -C docker down

cleanup:
	$(MAKE) -C docker cleanup

download-kafka:
	$(MAKE) -C docker download-kafka