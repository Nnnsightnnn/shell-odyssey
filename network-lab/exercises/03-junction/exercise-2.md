# Exercise 2: Create Custom Networks

## Objective
Learn to create and configure your own Docker networks.

## Tasks

### Task 1: Create a Simple Network

From your **host machine**:

```bash
# Create a new bridge network
docker network create testnet

# Verify it was created
docker network ls | grep testnet

# Inspect it
docker network inspect testnet
```

**Notice:** Docker automatically assigned a subnet (probably 172.x.0.0/16).

### Task 2: Create a Network with Custom Subnet

For predictable IPs, specify the subnet:

```bash
# Create network with specific subnet
docker network create \
  --subnet=172.30.0.0/24 \
  --gateway=172.30.0.1 \
  customnet

# Verify the configuration
docker network inspect customnet --format '{{.IPAM.Config}}'
```

### Task 3: Run Containers on Custom Network

```bash
# Start a container on the custom network
docker run -d --name custom-server \
  --network customnet \
  nginx:alpine

# Start another container
docker run -d --name custom-client \
  --network customnet \
  nicolaka/netshoot \
  sleep 3600

# Verify they can communicate
docker exec custom-client ping -c 2 custom-server
```

### Task 4: Assign Specific IPs

You can assign specific IPs when using custom subnets:

```bash
# Stop the existing container
docker rm -f custom-server

# Recreate with specific IP
docker run -d --name custom-server \
  --network customnet \
  --ip 172.30.0.100 \
  nginx:alpine

# Verify the IP
docker exec custom-client ping -c 2 172.30.0.100
```

### Task 5: Network Options

Create a network with additional options:

```bash
# Create with internal flag (no external access)
docker network create \
  --internal \
  --subnet=172.31.0.0/24 \
  isolated-net

# Test it - container can't reach external networks
docker run --rm --network isolated-net nicolaka/netshoot \
  ping -c 1 8.8.8.8
# This should fail!

# But containers on the network can still communicate
```

### Task 6: Explore Network Labels

Add labels for organization:

```bash
docker network create \
  --subnet=172.32.0.0/24 \
  --label env=testing \
  --label project=learning-lab \
  labeled-net

# Find networks by label
docker network ls --filter label=env=testing
```

### Task 7: Compare Our Lab Networks

Inspect our actual lab networks:

```bash
# Frontend network
docker network inspect network-lab_frontend_net --format '
Subnet: {{range .IPAM.Config}}{{.Subnet}}{{end}}
Gateway: {{range .IPAM.Config}}{{.Gateway}}{{end}}
Containers: {{range .Containers}}{{.Name}} {{end}}'

# Backend network
docker network inspect network-lab_backend_net --format '
Subnet: {{range .IPAM.Config}}{{.Subnet}}{{end}}
Gateway: {{range .IPAM.Config}}{{.Gateway}}{{end}}
Containers: {{range .Containers}}{{.Name}} {{end}}'
```

**Notice:** The `api`, `dns`, and `monitor` containers appear on both networks.

### Task 8: Cleanup Test Networks

```bash
# Remove containers first
docker rm -f custom-server custom-client 2>/dev/null

# Remove networks
docker network rm testnet customnet isolated-net labeled-net 2>/dev/null
```

### Task 9: Network Creation in Compose

Look at how our lab defines networks in `docker-compose.yml`:

```yaml
networks:
  frontend_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/24
          gateway: 172.20.0.1

  backend_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.21.0.0/24
          gateway: 172.21.0.1
```

Key points:
- `driver: bridge` - Uses bridge networking
- `ipam.config` - IP Address Management settings
- `subnet` - The network range
- `gateway` - The default gateway for containers

## Network Creation Options

| Option | Purpose | Example |
|--------|---------|---------|
| `--subnet` | Define IP range | `--subnet=172.30.0.0/24` |
| `--gateway` | Set gateway IP | `--gateway=172.30.0.1` |
| `--ip-range` | Limit assignable IPs | `--ip-range=172.30.0.128/25` |
| `--internal` | No external access | `--internal` |
| `--attachable` | Allow manual attachment | `--attachable` |
| `--label` | Add metadata | `--label env=prod` |

## Key Takeaways

1. **Custom subnets** - Give you predictable IP addresses
2. **Internal networks** - Provide extra isolation
3. **Labels** - Help organize networks
4. **Compose simplifies** - Define networks declaratively

## Verification Checklist

- [ ] Created a network with custom subnet
- [ ] Ran containers on custom network
- [ ] Assigned specific IPs to containers
- [ ] Understand internal network option
- [ ] Cleaned up test resources

## Next Exercise

Continue to [Exercise 3: Multi-Network Containers](exercise-3.md)
