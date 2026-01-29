#!/bin/bash
#
# Network Learning Lab Startup Script
# Starts the Docker-based networking lab environment
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║     ██╗  ██╗███████╗██╗     ██╗ ██████╗ ███████╗                              ║
║     ██║  ██║██╔════╝██║     ██║██╔═══██╗██╔════╝                              ║
║     ███████║█████╗  ██║     ██║██║   ██║███████╗                              ║
║     ██╔══██║██╔══╝  ██║     ██║██║   ██║╚════██║                              ║
║     ██║  ██║███████╗███████╗██║╚██████╔╝███████║                              ║
║     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝ ╚═════╝ ╚══════╝                              ║
║                                                                               ║
║              ORBITAL STATION - NETWORK TRAINING LAB                           ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        echo "Please install Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        echo -e "${RED}Error: Docker daemon is not running${NC}"
        echo "Please start Docker and try again"
        exit 1
    fi

    if ! command -v docker compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${RED}Error: Docker Compose is not available${NC}"
        echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
        exit 1
    fi
}

start_lab() {
    echo -e "${BLUE}Starting Network Learning Lab...${NC}"
    echo ""

    # Pull images first
    echo -e "${YELLOW}Pulling required images...${NC}"
    docker compose pull --quiet 2>/dev/null || docker-compose pull --quiet 2>/dev/null

    # Build and start containers
    echo -e "${YELLOW}Building and starting containers...${NC}"
    docker compose up -d --build 2>/dev/null || docker-compose up -d --build 2>/dev/null

    echo ""
    echo -e "${GREEN}✓ Lab started successfully!${NC}"
    echo ""
}

show_status() {
    echo -e "${BLUE}Container Status:${NC}"
    echo "─────────────────────────────────────────"
    docker compose ps 2>/dev/null || docker-compose ps 2>/dev/null
    echo ""
}

show_networks() {
    echo -e "${BLUE}Lab Networks:${NC}"
    echo "─────────────────────────────────────────"
    echo -e "  ${CYAN}frontend_net${NC}: 172.20.0.0/24 (client, server, api, dns)"
    echo -e "  ${CYAN}backend_net${NC}:  172.21.0.0/24 (api, database, dns, monitor)"
    echo ""
}

show_help() {
    cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NEXUS NETWORK EXPERT SYSTEM v3.7.2 - Training Mode Active

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
    echo -e "${BLUE}Quick Start:${NC}"
    echo "─────────────────────────────────────────"
    echo -e "  ${GREEN}1. Read the mission briefing:${NC}"
    echo "     cat .scroll"
    echo ""
    echo -e "  ${GREEN}2. Enter the client container (your workstation):${NC}"
    echo "     docker exec -it client bash"
    echo ""
    echo -e "  ${GREEN}3. Begin training:${NC}"
    echo "     cd exercises/01-comm-bay && cat .scroll"
    echo ""
    echo -e "${BLUE}Training Modules:${NC}"
    echo "─────────────────────────────────────────"
    echo "  01-comm-bay      Network Fundamentals"
    echo "  02-diagnostic    Troubleshooting"
    echo "  03-junction      Docker Networks"
    echo "  04-security-hub  Security & Isolation"
    echo ""
    echo -e "${BLUE}Lab Commands:${NC}"
    echo "─────────────────────────────────────────"
    echo "  ./start.sh            # Start the lab"
    echo "  ./start.sh stop       # Stop the lab"
    echo "  ./start.sh status     # Show container status"
    echo "  ./scripts/hint.sh     # Get hints for current mission"
    echo "  ./scripts/check-progress.sh  # View completion status"
    echo ""
    cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NEXUS: Training lab initialized. The station is counting on you, Specialist.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

stop_lab() {
    echo -e "${YELLOW}Stopping Network Learning Lab...${NC}"
    docker compose down 2>/dev/null || docker-compose down 2>/dev/null
    echo -e "${GREEN}✓ Lab stopped${NC}"
}

show_logs() {
    docker compose logs -f 2>/dev/null || docker-compose logs -f 2>/dev/null
}

# Main
print_banner
check_docker

case "${1:-start}" in
    start)
        start_lab
        show_status
        show_networks
        show_help
        ;;
    stop)
        stop_lab
        ;;
    restart)
        stop_lab
        echo ""
        start_lab
        show_status
        show_networks
        show_help
        ;;
    status)
        show_status
        show_networks
        ;;
    logs)
        show_logs
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Usage: $0 {start|stop|restart|status|logs|help}"
        exit 1
        ;;
esac
