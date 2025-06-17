#!/bin/bash

MEMORY="128m"
CPUS="1"

echo "Deploying DC1 services..."

docker run -d --name gateway-nginx --network dc1-net -p 80:80 --memory="$MEMORY" --cpus="$CPUS" gateway-nginx
docker run -d --name user-nginx --network dc1-net -p 8080:8080 --memory="$MEMORY" --cpus="$CPUS" user-nginx
docker run -d --name catalog-nginx --network dc1-net -p 8081:8081 --memory="$MEMORY" --cpus="$CPUS" catalog-nginx
docker run -d --name order-nginx --network dc1-net -p --memory="$MEMORY" --cpus="$CPUS" 8082:8082 order-nginx

echo "Deploying DC2 services..."

docker run -d --name payment-nginx --network dc2-net -p 8083:8083 --memory="$MEMORY" --cpus="$CPUS" payment-nginx
docker run -d --name notify-nginx --network dc2-net -p 8084:8084 --memory="$MEMORY" --cpus="$CPUS" notify-nginx
docker run -d --name order-nginx-replica --network dc2-net -p 18082:8082 --memory="$MEMORY" --cpus="$CPUS" order-nginx

echo "Deploying DC3 services..."

docker run -d --name analytics-nginx --network dc3-net -p 8085:8085 --memory="$MEMORY" --cpus="$CPUS" analytics-nginx
docker run -d --name discovery-nginx --network dc3-net -p 8500:8500 --memory="$MEMORY" --cpus="$CPUS" discovery-nginx

echo "All services deployed."