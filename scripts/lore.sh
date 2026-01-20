#!/bin/bash

# Shell Odyssey Lore System (Ship's Library)
# Provides etymology, mental models, and depth for shell commands

GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIBRARY_DIR="$GAME_DIR/odyssey/library"
ODYSSEY_DIR="$GAME_DIR/odyssey"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
DIM='\033[2m'
NC='\033[0m'

# Sector unlock mappings
# basics: always unlocked
# search: unlocked after engineering complete
# pipelines: unlocked after comms complete
# transform: unlocked after reactor complete
# concepts: unlocked after bridge complete (or all sectors)

check_sector_complete() {
    local sector="$1"
    local sector_dir="$ODYSSEY_DIR/$sector"

    # Check if .complete exists at sector root or all missions complete
    if [[ -f "$sector_dir/.complete" ]]; then
        return 0
    fi

    # Check for mission completions in subdirectories
    local missions_complete=true
    for mission_dir in "$sector_dir"/*/; do
        if [[ -d "$mission_dir" && -f "$mission_dir/.mission" ]]; then
            if [[ ! -f "$mission_dir/.complete" ]]; then
                missions_complete=false
                break
            fi
        fi
    done

    if $missions_complete; then
        return 0
    fi
    return 1
}

is_category_unlocked() {
    local category="$1"

    case "$category" in
        "basics")
            return 0  # Always unlocked
            ;;
        "search")
            check_sector_complete "engineering"
            return $?
            ;;
        "pipelines")
            check_sector_complete "comms"
            return $?
            ;;
        "transform")
            check_sector_complete "reactor"
            return $?
            ;;
        "concepts")
            # Unlocked after reactor (for now, since bridge is TBD)
            check_sector_complete "reactor"
            return $?
            ;;
        *)
            return 1
            ;;
    esac
}

get_unlock_requirement() {
    local category="$1"

    case "$category" in
        "search") echo "Complete Engineering sector" ;;
        "pipelines") echo "Complete Comms sector" ;;
        "transform") echo "Complete Reactor sector" ;;
        "concepts") echo "Complete Reactor sector" ;;
        *) echo "" ;;
    esac
}

find_lore_file() {
    local topic="$1"
    local lore_file=""

    # Search all categories for the topic
    for category in basics search pipelines transform concepts; do
        if [[ -f "$LIBRARY_DIR/$category/$topic.lore" ]]; then
            lore_file="$LIBRARY_DIR/$category/$topic.lore"
            echo "$category:$lore_file"
            return 0
        fi
    done

    return 1
}

list_topics() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              SHIP'S LIBRARY - ARCHIVE INDEX                   ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    for category in basics search pipelines transform concepts; do
        local category_upper=$(echo "$category" | tr '[:lower:]' '[:upper:]')
        local category_dir="$LIBRARY_DIR/$category"

        if is_category_unlocked "$category"; then
            echo -e "${GREEN}▸ $category_upper${NC}"

            if [[ -d "$category_dir" ]]; then
                shopt -s nullglob
                for lore_file in "$category_dir"/*.lore; do
                    local topic=$(basename "$lore_file" .lore)
                    echo -e "    ${CYAN}•${NC} $topic"
                done
                shopt -u nullglob
            fi
        else
            local requirement=$(get_unlock_requirement "$category")
            echo -e "${DIM}▸ $category_upper [LOCKED]${NC}"
            echo -e "    ${DIM}$requirement to unlock${NC}"
        fi
        echo ""
    done

    echo -e "${DIM}Usage: ./scripts/lore.sh <topic>${NC}"
    echo -e "${DIM}Example: ./scripts/lore.sh grep${NC}"
    echo ""
}

show_lore() {
    local topic="$1"

    # Find the lore file and its category
    local result=$(find_lore_file "$topic")

    if [[ -z "$result" ]]; then
        echo ""
        echo -e "${RED}[ARCHIVE NOT FOUND]${NC} No entry for '$topic'"
        echo ""
        echo "Available archives:"
        list_topics
        return 1
    fi

    local category=$(echo "$result" | cut -d':' -f1)
    local lore_file=$(echo "$result" | cut -d':' -f2-)

    # Check if category is unlocked
    if ! is_category_unlocked "$category"; then
        local requirement=$(get_unlock_requirement "$category")
        echo ""
        echo -e "${YELLOW}[ARCHIVE LOCKED]${NC} The '$topic' archive is not yet accessible."
        echo ""
        echo -e "${DIM}Requirement: $requirement${NC}"
        echo ""
        return 1
    fi

    # Display the lore file
    echo ""
    cat "$lore_file"
    echo ""
}

# Main
if [[ $# -eq 0 ]]; then
    list_topics
else
    show_lore "$1"
fi
