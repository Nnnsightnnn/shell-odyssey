# Shell Odyssey Game Mechanics

## Mission File Anatomy

Each mission location contains these files:

```
mission_directory/
├── .scroll        # Optional: Sector/story introduction (ASCII art)
├── .mission       # Required: Task description and objectives
├── .hints         # Optional: Progressive hint file
├── verify         # Required: Executable verification script
├── .complete      # Created by verify on success (DO NOT CREATE MANUALLY)
└── [data files]   # Puzzle-specific content
```

---

## File Formats

### `.scroll` - Sector Introduction

Story-focused, ASCII art welcome. Sets the scene.

```
    ╔═══════════════════════════════════════╗
    ║    SECTOR NAME                        ║
    ╚═══════════════════════════════════════╝

    [Story text and ASCII art]

    SKILLS:
    • command1 - description
    • command2 - description

    Begin your mission: cat .mission
```

### `.mission` - Task Description

Structured mission briefing with clear objectives.

```
╔═══════════════════════════════════════════════════════════════╗
║  MISSION: [MISSION NAME]                                      ║
║  DIFFICULTY: [Tutorial | Easy | Medium | Hard]                ║
║  STATUS: In Progress                                          ║
╚═══════════════════════════════════════════════════════════════╝

OBJECTIVE:
[Clear description of what player must accomplish]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TASK: [Task Name]
──────────────────
[Detailed instructions]

VERIFICATION:
When ready, run:  ./verify

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HINTS:
• [Basic hint 1]
• [Basic hint 2]

AVAILABLE FILES:
• file1.txt  - Description
• file2.log  - Description
```

### `.hints` - Progressive Hints

Format: `HINT N:` followed by the hint text.

```
HINT 1: Start by examining the available files with ls -la
HINT 2: Use grep to search for the specific pattern mentioned
HINT 3: The answer is in the error.log file on line 42
```

**Hint levels**: Players run `hint.sh` repeatedly to reveal more specific hints.

---

## Puzzle Types

### Type 1: File Creation

Player creates a file with a specific answer.

**Example**: Count crew members, write number to `crew_count.txt`

```bash
# verify script pattern
if [[ ! -f "answer.txt" ]]; then
    echo -e "${RED}[FAILED]${NC} File 'answer.txt' not found."
    exit 1
fi

ANSWER=$(cat answer.txt | tr -d '[:space:]')
if [[ "$ANSWER" == "expected_value" ]]; then
    echo -e "${GREEN}[SUCCESS]${NC} Correct!"
    touch .complete
else
    echo -e "${RED}[FAILED]${NC} Incorrect: '$ANSWER'"
    exit 1
fi
```

### Type 2: Code Submission

Player writes a command/script to a file that produces correct output.

**Example**: Write a grep command to `solution.sh`

```bash
# verify script pattern
if [[ ! -f "solution.sh" ]]; then
    echo -e "${RED}[FAILED]${NC} File 'solution.sh' not found."
    exit 1
fi

RESULT=$(bash solution.sh 2>/dev/null)
EXPECTED="expected_output"

if [[ "$RESULT" == "$EXPECTED" ]]; then
    echo -e "${GREEN}[SUCCESS]${NC} Command produced correct output!"
    touch .complete
else
    echo -e "${RED}[FAILED]${NC} Unexpected output"
    exit 1
fi
```

### Type 3: Search & Report

Player finds information and reports it.

**Example**: Find the file containing an error code

```bash
# verify script pattern
ANSWER=$(cat report.txt | tr -d '[:space:]')
EXPECTED_FILE="logs/subsystem/error_2847.log"

if [[ "$ANSWER" == "$EXPECTED_FILE" ]]; then
    echo -e "${GREEN}[SUCCESS]${NC} File located!"
    touch .complete
else
    echo -e "${RED}[FAILED]${NC} Incorrect file path"
    exit 1
fi
```

---

## Verification Script Standard Pattern

