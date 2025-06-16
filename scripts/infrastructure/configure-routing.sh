#!/bin/bash

echo "Adding routing between Docker networks..."

ip route add 10.300.0.0/16 via 10.200.1.1

ip route add 10.400.0.0/16 via 10.200.1.1

ip route add 10.200.0.0/16 via 10.300.1.1

echo "Routing configuration completed."