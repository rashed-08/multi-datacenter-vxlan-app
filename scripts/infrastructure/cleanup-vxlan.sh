#!/bin/bash

echo "Cleaning up VXLAN interfaces..."

sudo ip addr del 10.200.1.1/16 dev vxlan200 2>/dev/null
sudo ip addr del 10.300.1.1/16 dev vxlan300 2>/dev/null
sudo ip addr del 10.400.1.1/16 dev vxlan400 2>/dev/null

sudo ip link del vxlan200 2>/dev/null
sudo ip link del vxlan300 2>/dev/null
sudo ip link del vxlan400 2>/dev/null

sudo ip route del 10.300.0.0/16 via 10.200.1.1 2>/dev/null
sudo ip route del 10.400.0.0/16 via 10.200.1.1 2>/dev/null

echo "VXLAN interfaces cleaned up successfully."