```bash
#!/bin/bash

# Mission Verification Script

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     VERIFICATION PROTOCOL INITIATED        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""

# 1. Check required file exists
if [[ ! -f "$SCRIPT_DIR/answer_file.txt" ]]; then
    echo -e "${RED}[FAILED]${NC} Required file not found."
    echo ""
    echo "Create the file with your answer:"
    echo "  echo <answer> > answer_file.txt"
    echo ""
    exit 1
fi

# 2. Read and validate answer
ANSWER=$(cat "$SCRIPT_DIR/answer_file.txt" | tr -d '[:space:]')

# 3. Check correctness
if [[ "$ANSWER" == "expected_answer" ]]; then
    echo -e "${GREEN}[SUCCESS]${NC} Verification passed!"
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         MISSION COMPLETE!                  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""

    # 4. Create completion marker (CRITICAL)
    touch "$SCRIPT_DIR/.complete"

    # 5. Story continuation
    echo "ARIA: Well done, Operator."
    echo ""
    echo "Your next task awaits:"
    echo -e "  ${YELLOW}cd next_location${NC}"
    echo ""
else
    echo -e "${RED}[FAILED]${NC} Incorrect answer: '$ANSWER'"
    echo ""
    echo "Hint: [helpful hint about expected answer]"
    echo ""
    exit 1
fi
```

---

## Progress Tracking

### How `.complete` Files Work

1. Player solves puzzle correctly
2. `verify` script runs final check
3. On success: `touch "$SCRIPT_DIR/.complete"`
4. `check-progress.sh` scans for `.complete` files
5. Progress displayed per sector

### Checking Progress

```bash
./scripts/check-progress.sh
```

Output:
```
▸ AIRLOCK (Tutorial)
  [✓] airlock
  [✓] equipment_bay
  ── Sector Complete! ──

▸ ENGINEERING (Sector 1)
  [✓] logs
  [ ] schematics
  [ ] diagnostics
  ── 1/3 complete ──
```

---

## Hint System Mechanics

### Hint File Format

```
HINT 1: General guidance
HINT 2: More specific direction
HINT 3: Nearly the answer (use sparingly)
```

### How `hint.sh` Works

1. Tracks hint level per room in `.progress/.hints_ROOM_SUBROOM`
2. Each call increments hint level
3. Reads appropriate HINT N from `.hints` file
4. Falls back to generic hints if no `.hints` file

### Fallback Hints (in `hint.sh`)

```bash
case "$ROOM" in
    "airlock")
        echo "Start by reading everything: cat .scroll and cat .mission"
        ;;
    "engineering")
        echo "Key commands: find, grep, wc, tree"
        ;;
    # ... etc
esac
```

---

## Testing Workflow

### Full Reset → Install → Play Cycle

```bash
# 1. Reset all progress
./scripts/reset.sh

# 2. Reinstall (resets state quietly)
./install.sh

# 3. Navigate to mission
cd odyssey/airlock
cat .scroll
cat .mission

# 4. Solve puzzle
# ... player actions ...

# 5. Verify
./verify

# 6. Check progress
./scripts/check-progress.sh
```

### Testing a Single Mission

```bash
# Remove just this mission's completion
rm odyssey/engineering/logs/.complete

# Navigate and re-test
cd odyssey/engineering/logs
./verify
```

---

## Color Code Conventions

| Color | Variable | Usage |
|-------|----------|-------|
| Red | `$RED` | Errors, failures |
| Green | `$GREEN` | Success, completion |
| Yellow | `$YELLOW` | Warnings, commands to run |
| Cyan | `$CYAN` | Headers, decorative borders |
| Dim | `$DIM` | Secondary info, hints remaining |
| NC | `$NC` | Reset (No Color) |

Standard definitions:
```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m'
```

---

## Creating New Missions

1. Create directory under appropriate sector
2. Create `.mission` file with task description
3. Create `verify` script (executable: `chmod +x verify`)
4. Create data files needed for puzzle
5. Optional: Create `.hints` file
6. Test: `./scripts/reset.sh && ./install.sh`
7. Play through mission to verify difficulty

### Checklist

- [ ] `.mission` has clear objective
- [ ] `verify` is executable
- [ ] `verify` creates `.complete` on success
- [ ] `verify` gives helpful error messages
- [ ] Answer is not trivially obvious
- [ ] At least 2-3 hints provided
- [ ] Mission teaches intended skill
- [ ] Tested full flow: reset → solve → verify
