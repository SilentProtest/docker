#!/usr/bin/env sh

PREFIX=silentprotest

#set -e

echo "Stopping Containers"
docker stop $(docker ps --format '{{.Names}}' | grep $PREFIX)

echo "Deleting Containers"
docker rm -v $(docker ps -a --format '{{.Names}}' | grep $PREFIX)

echo "Removing Volumes"
docker volume rm $(docker volume ls -q | grep $PREFIX)

