#!/bin/bash

if [ -f docker-compose.yml ]; then
    echo "docker-compose.yml already downloaded."
else
    echo "Downloading docker-compose.yml..."
    #wget https://raw.githubusercontent.com/confluentinc/cp-all-in-one/7.9.0-post/cp-all-in-one-kraft/docker-compose.yml
    wget https://raw.githubusercontent.com/confluentinc/cp-all-in-one/7.9.0-post/cp-all-in-one-community/docker-compose.yml
fi

docker compose up -d