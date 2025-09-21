#!/bin/bash

# User Management Menu for CyberPanel Mods
# Integrated user-facing operations with admin functionality

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Source the function files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/user-functions.sh"
source "$SCRIPT_DIR/website-functions.sh"

# Logging function
log_message() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/cyberpanel_user_management.log
}

# Function to pause and wait for user input
pause() {
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# Function to show user management menu
show_user_management_menu() {
    while true; do
        clear
        echo -e "${PURPLE}"
        echo "  ╔══════════════════════════════════════════════════════════════╗"
        echo "  ║                                                              ║"
        echo "  ║  👥 CyberPanel User Management Interface 👥                 ║"
        echo "  ║                                                              ║"
        echo "  ║  Comprehensive user and website management tools             ║"
        echo "  ║                                                              ║"
        echo "  ╚══════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        
        echo -e "\n${WHITE}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${WHITE}║                    USER MANAGEMENT MENU                     ║${NC}"
        echo -e "${WHITE}╠══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${WHITE}║                                                              ║${NC}"
        echo -e "${WHITE}║  ${GREEN}USER FUNCTIONS${NC}                                         ${WHITE}║${NC}"
        echo -e "${WHITE}║  ${GREEN}1.${NC} 👤 Create User                                   ${WHITE}║${NC}"
        echo -e "${WHITE}║  ${GREEN}2.${NC} 🗑️  Delete User                                   ${WHITE}║${NC}"
        echo -e "${WHITE}║  ${GREEN}3.${NC} 📋 List Users                                    ${WHITE}║${NC}"
        echo -e "${WHITE}║                                                              ║${NC}"
        echo -e "${WHITE}║  ${GREEN}WEBSITE FUNCTIONS${NC}                                     ${WHITE}║${NC}"
        echo -e "${WHITE}║  ${GREEN}4.${NC} 🌐 Create Website                                ${WHITE}║${NC}"
        echo -e "${WHITE}║  ${GREEN}5.${NC} 🗑️  Delete Website                               ${WHITE}║${NC}"
        echo -e "${WHITE}║  ${GREEN}6.${NC} 📋 List Websites                                 ${WHITE}║${NC}"
        echo -e "${WHITE}║  ${GREEN}7.${NC} 🐘 Change PHP Version                            ${WHITE}║${NC}"
        echo -e "${WHITE}║                                                              ║${NC}"
        echo -e "${WHITE}║  ${GREEN}OTHER FUNCTIONS${NC}                                       ${WHITE}║${NC}"
        echo -e "${WHITE}║  ${GREEN}8.${NC} 📊 Full Menu (All Functions)                     ${WHITE}║${NC}"
        echo -e "${WHITE}║  ${GREEN}9.${NC} ↩️  Back to Main Menu                            ${WHITE}║${NC}"
        echo -e "${WHITE}║  ${GREEN}10.${NC} ❌ Exit                                         ${WHITE}║${NC}"
        echo -e "${WHITE}║                                                              ║${NC}"
        echo -e "${WHITE}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo -e ""
        printf "%s" "Please enter your choice [1-10]: "
        read choice
        
        case $choice in
            1) 
                log_message "User initiated: Create User"
                createUser 
                pause
                ;;
            2) 
                log_message "User initiated: Delete User"
                deleteUser 
                pause
                ;;
            3) 
                log_message "User initiated: List Users"
                listUsers 
                pause
                ;;
            4) 
                log_message "User initiated: Create Website"
                createWebsite 
                pause
                ;;
            5) 
                log_message "User initiated: Delete Website"
                deleteWebsite 
                pause
                ;;
            6) 
                log_message "User initiated: List Websites"
                listWebsite 
                pause
                ;;
            7) 
                log_message "User initiated: Change PHP Version"
                changePHP 
                pause
                ;;
            8)
                log_message "User initiated: Full Menu"
                show_full_menu
                ;;
            9) 
                log_message "User returned to main menu"
                return 
                ;;
            10) 
                log_message "User exited user management"
                echo -e "${GREEN}Thank you for using CyberPanel User Management!${NC}"
                exit 0 
                ;;
            *) 
                echo -e "${RED}Please enter a valid number [1-10]${NC}"
                sleep 2
                ;;
        esac
    done
}

# Function to show full menu with all options
show_full_menu() {
    # Source the main CLI script for full functionality
    if [[ -f "$SCRIPT_DIR/cyberpanel-user-cli.sh" ]]; then
        source "$SCRIPT_DIR/cyberpanel-user-cli.sh"
        Main
    else
        echo -e "${RED}Error: Full CLI script not found${NC}"
        pause
    fi
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}ERROR: This script must be run as root${NC}"
        echo -e "${YELLOW}Please run: sudo su -${NC}"
        exit 1
    fi
}

# Check if CyberPanel is installed
check_cyberpanel() {
    if ! command -v cyberpanel >/dev/null 2>&1; then
        echo -e "${RED}ERROR: CyberPanel CLI not found${NC}"
        echo -e "${YELLOW}Please install CyberPanel first${NC}"
        exit 1
    fi
}

# Main execution
main() {
    check_root
    check_cyberpanel
    log_message "User Management Interface started"
    show_user_management_menu
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
