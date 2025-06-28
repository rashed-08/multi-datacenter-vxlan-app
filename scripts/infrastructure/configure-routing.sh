#!/bin/bash

ROUTING_FILE="configs/network/routing-tables.conf"

if [ ! -f "$ROUTING_FILE" ]; then
  echo "Routing table file not found: $ROUTING_FILE"
  exit 1
fi

while read -r line; do
  # Skip empty lines or comments
  [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

  # Read values from each line
  SRC_DC=$(echo "$line" | awk '{print $1}')
  DEST_SUBNET=$(echo "$line" | awk '{print $2}')
  NEXT_HOP=$(echo "$line" | awk '{print $3}')

  echo "Adding route: $DEST_SUBNET via $NEXT_HOP (from $SRC_DC)"
  sudo ip route replace "$DEST_SUBNET" via "$NEXT_HOP" 2>/dev/null || \
  echo "Route may already exist or failed for: $DEST_SUBNET"

done < "$ROUTING_FILE"

echo "Routing setup complete."