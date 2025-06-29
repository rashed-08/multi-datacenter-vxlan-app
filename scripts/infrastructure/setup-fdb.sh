#!/bin/bash
set -e

# Map container name → VXLAN interface
declare -A CONTAINER_TO_VXLAN=(
  ["gateway-dc1"]="vxlan20"
  ["user-nginx"]="vxlan20"
  ["catalog-nginx"]="vxlan20"
  ["order-nginx"]="vxlan20"
  
  ["gateway-dc2"]="vxlan30"
  ["payment-nginx"]="vxlan30"
  ["notify-nginx"]="vxlan30"
  ["order-nginx-replica"]="vxlan30"
  
  ["gateway-dc3"]="vxlan40"
  ["analytics-nginx"]="vxlan40"
  ["discovery-nginx"]="vxlan40"
)

VXLAN_INTERFACES=("vxlan20" "vxlan30" "vxlan40")

declare -A CONTAINER_MACS

echo "Collecting MAC addresses..."

# First collect MACs for all running containers
for container in "${!CONTAINER_TO_VXLAN[@]}"; do
  if docker ps --format '{{.Names}}' | grep -qw "$container"; then
    mac=$(docker exec "$container" cat /sys/class/net/eth0/address 2>/dev/null)
    if [[ -n "$mac" ]]; then
      CONTAINER_MACS[$container]=$mac
    else
      echo "Failed to get MAC for $container"
    fi
  else
    echo "Container $container not running, skipping."
  fi
done

echo ""
echo "Setting FDB entries across all VXLAN interfaces..."

# For each container MAC, add entry to all VXLAN interfaces (except its own)
for container in "${!CONTAINER_MACS[@]}"; do
  mac=${CONTAINER_MACS[$container]}
  container_if=${CONTAINER_TO_VXLAN[$container]}

  for vxlan_if in "${VXLAN_INTERFACES[@]}"; do
    if [[ "$vxlan_if" != "$container_if" ]]; then
      echo "Adding FDB: $mac → $vxlan_if (from $container)"
      sudo bridge fdb replace "$mac" dev "$vxlan_if" dst 127.0.0.1
    fi
  done
done

echo "FDB full mesh setup complete."