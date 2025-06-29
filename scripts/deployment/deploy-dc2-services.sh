#!/bin/bash

MEMORY="128m"
CPUS="1"

echo "Deploying DC2 services..."

docker run -d --name gateway-dc2 --network dc2-net -p 19090:80 --memory="$MEMORY" --cpus="$CPUS" gateway-nginx:dc2
docker run -d --name payment-nginx --network dc2-net -p 8083:8083 --memory="$MEMORY" --cpus="$CPUS" payment-nginx
docker run -d --name notify-nginx --network dc2-net -p 8084:8084 --memory="$MEMORY" --cpus="$CPUS" notify-nginx
docker run -d --name order-nginx-replica --network dc2-net -p 18082:8082 --memory="$MEMORY" --cpus="$CPUS" order-nginx

echo "All services deployed."