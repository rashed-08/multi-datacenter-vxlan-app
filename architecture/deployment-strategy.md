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
- Attached to the proper VXLAN-connected Docker bridge

---

## Phase 3: Health Check & Cross-DC Test

- Run `make test`
- Run `make test-cross-dc`
- Use curl or browser to test service responses
- Ensure service discovery (port 8500) returns all expected services

---

## Failover Strategy

- If DC1 goes down, DC2 has a backup Gateway and Order service
- DC3 acts as DR with all services ready to take over

---

## Deployment Notes

- Docker must be installed and running
- Ensure IP forwarding enabled `sudo sysctl -w net.ipv4.ip_forward=1`
- MTU mismatch can cause packet drops — validated via ping 