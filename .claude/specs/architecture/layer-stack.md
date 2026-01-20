# Shell Odyssey Architecture

## Overview

Shell Odyssey is a Bash-based terminal learning game that teaches shell commands through puzzles. Players navigate a spaceship solving missions using `grep`, `find`, `awk`, `sed`, etc.

---

## Layer Stack

```mermaid
graph TB
    subgraph "Layer 4: Player Interface"
        L4[Directory Navigation<br/>cd, ls, cat, pwd]
    end

    subgraph "Layer 3: Content"
        L3A[.mission files]
        L3B[.scroll files]
        L3C[.hints files]
        L3D[Data files<br/>manifest.txt, logs/, etc.]
    end

    subgraph "Layer 2: Game Engine"
        L2A[verify scripts]
        L2B[.complete markers]
        L2C[Progress tracking<br/>.progress/]
    end

    subgraph "Layer 1: Core Scripts"
        L1A[install.sh]
        L1B[scripts/reset.sh]
        L1C[scripts/check-progress.sh]
        L1D[scripts/hint.sh]
    end

    subgraph "Layer 0: External Dependencies"
        L0[Bash 4.0+ | grep | find | sed | awk | cut | sort | uniq | wc | head | tail]
    end

    L4 --> L3A
    L4 --> L3B
    L3A --> L2A
    L2A --> L2B
    L2B --> L2C
    L1C --> L2C
    L1D --> L3C
    L1B --> L2B
    L1A --> L1B
    L1A --> L0
```

---

## Layer Details

### Layer 0: External Dependencies

**No external dependencies** - only standard Unix utilities.

| Utility | Purpose |
|---------|---------|
| Bash 4.0+ | Shell interpreter, associative arrays |
| grep | Pattern matching in files |
| find | File/directory search |
| sed | Stream editing, text transforms |
| awk | Text processing, field extraction |
| cut | Column extraction |
| sort | Sorting data |
| uniq | Deduplication |
| wc | Counting lines/words/chars |
| head/tail | File viewing |

### Layer 1: Core Scripts

| Script | Location | Purpose |
|--------|----------|---------|
| `install.sh` | `/install.sh` | Setup game, verify requirements, initialize state |
| `reset.sh` | `/scripts/reset.sh` | Clear progress, restore original files |
| `check-progress.sh` | `/scripts/check-progress.sh` | Display completion status per sector |
| `hint.sh` | `/scripts/hint.sh` | Contextual hint system based on location |

### Layer 2: Game Engine

**Verification System**:
- Each mission has a `verify` script that checks player solution
- Success creates a `.complete` marker file
- Progress tracked via `.complete` file presence

**Progress Tracking**:
- `.progress/` directory stores hint usage
- `check-progress.sh` scans for `.complete` files
- Associative array defines sector names and order

### Layer 3: Content

| File Type | Purpose | Example |
|-----------|---------|---------|
| `.scroll` | Sector introduction, ASCII art, story | Airlock welcome message |
| `.mission` | Task description, objectives, hints | "Count crew members" |
| `.hints` | Progressive hint system (HINT 1:, HINT 2:, etc.) | Step-by-step help |
| Data files | Puzzle content (logs, configs, manifests) | `manifest.txt` |

### Layer 4: Player Interface

Players interact entirely through standard shell navigation:
- `cd` to move between sectors/missions
- `ls -la` to discover hidden files
- `cat` to read scrolls, missions, hints
- Standard Unix commands to solve puzzles
- `./verify` to check solutions

---

## Directory Structure

```
shell-odyssey/
├── install.sh                 # L1: Main installer
├── scripts/
│   ├── check-progress.sh      # L1: Progress display
│   ├── reset.sh               # L1: Game reset
│   └── hint.sh                # L1: Hint system
├── odyssey/                   # Game content root
│   ├── airlock/               # Tutorial sector
│   │   ├── .scroll            # L3: Sector intro
│   │   ├── .mission           # L3: Task description
│   │   ├── .hints             # L3: Progressive hints
│   │   ├── verify             # L2: Solution checker
│   │   ├── manifest.txt       # L3: Puzzle data
│   │   └── equipment_bay/     # Sub-mission
│   ├── engineering/           # Sector 1: find, grep
│   │   ├── logs/
│   │   ├── schematics/
│   │   └── diagnostics/
│   ├── comms/                 # Sector 2: pipes, text processing
│   │   ├── transmissions/
│   │   ├── signals/
│   │   └── decrypted/
│   ├── reactor/               # Sector 3: sed, scripting
│   │   ├── core/
│   │   ├── cooling/
│   │   └── scripts/
│   └── bridge/                # Sector 4: advanced ops
├── .progress/                 # L2: Hint tracking
└── .originals/                # Backup for reset
```

---

## Sector Progression

| Sector | Directory | Skills Taught | Missions |
|--------|-----------|---------------|----------|
| Tutorial | `airlock/` | Basic navigation, cat, echo | 2 |
| Sector 1 | `engineering/` | find, grep, wc | 4 |
| Sector 2 | `comms/` | pipes, cut, sort, awk | 4 |
| Sector 3 | `reactor/` | sed, xargs, scripting | 4 |
| Sector 4 | `bridge/` | Advanced (processes, curl) | TBD |

---

## Data Flow

```
Player Action → verify script → Check solution → Create .complete → Update progress
                    │
                    ├── Success: .complete created, show next step
                    │
                    └── Failure: Show error, suggest hints
```

---

## Key Design Principles

1. **Pure Bash**: No external dependencies beyond standard Unix utilities
2. **File-based state**: Progress tracked via `.complete` marker files
3. **Progressive disclosure**: Story reveals as sectors complete
4. **Portable**: Works on macOS and Linux with Bash 4.0+
5. **Self-contained**: Each mission directory has all needed files
