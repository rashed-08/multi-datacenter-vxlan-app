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
	ping -c 2 10.10.1.1 || echo "DC1 gateway unreachable"
	ping -c 2 10.20.1.1 || echo "DC2 gateway unreachable"
	ping -c 2 10.30.1.1 || echo "DC3 gateway unreachable"

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
test: test-connectivity test-services test-cross-dc health-check

test-connectivity:
	@echo "Pinging Gateways & Services (VXLAN Gateway IPs)"
	ping -c 1 10.20.1.1 || echo "DC1 Gateway not reachable"
	ping -c 1 10.30.1.1 || echo "DC2 Gateway not reachable"
	ping -c 1 10.40.1.1 || echo "DC3 Gateway not reachable"
test-services:
	@echo "Checking basic service responses (localhost ports)"
	curl -s http://localhost | grep "DC1" || echo "Gateway DC1 not responding"
	curl -s http://localhost:9090 | grep "DC2" || echo "Gateway DC2 not responding"
	curl -s http://localhost9091 | grep "DC3" || echo "Gateway DC3 not responding"
	curl -s http://localhost:8081 | grep "user" || echo "User Service not responding"
	curl -s http://localhost:8082 | grep "catalog" || echo "Catalog Service not responding"
	curl -s http://localhost:8083 | grep "order" || echo "Order Service (DC1) not responding"
	curl -s http://localhost:8085 | grep "payment" || echo "Payment Service not responding"
	curl -s http://localhost:8086 | grep "notify" || echo "Notify Service not responding"
	curl -s http://localhost:8089 | grep "analytics" || echo "Analytics Service not responding"
	curl -s http://localhost:8090 | grep "services" || echo "Discovery Service not responding"
test-cross-dc:
	@echo "Testing cross-DC reachability (within Docker network)"
	@ORDER_IP=$$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' order-nginx-dc2); \
	echo "Pinging ORDER Service (DC2) from Gateway (DC1): $$ORDER_IP"; \
	docker exec gateway-dc1 ping -c 1 $$ORDER_IP || echo "DC1 ➝ DC2 order-nginx not reachable"
	
	@DISCOVERY_IP=$$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' discovery-nginx); \
	echo "Pinging Discovery (DC3) from Gateway (DC2): $$DISCOVERY_IP"; \
	docker exec gateway-dc2 ping -c 1 $$DISCOVERY_IP || echo "DC2 ➝ DC3 discovery-nginx not reachable"

	@ANALYTICS_IP=$$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' analytics-nginx); \
	echo "Pinging Analytics (DC3) from Payment (DC2): $$ANALYTICS_IP"; \
	docker exec payment-nginx ping -c 1 $$ANALYTICS_IP || echo "DC2 ➝ DC3 analytics-nginx not reachable"
health-check:
	@echo "Running health checks for all containers..."
	@docker ps --format "table {{.Names}}\t{{.Status}}" | grep -v "Exited" || echo "Some containers are down"
show-logs:
	@echo "Displaying logs for all services..."
	@docker ps --format "{{.Names}}" | while read container; do \
	  echo "==== Logs for $$container ===="; \
	  docker logs $$container --tail=5; \
	  echo ""; \
	done