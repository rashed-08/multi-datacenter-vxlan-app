#!/bin/bash

echo "Applying firewall rules..."

# Allow VXLAN UDP traffic (port 4789)
sudo iptables -A INPUT -p udp --dport 4789 -j ACCEPT

# Allow internal Docker network ranges (simulated DC subnets)
sudo iptables -A INPUT -s 10.20.0.0/16 -j ACCEPT
sudo iptables -A INPUT -s 10.30.0.0/16 -j ACCEPT
sudo iptables -A INPUT -s 10.40.0.0/16 -j ACCEPT

# Optional: allow loopback & local
sudo iptables -A INPUT -i lo -j ACCEPT

# Optional: drop everything else (only if needed)
# sudo iptables -P INPUT DROP

echo "Firewall rules applied."