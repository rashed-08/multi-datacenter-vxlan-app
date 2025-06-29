#!/bin/bash

# Get discovery-nginx IP (Consul Agent)
CONSUL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' discovery-nginx)

echo "Registering services to Consul at $CONSUL_IP"

# Helper function to register a service
register_service() {
  local NAME=$1
  local CONTAINER=$2
  local PORT=$3
  local HEALTH_PORT=${4:-$PORT}

  SERVICE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER")

  curl -s -X PUT "http://${CONSUL_IP}:8500/v1/agent/service/register" \
    -H "Content-Type: application/json" \
    -d "{
      \"Name\": \"${NAME}\",
      \"ID\": \"${NAME}\",
      \"Address\": \"${SERVICE_IP}\",
      \"Port\": ${PORT},
      \"Check\": {
        \"HTTP\": \"http://${SERVICE_IP}:${HEALTH_PORT}/health\",
        \"Interval\": \"10s\"
      }
    }"

  echo "Registered $NAME at $SERVICE_IP:$PORT"
}

# Register all services
register_service gateway-dc1 gateway-dc1 80
register_service gateway-dc2 gateway-dc2 19090
register_service gateway-dc3 gateway-dc3 19091
register_service user-nginx user-nginx 8080
register_service catalog-nginx catalog-nginx 8081
register_service order-nginx order-nginx 8082
register_service order-nginx-replica order-nginx-replica 8082 18082
register_service payment-nginx payment-nginx 8083
register_service notify-nginx notify-nginx 8084
register_service analytics-nginx analytics-nginx 8085

# Register discovery-nginx itself (optional)
DISCOVERY_NGINX_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' discovery-nginx)

curl -s -X PUT "http://${CONSUL_IP}:8500/v1/agent/service/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"Name\": \"discovery-nginx\",
    \"ID\": \"discovery-nginx\",
    \"Address\": \"${DISCOVERY_NGINX_IP}\",
    \"Port\": 8500,
    \"Check\": {
      \"HTTP\": \"http://${DISCOVERY_NGINX_IP}:8500/v1/agent/self\",
      \"Interval\": \"10s\"
    }
  }"

echo "All services registered to Consul."