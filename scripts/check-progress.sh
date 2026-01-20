#!/bin/bash

# Shell Odyssey Progress Checker
# Shows completion status for all sectors

GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ODYSSEY_DIR="$GAME_DIR/odyssey"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m'

echo ""
echo -e "${CYAN}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║           ODYSSEY MISSION STATUS REPORT                   ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

total_missions=0
completed_missions=0

# Function to display sector status
display_sector() {
    local sector_dir="$1"
    local sector_name="$2"

    if [[ ! -d "$sector_dir" ]]; then
        return
    fi

    echo -e "${YELLOW}▸ $sector_name${NC}"

    local sector_total=0
    local sector_complete=0

    # Find all .mission files in this sector (including subdirectories)
    while IFS= read -r mission_file; do
        mission_dir=$(dirname "$mission_file")
        mission_name=$(basename "$mission_dir")
        complete_file="$mission_dir/.complete"

        ((sector_total++))
        ((total_missions++))

        if [[ -f "$complete_file" ]]; then
            ((sector_complete++))
            ((completed_missions++))
            echo -e "  ${GREEN}[✓]${NC} $mission_name"
        else
            echo -e "  ${DIM}[ ]${NC} $mission_name"
        fi
    done < <(find "$sector_dir" -maxdepth 2 -name ".mission" -type f 2>/dev/null | sort)

    if [[ $sector_total -eq 0 ]]; then
        echo -e "  ${DIM}(no missions found)${NC}"
    else
        if [[ $sector_complete -eq $sector_total ]]; then
            echo -e "  ${GREEN}── Sector Complete! ──${NC}"
        else
            echo -e "  ${DIM}── $sector_complete/$sector_total complete ──${NC}"
        fi
    fi
    echo ""
}

# Display each sector
display_sector "$ODYSSEY_DIR/airlock" "AIRLOCK (Tutorial)"
display_sector "$ODYSSEY_DIR/engineering" "ENGINEERING (Sector 1)"
display_sector "$ODYSSEY_DIR/comms" "COMMUNICATIONS (Sector 2)"
display_sector "$ODYSSEY_DIR/reactor" "REACTOR (Sector 3)"
display_sector "$ODYSSEY_DIR/bridge" "BRIDGE (Bonus)"

# Overall progress bar
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

if [[ $total_missions -gt 0 ]]; then
    percent=$((completed_missions * 100 / total_missions))
    bar_width=40
    filled=$((percent * bar_width / 100))
    empty=$((bar_width - filled))

    echo -n "OVERALL PROGRESS: ["
    echo -ne "${GREEN}"
    for ((i=0; i<filled; i++)); do echo -n "█"; done
    echo -ne "${NC}"
    for ((i=0; i<empty; i++)); do echo -n "░"; done
    echo "] $percent%"
    echo ""
    echo "Missions completed: $completed_missions / $total_missions"
else
    echo "No missions found. Run install.sh to set up the game."
fi

echo ""

# Special messages based on progress
if [[ $completed_missions -eq 0 ]]; then
    echo -e "${DIM}Begin your journey in the airlock: cd ~/shell-odyssey/odyssey/airlock${NC}"
elif [[ $completed_missions -eq $total_missions ]] && [[ $total_missions -gt 0 ]]; then
    echo -e "${GREEN}★ CONGRATULATIONS! All systems restored! The Odyssey is saved! ★${NC}"
elif [[ $percent -ge 75 ]]; then
    echo -e "${YELLOW}The ship's systems are nearly restored. You're almost there!${NC}"
elif [[ $percent -ge 50 ]]; then
    echo -e "${CYAN}Good progress, Operator. The crew is counting on you.${NC}"
fi

echo ""
