# Troubleshooting Guide

This document lists common issues encountered while setting up and deploying the Multi-Datacenter Microservices Architecture project, along with their solutions.

---

## Makefile Issues 

### `make: command not found`
**Cause:** `make` is not installed on your system.

**Solution:**
```bash
sudo apt update && sudo apt install make
```

## Docker Issues 

### `Cannot connect to the Docker daemon`
**Cause:** User doesn’t have permission to access Docker.

**Solution:**
```bash
sudo usermod -aG docker $USER
newgrp docker
sudo init 6
```

## General Debug

```bash
docker ps -a                       # Show container status
docker logs <container>            # View logs
ip route show                      # View routing table
ip link show                       # Check interface status
ping <vxlan gateway>               # Test DC gateway reachability
```

### `If you face issues:`
```bash
	1.	Re-run `make cleanup-infrastructure`
	2.	Run `make setup-infrastructure` again
	3.	Use `make test` to verify setup
```