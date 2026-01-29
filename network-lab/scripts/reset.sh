#!/bin/bash

# Network Lab Reset Script
# Clears all progress and restores to initial state

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"
EXERCISES_DIR="$LAB_DIR/exercises"
PROGRESS_DIR="$LAB_DIR/.progress"

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
╔═══════════════════════════════════════════════════════════════════════════════╗
║                       NETWORK LAB RESET                                       ║
╚═══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
    echo -e "${YELLOW}WARNING:${NC} This will reset all progress and clear:"
    echo "  - All .complete markers"
    echo "  - Hint tracking"
    echo "  - Any files you created in mission directories"
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
    echo -e "${YELLOW}[RESET]${NC} Clearing completion markers..."
fi

# Remove all .complete files
find "$EXERCISES_DIR" -name ".complete" -type f -delete 2>/dev/null

if [[ "$QUIET" == false ]]; then
    echo -e "${GREEN}[  OK  ]${NC} Completion markers cleared"
    echo -e "${YELLOW}[RESET]${NC} Clearing hint history..."
fi

# Remove hint tracking files
rm -rf "$PROGRESS_DIR"/.hints_* 2>/dev/null

if [[ "$QUIET" == false ]]; then
    echo -e "${GREEN}[  OK  ]${NC} Hint history cleared"
    echo -e "${YELLOW}[RESET]${NC} Removing user-created files..."
fi

# Remove common user-created files from mission directories
# Be careful to only remove expected answer files
for mission_dir in "$EXERCISES_DIR"/*/*/; do
    if [[ -d "$mission_dir" ]]; then
        # Remove common answer files
        rm -f "$mission_dir/network_info.txt" 2>/dev/null
        rm -f "$mission_dir/ping_results.txt" 2>/dev/null
        rm -f "$mission_dir/dns_report.txt" 2>/dev/null
        rm -f "$mission_dir/diagnosis.txt" 2>/dev/null
        rm -f "$mission_dir/capture_analysis.txt" 2>/dev/null
        rm -f "$mission_dir/capture.pcap" 2>/dev/null
        rm -f "$mission_dir/path_report.txt" 2>/dev/null
        rm -f "$mission_dir/bridge_info.txt" 2>/dev/null
        rm -f "$mission_dir/network_creation.txt" 2>/dev/null
        rm -f "$mission_dir/multi_net.txt" 2>/dev/null
        rm -f "$mission_dir/isolation_test.txt" 2>/dev/null
        rm -f "$mission_dir/segmentation_design.txt" 2>/dev/null
        rm -f "$mission_dir/monitoring_report.txt" 2>/dev/null
        rm -f "$mission_dir"/*.pcap 2>/dev/null
    fi
done

if [[ "$QUIET" == false ]]; then
    echo -e "${GREEN}[  OK  ]${NC} User files removed"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}Reset complete!${NC}"
    echo ""
    echo "The Network Lab has been restored to its initial state."
    echo "Begin your training:"
    echo ""
    echo -e "  ${YELLOW}cd $EXERCISES_DIR/01-comm-bay${NC}"
    echo -e "  ${YELLOW}cat .scroll${NC}"
    echo ""
fi
