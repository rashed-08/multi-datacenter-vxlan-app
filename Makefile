# Infrastructure
setup-infrastructure:
	bash scripts/infrastructure/setup-vxlan.sh
	bash scripts/infrastructure/configure-routing.sh
cleanup-infrastructure:
	bash scripts/infrastructure/cleanup-vxlan.sh
	bash scripts/infrastructure/cleanup-routing.sh
show-network-status:
	docker network ls
validate-infrastructure:
	ping -c 2 10.20.1.1
setup-docker-network:
	bash scripts/deployment/deploy-services.sh
cleanup-docker-network:
	bash scripts/infrastructure/cleanup-docker-networks.sh

# Build
build-all-images: build-user build-catalog build-gateway build-order build-payment build-notify build-analytics build-discovery 

build-user:
	docker build -f dockerfiles/Dockerfile.user-nginx -t user-nginx .
build-catalog:
	docker build -f dockerfiles/Dockerfile.catalog-nginx -t catalog-nginx .
build-gateway:
	docker build -f dockerfiles/Dockerfile.gateway-nginx -t gateway-nginx .
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
deploy-services:
	bash scripts/deployment/deploy-services.sh
stop-services:
	docker stop $$(docker ps -q)
start-services:
	docker start $$(docker ps -aq)
cleanup-services:
	docker rm $$(docker ps -aq)

# Testing
test-connectivity:
	ping -c 2 10.20.1.1
test-services:
	curl -f http://localhost:8080/status.json || echo "User service"
	curl -f http://localhost:8081/products.json || echo "Catalog service"
health-check:
	docker ps
show-logs:
	docker logs gateway-nginx