#!/bin/bash

echo "Applying firewall rules..."

# Allow VXLAN UDP traffic (port 4789)
iptables -C INPUT -p udp --dport 4789 -j ACCEPT 2>/dev/null  || sudo iptables -A INPUT -p udp --dport 4789 -j ACCEPT
sudo sysctl -w net.bridge.bridge-nf-call-iptables=0
sudo sysctl -w net.bridge.bridge-nf-call-arptables=0
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -D DOCKER-ISOLATION-STAGE-2 -o br-dc1 -j DROP 2>/dev/null || true
sudo iptables -D DOCKER-ISOLATION-STAGE-2 -o br-dc2 -j DROP 2>/dev/null || true
sudo iptables -D DOCKER-ISOLATION-STAGE-2 -o br-dc3 -j DROP 2>/dev/null || true

# Allow internal Docker network ranges (simulated DC subnets)
sudo iptables -A INPUT -s 10.20.0.0/16 -j ACCEPT
sudo iptables -A INPUT -s 10.30.0.0/16 -j ACCEPT
sudo iptables -A INPUT -s 10.40.0.0/16 -j ACCEPT

# Optional: allow loopback & local
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -I DOCKER-USER -j ACCEPT

# Optional: drop everything else (only if needed)
# sudo iptables -P INPUT DROP

echo "Firewall rules applied."