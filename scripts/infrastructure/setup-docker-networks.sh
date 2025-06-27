#!/bin/bash
# setup-docker-network.sh

source configs/network/vxlan-config.sh

echo "Creating Docker networks with VXLAN bridges..."

# Create custom bridge networks using VXLAN bridges
docker network create -d bridge \
  --subnet=$VXLAN_DC1_SUBNET \
  --gateway=$(echo $VXLAN_DC1_GATEWAY | cut -d'/' -f1 | sed 's/0$/1/') \
  --opt com.docker.network.bridge.name=br-dc1 \
  dc1-net || true

docker network create -d bridge \
  --subnet=$VXLAN_DC2_SUBNET \
  --gateway=$(echo $VXLAN_DC2_GATEWAY | cut -d'/' -f1 | sed 's/0$/1/') \
  --opt com.docker.network.bridge.name=br-dc2 \
  dc2-net || true

docker network create -d bridge \
  --subnet=$VXLAN_DC3_SUBNET \
  --gateway=$(echo $VXLAN_DC3_GATEWAY | cut -d'/' -f1 | sed 's/0$/1/') \
  --opt com.docker.network.bridge.name=br-dc3 \
  dc3-net || true

echo "Docker networks with VXLAN bridges created!"