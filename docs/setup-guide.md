# Multi-Datacenter Microservices Platform – Setup Guide

This guide walks you through setting up the complete infrastructure and services for the simulated multi-datacenter microservices system.

---

## 1. Prerequisites

Ensure the following are installed:

- [x] Docker  
- [x] Make  
- [x] Bash shell  
- [x] `curl`, `iproute2` (for `ip` and `ping`)  
- [x] Linux host or VM (Tested on Ubuntu)

---

## 2. Project Structure Overview
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

## 3. Infrastructure Setup

### Step 1: Clean previous configuration

```bash
make cleanup-infrastructure
```

### Step 2: Set up full infrastructure

```bash
make setup-infrastructure
```
```markdown
This will:

- Create 3 VXLAN interfaces (`vxlan200`, `vxlan300`, `vxlan400`)
- Assign gateway IPs (`10.10.1.1`, `10.20.1.1`, `10.30.1.1`)
- Create Docker networks for each datacenter
- Configure static routing between datacenters
```
---

## 4. Build All Services
```bash
make build-all-images
```
```markdown
This command builds 8 custom Nginx services:

- gateway-nginx (DC1–DC3)
- user-nginx, catalog-nginx, order-nginx
- payment-nginx, notify-nginx
- analytics-nginx, discovery-nginx
```
---

## 5. Deploy Services
### Option 1: Deploy all services
```bash
make deploy-services
```
### Option 2: Deploy services by datacenter
```bash
make deploy-dc1-services
make deploy-dc2-services
make deploy-dc3-services
```
---

## 6. Test the Setup
### Option 1: Run all tests
```bash
make test
```
### Option 2: Run individual tests
```bash
make test-connectivity – ping gateway IPs
make test-services – test HTTP responses
make test-cross-dc – container-to-container ping
make health-check – Docker container health
```
---

## 7. Logs and Network Diagnostics
```bash
make show-logs
make show-network-status
make show-routing-table
```
---

## 8. Tear Down and Cleanup
```bash
make cleanup-infrastructure
```
```markdown
This command removes:

- All VXLAN interfaces
- Static routes
- Docker containers and networks
- Built images
```