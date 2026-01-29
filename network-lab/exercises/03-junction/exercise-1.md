# Exercise 1: Bridge Networks

## Objective
Understand Docker bridge networking - both default and user-defined bridges.

## Background

A **bridge network** is like a virtual switch. Containers connected to the same bridge can communicate with each other.

Docker provides:
- **Default bridge** (`bridge`) - Basic connectivity, no DNS
- **User-defined bridges** - Better isolation, automatic DNS

Our lab uses user-defined bridges (frontend_net, backend_net).

## Tasks

### Task 1: Explore the Default Bridge

From your **host machine** (not inside a container):

```bash
# List all Docker networks
docker network ls
```

You should see:
- `bridge` - Docker's default network
- `network-lab_frontend_net` - Our lab's frontend network
- `network-lab_backend_net` - Our lab's backend network

### Task 2: Inspect a Network

Get detailed information about our frontend network:

```bash
docker network inspect network-lab_frontend_net
```

**Find these details:**
1. The subnet (should be 172.20.0.0/24)
2. The gateway (172.20.0.1)
3. Which containers are connected
4. Their IP addresses

<details>
<summary>Key Information to Find</summary>

Look for the "IPAM" section:
```json
"IPAM": {
    "Config": [
        {
            "Subnet": "172.20.0.0/24",
            "Gateway": "172.20.0.1"
        }
    ]
}
```

And the "Containers" section showing each connected container.
</details>

### Task 3: Compare Default vs User-Defined Bridge

**Default bridge limitations:**
```bash
# Create a test container on default bridge
docker run -d --name test1 nginx:alpine

# Default bridge doesn't have DNS resolution!
docker exec test1 ping -c 1 client
# This will fail - "ping: bad address 'client'"

# Clean up
docker rm -f test1
```

**User-defined bridge advantages:**
```bash
# In our lab, DNS works automatically
docker exec client ping -c 1 server
# This works!
```

### Task 4: View Bridge from Inside Container

Enter the client container:

```bash
docker exec -it client bash
```

View network interfaces:
```bash
ip addr
```

You'll see:
- `lo` - Loopback (127.0.0.1)
- `eth0` - Bridge connection (172.20.0.10)

Check the routing:
```bash
ip route
```

The default gateway (172.20.0.1) is Docker's bridge interface.

### Task 5: See the Bridge on the Host

From your **host machine**:

```bash
# See Docker's bridge interfaces
ip addr show type bridge 2>/dev/null || ifconfig | grep -A1 "br-"

# Or look for Docker networks
docker network ls --format "{{.Name}}: {{.Driver}}"
```

On Linux, you might see interfaces like `br-xxxxx` which are the actual bridge interfaces.

### Task 6: How Bridge Networking Works

```
┌──────────────────────────────────────────────────────┐
│                     Docker Host                       │
│                                                       │
│   ┌─────────┐     ┌─────────┐     ┌─────────┐       │
│   │ client  │     │ server  │     │   api   │       │
│   │ eth0    │     │ eth0    │     │ eth0    │       │
│   └────┬────┘     └────┬────┘     └────┬────┘       │
│        │               │               │             │
│   ─────┴───────────────┴───────────────┴────────    │
│              Docker Bridge (br-xxxx)                 │
│              172.20.0.1 (gateway)                    │
│                         │                            │
│                    ┌────┴─────┐                      │
│                    │   NAT    │                      │
│                    └────┬─────┘                      │
└─────────────────────────┼────────────────────────────┘
                          │
                     Physical Network
```

### Task 7: Bridge Network Properties

User-defined bridges provide:

1. **Automatic DNS**: Containers can reach each other by name
2. **Better isolation**: Only connected containers communicate
3. **On-the-fly connection**: Add/remove containers without restart
4. **Configurable**: Custom subnets, gateways, options

Verify DNS works:
```bash
# From client container
nslookup server
nslookup api
```

### Task 8: Network Inspection Commands

Useful commands from the host:

```bash
# Show containers on a network
docker network inspect network-lab_frontend_net \
  --format '{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}'

# Show which networks a container uses
docker inspect client \
  --format '{{range $net, $config := .NetworkSettings.Networks}}{{$net}}: {{$config.IPAddress}}{{"\n"}}{{end}}'
```

## Key Takeaways

1. **Bridge = virtual switch** - Connects containers on same network
2. **User-defined > default** - Better DNS, isolation, flexibility
3. **Automatic DNS** - Containers resolve each other by name
4. **Gateway handles routing** - Docker manages NAT to external

## Verification Checklist

- [ ] Can list Docker networks
- [ ] Can inspect network details
- [ ] Understand default vs user-defined bridges
- [ ] Know why user-defined is preferred

## Next Exercise

Continue to [Exercise 2: Create Custom Networks](exercise-2.md)
