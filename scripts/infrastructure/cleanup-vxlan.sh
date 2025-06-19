#!/bin/bash

set -e

# Load VXLAN config
source configs/network/vxlan-config.sh

echo "[🧹] Cleaning up VXLAN interfaces using config..."

# DC1
echo "→ Removing vxlan${VXLAN_DC1_ID}..."
sudo ip addr del ${VXLAN_DC1_GATEWAY}/16 dev vxlan${VXLAN_DC1_ID} 2>/dev/null || true
sudo ip link del vxlan${VXLAN_DC1_ID} 2>/dev/null || true

# DC2
echo "→ Removing vxlan${VXLAN_DC2_ID}..."
sudo ip addr del ${VXLAN_DC2_GATEWAY}/16 dev vxlan${VXLAN_DC2_ID} 2>/dev/null || true
sudo ip link del vxlan${VXLAN_DC2_ID} 2>/dev/null || true

# DC3
echo "→ Removing vxlan${VXLAN_DC3_ID}..."
sudo ip addr del ${VXLAN_DC3_GATEWAY}/16 dev vxlan${VXLAN_DC3_ID} 2>/dev/null || true
sudo ip link del vxlan${VXLAN_DC3_ID} 2>/dev/null || true

# Remove routes (if added)
echo "→ Cleaning up VXLAN static routes..."
sudo ip route del 10.300.0.0/16 via ${VXLAN_DC1_GATEWAY} 2>/dev/null || true
sudo ip route del 10.400.0.0/16 via ${VXLAN_DC1_GATEWAY} 2>/dev/null || true

sudo ip route del 10.200.0.0/16 via ${VXLAN_DC2_GATEWAY} 2>/dev/null || true
sudo ip route del 10.400.0.0/16 via ${VXLAN_DC2_GATEWAY} 2>/dev/null || true

sudo ip route del 10.200.0.0/16 via ${VXLAN_DC3_GATEWAY} 2>/dev/null || true
sudo ip route del 10.300.0.0/16 via ${VXLAN_DC3_GATEWAY} 2>/dev/null || true

echo "VXLAN cleanup complete."