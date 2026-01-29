# Exercise 3: Inspect Cross-Network Traffic

## Objective
Learn to monitor traffic crossing network boundaries for security analysis.

## Background

Monitoring traffic at zone boundaries helps you:
- Detect unauthorized access attempts
- Understand application communication patterns
- Identify anomalous behavior
- Troubleshoot connectivity issues

The `monitor` container in our lab has access to both networks for this purpose.

## Tasks

### Task 1: Position the Monitor

The monitor container is on both networks:

```bash
docker exec monitor ip addr | grep inet
```

It can see traffic on both frontend (172.20.0.0/24) and backend (172.21.0.0/24).

### Task 2: Capture Frontend Traffic

Enter the monitor container:
```bash
docker exec -it monitor bash
```

Capture traffic on the frontend network:
```bash
tcpdump -i eth0 -n -c 20
```

In another terminal, generate traffic:
```bash
docker exec client curl http://server
docker exec client ping -c 2 api
```

**Observe:** You see the HTTP and ICMP traffic between frontend hosts.

### Task 3: Capture Backend Traffic

Still in monitor, find the backend interface:
```bash
ip addr
# Look for the interface with 172.21.x.x
```

Capture on that interface:
```bash
tcpdump -i eth1 -n -c 20
```

In another terminal, trigger API to database traffic:
```bash
docker exec client curl http://api:5000/db/status
```

**Observe:** You see the API connecting to PostgreSQL (port 5432).

### Task 4: Monitor Cross-Zone Communication

Watch specifically for traffic crossing the boundary (API):

```bash
# In monitor container
tcpdump -i any host 172.20.0.30 or host 172.21.0.30 -n
```

This captures all traffic to/from the API container (which is on both networks).

Generate cross-zone traffic:
```bash
docker exec client curl http://api:5000/info
docker exec client curl http://api:5000/db/status
```

### Task 5: Analyze HTTP Traffic

Capture HTTP content crossing zones:

```bash
tcpdump -i any port 5000 -A -n -c 50
```

Make an API call:
```bash
docker exec client curl http://api:5000/echo
```

**Observe:** You can see the HTTP headers and JSON response.

### Task 6: Identify Suspicious Patterns

What might indicate a problem?

1. **Unexpected connections:**
```bash
# Watch for connections to unusual ports
tcpdump -i eth0 'not port 80 and not port 5000 and not port 53'
```

2. **High volume from single source:**
```bash
# Count packets per source
tcpdump -i eth0 -n -c 100 | awk '{print $3}' | cut -d. -f1-4 | sort | uniq -c | sort -rn
```

3. **Failed connection attempts:**
```bash
# TCP RST (reset) packets indicate rejected connections
tcpdump -i eth0 'tcp[tcpflags] & tcp-rst != 0'
```

### Task 7: Create a Simple IDS Rule

Let's watch for port scanning (connection attempts to multiple ports):

```bash
# Watch for SYN packets (connection initiations)
tcpdump -i eth0 'tcp[tcpflags] == tcp-syn' -n
```

In another terminal, simulate a port scan:
```bash
docker exec client sh -c "for p in 22 80 443 3306 5432; do nc -zv server \$p 2>&1; done"
```

You should see the connection attempts in your capture.

### Task 8: Monitor DNS Queries

DNS reveals what hosts are being looked up:

```bash
tcpdump -i any port 53 -n
```

Generate DNS traffic:
```bash
docker exec client dig server
docker exec client dig database
docker exec client dig google.com
```

This shows:
- Internal lookups (server, database)
- External lookups (google.com forwarded upstream)

### Task 9: Save Captures for Analysis

For detailed analysis, save packets:

```bash
# Capture to file
tcpdump -i any -w /tmp/traffic.pcap -c 100 &

# Generate traffic
docker exec client curl http://server
docker exec client curl http://api:5000/health

# Wait for capture to complete
wait

# Analyze the file
tcpdump -r /tmp/traffic.pcap -n
tcpdump -r /tmp/traffic.pcap -A | head -100  # With content
```

### Task 10: Monitor Summary

Exit monitor and summarize what we learned:

```bash
exit
```

**Monitoring Strategy:**
1. **Place monitors at zone boundaries** - See what crosses
2. **Capture baseline traffic** - Know what's normal
3. **Alert on anomalies** - Unexpected patterns
4. **Log for forensics** - Keep captures for investigation

## Traffic Inspection Commands Reference

| Purpose | Command |
|---------|---------|
| All traffic | `tcpdump -i any` |
| Specific host | `tcpdump host 172.20.0.10` |
| Specific port | `tcpdump port 80` |
| HTTP content | `tcpdump -A port 80` |
| TCP flags | `tcpdump 'tcp[tcpflags] & tcp-syn != 0'` |
| Save to file | `tcpdump -w file.pcap` |
| Read from file | `tcpdump -r file.pcap` |

## Key Takeaways

1. **Monitor at boundaries** - Zone boundaries are critical inspection points
2. **Know your baseline** - Understand normal traffic patterns
3. **Content inspection reveals intent** - See what's actually being sent
4. **DNS tells the story** - Queries reveal reconnaissance
5. **Save for later** - pcap files enable deep analysis

## Verification Checklist

- [ ] Can position monitor on multiple networks
- [ ] Can capture cross-zone traffic
- [ ] Can analyze HTTP content in captures
- [ ] Understand what patterns to look for

## Module Complete!

You've completed Module 4: Network Security. You now understand:
- Network isolation as security control
- Designing segmented architectures
- Monitoring cross-network traffic

## Lab Complete!

Congratulations! You've completed the Network Learning Lab. You've learned:

- **Module 1:** Network fundamentals (IP, DNS, connectivity)
- **Module 2:** Troubleshooting (diagnosis, tcpdump, traceroute)
- **Module 3:** Docker networking (bridges, custom networks, multi-network)
- **Module 4:** Security (isolation, segmentation, monitoring)

### Next Steps

1. **Practice:** Recreate these scenarios in your own projects
2. **Explore:** Try overlay networks for multi-host setups
3. **Secure:** Apply segmentation to your Docker Compose files
4. **Monitor:** Set up real monitoring with Prometheus/Grafana

### Cleanup

When done with the lab:
```bash
cd network-lab
./start.sh stop
```

To remove everything:
```bash
docker compose down -v
docker network prune
```
