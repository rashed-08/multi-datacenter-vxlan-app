#!/bin/bash

set -e

# Load configuration
source configs/network/vxlan-config.sh

echo "Creating Docker networks..."
docker network create --driver bridge --subnet=$DOCKER_DC1_SUBNET dc1-net || true
docker network create --driver bridge --subnet=$DOCKER_DC2_SUBNET dc2-net || true
docker network create --driver bridge --subnet=$DOCKER_DC3_SUBNET dc3-net || true
echo "Docker networks created successfully..."