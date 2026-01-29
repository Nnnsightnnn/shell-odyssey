# Exercise 2: Capture Packets with tcpdump

## Objective
Learn to capture and analyze network traffic using tcpdump.

## Background

`tcpdump` is a packet analyzer that lets you see the actual data flowing over the network. It's essential for understanding protocols and debugging complex issues.

**Important:** You need elevated privileges for packet capture. Our containers have the required capabilities.

## Tasks

### Task 1: Basic Capture

Start a basic capture on your network interface:

```bash
tcpdump -i eth0 -c 5
```

- `-i eth0` - Capture on interface eth0
- `-c 5` - Stop after 5 packets

Now generate some traffic in another terminal:
```bash
docker exec client ping -c 2 server
```

**Observe:** You should see ICMP echo request and reply packets.

### Task 2: Filter by Host

Capture only traffic to/from the server:

```bash
tcpdump -i eth0 host server -c 10
```

In another terminal, generate traffic:
```bash
docker exec client curl http://server
```

**Question:** What types of packets do you see?

### Task 3: Filter by Port

Capture only HTTP traffic (port 80):

```bash
tcpdump -i eth0 port 80 -c 20
```

Generate HTTP traffic:
```bash
curl http://server
```

You'll see the TCP handshake (SYN, SYN-ACK, ACK) followed by HTTP data.

### Task 4: Show Packet Contents

Add `-A` to see ASCII content:

```bash
tcpdump -i eth0 port 80 -A -c 20
```

Now make a request:
```bash
curl http://server
```

**Observe:** You can see the actual HTTP headers in the output!

Look for:
- `GET / HTTP/1.1` - The request
- `HTTP/1.1 200 OK` - The response
- The HTML content

### Task 5: Capture DNS Traffic

DNS uses port 53. Let's capture a DNS lookup:

```bash
# In one terminal, start capture
tcpdump -i eth0 port 53 -c 4

# In another terminal, do a DNS lookup
dig server
```

**Observe:** You should see the query going out and the response coming back.

### Task 6: Write to File

For detailed analysis, save packets to a file:

```bash
# Capture to file
tcpdump -i eth0 -w /tmp/capture.pcap -c 50 &

# Generate some traffic
curl http://server
curl http://api:5000/health
ping -c 2 server

# Read the capture
tcpdump -r /tmp/capture.pcap
```

### Task 7: Advanced Filters

tcpdump supports complex filters:

```bash
# HTTP GET requests only
tcpdump -i eth0 'tcp port 80 and (tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420)'

# Traffic to subnet
tcpdump -i eth0 net 172.20.0.0/24

# TCP SYN packets (connection starts)
tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0'

# Not from specific host
tcpdump -i eth0 not host dns
```

### Task 8: Monitor Mode (Using Monitor Container)

The `monitor` container is on both networks. Use it to see cross-network traffic:

```bash
# From host
docker exec -it monitor bash

# Inside monitor, capture backend traffic
tcpdump -i eth0 net 172.21.0.0/24 -c 10
```

In another terminal, trigger API to database communication:
```bash
docker exec client curl http://api:5000/db/status
```

### Task 9: Analyze a TCP Connection

Let's trace a complete HTTP connection:

```bash
tcpdump -i eth0 host server and port 80 -c 20
```

Then:
```bash
curl http://server
```

**Identify these packets:**
1. **SYN** - Client initiates connection (Flags [S])
2. **SYN-ACK** - Server acknowledges (Flags [S.])
3. **ACK** - Client confirms (Flags [.])
4. **PSH** - Data packets (Flags [P.])
5. **FIN** - Connection close (Flags [F.])

### Task 10: Practical Debug Scenario

Imagine HTTP requests are slow. Let's see why:

```bash
# Capture with timestamps
tcpdump -i eth0 -tttt port 80 -c 30
```

The `-tttt` shows precise timestamps. Look for:
- Time between SYN and SYN-ACK (connection latency)
- Time between request and response (server processing time)

## Key tcpdump Options

| Option | Purpose |
|--------|---------|
| `-i eth0` | Capture on interface |
| `-c N` | Stop after N packets |
| `-n` | Don't resolve hostnames |
| `-A` | Show ASCII content |
| `-X` | Show hex + ASCII |
| `-w file` | Write to file |
| `-r file` | Read from file |
| `-v`, `-vv` | Verbose output |
| `-tttt` | Full timestamp |

## Key Takeaways

1. **tcpdump sees everything** - Actual bytes on the wire
2. **Filters are essential** - Focus on relevant traffic
3. **TCP flags tell the story** - SYN, ACK, FIN show connection state
4. **Save for analysis** - Use `-w` for complex debugging
5. **ASCII mode reveals protocols** - `-A` shows HTTP clearly

## Verification Checklist

- [ ] Can capture packets on an interface
- [ ] Can filter by host and port
- [ ] Can view packet contents with `-A`
- [ ] Can identify TCP handshake packets
- [ ] Can save and read capture files

## Next Exercise

Continue to [Exercise 3: Trace Network Paths](exercise-3.md)
