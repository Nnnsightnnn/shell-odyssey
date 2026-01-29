#!/bin/bash

# Network Lab Progress Checker
# Shows completion status for all modules and missions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"
EXERCISES_DIR="$LAB_DIR/exercises"

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
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    NETWORK LAB PROGRESS REPORT                                ║
╚═══════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

total_missions=0
completed_missions=0

# Function to display module status
display_module() {
    local module_dir="$1"
    local module_name="$2"
    local module_desc="$3"

    if [[ ! -d "$module_dir" ]]; then
        return
    fi

    echo -e "${YELLOW}$module_name${NC} - $module_desc"

    local module_total=0
    local module_complete=0

    # Find all mission directories (directories with verify scripts)
    for mission_dir in "$module_dir"/*/; do
        if [[ -d "$mission_dir" ]]; then
            mission_name=$(basename "$mission_dir")

            # Skip if not a mission directory
            if [[ ! -f "$mission_dir/verify" ]] && [[ ! -f "$mission_dir/.mission" ]]; then
                continue
            fi

            ((module_total++))
            ((total_missions++))

            complete_file="$mission_dir/.complete"

            if [[ -f "$complete_file" ]]; then
                ((module_complete++))
                ((completed_missions++))
                echo -e "  ${GREEN}[x]${NC} $mission_name"
            else
                echo -e "  ${DIM}[ ]${NC} $mission_name"
            fi
        fi
    done

    if [[ $module_total -eq 0 ]]; then
        echo -e "  ${DIM}(no missions found)${NC}"
    else
        if [[ $module_complete -eq $module_total ]]; then
            echo -e "  ${GREEN}--- Module Complete! ---${NC}"
        else
            echo -e "  ${DIM}--- $module_complete/$module_total complete ---${NC}"
        fi
    fi
    echo ""
}

# Display each module
display_module "$EXERCISES_DIR/01-comm-bay" "Module 1: COMM-BAY" "Network Basics"
display_module "$EXERCISES_DIR/02-diagnostic" "Module 2: DIAGNOSTIC" "Troubleshooting"
display_module "$EXERCISES_DIR/03-junction" "Module 3: JUNCTION" "Docker Networks"
display_module "$EXERCISES_DIR/04-security-hub" "Module 4: SECURITY-HUB" "Network Security"

# Overall progress bar
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

if [[ $total_missions -gt 0 ]]; then
    percent=$((completed_missions * 100 / total_missions))
    bar_width=50
    filled=$((percent * bar_width / 100))
    empty=$((bar_width - filled))

    echo -n "OVERALL PROGRESS: ["
    echo -ne "${GREEN}"
    for ((i=0; i<filled; i++)); do echo -n "="; done
    echo -ne "${NC}"
    for ((i=0; i<empty; i++)); do echo -n " "; done
    echo "] $percent%"
    echo ""
    echo "Missions completed: $completed_missions / $total_missions"
else
    echo "No missions found. Make sure you're in the network-lab directory."
fi

echo ""

# Status messages
if [[ $completed_missions -eq 0 ]]; then
    echo -e "${DIM}Begin your training:${NC}"
    echo -e "  ${CYAN}cd $EXERCISES_DIR/01-comm-bay${NC}"
    echo -e "  ${CYAN}cat .scroll${NC}"
elif [[ $completed_missions -eq $total_missions ]] && [[ $total_missions -gt 0 ]]; then
    echo -e "${GREEN}CONGRATULATIONS! All modules complete! Network mastery achieved!${NC}"
elif [[ $percent -ge 75 ]]; then
    echo -e "${YELLOW}Almost there! The final missions await...${NC}"
elif [[ $percent -ge 50 ]]; then
    echo -e "${CYAN}Good progress! Keep exploring the network.${NC}"
elif [[ $percent -ge 25 ]]; then
    echo -e "${CYAN}You're learning the fundamentals. Continue to the next mission.${NC}"
fi

echo ""
