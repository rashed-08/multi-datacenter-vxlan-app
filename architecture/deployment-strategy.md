# Deployment Strategy

This deployment is divided into three logical phases.

---

## Phase 1: Infrastructure Setup

- Run `make setup-infrastructure`
- Creates Docker bridges per DC
- Configures VXLAN tunnels
- Adds static inter-DC routes
- Validates network reachability

---

## Phase 2: Build & Deploy Services

- Run `make build-all-images`  
- Then deploy by DC:
  - `make deploy-dc1-services`
  - `make deploy-dc2-services`
  - `make deploy-dc3-services`
- Each service uses individual ports and nginx config

---

## Phase 3: Health Check & Cross-DC Test

- Run `make test-connectivity`
- Run `make test-services`
- Use curl or browser to test service responses
- Ensure service discovery (port 8500) returns all expected services

---

## Failover Strategy

- If DC1 goes down, DC2 has a backup Gateway and Order service
- DC3 acts as DR with all services ready to take over

---

## Deployment Notes

- Ensure Docker and IP forwarding enabled
- VXLAN uses multicast group `239.1.1.1`
- MTU mismatch can cause packet drops — validated via ping with DF