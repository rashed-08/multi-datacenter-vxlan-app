# Network Architecture Specifications

This document describes the complete network design used in the multi-datacenter microservices platform. It includes VXLAN implementation, subnet planning, tier segmentation, and inter-datacenter routing strategy.

---

## VXLAN Overlay Networks

Each datacenter is connected using simulated VXLAN tunnels.

| Datacenter | Region         | VXLAN ID | Subnet        | Gateway IP    |
|------------|----------------|----------|---------------|---------------|
| DC1        | North America  | 200      | 10.200.0.0/16 | 10.200.1.1    |
| DC2        | Europe         | 300      | 10.300.0.0/16 | 10.300.1.1    |
| DC3        | Asia-Pacific   | 400      | 10.400.0.0/16 | 10.400.1.1    |

- **VXLAN ID** is unique per DC to ensure isolation.
- Docker networks are used to simulate VXLAN bridges.

---

## Multi-Tier Network Segmentation

Each datacenter has logically separated network tiers:

| Tier        | Purpose                       | Example Services             |
|-------------|-------------------------------|------------------------------|
| Web Tier    | External entry point          | Gateway-Nginx                |
| App Tier    | Core business logic           | User, Catalog, Order, Payment |
| Data Tier   | Analytics, Discovery, Logs    | Analytics, Discovery         |

- Though physically on the same host, containers are logically grouped by tier.
- Tier-based separation helps in applying access control and diagnostics.

---

## Inter-Datacenter Routing

- Basic routing is enabled to allow services in one DC to talk to another.
- Example: Order service in DC1 can call Payment in DC2 via internal IP.

Routing plan (conceptual):

From DC1 (10.200.0.0/16) to:
    - DC2 (10.300.0.0/16) → via 10.200.1.1
    - DC3 (10.400.0.0/16) → via 10.200.1.1

From DC2 (10.300.0.0/16) to:
    - DC1 (10.200.0.0/16) → via 10.300.1.1
    - DC3 (10.400.0.0/16) → via 10.300.1.1