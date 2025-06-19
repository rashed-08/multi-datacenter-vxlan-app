#!/bin/bash

# Project root directory
mkdir -p microservices-vxlan-project && cd microservices-vxlan-project

# Top-level files
touch Makefile README.md

# architecture docs
mkdir -p architecture
touch architecture/network-topology.md
touch architecture/service-architecture.md
touch architecture/deployment-strategy.md

# dockerfiles
mkdir -p dockerfiles
touch dockerfiles/Dockerfile.gateway-nginx
touch dockerfiles/Dockerfile.user-nginx
touch dockerfiles/Dockerfile.catalog-nginx
touch dockerfiles/Dockerfile.order-nginx
touch dockerfiles/Dockerfile.payment-nginx
touch dockerfiles/Dockerfile.notify-nginx
touch dockerfiles/Dockerfile.analytics-nginx
touch dockerfiles/Dockerfile.discovery-nginx

# configs
mkdir -p configs/nginx
touch configs/nginx/gateway-nginx.conf

mkdir -p configs/network
touch configs/network/vxlan-config.sh
touch configs/network/routing-tables.conf
touch configs/network/firewall-rules.sh

# data
mkdir -p data/service-responses/user-nginx
mkdir -p data/service-responses/catalog-nginx
mkdir -p data/service-responses/order-nginx
mkdir -p data/service-responses/payment-nginx
mkdir -p data/service-responses/notify-nginx
mkdir -p data/service-responses/analytics-nginx
mkdir -p data/sample-datasets

# scripts
mkdir -p scripts/infrastructure
touch scripts/infrastructure/setup-vxlan.sh
touch scripts/infrastructure/configure-routing.sh
touch scripts/infrastructure/network-diagnostics.sh

mkdir -p scripts/deployment
touch scripts/deployment/deploy-services.sh

# docs
mkdir -p docs
touch docs/setup-guide.md
touch docs/troubleshooting.md

echo "Project structure created successfully."
