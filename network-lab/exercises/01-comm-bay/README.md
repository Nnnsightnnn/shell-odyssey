# Module 1: Network Basics

Welcome to the Network Learning Lab! In this module, you'll learn fundamental networking concepts through hands-on exploration.

## Learning Objectives

By the end of this module, you will:
- Understand IP addresses and how containers are addressed
- Test network connectivity using `ping`
- Understand DNS resolution and how names map to IPs
- Use basic network diagnostic tools

## Prerequisites

- Lab is running (`./start.sh` from network-lab directory)
- You're in the client container: `docker exec -it client bash`

## Lab Environment

```
┌─────────────────────────────────────────────┐
│           frontend_net (172.20.0.0/24)      │
├─────────────────────────────────────────────┤
│  client: 172.20.0.10    (you are here)      │
│  server: 172.20.0.20    (nginx web server)  │
│  api:    172.20.0.30    (Flask API)         │
│  dns:    172.20.0.53    (DNS server)        │
└─────────────────────────────────────────────┘
```

## Exercises

Complete these exercises in order:

1. **[Exercise 1: Explore Container IPs](exercise-1.md)**
   Discover your container's network configuration

2. **[Exercise 2: Test Connectivity](exercise-2.md)**
   Use ping to test network reachability

3. **[Exercise 3: DNS Resolution](exercise-3.md)**
   Understand how hostnames become IP addresses

## Quick Reference

| Command | Purpose |
|---------|---------|
| `ip addr` | Show IP addresses |
| `ping host` | Test connectivity |
| `dig host` | DNS lookup |
| `cat /etc/resolv.conf` | See DNS config |

## Next Module

After completing all exercises, proceed to [Module 2: Troubleshooting](../02-troubleshooting/README.md)
