#!/bin/bash

echo "Removing custom Docker networks..."

docker network rm dc1-net 2>/dev/null || echo "dc1-net not found."
docker network rm dc2-net 2>/dev/null || echo "dc2-net not found."
docker network rm dc3-net 2>/dev/null || echo "dc3-net not found."

echo "Docker networks removed successfully."