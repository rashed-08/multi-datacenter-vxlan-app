# Infrastructure
setup-infrastructure:
	@echo "Setting up full infrastructure..."
	bash scripts/infrastructure/setup-vxlan.sh
	bash scripts/infrastructure/setup-vxlan-bridge.sh
	bash scripts/infrastructure/setup-docker-networks.sh
	bash scripts/infrastructure/configure-routing.sh
	bash scripts/infrastructure/firewall-rules.sh
	@echo "Infrastructure setup complete. Use 'make build-all-images' to build all images."
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
	ping -c 2 10.20.1.1 || echo "DC1 gateway unreachable"
	ping -c 2 10.30.1.1 || echo "DC2 gateway unreachable"
	ping -c 2 10.40.1.1 || echo "DC3 gateway unreachable"

# Build
build-all-images: build-user build-catalog build-gateway build-order build-payment build-notify build-analytics build-discovery build-load-balancer
	@echo "After building, use 'make deploy-services' to deploy all services."

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
build-load-balancer:
	docker build -f services/haproxy-lb/Dockerfile -t order-load-balancer services/haproxy-lb

# Deploy
deploy-services: deploy-dc1-services deploy-dc2-services deploy-dc3-services setup-fdb generate-haproxy-config deploy-load-balancer
	@echo "Deploying services across all data centers..."
	@echo "Services deployed successfully. Use 'make test' to verify connectivity and functionality."

deploy-dc1-services:
	@echo "Deploying services in DC1..."
	bash scripts/deployment/deploy-dc1-services.sh
deploy-dc2-services:
	@echo "Deploying services in DC2..."
	bash scripts/deployment/deploy-dc2-services.sh
deploy-dc3-services:
	@echo "Deploying services in DC3..."
	bash scripts/deployment/deploy-dc3-services.sh
generate-haproxy-config:
	@echo "Generating HAProxy config..."
	bash scripts/deployment/generate-haproxy-config.sh
deploy-load-balancer:
	@echo "Deploying load balancer service..."
	docker run -d --name haproxy-lb --net=dc1-net -p 8070:80 --restart unless-stopped order-load-balancer
setup-fdb:
	@echo "Setting up FDB (Fast Data Bridge) for VXLAN..."
	bash scripts/infrastructure/setup-fdb.sh

stop-services:
	docker stop $$(docker ps -q)
start-services:
	docker start $$(docker ps -aq)
cleanup-services:
	docker rm -f $$(docker ps -a -q)
	docker rmi -f user-nginx catalog-nginx gateway-nginx:dc1 gateway-nginx:dc2 gateway-nginx:dc3 order-nginx payment-nginx notify-nginx analytics-nginx discovery-nginx order-load-balancer || true

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
	curl -s http://localhost:9091 | grep "DC3" || echo "Gateway DC3 not responding"
	curl -s http://localhost:8080 | grep "User" || echo "User Service not responding"
	curl -s http://localhost:8081 | grep "Product" || echo "Catalog Service not responding"
	curl -s http://localhost:8082 | grep "Order" || echo "Order Service (DC1) not responding"
	curl -s http://localhost:8083 | grep "Payment" || echo "Payment Service not responding"
	curl -s http://localhost:8084 | grep "Notification" || echo "Notify Service not responding"
	curl -s http://localhost:8085 | grep "Analytics" || echo "Analytics Service not responding"
	curl -s http://localhost:8500 || echo "Discovery Service not responding"
test-cross-dc:
	@echo "Testing cross-DC reachability (within Docker network)"
	@ORDER_IP=$$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' order-nginx); \
	echo "Pinging ORDER Service (DC2) from Gateway (DC1): $$ORDER_IP"; \
	docker exec gateway-dc1 ping -c 1 $$ORDER_IP || echo "DC1 ➝ DC2 order-nginx not reachable"
	
	@DISCOVERY_IP=$$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' discovery-nginx); \
	echo "Pinging Discovery (DC3) from Gateway (DC2): $$DISCOVERY_IP"; \
	docker exec gateway-dc2 ping -c 1 $$DISCOVERY_IP || echo "DC2 ➝ DC3 discovery-nginx not reachable"

	@ANALYTICS_IP=$$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' analytics-nginx); \
	echo "Pinging Analytics (DC3) from Payment (DC2): $$ANALYTICS_IP"; \
	docker exec payment-nginx ping -c 1 $$ANALYTICS_IP || echo "DC2 ➝ DC3 analytics-nginx not reachable"
test-order-dc1:
	@ORDER_DC1_IP=$$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' order-nginx); \
	echo "DC1 Order IP: $$ORDER_DC1_IP"; \
	curl -s http://$$ORDER_DC1_IP | grep "Order" || echo "Order DC1 not responding"
test-order-dc2:
	@ORDER_DC2_IP=$$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' order-nginx-replica); \
	echo "DC2 Order IP: $$ORDER_DC2_IP"; \
	curl -s http://$$ORDER_DC2_IP | grep "Order" || echo "Order DC2 (replica) not responding"
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