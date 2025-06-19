# Network Topology

This project simulates a multi-datacenter environment using Docker and VXLAN tunneling.

---

## Datacenter Overview

| DC | Region         | VXLAN ID | Subnet          | Gateway       |
|----|----------------|----------|------------------|---------------|
| DC1| North America  | 20      | 10.10.0.0/16     | 10.10.1.1     |
| DC2| Europe         | 30      | 10.20.0.0/16     | 10.20.1.1     |
| DC3| Asia-Pacific   | 40      | 10.30.0.0/16     | 10.30.1.1     |

---

## VXLAN Tunnel Mapping

- VXLAN interfaces:
  - DC1 → `vxlan20`
  - DC2 → `vxlan30`
  - DC3 → `vxlan40`
- VXLAN Port: 4789
- Multicast Group: `239.1.1.1`
- MTU: 1450

---

## Inter-Datacenter Routing

| Source DC | Destination Subnet | Next Hop      |
|-----------|--------------------|---------------|
| DC1       | 10.20.0.0/16       | 10.10.1.1     |
| DC1       | 10.30.0.0/16       | 10.10.1.1     |
| DC2       | 10.10.0.0/16       | 10.20.1.1     |
| DC2       | 10.30.0.0/16       | 10.20.1.1     |
| DC3       | 10.10.0.0/16       | 10.30.1.1     |
| DC3       | 10.20.0.0/16       | 10.30.1.1     |

---

## Multi-Tier Network Segmentation

| Tier         | Services                       | Description                   |
|--------------|-------------------------------|-------------------------------|
| Web Tier     | Gateway-Nginx                 | Entry point for all traffic  |
| App Tier     | User, Order, Catalog, Payment, Notify | Core business logic     |
| Data Tier    | Analytics, Discovery          | Monitoring, Reporting, Registry |