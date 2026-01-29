# Exercise 1: Network Isolation Demo

## Objective
Demonstrate how network isolation provides security by preventing unauthorized access.

## Background

Network isolation is a fundamental security control. By placing resources on different networks, you create boundaries that traffic cannot cross without explicit permission.

## Tasks

### Task 1: Map the Trust Boundaries

Our lab has two network zones:

**Frontend Zone (172.20.0.0/24)** - Publicly accessible
- `client` - User workstation
- `server` - Web server
- `api` - Application gateway

**Backend Zone (172.21.0.0/24)** - Internal only
- `database` - Data storage
- `api` - Backend connection
- `monitor` - Administrative access

### Task 2: Verify Isolation from Client

Enter the client container:
```bash
docker exec -it client bash
```

Test what you CAN reach:
```bash
# Frontend services - should work
ping -c 1 server
ping -c 1 api
curl -s http://server | head -5
curl -s http://api:5000/health
```

Test what you CANNOT reach:
```bash
# Backend services - should fail
ping -c 1 database
# Result: Name does not resolve OR no route

ping -c 1 172.21.0.40
# Result: No route to host
```

**This is isolation working!** The client cannot directly access the database.

### Task 3: Verify Isolation from Database

Enter the database container:
```bash
docker exec -it database bash
```

Test what database can reach:
```bash
# Database has no networking tools, but we can test with basic commands
# It's on backend_net only

# Can it resolve frontend hosts?
cat /etc/resolv.conf
# Uses the DNS server
```

Exit and check from outside:
```bash
docker exec database sh -c "ping -c 1 172.20.0.10 2>&1 || echo 'Cannot reach client'"
```

The database cannot initiate connections to frontend - it's protected in both directions.

### Task 4: The API Gateway Pattern

The API container bridges the networks securely:

```bash
# Enter API container
docker exec -it api bash

# API can reach frontend
ping -c 1 server
curl -s http://server | head -3

# API can reach backend
ping -c 1 database

# Check both interfaces
ip addr | grep inet
```

Exit and test the flow:
```bash
# Client → API → Database flow
docker exec client curl -s http://api:5000/db/status
```

This works because:
1. Client sends request to API (frontend network)
2. API processes and queries database (backend network)
3. API returns response to client (frontend network)

The client never directly touches the database!

### Task 5: What Isolation Prevents

Without isolation, an attacker who compromises the web client could:
- Directly connect to the database
- Scan the internal network
- Access other backend services

With isolation:
- Attacker is confined to frontend network
- Database is invisible and unreachable
- Attack surface is reduced to the API

### Task 6: Visualize with Route Tables

Compare routes from different containers:

```bash
# Client sees only frontend
docker exec client ip route
# Output: 172.20.0.0/24 dev eth0

# API sees both networks
docker exec api ip route
# Output: 172.20.0.0/24 AND 172.21.0.0/24

# Database sees only backend
docker exec database sh -c "ip route 2>/dev/null || cat /proc/net/route"
# Output: 172.21.0.0/24 dev eth0
```

### Task 7: DNS and Isolation

DNS configuration also respects network boundaries:

```bash
# Client can resolve frontend services
docker exec client dig +short server
docker exec client dig +short api

# But backend resolution depends on DNS being on both networks
docker exec client dig +short database
# May resolve (DNS is on both networks) but can't connect!
```

This is important: **DNS resolution doesn't mean connectivity!**

### Task 8: Test Isolation Bypass (Blocked)

Try to manually route to backend from client:

```bash
docker exec client ip route add 172.21.0.0/24 via 172.20.0.1
# This will fail - you don't have permission to add routes
# Even if you could, the gateway (Docker) won't forward the packets
```

Docker's networking enforces isolation at the infrastructure level.

## Key Takeaways

1. **Isolation is enforced by network topology** - Not just access control
2. **Containers only see networks they're attached to** - No automatic visibility
3. **Gateway pattern controls access** - API bridges zones with business logic
4. **Defense in depth** - Even if one control fails, others protect

## Verification Checklist

- [ ] Confirmed client cannot reach database
- [ ] Confirmed database cannot reach client
- [ ] Understand how API bridges zones
- [ ] Know that DNS ≠ connectivity

## Next Exercise

Continue to [Exercise 2: Segment Frontend/Backend](exercise-2.md)
