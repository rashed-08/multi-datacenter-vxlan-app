#!/bin/bash

set -e

# Load configuration
source configs/network/vxlan-config.sh

echo "Configuring VXLAN interfaces..."

# DC1
sudo ip link add vxlan${VXLAN_DC1_ID} type vxlan id $VXLAN_DC1_ID dev enp0s1 dstport $VXLAN_PORT group $VXLAN_GROUP || true
sudo ip addr add $VXLAN_DC1_GATEWAY/16 dev vxlan${VXLAN_DC1_ID} || true
sudo ip link set vxlan${VXLAN_DC1_ID} mtu 1450
sudo ip link set vxlan${VXLAN_DC1_ID} up

# DC2
sudo ip link add vxlan${VXLAN_DC2_ID} type vxlan id $VXLAN_DC2_ID dev enp0s1 dstport $VXLAN_PORT group $VXLAN_GROUP || true
sudo ip addr add $VXLAN_DC2_GATEWAY/16 dev vxlan${VXLAN_DC2_ID} || true
sudo ip link set vxlan${VXLAN_DC2_ID} mtu 1450
sudo ip link set vxlan${VXLAN_DC2_ID} up

# DC3
sudo ip link add vxlan${VXLAN_DC3_ID} type vxlan id $VXLAN_DC3_ID dev enp0s1 dstport $VXLAN_PORT group $VXLAN_GROUP || true
sudo ip addr add $VXLAN_DC3_GATEWAY/16 dev vxlan${VXLAN_DC3_ID} || true
sudo ip link set vxlan${VXLAN_DC3_ID} mtu 1450
sudo ip link set vxlan${VXLAN_DC3_ID} up

echo "VXLAN interfaces created using config file!"