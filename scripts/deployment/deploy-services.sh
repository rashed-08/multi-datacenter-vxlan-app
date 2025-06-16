#!/bin/bash

echo "Deploying DC1 services..."

docker run -d --name gateway-nginx --network dc1-net -p 80:80 gateway-nginx
docker run -d --name user-nginx --network dc1-net -p 8080:8080 user-nginx
docker run -d --name catalog-nginx --network dc1-net -p 8081:8081 catalog-nginx
docker run -d --name order-nginx --network dc1-net -p 8082:8082 order-nginx

echo "Deploying DC2 services..."

docker run -d --name payment-nginx --network dc2-net -p 8083:8083 payment-nginx
docker run -d --name notify-nginx --network dc2-net -p 8084:8084 notify-nginx
docker run -d --name order-nginx-replica --network dc2-net -p 18082:8082 order-nginx

echo "Deploying DC3 services..."

docker run -d --name analytics-nginx --network dc3-net -p 8085:8085 analytics-nginx
docker run -d --name discovery-nginx --network dc3-net -p 8500:8500 discovery-nginx

echo "All services deployed."