#!/bin/bash
# setup-docker-network.sh

source configs/network/vxlan-config.sh

echo "Creating Docker networks with VXLAN bridges..."

# Create custom bridge networks using VXLAN bridges
docker network create -d bridge \
  --subnet=$DOCKER_DC1_SUBNET \
  --gateway=$(echo $DOCKER_DC1_SUBNET | cut -d'/' -f1 | sed 's/0$/1/') \
  -o com.docker.network.bridge.name=br-dc1 \
  dc1-net || true

docker network create -d bridge \
  --subnet=$DOCKER_DC2_SUBNET \
  --gateway=$(echo $DOCKER_DC2_SUBNET | cut -d'/' -f1 | sed 's/0$/1/') \
  -o com.docker.network.bridge.name=br-dc2 \
  dc2-net || true

docker network create -d bridge \
  --subnet=$DOCKER_DC3_SUBNET \
  --gateway=$(echo $DOCKER_DC3_SUBNET | cut -d'/' -f1 | sed 's/0$/1/') \
  -o com.docker.network.bridge.name=br-dc3 \
  dc3-net || true

echo "Docker networks with VXLAN bridges created!"