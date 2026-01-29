# Exercise 3: Multi-Network Containers

## Objective
Learn to connect containers to multiple networks for controlled communication.

## Background

Some containers need to communicate with multiple network segments:
- **API servers** - Accept requests from frontend, connect to backend database
- **Monitoring** - Need visibility into multiple networks
- **Gateways** - Route traffic between networks

Our `api` and `monitor` containers are connected to both frontend and backend networks.

## Tasks

### Task 1: Examine Multi-Network Container

Check the api container's network configuration:

```bash
# From host
docker inspect api --format '
Networks:
{{range $net, $config := .NetworkSettings.Networks}}
  {{$net}}: {{$config.IPAddress}}
{{end}}'
```

You should see two IPs:
- `172.20.0.30` on frontend_net
- `172.21.0.30` on backend_net

### Task 2: View Inside the Container

Enter the api container:

```bash
docker exec -it api bash
```

View network interfaces:
```bash
ip addr
```

You should see **two eth interfaces** (eth0 and eth1), each with a different IP.

Check routes:
```bash
ip route
```

You'll see routes to both 172.20.0.0/24 and 172.21.0.0/24.

Exit the container:
```bash
exit
```

### Task 3: Understand the Communication Flow

```
┌───────────────┐         ┌───────────────┐         ┌───────────────┐
│    client     │         │      api      │         │   database    │
│  172.20.0.10  │ ──────▶ │  172.20.0.30  │         │  172.21.0.40  │
│               │         │  172.21.0.30  │ ──────▶ │               │
└───────────────┘         └───────────────┘         └───────────────┘
       │                         │                         │
       │                         │                         │
  frontend_net              BOTH NETS               backend_net
  172.20.0.0/24                                    172.21.0.0/24
```

The API acts as a bridge:
- Client (frontend only) → API (frontend interface)
- API (backend interface) → Database (backend only)

### Task 4: Connect Client to Backend (Temporarily)

Let's give client access to the backend network:

```bash
# Connect client to backend_net
docker network connect network-lab_backend_net client

# Verify
docker exec client ip addr
```

Now client has two interfaces! Test database connectivity:

```bash
docker exec client ping -c 2 172.21.0.40
# This should work now!
```

### Task 5: Remove the Connection

```bash
# Disconnect client from backend
docker network disconnect network-lab_backend_net client

# Verify it's gone
docker exec client ip addr
# Only one interface now

# Database is unreachable again
docker exec client ping -c 2 172.21.0.40
# Fails!
```

### Task 6: Create a Test Multi-Network Setup

Build your own multi-network scenario:

```bash
# Create two networks
docker network create --subnet=172.40.0.0/24 net-a
docker network create --subnet=172.41.0.0/24 net-b

# Create a container on net-a
docker run -d --name box-a \
  --network net-a \
  nicolaka/netshoot sleep 3600

# Create a container on net-b
docker run -d --name box-b \
  --network net-b \
  nicolaka/netshoot sleep 3600

# Create a gateway on both
docker run -d --name gateway \
  --network net-a \
  nicolaka/netshoot sleep 3600
docker network connect net-b gateway

# Test: box-a cannot reach box-b
docker exec box-a ping -c 1 172.41.0.2
# Fails - no route

# But gateway can reach both
docker exec gateway ping -c 1 172.40.0.2  # box-a
docker exec gateway ping -c 1 172.41.0.2  # box-b
# Both work!
```

### Task 7: Practical Scenario - Database Proxy

Imagine you want to let client access database through a proxy:

```bash
# The 'api' container already serves this purpose!
# From client, you can call the API which queries the database

docker exec client curl -s http://api:5000/db/status
```

The API:
1. Receives request on frontend network (172.20.0.30)
2. Connects to database on backend network (172.21.0.30 → 172.21.0.40)
3. Returns result to client

### Task 8: Cleanup Test Resources

```bash
docker rm -f box-a box-b gateway 2>/dev/null
docker network rm net-a net-b 2>/dev/null
```

### Task 9: Multi-Network in Compose

Here's how our compose file configures multi-network containers:

```yaml
services:
  api:
    networks:
      frontend_net:
        ipv4_address: 172.20.0.30
      backend_net:
        ipv4_address: 172.21.0.30
```

The container gets an interface on each listed network with the specified IPs.

### Task 10: Dynamic Network Management Commands

Useful commands for managing container networks:

```bash
# Connect (can specify IP)
docker network connect --ip 172.21.0.99 network-lab_backend_net client

# Disconnect
docker network disconnect network-lab_backend_net client

# List container's networks
docker inspect client --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}'

# Find containers on a network
docker network inspect network-lab_backend_net --format '{{range .Containers}}{{.Name}} {{end}}'
```

## Key Takeaways

1. **Containers can join multiple networks** - Each gets a separate interface
2. **Control communication paths** - Choose what can reach what
3. **Dynamic management** - Add/remove network connections without restart
4. **Gateways/proxies** - Multi-network containers can bridge segments
5. **Security through topology** - Network architecture enforces access patterns

## Verification Checklist

- [ ] Understand why containers need multiple networks
- [ ] Can connect/disconnect containers from networks
- [ ] Know how traffic flows through multi-network containers
- [ ] Can set up custom multi-network topology

## Module Complete!

You've completed Module 3: Docker Networks. You now understand:
- Bridge networking fundamentals
- Creating custom networks
- Multi-network container configurations

**Next Module:** [04-security](../04-security/README.md) - Network security and isolation
