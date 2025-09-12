#!/bin/bash

# Enhanced PHP Version Manager for CyberPanel
# Supports all CyberPanel-compatible operating systems
# Ubuntu 20.04-24.04, AlmaLinux 8-10, RockyLinux 8-9, RHEL 8-9, CentOS 7-9, CloudLinux 7-8

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging function
log_message() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/php_version_manager.log
}

# Function to detect OS and package manager
detect_os() {
    if [[ ! -f /etc/os-release ]]; then
        echo -e "${RED}ERROR: Unable to detect operating system${NC}"
        exit 1
    fi
    
    source /etc/os-release
    
    case "$ID" in
        "ubuntu")
            OS_NAME="Ubuntu"
            OS_VERSION="$VERSION_ID"
            PKG_MANAGER="apt"
            PKG_INSTALL="DEBIAN_FRONTEND=noninteractive apt install -y"
            ;;
        "almalinux"|"rocky"|"rhel"|"centos"|"cloudlinux")
            OS_NAME="$ID"
            OS_VERSION="$VERSION_ID"
            if command -v dnf >/dev/null 2>&1; then
                PKG_MANAGER="dnf"
                PKG_INSTALL="dnf install -y"
            else
                PKG_MANAGER="yum"
                PKG_INSTALL="yum install -y"
            fi
            ;;
        "openeuler")
            OS_NAME="openEuler"
            OS_VERSION="$VERSION_ID"
            PKG_MANAGER="yum"
            PKG_INSTALL="yum install -y"
            ;;
        "debian")
            OS_NAME="Debian"
            OS_VERSION="$VERSION_ID"
            PKG_MANAGER="apt"
            PKG_INSTALL="DEBIAN_FRONTEND=noninteractive apt install -y"
            ;;
        *)
            echo -e "${RED}ERROR: Unsupported operating system: $ID${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${BLUE}Detected OS: $OS_NAME $OS_VERSION${NC}"
    echo -e "${BLUE}Using package manager: $PKG_MANAGER${NC}"
    log_message "Detected OS: $OS_NAME $OS_VERSION, Package manager: $PKG_MANAGER"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}ERROR: This script must be run as root${NC}"
        exit 1
    fi
}

# Function to list available PHP versions
list_available_versions() {
    echo -e "\n${CYAN}Available PHP versions:${NC}"
    echo -e "${GREEN}• PHP 7.1 (71)${NC}"
    echo -e "${GREEN}• PHP 7.2 (72)${NC}"
    echo -e "${GREEN}• PHP 7.3 (73)${NC}"
    echo -e "${GREEN}• PHP 7.4 (74)${NC}"
    echo -e "${GREEN}• PHP 8.0 (80)${NC}"
    echo -e "${GREEN}• PHP 8.1 (81)${NC}"
    echo -e "${GREEN}• PHP 8.2 (82)${NC}"
    echo -e "${GREEN}• PHP 8.3 (83)${NC}"
    echo -e "${GREEN}• PHP 8.4 (84)${NC}"
    echo -e ""
}

# Function to check current PHP version
check_current_php() {
    if [[ -L /usr/local/lscp/fcgi-bin/lsphp ]]; then
        CURRENT_PHP=$(readlink /usr/local/lscp/fcgi-bin/lsphp | grep -o 'lsphp[0-9]*' | sed 's/lsphp//')
        echo -e "${BLUE}Current default PHP version: $CURRENT_PHP${NC}"
    else
        echo -e "${YELLOW}No default PHP version set${NC}"
    fi
}

# Function to install PHP version
install_php_version() {
    local php_version="$1"
    local php_display="$2"
    
    echo -e "${BLUE}Installing PHP $php_display...${NC}"
    log_message "Installing PHP $php_display"
    
    # Install PHP packages
    if ! $PKG_INSTALL lsphp$php_version*; then
        echo -e "${RED}ERROR: Failed to install PHP $php_display${NC}"
        echo -e "${YELLOW}Package may not be available for $OS_NAME $OS_VERSION${NC}"
        log_message "ERROR: Failed to install PHP $php_display"
        return 1
    fi
    
    echo -e "${GREEN}PHP $php_display installed successfully${NC}"
    log_message "PHP $php_display installed successfully"
    return 0
}

