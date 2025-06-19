#!/bin/bash

echo "Running network diagnostics..."

echo "Docker network list:"
docker network ls

echo "Inspecting dc1-net:"
docker network inspect dc1-net | grep Subnet || true

echo "Inspecting dc2-net:"
docker network inspect dc2-net | grep Subnet || true

echo "Inspecting dc3-net:"
docker network inspect dc3-net | grep Subnet || true

echo "Ping test from host to DC1 gateway..."
ping -c 3 10.20.1.1 || echo "Failed to reach DC1 gateway"

echo "Ping test to sample container (if known IP)..."
ping -c 3 10.20.5.10 || echo "Failed to reach container"

for svc in user-nginx catalog-nginx gateway-nginx; do
  if docker ps --format '{{.Names}}' | grep -q $svc; then
    echo "$svc is running"
    docker exec $svc ping -c 2 127.0.0.1 || true
  else
    echo "$svc is not running"
  fi
done

echo "Diagnostics complete."