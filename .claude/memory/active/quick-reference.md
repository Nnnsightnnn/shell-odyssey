# Shell Odyssey Quick Reference

Top patterns for working on this project. Check this FIRST before any task.

---

## [MISSION-FILES]

**Quick Check**: Every mission directory needs these files

| File | Required | Purpose |
|------|----------|---------|
| `.mission` | Yes | Task description |
| `verify` | Yes | Solution checker (must be executable) |
| `.scroll` | No | Sector intro (usually at sector root) |
| `.hints` | No | Progressive hints |
| `.complete` | NO - created by verify | Completion marker |

**Common Mistake**: Creating `.complete` manually - always let `verify` create it

**See Also**: `.claude/specs/game-mechanics.md`

---

## [VERIFY-SCRIPT]

**Quick Check**: Standard structure for verify scripts

```bash
#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Check file exists
if [[ ! -f "$SCRIPT_DIR/answer.txt" ]]; then
    echo -e "${RED}[FAILED]${NC} File not found."
    exit 1
fi

# 2. Read answer (strip whitespace)
ANSWER=$(cat "$SCRIPT_DIR/answer.txt" | tr -d '[:space:]')

# 3. Validate
if [[ "$ANSWER" == "expected" ]]; then
    echo -e "${GREEN}[SUCCESS]${NC}"
    touch "$SCRIPT_DIR/.complete"  # CRITICAL
else
    echo -e "${RED}[FAILED]${NC} Got: '$ANSWER'"
    exit 1
fi
```

**Common Mistake**: Forgetting `$SCRIPT_DIR` prefix for file paths

---

## [COLOR-OUTPUT]

**Quick Check**: Standard color variables

```bash
RED='\033[0;31m'      # Errors, failures
GREEN='\033[0;32m'    # Success, completion
YELLOW='\033[1;33m'   # Warnings, commands
CYAN='\033[0;36m'     # Headers, borders
DIM='\033[2m'         # Secondary info
NC='\033[0m'          # Reset (No Color)
```

**Usage**: `echo -e "${GREEN}[SUCCESS]${NC} Message"`

---

## [PROGRESS-TRACKING]

**Quick Check**: How completion works

1. Player solves puzzle
2. `./verify` checks solution
3. Success → `touch .complete`
4. `check-progress.sh` scans for `.complete` files

**View Progress**: `./scripts/check-progress.sh`

**Reset Progress**: `./scripts/reset.sh`

**Common Mistake**: Checking for `.complete` existence instead of letting verify create it

---

## [HINT-FORMAT]

**Quick Check**: Progressive hints in `.hints` files

```
HINT 1: General guidance (what command category)
HINT 2: More specific (which flags to use)
HINT 3: Nearly the answer (exact command structure)
```

**How It Works**:
- Player runs `./scripts/hint.sh`
- Each call shows next hint level
- Tracked in `.progress/.hints_SECTOR_MISSION`

**Fallback**: If no `.hints` file, `hint.sh` uses generic sector hints

---

## [TESTING-WORKFLOW]

**Quick Check**: Full test cycle

```bash
# Reset everything
./scripts/reset.sh

# Reinstall
./install.sh

# Play through mission
cd odyssey/SECTOR/MISSION
cat .mission
# ... solve puzzle ...
./verify

# Check overall progress
./scripts/check-progress.sh
```

**Test Single Mission**:
```bash
rm odyssey/sector/mission/.complete
cd odyssey/sector/mission
./verify
```

---

## [SECTOR-OVERVIEW]

| Sector | Directory | Skills | Missions |
|--------|-----------|--------|----------|
| Tutorial | `airlock/` | cat, echo, ls -la | 2 |
| Sector 1 | `engineering/` | find, grep, wc | 4 |
| Sector 2 | `comms/` | pipes, cut, sort, awk | 4 |
| Sector 3 | `reactor/` | sed, xargs, scripting | 4 |
| Sector 4 | `bridge/` | Advanced | TBD |

---

## [FILE-LOCATIONS]

| What | Where |
|------|-------|
| Main installer | `/install.sh` |
| Reset script | `/scripts/reset.sh` |
| Progress checker | `/scripts/check-progress.sh` |
| Hint system | `/scripts/hint.sh` |
| Game content | `/odyssey/` |
| Progress data | `/.progress/` |
| Original backups | `/.originals/` |

---

## [PORTABLE-SED]

**Quick Check**: macOS vs Linux sed differences

```bash
# macOS requires '' for in-place, Linux doesn't
# PORTABLE: Use temp file approach
sed 's/old/new/g' file > file.tmp && mv file.tmp file

# Or detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/old/new/g' file
else
    sed -i 's/old/new/g' file
fi
```

**Common Mistake**: Using `sed -i` without empty string on macOS

---

## [BASH-COMPAT]

**Quick Check**: Bash 4.0+ features used

- Associative arrays (`declare -A`)
- `${var,,}` lowercase transform
- `mapfile` / `readarray`

**Install on macOS**: `brew install bash`

**Check Version**: `echo $BASH_VERSION` (need 4.0+)

---

**Last Updated**: 2026-01-19
**Pattern Count**: 10
**Next Review**: 2026-01-26
