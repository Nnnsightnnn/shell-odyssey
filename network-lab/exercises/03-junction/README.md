# Module 3: Docker Networking Modes

This module explores how Docker implements networking and the different modes available.

## Learning Objectives

By the end of this module, you will:
- Understand Docker's default bridge networking
- Create and manage custom networks
- Connect containers to multiple networks
- Know when to use different network modes

## Prerequisites

- Completed Modules 1 and 2
- Lab is running
- Access to both container and host terminals

## Docker Network Types

| Type | Description | Use Case |
|------|-------------|----------|
| Bridge | Default, isolated network | Most containers |
| Host | Share host's network stack | Performance-critical |
| None | No networking | Maximum isolation |
| Overlay | Multi-host networking | Docker Swarm |
| Macvlan | Assign MAC address | Physical network integration |

## Exercises

1. **[Exercise 1: Bridge Networks](exercise-1.md)**
   Default vs user-defined bridges

2. **[Exercise 2: Create Custom Networks](exercise-2.md)**
   Build your own network topology

3. **[Exercise 3: Multi-Network Containers](exercise-3.md)**
   Connect containers to multiple networks

## Quick Reference

```bash
# List networks
docker network ls

# Inspect network
docker network inspect network-lab_frontend_net

# Create network
docker network create mynet

# Connect container to network
docker network connect mynet container_name

# Disconnect
docker network disconnect mynet container_name
```

## Next Module

After completing all exercises, proceed to [Module 4: Security](../04-security/README.md)