# Function to link PHP version
link_php_version() {
    local php_version="$1"
    local php_display="$2"
    
    echo -e "${BLUE}Setting PHP $php_display as default...${NC}"
    log_message "Setting PHP $php_display as default"
    
    # Remove existing symlink
    rm -f /usr/local/lscp/fcgi-bin/lsphp
    
    # Create new symlink
    if [[ -f /usr/local/lsws/lsphp$php_version/bin/lsphp ]]; then
        ln -s /usr/local/lsws/lsphp$php_version/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
        echo -e "${GREEN}PHP $php_display set as default${NC}"
        
        # Restart LiteSpeed
        echo -e "${BLUE}Restarting LiteSpeed...${NC}"
        if systemctl is-active --quiet lscpd; then
            systemctl restart lscpd
        else
            service lscpd restart
        fi
        
        log_message "PHP $php_display set as default and LiteSpeed restarted"
    else
        echo -e "${RED}ERROR: PHP $php_display binary not found${NC}"
        log_message "ERROR: PHP $php_display binary not found"
        return 1
    fi
}

# Function to change PHP version
change_php_version() {
    local php_version="$1"
    local php_display="$2"
    
    echo -e "\n${CYAN}Changing to PHP $php_display...${NC}"
    
    # Check if PHP version is already installed
    if [[ -f /usr/local/lsws/lsphp$php_version/bin/lsphp ]]; then
        echo -e "${GREEN}PHP $php_display is already installed${NC}"
        link_php_version "$php_version" "$php_display"
    else
        echo -e "${YELLOW}PHP $php_display not found, installing...${NC}"
        if install_php_version "$php_version" "$php_display"; then
            link_php_version "$php_version" "$php_display"
        else
            echo -e "${RED}Failed to install PHP $php_display${NC}"
            return 1
        fi
    fi
}

# Function to show PHP status
show_php_status() {
    echo -e "\n${CYAN}=== PHP Status ===${NC}"
    
    # Show current default version
    check_current_php
    
    # Show all installed PHP versions
    echo -e "\n${BLUE}Installed PHP versions:${NC}"
    for version in 71 72 73 74 80 81 82 83 84; do
        if [[ -f /usr/local/lsws/lsphp$version/bin/lsphp ]]; then
            if [[ -L /usr/local/lscp/fcgi-bin/lsphp ]] && [[ $(readlink /usr/local/lscp/fcgi-bin/lsphp) == *"lsphp$version"* ]]; then
                echo -e "${GREEN}• PHP $version (DEFAULT)${NC}"
            else
                echo -e "${BLUE}• PHP $version${NC}"
            fi
        fi
    done
}

# Function to uninstall PHP version
uninstall_php_version() {
    local php_version="$1"
    local php_display="$2"
    
    echo -e "\n${YELLOW}Uninstalling PHP $php_display...${NC}"
    log_message "Uninstalling PHP $php_display"
    
    # Check if it's the current default
    if [[ -L /usr/local/lscp/fcgi-bin/lsphp ]] && [[ $(readlink /usr/local/lscp/fcgi-bin/lsphp) == *"lsphp$php_version"* ]]; then
        echo -e "${RED}ERROR: Cannot uninstall the current default PHP version${NC}"
        echo -e "${YELLOW}Please change to another PHP version first${NC}"
        return 1
    fi
    
    # Uninstall packages
    if [[ $PKG_MANAGER == "apt" ]]; then
        $PKG_MANAGER remove -y lsphp$php_version* || true
    else
        $PKG_MANAGER remove -y lsphp$php_version* || true
    fi
    
    # Remove configuration directory
    rm -rf /usr/local/lsws/lsphp$php_version
    
    echo -e "${GREEN}PHP $php_display uninstalled successfully${NC}"
    log_message "PHP $php_display uninstalled successfully"
}

# Function to show help
show_help() {
    echo -e "${CYAN}Enhanced PHP Version Manager for CyberPanel${NC}"
    echo -e ""
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  $0 [version] [options]"
    echo -e ""
    echo -e "${BLUE}Arguments:${NC}"
    echo -e "  version     PHP version to install/set (71, 72, 73, 74, 80, 81, 82, 83, 84)"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  --status    Show current PHP status"
    echo -e "  --list      List available PHP versions"
    echo -e "  --uninstall Uninstall a PHP version"
    echo -e "  --help      Show this help message"
    echo -e ""
    echo -e "${BLUE}Examples:${NC}"
    echo -e "  $0 81              # Install and set PHP 8.1 as default"
    echo -e "  $0 --status        # Show current PHP status"
    echo -e "  $0 --uninstall 71  # Uninstall PHP 7.1"
    echo -e ""
    echo -e "${BLUE}Supported Operating Systems:${NC}"
    echo -e "• Ubuntu 20.04, 22.04, 24.04"
    echo -e "• AlmaLinux 8, 9, 10"
    echo -e "• RockyLinux 8, 9"
    echo -e "• RHEL 8, 9"
    echo -e "• CentOS 7, 8, 9"
    echo -e "• CloudLinux 7, 8"
    echo -e "• openEuler 20.03, 22.03"
    echo -e "• Debian (community support)"
}

