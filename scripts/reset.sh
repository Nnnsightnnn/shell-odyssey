#!/bin/bash

# Shell Odyssey Reset Script
# Restores the game to its initial state

GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ODYSSEY_DIR="$GAME_DIR/odyssey"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

QUIET=false
if [[ "$1" == "--quiet" ]] || [[ "$1" == "-q" ]]; then
    QUIET=true
fi

if [[ "$QUIET" == false ]]; then
    echo ""
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║              ODYSSEY SYSTEM RESET                         ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
    echo -e "${YELLOW}WARNING:${NC} This will reset all game progress and restore"
    echo "         all files to their original state."
    echo ""
    read -p "Are you sure you want to reset? (y/N): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Reset cancelled."
        echo ""
        exit 0
    fi
fi

if [[ "$QUIET" == false ]]; then
    echo ""
    echo -e "${YELLOW}[RESET]${NC} Clearing progress markers..."
fi

# Remove all .complete files
find "$ODYSSEY_DIR" -name ".complete" -type f -delete 2>/dev/null

if [[ "$QUIET" == false ]]; then
    echo -e "${GREEN}[  OK  ]${NC} Progress markers cleared"
    echo -e "${YELLOW}[RESET]${NC} Clearing hint history..."
fi

# Remove hint tracking files
rm -rf "$GAME_DIR/.progress/.hints_"* 2>/dev/null
rm -f "$GAME_DIR/.progress/.hint_count" 2>/dev/null

if [[ "$QUIET" == false ]]; then
    echo -e "${GREEN}[  OK  ]${NC} Hint history cleared"
    echo -e "${YELLOW}[RESET]${NC} Restoring modified files..."
fi

# Restore any files that might have been modified by puzzles
# This restores files from the .originals backup if it exists
BACKUP_DIR="$GAME_DIR/.originals"
if [[ -d "$BACKUP_DIR" ]]; then
    cp -r "$BACKUP_DIR/"* "$ODYSSEY_DIR/" 2>/dev/null
    if [[ "$QUIET" == false ]]; then
        echo -e "${GREEN}[  OK  ]${NC} Original files restored"
    fi
else
    if [[ "$QUIET" == false ]]; then
        echo -e "${GREEN}[  OK  ]${NC} No backup files to restore"
    fi
fi

# Remove any player-created files in sandbox areas
SANDBOX_DIRS=("$ODYSSEY_DIR/reactor/sandbox" "$ODYSSEY_DIR/comms/workspace")
for sandbox in "${SANDBOX_DIRS[@]}"; do
    if [[ -d "$sandbox" ]]; then
        # Remove everything except .gitkeep
        find "$sandbox" -type f ! -name ".gitkeep" -delete 2>/dev/null
        find "$sandbox" -type d -empty -delete 2>/dev/null
    fi
done

# Ensure .hidden directories are properly locked/unlocked based on progress
# (In initial state, some should be hidden)

if [[ "$QUIET" == false ]]; then
    echo -e "${GREEN}[  OK  ]${NC} Sandbox areas cleared"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}Reset complete!${NC}"
    echo ""
    echo "The Odyssey has been restored to its initial state."
    echo "Begin your mission again:"
    echo ""
    echo -e "  ${YELLOW}cd ~/shell-odyssey/odyssey/airlock${NC}"
    echo -e "  ${YELLOW}cat .scroll${NC}"
    echo ""
fi
