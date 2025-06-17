#!/bin/bash

set -e

# Step 1: Load configuration
source configs/network/vxlan-config.sh

echo "Creating Docker networks..."
docker network create --driver bridge --subnet=$VXLAN_DC1_SUBNET dc1-net || true
docker network create --driver bridge --subnet=$VXLAN_DC2_SUBNET dc2-net || true
docker network create --driver bridge --subnet=$VXLAN_DC3_SUBNET dc3-net || true

echo "Configuring VXLAN interfaces..."

# DC1
sudo ip link add vxlan${VXLAN_DC1_ID} type vxlan id $VXLAN_DC1_ID dev eth0 dstport $VXLAN_PORT group $VXLAN_GROUP || true
sudo ip addr add $VXLAN_DC1_GATEWAY/16 dev vxlan${VXLAN_DC1_ID} || true
sudo ip link set vxlan${VXLAN_DC1_ID} mtu 1450
sudo ip link set vxlan${VXLAN_DC1_ID} up

# DC2
sudo ip link add vxlan${VXLAN_DC2_ID} type vxlan id $VXLAN_DC2_ID dev eth0 dstport $VXLAN_PORT group $VXLAN_GROUP || true
sudo ip addr add $VXLAN_DC2_GATEWAY/16 dev vxlan${VXLAN_DC2_ID} || true
sudo ip link set vxlan${VXLAN_DC2_ID} mtu 1450
sudo ip link set vxlan${VXLAN_DC2_ID} up

# DC3
sudo ip link add vxlan${VXLAN_DC3_ID} type vxlan id $VXLAN_DC3_ID dev eth0 dstport $VXLAN_PORT group $VXLAN_GROUP || true
sudo ip addr add $VXLAN_DC3_GATEWAY/16 dev vxlan${VXLAN_DC3_ID} || true
sudo ip link set vxlan${VXLAN_DC3_ID} mtu 1450
sudo ip link set vxlan${VXLAN_DC3_ID} up

echo "[✅] VXLAN interfaces created using config file!"