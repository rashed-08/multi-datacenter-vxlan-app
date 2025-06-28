#!/bin/bash
set -e

echo "Generating HAProxy config from live container IPs..."

ORDER_DC1_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' order-nginx)
ORDER_DC2_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' order-nginx-replica)

cat <<EOF > services/haproxy-lb/haproxy.cfg
global
    daemon
    maxconn 256

defaults
    mode http
    timeout connect 5s
    timeout client  50s
    timeout server  50s

frontend http_front
    bind *:80
    default_backend order_service

backend order_service
    balance roundrobin
    option httpchk GET /health
    server order-dc1 $ORDER_DC1_IP:80 check
    server order-dc2 $ORDER_DC2_IP:80 check
EOF

echo "HAProxy config written with IPs: $ORDER_DC1_IP and $ORDER_DC2_IP"