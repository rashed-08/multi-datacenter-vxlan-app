#!/bin/bash

set -e

# Load configuration
source configs/network/vxlan-config.sh

echo "Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    echo "Docker not installed"
    exit 1
fi

if ! ip link show "$PHYSICAL_INTERFACE" > /dev/null 2>&1; then
    echo "Interface $PHYSICAL_INTERFACE not found"
    exit 1
fi

echo "Configuring VXLAN interfaces..."

# DC
sudo ip link add vxlan${VXLAN_DC1_ID} type vxlan id $VXLAN_DC1_ID dev $PHYSICAL_INTERFACE dstport $VXLAN_PORT local ${HOST_DC1_IP} nolearning || true
sudo ip link set vxlan${VXLAN_DC1_ID} up
sudo ip link set mtu 1450 dev vxlan${VXLAN_DC1_ID}

# DC2
sudo ip link add vxlan${VXLAN_DC2_ID} type vxlan id $VXLAN_DC2_ID dev $PHYSICAL_INTERFACE dstport $VXLAN_PORT local ${HOST_DC2_IP} nolearning || true
sudo ip link set vxlan${VXLAN_DC2_ID} up
sudo ip link set mtu 1450 dev vxlan${VXLAN_DC2_ID}

# DC3
sudo ip link add vxlan${VXLAN_DC3_ID} type vxlan id $VXLAN_DC3_ID dev $PHYSICAL_INTERFACE dstport $VXLAN_PORT local ${HOST_DC3_IP} nolearning || true
sudo ip link set vxlan${VXLAN_DC3_ID} up
sudo ip link set mtu 1450 dev vxlan${VXLAN_DC3_ID}

echo "VXLAN interfaces created using config file!"