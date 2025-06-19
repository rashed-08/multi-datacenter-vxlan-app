# Infrastructure
setup-infrastructure:
	@echo "Setting up full infrastructure..."
	bash scripts/infrastructure/setup-vxlan.sh
	bash scripts/infrastructure/configure-routing.sh
	bash scripts/infrastructure/setup-docker-networks.sh
setup-vxlan-mesh:
	@echo "Creating VXLAN mesh across DCs..."
	bash scripts/infrastructure/setup-vxlan.sh
setup-docker-networks:
	@echo "Creating Docker Network..."
	bash scripts/infrastructure/setup-docker-networks.sh
cleanup-infrastructure:
	@echo "Cleaning entire infrastructure..."
	bash scripts/infrastructure/cleanup-vxlan.sh
	bash scripts/infrastructure/cleanup-routing.sh
	bash scripts/infrastructure/cleanup-docker-networks.sh
cleanup-vxlan:
	@echo "Cleaning VXLAN interfaces only..."
	bash scripts/infrastructure/cleanup-vxlan.sh
cleanup-routing:
	@echo "Cleaning routing..."
	bash scripts/infrastructure/cleanup-routing.sh
cleanup-docker-network:
	bash scripts/infrastructure/cleanup-docker-networks.sh
show-network-status:
	@echo "Showing active VXLAN & Docker interfaces..."
	ip link show | grep vxlan || true
	docker network ls
show-routing-table:
	@echo "Current routing table:"
	ip route show
validate-infrastructure:
	@echo "Validating connectivity and interfaces..."
	ping -c 2 10.10.1.1 || echo "⚠️ DC1 gateway unreachable"
	ping -c 2 10.20.1.1 || echo "⚠️ DC2 gateway unreachable"
	ping -c 2 10.30.1.1 || echo "⚠️ DC3 gateway unreachable"

# Build
build-all-images: build-user build-catalog build-gateway build-order build-payment build-notify build-analytics build-discovery

build-user:
	docker build -f dockerfiles/Dockerfile.user-nginx -t user-nginx .
build-catalog:
	docker build -f dockerfiles/Dockerfile.catalog-nginx -t catalog-nginx .
build-gateway:
	docker build -f dockerfiles/Dockerfile.gateway-nginx -t gateway-nginx:dc1 --build-arg HTML_PATH=data/service-responses/gateway-nginx-dc1/index.html .
	docker build -f dockerfiles/Dockerfile.gateway-nginx -t gateway-nginx:dc2 --build-arg HTML_PATH=data/service-responses/gateway-nginx-dc2/index.html .
	docker build -f dockerfiles/Dockerfile.gateway-nginx -t gateway-nginx:dc3 --build-arg HTML_PATH=data/service-responses/gateway-nginx-dc3/index.html .
build-order:
	docker build -f dockerfiles/Dockerfile.order-nginx -t order-nginx .
build-payment:
	docker build -f dockerfiles/Dockerfile.payment-nginx -t payment-nginx .
build-notify:
	docker build -f dockerfiles/Dockerfile.notify-nginx -t notify-nginx .
build-analytics:
	docker build -f dockerfiles/Dockerfile.analytics-nginx -t analytics-nginx .
build-discovery:
	docker build -f dockerfiles/Dockerfile.discovery-nginx -t discovery-nginx .

# Deploy
deploy-services: deploy-dc1-services deploy-dc2-services deploy-dc3-services

deploy-dc1-services:
	bash scripts/deployment/deploy-dc1-services.sh
deploy-dc2-services:
	bash scripts/deployment/deploy-dc2-services.sh
deploy-dc3-services:
	bash scripts/deployment/deploy-dc3-services.sh

stop-services:
	docker stop $$(docker ps -q)
start-services:
	docker start $$(docker ps -aq)
cleanup-services:
	docker rm -f $$(docker ps -a -q)
	docker rmi -f user-nginx catalog-nginx gateway-nginx:dc1 gateway-nginx:dc2 gateway-nginx:dc3 order-nginx payment-nginx notify-nginx analytics-nginx discovery-nginx || true

# Testing
test-connectivity:
	ping -c 2 10.20.1.1
test-services:
	curl -f http://localhost:8080/users.json || echo "User service"
	curl -f http://localhost:8081/products.json || echo "Catalog service"