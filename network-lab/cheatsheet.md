# Network Learning Lab - Command Cheatsheet

Quick reference for networking commands available in the lab containers.

---

## Connectivity Testing

### ping - Test basic connectivity
```bash
# Basic ping
ping server

# Ping with count limit
ping -c 4 server

# Ping with interval (every 0.5 seconds)
ping -i 0.5 server

# Ping with specific packet size
ping -s 1000 server
```

### traceroute - Trace network path
```bash
# Basic traceroute
traceroute server

# Use TCP instead of UDP
traceroute -T server

# Use ICMP
traceroute -I server

# Limit hops
traceroute -m 5 server
```

### mtr - Combined ping + traceroute
```bash
# Interactive mode
mtr server

# Report mode (runs 10 cycles)
mtr -r server

# Show IP addresses only
mtr -n server
```

---

## DNS Tools

### dig - DNS queries
```bash
# Basic lookup
dig server

# Query specific record type
dig server A
dig server AAAA
dig server MX

# Query specific DNS server
dig @172.20.0.53 server

# Short answer only
dig +short server

# Trace DNS resolution path
dig +trace server

# Reverse lookup
dig -x 172.20.0.20
```

### nslookup - Simple DNS lookup
```bash
# Basic lookup
nslookup server

# Query specific DNS server
nslookup server 172.20.0.53

# Query specific record type
nslookup -type=A server
```

### host - Simple DNS lookup
```bash
# Basic lookup
host server

# Verbose output
host -v server

# Query specific type
host -t MX server
```

---

## HTTP/Service Testing

### curl - HTTP client
```bash
# Basic GET request
curl http://server

# Show response headers
curl -I http://server

# Show headers + body
curl -i http://server

# Verbose (see full request/response)
curl -v http://server

# POST request with data
curl -X POST -d "key=value" http://api:5000/echo

# POST with JSON
curl -X POST -H "Content-Type: application/json" \
     -d '{"key":"value"}' http://api:5000/echo

# Follow redirects
curl -L http://server

# Set timeout
curl --connect-timeout 5 http://server

# Download file
curl -O http://server/file.txt
```

### nc (netcat) - Network Swiss Army knife
```bash
# Test if port is open
nc -zv server 80

# Scan port range
nc -zv server 1-100

# Connect to port
nc server 80

# Listen on port
nc -l 8080

# Transfer file (receiver)
nc -l 8080 > received_file

# Transfer file (sender)
nc server 8080 < file_to_send
```

### wget - Download files
```bash
# Download file
wget http://server/index.html

# Download to specific location
wget -O output.html http://server/

# Quiet mode
wget -q http://server/index.html
```

---

## Connection Monitoring

### ss - Socket statistics (modern netstat)
```bash
# Show all TCP connections
ss -t

# Show all listening sockets
ss -l

# Show TCP and UDP
ss -tu

# Show listening with process names
ss -tlp

# Show all with numeric addresses
ss -tuln

# Show established connections
ss -t state established

# Filter by port
ss -t sport = :80
ss -t dport = :5432
```

### netstat - Network statistics (legacy)
```bash
# Show all connections
netstat -a

# Show TCP connections
netstat -t

# Show listening ports
netstat -l

# Show numeric addresses
netstat -n

# Combined: TCP listening, numeric
netstat -tln

# Show with process IDs
netstat -tlnp
```

---

## Packet Capture

### tcpdump - Capture network packets
```bash
# Capture all on interface
tcpdump -i eth0

# Capture specific host
tcpdump -i eth0 host server

# Capture specific port
tcpdump -i eth0 port 80

# Capture with ASCII output
tcpdump -i eth0 -A port 80

# Capture to file
tcpdump -i eth0 -w capture.pcap

# Read from file
tcpdump -r capture.pcap

# Capture HTTP requests
tcpdump -i eth0 -A 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'

# Show packet contents in hex
tcpdump -i eth0 -X port 80

# Capture DNS traffic
tcpdump -i eth0 port 53

# Limit packet count
tcpdump -i eth0 -c 10

# Don't resolve hostnames
tcpdump -i eth0 -n
```

### tshark - Wireshark CLI
```bash
# Capture packets
tshark -i eth0

# Capture with filter
tshark -i eth0 -f "port 80"

# Display filter
tshark -i eth0 -Y "http"

# Save to file
tshark -i eth0 -w capture.pcap
```

---

## Network Configuration

### ip - Network configuration
```bash
# Show all interfaces
ip addr

# Show specific interface
ip addr show eth0

# Show routing table
ip route

# Show neighbors (ARP table)
ip neigh

# Show link status
ip link
```

### ifconfig - Interface configuration (legacy)
```bash
# Show all interfaces
ifconfig

# Show specific interface
ifconfig eth0
```

### route - Routing table (legacy)
```bash
# Show routing table
route -n
```

---

## Docker Network Commands

Run these from the host (not inside containers):

```bash
# List networks
docker network ls

# Inspect network
docker network inspect network-lab_frontend_net

# See container IPs
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' client

# Connect container to network
docker network connect network-lab_backend_net client

# Disconnect container from network
docker network disconnect network-lab_backend_net client

# Create new network
docker network create --subnet=172.22.0.0/24 test_net
```

---

## Useful Combinations

### Find what's listening on a port
```bash
ss -tlnp | grep :80
```

### Test HTTP and see full exchange
```bash
curl -v http://server 2>&1 | head -50
```

### Capture HTTP traffic while making request
```bash
# Terminal 1
tcpdump -i eth0 -A port 80

# Terminal 2
curl http://server
```

### Check connectivity through the stack
```bash
# Layer 3: IP connectivity
ping -c 2 server

# Layer 4: TCP port open
nc -zv server 80

# Layer 7: HTTP works
curl -I http://server
```

### DNS debugging
```bash
# Check what DNS server is configured
cat /etc/resolv.conf

# Query that server directly
dig @172.20.0.53 server

# Trace full resolution
dig +trace server
```

---

## Environment Quick Reference

| Container | IP (frontend) | IP (backend) | Services |
|-----------|---------------|--------------|----------|
| client    | 172.20.0.10   | -            | netshoot |
| server    | 172.20.0.20   | -            | nginx:80 |
| api       | 172.20.0.30   | 172.21.0.30  | flask:5000 |
| database  | -             | 172.21.0.40  | postgres:5432 |
| dns       | 172.20.0.53   | 172.21.0.53  | dnsmasq:53 |
| monitor   | 172.20.0.100  | 172.21.0.100 | netshoot |
