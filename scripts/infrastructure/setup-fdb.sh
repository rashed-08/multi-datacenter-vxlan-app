#!/bin/bash
set -e

# Map container name → vxlan interface name
declare -A CONTAINER_TO_VXLAN=(
  # DC1 services (dc1-net uses vxlan20)
  ["gateway-dc1"]="vxlan20"
  ["gateway-dc2"]="vxlan20"         # Note: same network dc1-net
  ["gateway-dc3"]="vxlan20"
  ["user-nginx"]="vxlan20"
  ["catalog-nginx"]="vxlan20"
  ["order-nginx"]="vxlan20"

  # DC2 services (dc2-net uses vxlan30)
  ["payment-nginx"]="vxlan30"
  ["notify-nginx"]="vxlan30"
  ["order-nginx-replica"]="vxlan30"

  # DC3 services (dc3-net uses vxlan40)
  ["analytics-nginx"]="vxlan40"
  ["discovery-nginx"]="vxlan40"
)

echo "Starting FDB setup..."

for container in "${!CONTAINER_TO_VXLAN[@]}"; do
  vxlan_if=${CONTAINER_TO_VXLAN[$container]}

  # Check if container running
  if ! docker ps --format '{{.Names}}' | grep -qw "$container"; then
    echo "Container $container not running, skipping."
    continue
  fi

  # Get MAC address
  mac=$(docker exec "$container" cat /sys/class/net/eth0/address 2>/dev/null)
  if [[ -z "$mac" ]]; then
    echo "Failed to get MAC for $container, skipping."
    continue
  fi

  echo "Adding/replacing FDB entry: MAC=$mac on interface=$vxlan_if for container=$container"
  sudo bridge fdb replace "$mac" dev "$vxlan_if" dst 127.0.0.1
done

echo "FDB setup complete."