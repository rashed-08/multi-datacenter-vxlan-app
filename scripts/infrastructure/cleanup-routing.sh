#!/bin/bash

ROUTING_FILE="configs/network/routing-tables.conf"

echo "Cleaning up static routes from $ROUTING_FILE..."

if [ ! -f "$ROUTING_FILE" ]; then
  echo "Routing config file not found."
  exit 1
fi

while read -r line; do
  # Skip blank lines or comments
  [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

  # Read values
  SRC_DC=$(echo "$line" | awk '{print $1}')
  DEST_SUBNET=$(echo "$line" | awk '{print $2}')
  NEXT_HOP=$(echo "$line" | awk '{print $3}')

  echo "→ Deleting route to $DEST_SUBNET via $NEXT_HOP"
  sudo ip route del "$DEST_SUBNET" via "$NEXT_HOP" 2>/dev/null || \
    echo "Route not found or already removed: $DEST_SUBNET"

done < "$ROUTING_FILE"

echo "Routing cleanup complete."