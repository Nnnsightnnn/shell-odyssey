# Exercise 3: Trace Network Paths

## Objective
Learn to trace the path packets take through the network and identify routing issues.

## Background

When packets travel from source to destination, they may pass through multiple routers. `traceroute` and `mtr` show you each hop along the way.

In our Docker environment, paths are simple (usually 1-2 hops), but these tools are essential for real-world debugging.

## Tasks

### Task 1: Basic Traceroute

Trace the path to the server:

```bash
traceroute server
```

**Observe:** In our Docker network, you'll likely see just 1 hop (direct connection on the same bridge network).

<details>
<summary>Expected Output</summary>

```
traceroute to server (172.20.0.20), 30 hops max, 60 byte packets
 1  server (172.20.0.20)  0.123 ms  0.045 ms  0.042 ms
```

Only one hop - the server is directly reachable.
</details>

### Task 2: Traceroute to External Host

Try tracing to an external address:

```bash
traceroute -m 10 8.8.8.8
```

- `-m 10` limits to 10 hops

**Observe:** You'll see the path through Docker's networking out to the internet.

### Task 3: Different Traceroute Methods

traceroute can use different protocols:

```bash
# UDP (default)
traceroute server

# ICMP (like ping)
traceroute -I server

# TCP (useful when ICMP is blocked)
traceroute -T -p 80 server
```

**Note:** Some networks block ICMP. TCP traceroute can work when ICMP fails.

### Task 4: Understanding Traceroute Output

Each line shows:
```
hop_number  hostname (ip)  time1  time2  time3
```

The three times are separate probes. Inconsistent times might indicate:
- Network congestion
- Load balancing (different paths)
- Rate limiting

Try:
```bash
traceroute -q 1 server
```

The `-q 1` sends only 1 probe per hop instead of 3.

### Task 5: Using mtr (My Traceroute)

`mtr` combines ping and traceroute, continuously monitoring:

```bash
mtr server
```

This runs interactively. Press `q` to quit.

**Key columns:**
- `Loss%` - Packet loss percentage
- `Avg` - Average latency
- `Best/Wrst` - Best and worst latency

### Task 6: mtr Report Mode

For a quick report without interactive mode:

```bash
mtr -r -c 10 server
```

- `-r` - Report mode
- `-c 10` - Send 10 packets

This is great for sharing diagnostics.

### Task 7: Diagnose Routing Issues

Check your routing table:

```bash
ip route
```

**Understand each line:**
- `default via X.X.X.X` - Where unknown destinations go
- `172.20.0.0/24 dev eth0` - Direct connection to local subnet

Try to trace to the database:

```bash
traceroute 172.21.0.40
```

**Question:** Why does this fail?

<details>
<summary>Explanation</summary>

Your container has no route to 172.21.0.0/24. The traceroute will either:
- Fail immediately (no route)
- Go to the default gateway and get lost

This is the routing layer showing you the network isolation.
</details>

### Task 8: Compare Paths

From client, trace to api:
```bash
traceroute api
```

Now enter the monitor container (which is on both networks):
```bash
# From host
docker exec -it monitor bash

# From monitor
traceroute api
traceroute database
```

**Observe:** The monitor can reach both, while client can only reach api.

### Task 9: Path Analysis Checklist

When debugging routing:

```bash
# 1. Check your IP
ip addr show eth0

# 2. Check your routes
ip route

# 3. Check which interface for a destination
ip route get 172.20.0.20
ip route get 172.21.0.40

# 4. Check ARP table (Layer 2)
ip neigh
```

### Task 10: Latency Investigation

If something is slow, mtr helps identify where:

```bash
# Run for longer to catch intermittent issues
mtr -r -c 100 server
```

Look for:
- High `Loss%` at a specific hop
- Spike in `Avg` latency at a hop
- Increasing latency along the path

## Tool Comparison

| Tool | Best For | Pros | Cons |
|------|----------|------|------|
| traceroute | One-time path check | Simple, always available | Limited statistics |
| mtr | Ongoing monitoring | Real-time, statistics | Requires installation |
| ip route | Local routing check | Shows your perspective | Only local info |

## Key Takeaways

1. **traceroute shows the path** - Every router between you and destination
2. **mtr provides statistics** - Loss and latency over time
3. **No route = no connection** - Routing is fundamental
4. **Different protocols help** - TCP traceroute when ICMP blocked
5. **Docker networks are isolated** - Routes only exist where networks connect

## Verification Checklist

- [ ] Can run traceroute to a destination
- [ ] Understand traceroute output format
- [ ] Can use mtr for continuous monitoring
- [ ] Understand routing table output
- [ ] Can identify routing failures

## Module Complete!

You've completed Module 2: Network Troubleshooting. You now have skills to:
- Systematically diagnose connection failures
- Capture and analyze network packets
- Trace network paths

**Next Module:** [03-docker-networks](../03-docker-networks/README.md) - Deep dive into Docker networking modes
