# Exercise 2: Test Connectivity with Ping

## Objective
Learn to use `ping` to test network connectivity and understand what the results mean.

## Background

`ping` sends ICMP (Internet Control Message Protocol) echo requests to a host and waits for replies. It's the most basic network diagnostic tool.

What ping tells you:
- **Whether a host is reachable** - Did the packets arrive?
- **Round-trip time (RTT)** - How long did it take?
- **Packet loss** - Are packets being dropped?

## Tasks

### Task 1: Ping by IP Address

First, let's ping the server by its IP address:

```bash
ping -c 4 172.20.0.20
```

The `-c 4` means "send 4 packets then stop."

**Questions:**
1. Did all 4 packets receive replies?
2. What was the average round-trip time?

<details>
<summary>Expected Output</summary>

```
PING 172.20.0.20 (172.20.0.20) 56(84) bytes of data.
64 bytes from 172.20.0.20: icmp_seq=1 ttl=64 time=0.123 ms
64 bytes from 172.20.0.20: icmp_seq=2 ttl=64 time=0.089 ms
64 bytes from 172.20.0.20: icmp_seq=3 ttl=64 time=0.091 ms
64 bytes from 172.20.0.20: icmp_seq=4 ttl=64 time=0.088 ms

--- 172.20.0.20 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3055ms
rtt min/avg/max/mdev = 0.088/0.097/0.123/0.014 ms
```
</details>

### Task 2: Ping by Hostname

Now ping using the hostname instead:

```bash
ping -c 4 server
```

**Questions:**
1. Does this work? What does that tell you about DNS?
2. What IP address does the ping resolve to?

### Task 3: Ping Across Networks

Try to ping the database container:

```bash
ping -c 2 database
```

**Question:** Does this work? Why or why not?

<details>
<summary>Explanation</summary>

This should **fail** because:
- The `database` container (172.21.0.40) is on `backend_net`
- The `client` container is only on `frontend_net`
- There's no route between these networks from the client

This is **network isolation** in action - a key security feature!
</details>

### Task 4: Verify API Connectivity

The `api` container is on both networks. Let's verify:

```bash
ping -c 2 api
```

**Question:** This should succeed. Why can we reach `api` but not `database`?

<details>
<summary>Explanation</summary>

The `api` container has interfaces on both networks:
- `172.20.0.30` on frontend_net (reachable by client)
- `172.21.0.30` on backend_net (reachable by database)

It acts as a bridge between the two network segments.
</details>

### Task 5: Understanding Ping Failure

Let's ping something that doesn't exist:

```bash
ping -c 2 nonexistent
```

**Question:** What error message do you get?

<details>
<summary>Expected Output</summary>

```
ping: nonexistent: Name or service not known
```

This is a DNS failure - the name couldn't be resolved to an IP.
</details>

Now try:

```bash
ping -c 2 172.20.0.250
```

**Question:** How is this failure different from the DNS failure?

<details>
<summary>Expected Output</summary>

You might see no response (packets lost) or "Destination Host Unreachable". This is a connectivity failure - DNS worked (we used an IP directly) but the host isn't there.
</details>

## Key Takeaways

1. `ping` tests basic connectivity (Layer 3)
2. Successful ping = network path exists and host responds
3. Failed ping could mean: DNS failure, no route, host down, or firewall
4. Docker networks provide isolation - containers only reach networks they're attached to

## Verification Checklist

- [ ] Successfully pinged server by IP
- [ ] Successfully pinged server by hostname
- [ ] Understood why database is unreachable
- [ ] Understood why api is reachable
- [ ] Can differentiate between DNS failure and connectivity failure

## Next Exercise

Continue to [Exercise 3: DNS Resolution](exercise-3.md)
