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

---

## Docker Issues 

### `Cannot connect to the Docker daemon`
**Cause:** User doesn’t have permission to access Docker.

**Solution:**
```bash
sudo usermod -aG docker $USER
newgrp docker
sudo init 6
```

---

## General Debug

```bash
docker ps -a                       # Show container status
docker logs <container>            # View logs
ip route show                      # View routing table
ip link show                       # Check interface status
ping <vxlan gateway>               # Test DC gateway reachability
```

---

### If You Face Issues

Follow these steps to reset and verify your infrastructure:

1. Re-run the cleanup process to remove all VXLAN, routing, and networks:

    ```bash
    make cleanup-infrastructure
    ```

2. Set up the infrastructure again from scratch:

    ```bash
    make setup-infrastructure
    ```

3. Run all basic tests to ensure everything is working:

    ```bash
    make test
    ```

If problems persist, manually inspect the following:

- `ip route show` – Check if routing is correct  
- `ip link show` – See if VXLAN interfaces are active  
- `docker ps` – Ensure all containers are running  
- `docker logs <container>` – View individual container logs

---
