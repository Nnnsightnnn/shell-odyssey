# Shell Odyssey - Claude Context

A Bash-based terminal learning game that teaches shell commands through puzzles.

## Tech Stack

Bash 4.0+ | Pure Shell | Unix utilities (grep, find, sed, awk, etc.)

## Project Structure

```
/odyssey/     - Game content (sectors, missions, puzzles)
/scripts/     - Core game scripts (reset, progress, hints)
/.claude/     - Context and documentation
/.progress/   - Runtime progress tracking
```

---

## Critical Guard Rails

### 🎮 Game Integrity [GAME]

**[GAME-00001]** NEVER create `.complete` files manually
> TRIGGER: When modifying game content
> WHY: `.complete` files must only be created by `verify` scripts

**[GAME-00002]** NEVER modify verify scripts without understanding expected answers
> TRIGGER: When editing puzzles
> WHY: Verify scripts contain answer validation logic

**[GAME-00003]** Test changes with: `./scripts/reset.sh && ./install.sh`
> TRIGGER: After any game content changes

---

### 🔧 Development [DEV]

**[DEV-00001]** Full test flow: reset → install → play affected missions
> TRIGGER: Before committing puzzle changes
> COMMAND: `./scripts/reset.sh && ./install.sh && cd odyssey/SECTOR && ./verify`

**[DEV-00002]** Maintain Bash 4.0+ compatibility
> TRIGGER: When writing scripts
> CHECK: Avoid bash 5+ features, test on macOS default bash

**[DEV-00003]** Keep scripts portable (macOS/Linux sed differences)
> TRIGGER: When using sed -i
> FIX: Use `sed 's/x/y/g' file > file.tmp && mv file.tmp file`

---

### 🧠 Memory Check (REQUIRED)

**ALWAYS check first:** `.claude/memory/active/quick-reference.md`
> TRIGGER: Before starting any task

### ✅ Verification [VERIFY]

**[VERIFY-00001]** Read code before recommending changes
> TRIGGER: Before proposing ANY changes

### ⚡ Execution [EXEC]

**[EXEC-00001]** Parallelize independent operations
> TRIGGER: Before making tool calls

---

## Sector Overview

| Sector | Directory | Skills Taught | Missions |
|--------|-----------|---------------|----------|
| Tutorial | `odyssey/airlock/` | cat, echo, ls -la, basic nav | 2 |
| Sector 1 | `odyssey/engineering/` | find, grep, wc | 4 |
| Sector 2 | `odyssey/comms/` | pipes, cut, sort, awk | 4 |
| Sector 3 | `odyssey/reactor/` | sed, xargs, scripting | 4 |
| Sector 4 | `odyssey/bridge/` | Advanced (processes, curl) | TBD |

---

## Key Files

| File | Purpose |
|------|---------|
| `install.sh` | Main installer, verifies requirements |
| `scripts/reset.sh` | Clears progress, restores original state |
| `scripts/check-progress.sh` | Displays completion status |
| `scripts/hint.sh` | Contextual hint system |
| `odyssey/*/verify` | Mission verification scripts |

---

## Mission File Anatomy

```
mission_dir/
├── .scroll      # Sector intro (optional)
├── .mission     # Task description (required)
├── .hints       # Progressive hints (optional)
├── verify       # Verification script (required, executable)
├── .complete    # Created by verify on success (NEVER CREATE MANUALLY)
└── [data]       # Puzzle-specific files
```

---

## Quick Reference

**Memory**: `.claude/memory/active/quick-reference.md`
**Architecture**: `.claude/specs/architecture/layer-stack.md`
**Game Mechanics**: `.claude/specs/game-mechanics.md`
**Pain Points**: `.claude/pain-points/active-pain-points.md`

---

## Important Reminders

- Do what is asked; nothing more, nothing less
- Verify assumptions before acting
- Parallelize independent work
- Test full flow through affected missions before committing
