# Microservices Architecture

This document describes the microservices simulated in this multi-datacenter VXLAN project using Nginx containers.

## List of Services

| Service Name       | Port  | Purpose                    | Hosted in DC | Redundant |
|--------------------|-------|----------------------------|--------------|-----------|
| Gateway-Nginx      | 80    | API Gateway / Load Balancer| DC1, DC2     | ✅        |
| User-Nginx         | 8080  | User Management            | DC1          | ❌        |
| Catalog-Nginx      | 8081  | Product Catalog            | DC1          | ❌        |
| Order-Nginx        | 8082  | Order Processing           | DC1, DC2     | ✅        |
| Payment-Nginx      | 8083  | Payment Handling           | DC2          | ❌        |
| Notify-Nginx       | 8084  | Notification System        | DC2          | ❌        |
| Analytics-Nginx    | 8085  | Analytics & Reporting      | DC3          | ❌        |
| Discovery-Nginx    | 8500  | Service Registry Simulation| DC3          | ❌        |

## Inter-Service Dependency Diagram

```mermaid
graph TD
  GW[Gateway-Nginx (DC1/DC2)] --> U[User-Nginx (DC1)]
  GW --> C[Catalog-Nginx (DC1)]
  GW --> O[Order-Nginx (DC1/DC2)]
  O --> P[Payment-Nginx (DC2)]
  O --> N[Notify-Nginx (DC2)]
  GW --> D[Discovery-Nginx (DC3)]
  O --> A[Analytics-Nginx (DC3)]
  U --> A
  C --> A