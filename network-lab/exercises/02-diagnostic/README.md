# Module 2: Network Troubleshooting

This module teaches you how to diagnose and debug network problems using professional tools.

## Learning Objectives

By the end of this module, you will:
- Diagnose connection failures systematically
- Capture and analyze network packets
- Trace network paths and identify bottlenecks
- Use the right tool for each troubleshooting scenario

## Prerequisites

- Completed Module 1: Network Basics
- Lab is running
- You're in the client container: `docker exec -it client bash`

## The Troubleshooting Mindset

When debugging network issues, work through the layers:

```
Layer 7: Application    (HTTP 404? API error?)
Layer 4: Transport      (TCP connection refused? Port closed?)
Layer 3: Network        (Can't ping? No route?)
Layer 2: Data Link      (ARP issues? MAC problems?)
Layer 1: Physical       (Cable unplugged? - less relevant in Docker)
```

Start from the bottom and work up!

## Exercises

1. **[Exercise 1: Diagnose Connection Failures](exercise-1.md)**
   Systematic approach to finding why connections fail

2. **[Exercise 2: Capture Packets with tcpdump](exercise-2.md)**
   See actual network traffic in real-time

3. **[Exercise 3: Trace Network Paths](exercise-3.md)**
   Understand how packets travel through the network

## Troubleshooting Quick Reference

| Symptom | First Tool | What to Check |
|---------|------------|---------------|
| Can't reach host | ping | Basic connectivity |
| DNS not working | dig | DNS resolution |
| Port seems closed | nc -zv | TCP connection |
| Slow response | mtr | Path latency |
| Need to see traffic | tcpdump | Packet capture |

## Next Module

After completing all exercises, proceed to [Module 3: Docker Networks](../03-docker-networks/README.md)
