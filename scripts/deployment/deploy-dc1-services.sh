#!/bin/bash

MEMORY="128m"
CPUS="1"

echo "Deploying DC1 services..."
docker run -d --name gateway-dc1 --network dc1-net -p 80:80 --memory="$MEMORY" --cpus="$CPUS" gateway-nginx:dc1
docker run -d --name user-nginx --network dc1-net -p 8080:8080 --memory="$MEMORY" --cpus="$CPUS" user-nginx
docker run -d --name catalog-nginx --network dc1-net -p 8081:8081 --memory="$MEMORY" --cpus="$CPUS" catalog-nginx
docker run -d --name order-nginx --network dc1-net -p 8082:8082 --memory="$MEMORY" --cpus="$CPUS"  order-nginx
echo "All services deployed."