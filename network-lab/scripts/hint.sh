#!/bin/bash

# Network Lab Hint System
# Provides contextual hints based on current directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"
EXERCISES_DIR="$LAB_DIR/exercises"
PROGRESS_DIR="$LAB_DIR/.progress"

# Colors
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m'

# Get current directory
CURRENT_DIR=$(pwd)

# Check if we're in the exercises directory
if [[ ! "$CURRENT_DIR" == "$EXERCISES_DIR"* ]]; then
    echo ""
    echo -e "${YELLOW}[HINT SYSTEM]${NC} You're not currently in a Network Lab exercise."
    echo ""
    echo "Navigate to an exercise first:"
    echo -e "  ${CYAN}cd $EXERCISES_DIR/01-comm-bay/ip-discovery${NC}"
    echo ""
    exit 0
fi

# Get the module and mission from path
RELATIVE_PATH="${CURRENT_DIR#$EXERCISES_DIR/}"
MODULE=$(echo "$RELATIVE_PATH" | cut -d'/' -f1)
MISSION=$(echo "$RELATIVE_PATH" | cut -d'/' -f2)

# Track hint usage
mkdir -p "$PROGRESS_DIR"
HINT_FILE="$PROGRESS_DIR/.hints_${MODULE}_${MISSION}"

if [[ -f "$HINT_FILE" ]]; then
    HINT_LEVEL=$(cat "$HINT_FILE")
else
    HINT_LEVEL=0
fi

# Increment hint level
HINT_LEVEL=$((HINT_LEVEL + 1))
echo "$HINT_LEVEL" > "$HINT_FILE"

echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       NETWORK LAB HINT SYSTEM          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${DIM}Location: $RELATIVE_PATH${NC}"
echo -e "${DIM}Hint level: $HINT_LEVEL${NC}"
echo ""

# Check for .hints file in current directory
HINTS_FILE="$CURRENT_DIR/.hints"

if [[ -f "$HINTS_FILE" ]]; then
    # Count total hints
    TOTAL_HINTS=$(grep -c "^HINT" "$HINTS_FILE" 2>/dev/null || echo "0")

    if [[ $HINT_LEVEL -gt $TOTAL_HINTS ]]; then
        HINT_LEVEL=$TOTAL_HINTS
    fi

    if [[ $TOTAL_HINTS -gt 0 ]]; then
        # Get the hint for this level
        # Format: HINT N: text (possibly multiline until next HINT)
        HINT=$(awk -v level="$HINT_LEVEL" '
            /^HINT [0-9]+:/ {
                if (match($0, /^HINT ([0-9]+):/, arr) && arr[1] == level) {
                    printing = 1
                    sub(/^HINT [0-9]+: */, "")
                    print
                    next
                } else if (printing) {
                    exit
                }
            }
            printing { print }
        ' "$HINTS_FILE")

        if [[ -z "$HINT" ]]; then
            # Fallback: try simpler extraction
            HINT=$(grep "^HINT $HINT_LEVEL:" "$HINTS_FILE" | sed "s/^HINT $HINT_LEVEL: *//")
        fi

        if [[ -n "$HINT" ]]; then
            echo -e "${YELLOW}$HINT${NC}"
            echo ""

            if [[ $HINT_LEVEL -lt $TOTAL_HINTS ]]; then
                echo -e "${DIM}Run hint.sh again for more help ($HINT_LEVEL/$TOTAL_HINTS)${NC}"
            else
                echo -e "${DIM}This is the most detailed hint available.${NC}"
            fi
        else
            echo "Hint not found. Check .hints file format."
        fi
    else
        echo "No hints available for this mission."
    fi
else
    # Generic hints based on module
    case "$MODULE" in
        "01-comm-bay")
            case $HINT_LEVEL in
                1) echo -e "${YELLOW}This module teaches network basics: IP addressing, connectivity, DNS.${NC}" ;;
                2) echo -e "${YELLOW}Key commands: ip addr, ip route, ping, dig, cat /etc/resolv.conf${NC}" ;;
                *) echo -e "${YELLOW}Read the .mission file carefully. Create the required file with your findings.${NC}" ;;
            esac
            ;;
        "02-diagnostic")
            case $HINT_LEVEL in
                1) echo -e "${YELLOW}This module teaches troubleshooting: diagnosis ladder, tcpdump, traceroute.${NC}" ;;
                2) echo -e "${YELLOW}Key commands: curl, nc -zv, tcpdump, traceroute, mtr${NC}" ;;
                *) echo -e "${YELLOW}Follow the diagnostic ladder: DNS -> Ping -> Port -> Protocol${NC}" ;;
            esac
            ;;
        "03-junction")
            case $HINT_LEVEL in
                1) echo -e "${YELLOW}This module covers Docker networking: bridges, custom networks, multi-network.${NC}" ;;
                2) echo -e "${YELLOW}Key commands: docker network ls, docker network inspect, docker network connect${NC}" ;;
                *) echo -e "${YELLOW}Run these commands from your HOST machine, not inside containers.${NC}" ;;
            esac
            ;;
        "04-security-hub")
            case $HINT_LEVEL in
                1) echo -e "${YELLOW}This module covers security: isolation, segmentation, monitoring.${NC}" ;;
                2) echo -e "${YELLOW}Key concepts: network isolation, three-tier architecture, zone boundaries${NC}" ;;
                *) echo -e "${YELLOW}Use tcpdump from the monitor container to see cross-zone traffic.${NC}" ;;
            esac
            ;;
        *)
            echo "No hints available for this area."
            ;;
    esac
fi

echo ""
