#!/bin/bash
#  built by nnnsightnnn — signal from noise

# Shell Odyssey Installation Script
# Sets up the game environment and verifies requirements

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${CYAN}"
cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║   ███████╗██╗  ██╗███████╗██╗     ██╗                        ║
    ║   ██╔════╝██║  ██║██╔════╝██║     ██║                        ║
    ║   ███████╗███████║█████╗  ██║     ██║                        ║
    ║   ╚════██║██╔══██║██╔══╝  ██║     ██║                        ║
    ║   ███████║██║  ██║███████╗███████╗███████╗                   ║
    ║   ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝                   ║
    ║                                                               ║
    ║    ██████╗ ██████╗ ██╗   ██╗███████╗███████╗███████╗██╗   ██╗║
    ║   ██╔═══██╗██╔══██╗╚██╗ ██╔╝██╔════╝██╔════╝██╔════╝╚██╗ ██╔╝║
    ║   ██║   ██║██║  ██║ ╚████╔╝ ███████╗███████╗█████╗   ╚████╔╝ ║
    ║   ██║   ██║██║  ██║  ╚██╔╝  ╚════██║╚════██║██╔══╝    ╚██╔╝  ║
    ║   ╚██████╔╝██████╔╝   ██║   ███████║███████║███████╗   ██║   ║
    ║    ╚═════╝ ╚═════╝    ╚═╝   ╚══════╝╚══════╝╚══════╝   ╚═╝   ║
    ║                                                               ║
    ║                  INSTALLATION SEQUENCE                        ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# Check bash version
echo -e "${YELLOW}[SYSTEM CHECK]${NC} Verifying terminal compatibility..."
BASH_VERSION_NUM="${BASH_VERSION%%[^0-9.]*}"
BASH_MAJOR="${BASH_VERSION_NUM%%.*}"

if [[ "$BASH_MAJOR" -lt 4 ]]; then
    echo -e "${RED}[WARNING]${NC} Bash version $BASH_VERSION detected."
    echo "          Some features work best with Bash 4.0+"
    echo "          On macOS, consider: brew install bash"
else
    echo -e "${GREEN}[  OK  ]${NC} Bash version $BASH_VERSION_NUM"
fi

# Check for required commands
echo -e "${YELLOW}[SYSTEM CHECK]${NC} Scanning for required tools..."

REQUIRED_CMDS=("grep" "find" "sed" "awk" "cut" "sort" "uniq" "wc" "head" "tail")
MISSING=()

for cmd in "${REQUIRED_CMDS[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}[  OK  ]${NC} $cmd"
    else
        echo -e "${RED}[MISSING]${NC} $cmd"
        MISSING+=("$cmd")
    fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}[ERROR]${NC} Missing required commands: ${MISSING[*]}"
    echo "        Please install them before continuing."
    exit 1
fi

# Make scripts executable
echo ""
echo -e "${YELLOW}[SETUP]${NC} Configuring executable permissions..."
chmod +x "$GAME_DIR/scripts/"*.sh 2>/dev/null || true
echo -e "${GREEN}[  OK  ]${NC} Scripts configured"

# Create progress directory
echo -e "${YELLOW}[SETUP]${NC} Initializing progress tracking..."
mkdir -p "$GAME_DIR/.progress"
echo -e "${GREEN}[  OK  ]${NC} Progress system ready"

# Initialize game state
echo -e "${YELLOW}[SETUP]${NC} Resetting game state..."
"$GAME_DIR/scripts/reset.sh" --quiet 2>/dev/null || true
echo -e "${GREEN}[  OK  ]${NC} Game state initialized"

# Add alias suggestion
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "To start your mission, run:"
echo ""
echo -e "  ${YELLOW}cd $GAME_DIR/odyssey/airlock${NC}"
echo -e "  ${YELLOW}cat .scroll${NC}"
echo ""
echo -e "${CYAN}[OPTIONAL]${NC} Add this alias to your ~/.zshrc or ~/.bashrc:"
echo ""
echo -e "  ${YELLOW}alias odyssey='cd $GAME_DIR/odyssey/airlock && cat .scroll'${NC}"
echo ""
echo "Then you can start the game anytime with: odyssey"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Good luck, Operator. The ${CYAN}Odyssey${NC} is counting on you."
echo ""
