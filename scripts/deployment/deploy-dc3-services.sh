#!/bin/bash

MEMORY="128m"
CPUS="1"

echo "Deploying DC3 services..."

docker run -d --name gateway-dc3 --network dc3-net -p 19091:80 --memory="$MEMORY" --cpus="$CPUS" gateway-nginx:dc3
docker run -d --name analytics-nginx --network dc3-net -p 8085:8085 --memory="$MEMORY" --cpus="$CPUS" analytics-nginx
docker run -d --name discovery-nginx --network dc3-net -p 8500:8500 consul agent -dev -client=0.0.0.0 -ui

echo "All services deployed."