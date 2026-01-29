# Module 4: Network Security & Isolation

This module explores how network architecture provides security through isolation and controlled access.

## Learning Objectives

By the end of this module, you will:
- Understand network isolation as a security mechanism
- Design segmented network architectures
- Monitor and inspect cross-network traffic
- Apply security best practices to container networking

## Prerequisites

- Completed Modules 1-3
- Lab is running
- Understanding of multi-network containers

## Security Principles

1. **Least Privilege** - Containers only access what they need
2. **Defense in Depth** - Multiple layers of protection
3. **Segmentation** - Separate concerns into isolated networks
4. **Visibility** - Monitor traffic to detect anomalies

## Lab Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Network Segmentation                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  [Frontend Zone - 172.20.0.0/24]                            │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                     │
│  │ client  │  │ server  │  │   api   │                     │
│  │(trusted)│  │ (web)   │  │(gateway)│                     │
│  └─────────┘  └─────────┘  └────┬────┘                     │
│                                  │                          │
│  ─────────────────────────────── │ ─────────────────────── │
│                                  │                          │
│  [Backend Zone - 172.21.0.0/24]  │                         │
│                            ┌─────┴─────┐  ┌─────────┐      │
│                            │    api    │  │database │      │
│                            │(connects) │  │(isolated│      │
│                            └───────────┘  └─────────┘      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Exercises

1. **[Exercise 1: Network Isolation Demo](exercise-1.md)**
   See isolation in action

2. **[Exercise 2: Segment Frontend/Backend](exercise-2.md)**
   Design secure network architecture

3. **[Exercise 3: Traffic Inspection](exercise-3.md)**
   Monitor cross-network communication

## Security Quick Reference

| Principle | Implementation |
|-----------|----------------|
| Isolation | Separate networks per tier |
| Least privilege | Connect only needed networks |
| Gateway pattern | API bridges frontend/backend |
| Monitoring | Use tcpdump/monitor container |