# Interactive mode
interactive_mode() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}  Enhanced PHP Version Manager${NC}"
    echo -e "${PURPLE}========================================${NC}"
    
    while true; do
        echo -e "\n${CYAN}Please choose an option:${NC}"
        echo -e "1. Change PHP version"
        echo -e "2. Show PHP status"
        echo -e "3. List available versions"
        echo -e "4. Uninstall PHP version"
        echo -e "5. Exit"
        echo -e ""
        printf "%s" "Please enter number [1-5]: "
        read choice
        
        case $choice in
            1)
                list_available_versions
                printf "%s" "Enter PHP version [71-84]: "
                read version
                case $version in
                    71) change_php_version 71 "7.1" ;;
                    72) change_php_version 72 "7.2" ;;
                    73) change_php_version 73 "7.3" ;;
                    74) change_php_version 74 "7.4" ;;
                    80) change_php_version 80 "8.0" ;;
                    81) change_php_version 81 "8.1" ;;
                    82) change_php_version 82 "8.2" ;;
                    83) change_php_version 83 "8.3" ;;
                    84) change_php_version 84 "8.4" ;;
                    *) echo -e "${RED}Invalid version. Please enter 71-84.${NC}" ;;
                esac
                ;;
            2) show_php_status ;;
            3) list_available_versions ;;
            4)
                show_php_status
                printf "%s" "Enter PHP version to uninstall [71-84]: "
                read version
                case $version in
                    71) uninstall_php_version 71 "7.1" ;;
                    72) uninstall_php_version 72 "7.2" ;;
                    73) uninstall_php_version 73 "7.3" ;;
                    74) uninstall_php_version 74 "7.4" ;;
                    80) uninstall_php_version 80 "8.0" ;;
                    81) uninstall_php_version 81 "8.1" ;;
                    82) uninstall_php_version 82 "8.2" ;;
                    83) uninstall_php_version 83 "8.3" ;;
                    84) uninstall_php_version 84 "8.4" ;;
                    *) echo -e "${RED}Invalid version. Please enter 71-84.${NC}" ;;
                esac
                ;;
            5) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Please enter a valid number [1-5]${NC}" ;;
        esac
    done
}

# Main function
main() {
    check_root
    detect_os
    
    # Handle command line arguments
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --status)
            show_php_status
            exit 0
            ;;
        --list)
            list_available_versions
            exit 0
            ;;
        --uninstall)
            if [[ -n "$2" ]]; then
                case $2 in
                    71) uninstall_php_version 71 "7.1" ;;
                    72) uninstall_php_version 72 "7.2" ;;
                    73) uninstall_php_version 73 "7.3" ;;
                    74) uninstall_php_version 74 "7.4" ;;
                    80) uninstall_php_version 80 "8.0" ;;
                    81) uninstall_php_version 81 "8.1" ;;
                    82) uninstall_php_version 82 "8.2" ;;
                    83) uninstall_php_version 83 "8.3" ;;
                    84) uninstall_php_version 84 "8.4" ;;
                    *) echo -e "${RED}Invalid version: $2${NC}"; exit 1 ;;
                esac
            else
                echo -e "${RED}Please specify a version to uninstall${NC}"
                exit 1
            fi
            exit 0
            ;;
        "")
            interactive_mode
            ;;
        *)
            # Direct version change
            case $1 in
                71) change_php_version 71 "7.1" ;;
                72) change_php_version 72 "7.2" ;;
                73) change_php_version 73 "7.3" ;;
                74) change_php_version 74 "7.4" ;;
                80) change_php_version 80 "8.0" ;;
                81) change_php_version 81 "8.1" ;;
                82) change_php_version 82 "8.2" ;;
                83) change_php_version 83 "8.3" ;;
                84) change_php_version 84 "8.4" ;;
                *) echo -e "${RED}Invalid version: $1${NC}"; show_help; exit 1 ;;
            esac
            ;;
    esac
}

# Run main function
main "$@"
