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
microservices-vxlan-project/
├── Makefile
├── dockerfiles/
├── configs/
├── data/
├── scripts/
├── docs/
├── architecture/

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