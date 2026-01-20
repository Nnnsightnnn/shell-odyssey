#!/bin/bash

# Shell Odyssey Hint System
# Provides contextual hints based on current directory

GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HINT_COUNT_FILE="$GAME_DIR/.progress/.hint_count"

# Colors
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m'

# Get current directory relative to odyssey
CURRENT_DIR=$(pwd)
ODYSSEY_DIR="$GAME_DIR/odyssey"

# Check if we're in the game directory
if [[ ! "$CURRENT_DIR" == "$ODYSSEY_DIR"* ]]; then
    echo ""
    echo -e "${YELLOW}[HINT SYSTEM]${NC} You're not currently in the Odyssey."
    echo ""
    echo "Navigate to a mission area first:"
    echo -e "  ${CYAN}cd ~/shell-odyssey/odyssey/airlock${NC}"
    echo ""
    exit 0
fi

# Get the room (immediate directory name within odyssey)
RELATIVE_PATH="${CURRENT_DIR#$ODYSSEY_DIR/}"
ROOM=$(echo "$RELATIVE_PATH" | cut -d'/' -f1)
SUBROOM=$(echo "$RELATIVE_PATH" | cut -d'/' -f2)

# Track hint usage
mkdir -p "$(dirname "$HINT_COUNT_FILE")"
ROOM_HINT_FILE="$GAME_DIR/.progress/.hints_${ROOM}_${SUBROOM}"
if [[ -f "$ROOM_HINT_FILE" ]]; then
    HINT_LEVEL=$(cat "$ROOM_HINT_FILE")
else
    HINT_LEVEL=0
fi

# Increment hint level
HINT_LEVEL=$((HINT_LEVEL + 1))
echo "$HINT_LEVEL" > "$ROOM_HINT_FILE"

echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║        ODYSSEY HINT SYSTEM             ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${DIM}Location: $RELATIVE_PATH${NC}"
echo -e "${DIM}Hint level: $HINT_LEVEL${NC}"
echo ""

# Check for .hints file in current directory
HINTS_FILE="$CURRENT_DIR/.hints"

if [[ -f "$HINTS_FILE" ]]; then
    # Read the hint for the current level
    TOTAL_HINTS=$(grep -c "^HINT" "$HINTS_FILE" 2>/dev/null || echo "0")

    if [[ $HINT_LEVEL -gt $TOTAL_HINTS ]]; then
        HINT_LEVEL=$TOTAL_HINTS
    fi

    if [[ $TOTAL_HINTS -gt 0 ]]; then
        # Extract the hint for this level
        HINT=$(sed -n "/^HINT $HINT_LEVEL:/,/^HINT [0-9]*:/p" "$HINTS_FILE" | head -n -1 | tail -n +1 | sed 's/^HINT [0-9]*: *//')

        if [[ -z "$HINT" ]]; then
            # Try getting the last hint if our level exceeds available
            HINT=$(grep "^HINT $TOTAL_HINTS:" "$HINTS_FILE" | sed 's/^HINT [0-9]*: *//')
        fi

        echo -e "${YELLOW}$HINT${NC}"
        echo ""

        if [[ $HINT_LEVEL -lt $TOTAL_HINTS ]]; then
            echo -e "${DIM}Run hint.sh again for a more specific hint ($((HINT_LEVEL))/$TOTAL_HINTS)${NC}"
        else
            echo -e "${DIM}This is the most specific hint available.${NC}"
        fi
    else
        echo "No hints configured for this room."
    fi
else
    # Generic hints based on room type
    case "$ROOM" in
        "airlock")
            case $HINT_LEVEL in
                1) echo -e "${YELLOW}Start by reading everything: cat .scroll and cat .mission${NC}" ;;
                2) echo -e "${YELLOW}Use ls -la to see all files, including hidden ones${NC}" ;;
                *) echo -e "${YELLOW}Follow the mission instructions carefully. The answer is in the files.${NC}" ;;
            esac
            ;;
        "engineering")
            case $HINT_LEVEL in
                1) echo -e "${YELLOW}This sector tests your ability to find and search files.${NC}" ;;
                2) echo -e "${YELLOW}Key commands: find, grep, wc, tree${NC}" ;;
                3) echo -e "${YELLOW}Use 'man <command>' to learn about command options.${NC}" ;;
                *) echo -e "${YELLOW}grep -r searches recursively. find can filter by type, name, and more.${NC}" ;;
            esac
            ;;
        "comms")
            case $HINT_LEVEL in
                1) echo -e "${YELLOW}This sector is about processing and transforming data.${NC}" ;;
                2) echo -e "${YELLOW}Key commands: pipes (|), head, tail, sort, uniq, cut, awk${NC}" ;;
                3) echo -e "${YELLOW}Chain commands together: cmd1 | cmd2 | cmd3${NC}" ;;
                *) echo -e "${YELLOW}cut -d',' -f2 extracts the second comma-separated field.${NC}" ;;
            esac
            ;;
        "reactor")
            case $HINT_LEVEL in
                1) echo -e "${YELLOW}This sector involves scripting and automated repairs.${NC}" ;;
                2) echo -e "${YELLOW}Key commands: sed, xargs, chmod, shell scripting${NC}" ;;
                3) echo -e "${YELLOW}sed 's/old/new/g' replaces text. xargs converts input to arguments.${NC}" ;;
                *) echo -e "${YELLOW}Write scripts to automate repetitive tasks.${NC}" ;;
            esac
            ;;
        "bridge")
            case $HINT_LEVEL in
                1) echo -e "${YELLOW}Advanced operations: processes, networking, version control.${NC}" ;;
                2) echo -e "${YELLOW}Key commands: ps, kill, curl, git, ssh${NC}" ;;
                *) echo -e "${YELLOW}Use ps aux to see running processes. curl fetches remote data.${NC}" ;;
            esac
            ;;
        *)
            echo "No hints available for this area."
            ;;
    esac
fi

echo ""
