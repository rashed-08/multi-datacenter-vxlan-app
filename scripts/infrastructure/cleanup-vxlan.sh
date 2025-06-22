#!/bin/bash

set -e

# Load VXLAN config
source configs/network/vxlan-config.sh

echo "Cleaning up VXLAN interfaces using config..."

# DC1
echo "Removing vxlan${VXLAN_DC1_ID}..."
sudo ip link set vxlan${VXLAN_DC1_ID} nomaster
sudo ip addr del ${VXLAN_DC1_GATEWAY}/16 dev vxlan${VXLAN_DC1_ID} 2>/dev/null || true
sudo ip link del vxlan${VXLAN_DC1_ID} 2>/dev/null || true
sudo ip link delete br-dc1

# DC2
echo "Removing vxlan${VXLAN_DC2_ID}..."
sudo ip link set vxlan${VXLAN_DC2_ID} nomaster
sudo ip addr del ${VXLAN_DC2_GATEWAY}/16 dev vxlan${VXLAN_DC2_ID} 2>/dev/null || true
sudo ip link del vxlan${VXLAN_DC2_ID} 2>/dev/null || true
sudo ip link delete br-dc2

# DC3
echo "Removing vxlan${VXLAN_DC3_ID}..."
sudo ip link set vxlan${VXLAN_DC3_ID} nomaster
sudo ip addr del ${VXLAN_DC3_GATEWAY}/16 dev vxlan${VXLAN_DC3_ID} 2>/dev/null || true
sudo ip link del vxlan${VXLAN_DC3_ID} 2>/dev/null || 
sudo ip link delete br-dc3

# Remove routes (if added)
echo "Cleaning up VXLAN static routes..."
sudo ip route del 10.30.0.0/16 via ${VXLAN_DC1_GATEWAY} 2>/dev/null || true
sudo ip route del 10.40.0.0/16 via ${VXLAN_DC1_GATEWAY} 2>/dev/null || true

sudo ip route del 10.20.0.0/16 via ${VXLAN_DC2_GATEWAY} 2>/dev/null || true
sudo ip route del 10.40.0.0/16 via ${VXLAN_DC2_GATEWAY} 2>/dev/null || true

sudo ip route del 10.20.0.0/16 via ${VXLAN_DC3_GATEWAY} 2>/dev/null || true
sudo ip route del 10.30.0.0/16 via ${VXLAN_DC3_GATEWAY} 2>/dev/null || true

echo "VXLAN interfaces:"
ip link show | grep -E "(vxlan${VXLAN_DC1_ID}|vxlan${VXLAN_DC2_ID}|vxlan${VXLAN_DC3_ID})" || echo "No VXLAN interfaces found"

echo "Bridge interfaces:"
ip link show | grep -E "(br-dc1|br-dc2|br-dc3)" || echo "No bridge interfaces found"

echo "VXLAN cleanup complete."