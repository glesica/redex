#!/bin/sh

HOST_PORT=9876
CONTAINER_NAME=redex

docker build -t $CONTAINER_NAME .
docker run -d -p 127.0.0.1:$HOST_PORT:6379 redex

