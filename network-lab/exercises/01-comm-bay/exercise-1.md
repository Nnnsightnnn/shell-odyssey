# Exercise 1: Explore Container IPs

## Objective
Learn how to discover your container's network configuration and understand IP addressing.

## Background

Every container in Docker gets its own IP address. Understanding your network configuration is the first step in network troubleshooting.

Key concepts:
- **IP Address**: A unique identifier for a device on a network (e.g., 172.20.0.10)
- **Subnet**: A range of IP addresses (e.g., 172.20.0.0/24 means 172.20.0.1-172.20.0.254)
- **Network Interface**: The "port" your container uses to connect (usually `eth0`)

## Tasks

### Task 1: View Your IP Address

Run the following command to see all network interfaces:

```bash
ip addr
```

**Questions to answer:**
1. What is the IP address of your `eth0` interface?
2. What is the subnet mask (shown as /24, /16, etc.)?

<details>
<summary>Expected Output</summary>

You should see something like:
```
1: lo: <LOOPBACK,UP,LOWER_UP> ...
    inet 127.0.0.1/8 scope host lo
2: eth0@if42: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
    inet 172.20.0.10/24 brd 172.20.0.255 scope global eth0
```

Your IP is `172.20.0.10` with a `/24` subnet.
</details>

### Task 2: View Your Default Gateway

The gateway is how your container reaches other networks:

```bash
ip route
```

**Question:** What is your default gateway IP?

<details>
<summary>Expected Output</summary>

```
default via 172.20.0.1 dev eth0
172.20.0.0/24 dev eth0 proto kernel scope link src 172.20.0.10
```

The gateway is `172.20.0.1` (Docker creates this automatically).
</details>

### Task 3: View DNS Configuration

Check which DNS server your container uses:

```bash
cat /etc/resolv.conf
```

**Question:** What DNS server is configured?

<details>
<summary>Expected Output</summary>

```
nameserver 172.20.0.53
```

This is our custom DNS server in the lab!
</details>

### Task 4: Explore Other Containers

From the client, you can see what IP the `server` container has:

```bash
dig +short server
```

**Question:** What IP address does `server` resolve to?

## Key Takeaways

1. **ip addr** shows your container's IP addresses
2. **ip route** shows how traffic is routed
3. **/etc/resolv.conf** contains DNS server configuration
4. Each container has a unique IP within its network

## Verification

You've completed this exercise when you can answer:
- [ ] What is the client container's IP address?
- [ ] What subnet is it on?
- [ ] What's the default gateway?
- [ ] What DNS server is configured?

## Next Exercise

Continue to [Exercise 2: Test Connectivity](exercise-2.md)
