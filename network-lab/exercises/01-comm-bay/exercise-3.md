# Exercise 3: DNS Resolution

## Objective
Understand how DNS (Domain Name System) translates hostnames to IP addresses.

## Background

DNS is like a phone book for the internet. When you type `ping server`, your computer needs to find the IP address for "server". This process is called **DNS resolution**.

Our lab has a custom DNS server (dnsmasq) that knows about all our containers.

## Tasks

### Task 1: Basic DNS Lookup with dig

The `dig` command queries DNS servers directly:

```bash
dig server
```

**Find these in the output:**
1. The QUESTION section (what you asked)
2. The ANSWER section (the IP address)
3. The SERVER line (which DNS server answered)

<details>
<summary>Understanding the Output</summary>

```
;; QUESTION SECTION:
;server.                        IN      A

;; ANSWER SECTION:
server.                 0       IN      A       172.20.0.20

;; SERVER: 172.20.0.53#53(172.20.0.53)
```

- `A` record = IPv4 address
- `172.20.0.53` is our DNS server
</details>

### Task 2: Short Format

Get just the IP without all the extra info:

```bash
dig +short server
```

Try it for multiple hosts:
```bash
dig +short api
dig +short dns
dig +short client
```

### Task 3: Query Different Record Types

DNS has different record types. Try these:

```bash
# A record (IPv4 address)
dig server A

# AAAA record (IPv6 address)
dig server AAAA

# ANY record (all records)
dig server ANY
```

**Question:** Does `server` have an IPv6 address?

### Task 4: Reverse DNS Lookup

You can also look up a hostname from an IP address:

```bash
dig -x 172.20.0.20
```

**Question:** What hostname does 172.20.0.20 map to?

### Task 5: Query Specific DNS Server

Specify which DNS server to ask:

```bash
# Ask our lab DNS
dig @172.20.0.53 server

# Ask Google's DNS (won't know our containers)
dig @8.8.8.8 server
```

**Question:** Why does Google's DNS fail to resolve `server`?

<details>
<summary>Explanation</summary>

Google's DNS (8.8.8.8) only knows about public internet hostnames. It has no idea about our private lab containers. Our DNS server (172.20.0.53) is configured with custom entries for each container.
</details>

### Task 6: DNS for External Hosts

Our DNS can also resolve real internet addresses:

```bash
dig +short google.com
dig +short github.com
```

This works because our DNS forwards unknown queries to Google's DNS (8.8.8.8).

### Task 7: Alternative Tools

Try these other DNS tools:

```bash
# nslookup - simpler output
nslookup server

# host - even simpler
host server
host 172.20.0.20
```

### Task 8: DNS Resolution Process

Let's see how DNS actually works step by step:

```bash
# Check your DNS configuration
cat /etc/resolv.conf

# See if the system resolver works
getent hosts server
```

**The resolution process:**
1. Application calls getaddrinfo() or similar
2. System checks /etc/hosts (no match)
3. System queries DNS server in /etc/resolv.conf
4. DNS server returns the IP address
5. Application connects to that IP

### Task 9: Explore DNS Configuration

Look at what DNS entries are configured:

```bash
# Query for all lab.local entries
dig +short server.lab.local
dig +short web.lab.local
```

Our DNS has aliases! `web.lab.local` points to the same IP as `server`.

## Key Takeaways

1. **DNS translates names to IPs** - Essential for human-usable networking
2. **dig is the most detailed tool** - Shows exactly what DNS returns
3. **DNS servers can be chained** - Our lab DNS → Google DNS → root servers
4. **Private DNS** - Internal networks often have their own DNS
5. **Multiple tools exist** - dig, nslookup, host all query DNS differently

## Verification Checklist

- [ ] Can use dig to look up server's IP
- [ ] Understand A records vs other record types
- [ ] Can query a specific DNS server
- [ ] Know why external DNS can't resolve internal names
- [ ] Understand the DNS resolution process

## Module Complete!

You've completed Module 1: Network Basics. You now understand:
- Container IP addressing
- Basic connectivity testing with ping
- DNS resolution and troubleshooting

**Next Module:** [02-troubleshooting](../02-troubleshooting/README.md) - Learn to diagnose network problems
