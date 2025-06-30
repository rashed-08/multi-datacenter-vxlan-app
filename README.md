# Multi-Datacenter Microservices Platform (VXLAN + Docker + Make)

A simulated multi-datacenter architecture using containerized microservices with VXLAN-based networking and full Makefile automation.

> Designed for hands-on learning of distributed systems, service orchestration, and virtual networking.

---

## Project Overview

- 3 Datacenter Simulation:
  - DC1 (Primary - North America)
  - DC2 (Secondary - Europe)
  - DC3 (Disaster Recovery - Asia-Pacific)

- 8 Nginx-based Microservices:
  - `gateway-nginx`, `user-nginx`, `catalog-nginx`, `order-nginx`, `payment-nginx`, `notify-nginx`, `analytics-nginx`, `discovery-nginx`

- VXLAN Mesh Overlay
- Docker networks per DC
- Health checks, service discovery, and basic routing
- Fully automated with `Makefile`

---

## Project Structure
```
microservices-vxlan-project/
├── Makefile
├── dockerfiles/
├── configs/
├── data/
├── scripts/
├── docs/
├── architecture/
```
---

## Core Technologies

- Docker & Docker Compose
- VXLAN Overlay Networking
- Nginx (simulated microservices)
- Bash scripting
- Static routing
- Linux networking tools
- Makefile automation

---

## Setup Instructions

See [docs/setup-guide.md](docs/setup-guide.md) for full steps.

Quick setup:

```bash
make cleanup-infrastructure
make setup-infrastructure
make build-all-images
make deploy-services
make test
```
---
## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md) 

Common issues:

```bash
•	VXLAN device not found
•	Docker network/subnet conflict
•	curl connection refused
•	static route missing
```

## Success Criteria

### Functional Requirements
- ✅ All 8 nginx-based microservices are deployed and operational
- ✅ Cross-datacenter communication via VXLAN tunnels is functional
- ✅ Simulated Load balancing 
- ✅ Service discovery via `discovery-nginx` works correctly
- ✅ Docker container health checks are configured and passing

---

### Technical Achievements

- ✅ VXLAN mesh networking configured across DC1, DC2, and DC3
- ✅ Static routing between datacenters using Linux `ip route`
- ✅ Custom Docker networks per datacenter (subnet-separated)
- ✅ Makefile automation with 20+ targets (build, deploy, test, cleanup)
- ✅ All services built using Dockerfiles and automated scripts
---
