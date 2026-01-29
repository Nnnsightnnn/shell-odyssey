# Exercise 2: Segment Frontend/Backend

## Objective
Learn to design and implement secure network segmentation.

## Background

Network segmentation divides your infrastructure into zones based on trust levels and access requirements. Common patterns:

- **DMZ** - Exposed services (web servers)
- **Application Tier** - Business logic
- **Data Tier** - Databases, storage

## Tasks

### Task 1: Analyze Current Architecture

Our lab already implements segmentation:

```
Internet
    │
    ▼
┌─────────────────────────────┐
│   Frontend Zone (DMZ)       │
│   172.20.0.0/24             │
│   - client (user access)    │
│   - server (web)            │
│   - api (gateway)           │
└──────────────┬──────────────┘
               │
        [API Gateway]
               │
┌──────────────┴──────────────┐
│   Backend Zone              │
│   172.21.0.0/24             │
│   - api (internal)          │
│   - database                │
│   - monitor (admin)         │
└─────────────────────────────┘
```

### Task 2: Design a Three-Tier Architecture

Let's design (conceptually) a more complete segmentation:

```yaml
# Example three-tier compose structure
networks:
  # Tier 1: Public-facing
  dmz:
    subnet: 172.50.0.0/24
    # Load balancer, WAF, reverse proxy

  # Tier 2: Application
  app_tier:
    subnet: 172.51.0.0/24
    # API servers, business logic

  # Tier 3: Data
  data_tier:
    subnet: 172.52.0.0/24
    # Databases, cache, message queues

  # Management: Admin access
  management:
    subnet: 172.53.0.0/24
    # Monitoring, logging, admin tools
```

### Task 3: Implement Access Rules Mentally

For each tier, think about:

| From | To | Allow? | Why |
|------|-----|--------|-----|
| DMZ | App | Yes | Forward requests |
| DMZ | Data | No | No direct DB access |
| App | Data | Yes | Query databases |
| App | DMZ | Response only | Return results |
| Data | * | No | Data doesn't initiate |
| Mgmt | All | Yes | Admin needs access |

### Task 4: Create a Test Segmented Network

Build a mini three-tier setup:

```bash
# Create networks
docker network create --subnet=172.50.0.0/24 tier-dmz
docker network create --subnet=172.51.0.0/24 tier-app
docker network create --subnet=172.52.0.0/24 tier-data

# DMZ tier - web server
docker run -d --name web \
  --network tier-dmz \
  nginx:alpine

# App tier - connects to DMZ and Data
docker run -d --name app \
  --network tier-app \
  nicolaka/netshoot sleep 3600

# Connect app to DMZ (for receiving requests)
docker network connect tier-dmz app

# Data tier - database
docker run -d --name db \
  --network tier-data \
  --env POSTGRES_PASSWORD=test \
  postgres:15-alpine

# Connect app to data (for queries)
docker network connect tier-data app
```

### Task 5: Verify Tier Isolation

```bash
# Web can only see DMZ
docker exec web ping -c 1 172.51.0.2 2>&1 || echo "Web cannot reach app tier"
docker exec web ping -c 1 172.52.0.2 2>&1 || echo "Web cannot reach data tier"

# App can reach both (it's connected to all)
docker exec app ping -c 1 172.50.0.2  # web
docker exec app ping -c 1 172.52.0.2  # db

# DB is isolated in data tier
docker exec db sh -c "ping -c 1 172.50.0.2 2>&1" || echo "DB cannot reach DMZ"
```

### Task 6: Map to Real-World Scenarios

**E-commerce Example:**
```
DMZ:        nginx reverse proxy, CDN edge
App Tier:   order-service, user-service, payment-service
Data Tier:  PostgreSQL, Redis, Elasticsearch
Management: Prometheus, Grafana, ELK stack
```

**Microservices Example:**
```
Public:     API Gateway
Services:   auth, users, products, orders (mesh)
Data:       Per-service databases
Ops:        Service mesh control plane, monitoring
```

### Task 7: Security Controls Per Tier

Each tier should have appropriate controls:

**DMZ:**
- Rate limiting
- WAF rules
- DDoS protection
- TLS termination

**App Tier:**
- Authentication/authorization
- Input validation
- Secure service-to-service
- Secret management

**Data Tier:**
- Encryption at rest
- Minimal exposed ports
- No direct external access
- Backup encryption

### Task 8: Cleanup Test Setup

```bash
docker rm -f web app db 2>/dev/null
docker network rm tier-dmz tier-app tier-data 2>/dev/null
```

### Task 9: Document Your Architecture

For any segmented network, document:

1. **Network map** - Subnets, gateways, connections
2. **Traffic flows** - What talks to what
3. **Access rules** - Allowed/denied connections
4. **Gateway services** - What bridges zones
5. **Monitoring points** - Where to inspect traffic

## Segmentation Best Practices

1. **Minimize cross-zone traffic** - Fewer connections = smaller attack surface
2. **Use gateway services** - Don't expose databases directly
3. **Implement least privilege** - Only needed connections
4. **Monitor zone boundaries** - Log cross-zone traffic
5. **Separate management** - Admin access on dedicated network

## Key Takeaways

1. **Segmentation limits blast radius** - Compromised tier can't reach others
2. **Gateway pattern controls flow** - Business logic at zone boundaries
3. **Each tier has different security needs** - Apply appropriate controls
4. **Documentation is critical** - Know your traffic patterns

## Verification Checklist

- [ ] Understand three-tier architecture
- [ ] Can design network segmentation
- [ ] Know what traffic to allow between tiers
- [ ] Created and tested segmented networks

## Next Exercise

Continue to [Exercise 3: Traffic Inspection](exercise-3.md)
