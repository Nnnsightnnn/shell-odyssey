# Exercise 1: Diagnose Connection Failures

## Objective
Learn a systematic approach to diagnosing why network connections fail.

## The Diagnostic Ladder

When a connection fails, check these in order:

1. **DNS** - Can you resolve the hostname?
2. **Ping** - Can you reach the IP?
3. **Port** - Is the service port open?
4. **Protocol** - Does the application respond?

## Scenario Setup

Let's troubleshoot a "broken" connection to the API.

### Task 1: The Problem

Try this command:

```bash
curl http://api:5000/health
```

This should work. Now let's simulate failures and learn to diagnose them.

### Task 2: Diagnose DNS Failures

Imagine curl returns "Could not resolve host". Here's how to diagnose:

```bash
# Step 1: Can we resolve the name?
dig +short api

# Step 2: Is DNS reachable?
ping -c 1 172.20.0.53

# Step 3: What's in resolv.conf?
cat /etc/resolv.conf

# Step 4: Try direct query to DNS server
dig @172.20.0.53 api
```

**Practice:** Try resolving a fake hostname and observe the failure:
```bash
dig +short fakehost
# Returns nothing - DNS failure
```

### Task 3: Diagnose Connectivity Failures

If DNS works but you can't connect:

```bash
# Step 1: Get the IP
dig +short api
# Returns: 172.20.0.30

# Step 2: Can we ping it?
ping -c 2 172.20.0.30

# Step 3: Check routing
ip route get 172.20.0.30
```

**Practice:** Try pinging the database (you can't reach it):
```bash
ping -c 2 172.21.0.40
```

What does the failure look like?

### Task 4: Diagnose Port/Service Failures

DNS works, ping works, but the service doesn't respond:

```bash
# Step 1: Is the port open?
nc -zv api 5000
# Should say "succeeded" or "open"

# Step 2: What about a wrong port?
nc -zv api 8080
# Should fail

# Step 3: Check with ss what's listening (on the target)
# From monitor container you could run:
# ss -tuln
```

**Practice:** Check which ports are open on server:
```bash
nc -zv server 80    # Should succeed (nginx)
nc -zv server 443   # Might fail (no HTTPS configured)
nc -zv server 22    # Should fail (no SSH)
```

### Task 5: Full Diagnostic Workflow

Let's put it all together. Run this diagnostic sequence:

```bash
TARGET="api"
PORT="5000"

echo "=== Diagnosing connection to $TARGET:$PORT ==="

echo -e "\n[1] DNS Resolution:"
IP=$(dig +short $TARGET)
if [ -z "$IP" ]; then
    echo "FAIL: Cannot resolve $TARGET"
else
    echo "OK: $TARGET -> $IP"
fi

echo -e "\n[2] Ping Test:"
if ping -c 1 -W 2 $TARGET > /dev/null 2>&1; then
    echo "OK: $TARGET is reachable"
else
    echo "FAIL: Cannot ping $TARGET"
fi

echo -e "\n[3] Port Check:"
if nc -zv -w 2 $TARGET $PORT 2>&1 | grep -q succeeded; then
    echo "OK: Port $PORT is open"
else
    echo "FAIL: Port $PORT is closed or filtered"
fi

echo -e "\n[4] HTTP Check:"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://$TARGET:$PORT/health 2>/dev/null)
if [ "$RESPONSE" = "200" ]; then
    echo "OK: HTTP 200 received"
else
    echo "FAIL: HTTP response: $RESPONSE"
fi
```

### Task 6: Common Failure Patterns

| Symptom | Likely Cause | Tool to Use |
|---------|--------------|-------------|
| "Could not resolve" | DNS failure | dig |
| "No route to host" | Network isolation | ip route |
| "Connection refused" | Service not running | nc -zv |
| "Connection timed out" | Firewall or no listener | tcpdump |
| HTTP 5xx | Application error | curl -v |

### Task 7: Practice Diagnosis

Try to connect to the database from client:

```bash
curl http://database:5432
```

Walk through the diagnostic steps:
1. Can you resolve "database"?
2. Can you ping the IP?
3. What's different about this failure?

<details>
<summary>Analysis</summary>

```bash
# DNS works!
dig +short database
# Returns: 172.21.0.40

# But ping fails
ping -c 1 172.21.0.40
# No response - network unreachable

# Why? Check your routes
ip route
# There's no route to 172.21.0.0/24
```

The database is on a different network (backend_net) that the client can't reach.
</details>

## Key Takeaways

1. **Work systematically** - DNS → Ping → Port → Protocol
2. **Match symptoms to layers** - Each failure type indicates a specific problem
3. **Use the right tool** - dig for DNS, ping for connectivity, nc for ports
4. **Network isolation is intentional** - Not being able to reach something might be by design

## Verification Checklist

- [ ] Can diagnose DNS failures
- [ ] Can diagnose connectivity failures
- [ ] Can diagnose port/service failures
- [ ] Understand the diagnostic workflow

## Next Exercise

Continue to [Exercise 2: Packet Capture](exercise-2.md)
