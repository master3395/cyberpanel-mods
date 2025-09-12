#!/bin/bash

# Enhanced MariaDB Version Manager for CyberPanel
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
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/mariadb_version_manager.log
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
            PKG_REMOVE="apt remove -y"
            PKG_UPDATE="apt update"
            ;;
        "almalinux"|"rocky"|"rhel"|"centos"|"cloudlinux")
            OS_NAME="$ID"
            OS_VERSION="$VERSION_ID"
            if command -v dnf >/dev/null 2>&1; then
                PKG_MANAGER="dnf"
                PKG_INSTALL="dnf install -y"
                PKG_REMOVE="dnf remove -y"
                PKG_UPDATE="dnf update -y"
            else
                PKG_MANAGER="yum"
                PKG_INSTALL="yum install -y"
                PKG_REMOVE="yum remove -y"
                PKG_UPDATE="yum update -y"
            fi
            ;;
        "openeuler")
            OS_NAME="openEuler"
            OS_VERSION="$VERSION_ID"
            PKG_MANAGER="yum"
            PKG_INSTALL="yum install -y"
            PKG_REMOVE="yum remove -y"
            PKG_UPDATE="yum update -y"
            ;;
        "debian")
            OS_NAME="Debian"
            OS_VERSION="$VERSION_ID"
            PKG_MANAGER="apt"
            PKG_INSTALL="DEBIAN_FRONTEND=noninteractive apt install -y"
            PKG_REMOVE="apt remove -y"
            PKG_UPDATE="apt update"
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

# Function to check current MariaDB version
check_current_mariadb() {
    if command -v mysql >/dev/null 2>&1; then
        CURRENT_VERSION=$(mysql --version 2>/dev/null | grep -oP 'Distrib \K[0-9]+\.[0-9]+' || echo "Unknown")
        echo -e "${BLUE}Current MariaDB version: $CURRENT_VERSION${NC}"
        return 0
    else
        echo -e "${YELLOW}MariaDB not installed${NC}"
        return 1
    fi
}

# Function to list available MariaDB versions
list_available_versions() {
    echo -e "\n${CYAN}Available MariaDB versions:${NC}"
    echo -e "${GREEN}• MariaDB 10.3 (Legacy)${NC}"
    echo -e "${GREEN}• MariaDB 10.4 (Stable)${NC}"
    echo -e "${GREEN}• MariaDB 10.5 (Stable)${NC}"
    echo -e "${GREEN}• MariaDB 10.6 (Stable)${NC}"
    echo -e "${GREEN}• MariaDB 10.7 (Stable)${NC}"
    echo -e "${GREEN}• MariaDB 10.8 (Stable)${NC}"
    echo -e "${GREEN}• MariaDB 10.9 (Stable)${NC}"
    echo -e "${GREEN}• MariaDB 10.10 (Stable)${NC}"
    echo -e "${GREEN}• MariaDB 10.11 (Stable)${NC}"
    echo -e "${GREEN}• MariaDB 11.0 (Stable)${NC}"
    echo -e "${GREEN}• MariaDB 11.1 (Stable)${NC}"
    echo -e "${GREEN}• MariaDB 11.2 (Stable)${NC}"
    echo -e "${GREEN}• MariaDB 11.3 (Stable)${NC}"
    echo -e "${GREEN}• MariaDB 11.4 (Stable)${NC}"
    echo -e ""
}

# Function to backup existing data
backup_mariadb_data() {
    local backup_dir="/tmp/mariadb_backup_$(date +%Y%m%d_%H%M%S)"
    
    echo -e "${BLUE}Creating backup of existing MariaDB data...${NC}"
    log_message "Creating backup to $backup_dir"
    
    mkdir -p "$backup_dir"
    
    # Backup data directory
    if [[ -d /var/lib/mysql ]]; then
        cp -r /var/lib/mysql "$backup_dir/" || {
            echo -e "${YELLOW}Warning: Could not backup data directory${NC}"
        }
    fi
    
    # Backup configuration
    if [[ -f /etc/my.cnf ]]; then
        cp /etc/my.cnf "$backup_dir/my.cnf.bak"
    fi
    
    # Backup additional config files
    for config_file in /etc/mysql/my.cnf /etc/my.cnf.d/*.cnf; do
        if [[ -f "$config_file" ]]; then
            cp "$config_file" "$backup_dir/"
        fi
    done
    
    echo -e "${GREEN}Backup created at: $backup_dir${NC}"
    log_message "Backup created at: $backup_dir"
    echo "$backup_dir"
}

# Function to stop MariaDB service
stop_mariadb_service() {
    echo -e "${BLUE}Stopping MariaDB service...${NC}"
    log_message "Stopping MariaDB service"
    
    # Try different service names
    local service_names=("mariadb" "mysqld" "mysql")
    local service_stopped=false
    
    for service in "${service_names[@]}"; do
        if systemctl list-unit-files | grep -q "^${service}.service"; then
            if systemctl is-active --quiet "$service"; then
                echo -e "${BLUE}Stopping $service service...${NC}"
                systemctl stop "$service" && {
                    service_stopped=true
                    log_message "Stopped $service service"
                    break
                }
            fi
        fi
    done
    
    if [[ "$service_stopped" == "false" ]]; then
        echo -e "${YELLOW}MariaDB service was not running${NC}"
    fi
}

# Function to remove existing MariaDB
remove_existing_mariadb() {
    echo -e "${BLUE}Removing existing MariaDB installation...${NC}"
    log_message "Removing existing MariaDB installation"
    
    # Stop service first
    stop_mariadb_service
    
    # Remove packages
    $PKG_REMOVE mariadb* mysql* || true
    
    # Remove configuration files
    rm -f /etc/my.cnf /etc/mysql/my.cnf
    rm -rf /etc/my.cnf.d /etc/mysql/conf.d
    
    # Remove data directory (with confirmation)
    if [[ -d /var/lib/mysql ]]; then
        echo -e "${YELLOW}Data directory /var/lib/mysql exists${NC}"
        echo -e "${YELLOW}This will be removed. Make sure you have a backup!${NC}"
        read -p "Continue? [y/N]: " confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            rm -rf /var/lib/mysql
            echo -e "${GREEN}Data directory removed${NC}"
        else
            echo -e "${YELLOW}Keeping data directory${NC}"
        fi
    fi
    
    echo -e "${GREEN}Existing MariaDB installation removed${NC}"
    log_message "Existing MariaDB installation removed"
}

# Function to add MariaDB repository
add_mariadb_repository() {
    local version="$1"
    
    echo -e "${BLUE}Adding MariaDB $version repository...${NC}"
    log_message "Adding MariaDB $version repository"
    
    # Download and run MariaDB repository setup script
    curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --mariadb-server-version="$version" || {
        echo -e "${RED}ERROR: Failed to add MariaDB repository${NC}"
        log_message "ERROR: Failed to add MariaDB repository"
        return 1
    }
    
    # Update package lists
    $PKG_UPDATE || {
        echo -e "${YELLOW}Warning: Package list update failed${NC}"
    }
    
    echo -e "${GREEN}MariaDB $version repository added successfully${NC}"
    log_message "MariaDB $version repository added successfully"
}

# Function to install MariaDB
install_mariadb() {
    local version="$1"
    
    echo -e "${BLUE}Installing MariaDB $version...${NC}"
    log_message "Installing MariaDB $version"
    
    # Install MariaDB packages
    if [[ $OS_NAME == "Ubuntu" ]] || [[ $OS_NAME == "Debian" ]]; then
        $PKG_INSTALL mariadb-server mariadb-client mariadb-backup || {
            echo -e "${RED}ERROR: Failed to install MariaDB packages${NC}"
            log_message "ERROR: Failed to install MariaDB packages"
            return 1
        }
    else
        $PKG_INSTALL MariaDB-server MariaDB-client MariaDB-backup MariaDB-devel || {
            echo -e "${RED}ERROR: Failed to install MariaDB packages${NC}"
            log_message "ERROR: Failed to install MariaDB packages"
            return 1
        }
    fi
    
    echo -e "${GREEN}MariaDB $version installed successfully${NC}"
    log_message "MariaDB $version installed successfully"
}

# Function to start MariaDB service
start_mariadb_service() {
    echo -e "${BLUE}Starting MariaDB service...${NC}"
    log_message "Starting MariaDB service"
    
    # Try different service names
    local service_names=("mariadb" "mysqld" "mysql")
    local service_started=false
    
    for service in "${service_names[@]}"; do
        if systemctl list-unit-files | grep -q "^${service}.service"; then
            echo -e "${BLUE}Starting $service service...${NC}"
            systemctl start "$service" && {
                systemctl enable "$service" || true
                service_started=true
                log_message "Started $service service"
                break
            }
        fi
    done
    
    if [[ "$service_started" == "false" ]]; then
        echo -e "${RED}ERROR: Could not start MariaDB service${NC}"
        log_message "ERROR: Could not start MariaDB service"
        return 1
    fi
    
    # Wait for service to be ready
    sleep 5
    
    echo -e "${GREEN}MariaDB service started successfully${NC}"
    log_message "MariaDB service started successfully"
}

# Function to secure MariaDB installation
secure_mariadb() {
    local mysql_password="$1"
    
    echo -e "${BLUE}Securing MariaDB installation...${NC}"
    log_message "Securing MariaDB installation"
    
    # Wait for MariaDB to be ready
    sleep 10
    
    # Try different MariaDB client commands
    local mariadb_cmd=""
    if command -v mariadb >/dev/null 2>&1; then
        mariadb_cmd="mariadb"
    elif command -v mysql >/dev/null 2>&1; then
        mariadb_cmd="mysql"
    else
        echo -e "${RED}ERROR: No MariaDB client found${NC}"
        log_message "ERROR: No MariaDB client found"
        return 1
    fi
    
    # Set root password
    echo -e "${BLUE}Setting MariaDB root password...${NC}"
    ${mariadb_cmd} -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${mysql_password}');" 2>/dev/null || {
        # Try alternative method
        ${mariadb_cmd} -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_password}';" 2>/dev/null || {
            echo -e "${YELLOW}Warning: Could not set root password automatically${NC}"
            log_message "Warning: Could not set root password automatically"
        }
    }
    
    # Remove test database and anonymous users
    ${mariadb_cmd} -u root -p"${mysql_password}" -e "DROP DATABASE IF EXISTS test;" 2>/dev/null || true
    ${mariadb_cmd} -u root -p"${mysql_password}" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" 2>/dev/null || true
    ${mariadb_cmd} -u root -p"${mysql_password}" -e "DELETE FROM mysql.user WHERE User='';" 2>/dev/null || true
    ${mariadb_cmd} -u root -p"${mysql_password}" -e "FLUSH PRIVILEGES;" 2>/dev/null || true
    
    echo -e "${GREEN}MariaDB installation secured${NC}"
    log_message "MariaDB installation secured"
}

# Function to verify MariaDB installation
verify_mariadb() {
    echo -e "${BLUE}Verifying MariaDB installation...${NC}"
    log_message "Verifying MariaDB installation"
    
    # Check if MariaDB is running
    if systemctl is-active --quiet mariadb || systemctl is-active --quiet mysqld || systemctl is-active --quiet mysql; then
        echo -e "${GREEN}MariaDB service is running${NC}"
    else
        echo -e "${RED}ERROR: MariaDB service is not running${NC}"
        log_message "ERROR: MariaDB service is not running"
        return 1
    fi
    
    # Check if MariaDB client is available
    if command -v mariadb >/dev/null 2>&1 || command -v mysql >/dev/null 2>&1; then
        echo -e "${GREEN}MariaDB client is available${NC}"
    else
        echo -e "${RED}ERROR: MariaDB client is not available${NC}"
        log_message "ERROR: MariaDB client is not available"
        return 1
    fi
    
    # Test connection
    local mysql_password=$(cat /etc/cyberpanel/mysqlPassword 2>/dev/null || echo "")
    if [[ -n "$mysql_password" ]]; then
        local mariadb_cmd=""
        if command -v mariadb >/dev/null 2>&1; then
            mariadb_cmd="mariadb"
        else
            mariadb_cmd="mysql"
        fi
        
        if ${mariadb_cmd} -u root -p"${mysql_password}" -e "SELECT 1;" >/dev/null 2>&1; then
            echo -e "${GREEN}MariaDB connection test successful${NC}"
            log_message "MariaDB connection test successful"
        else
            echo -e "${YELLOW}Warning: MariaDB connection test failed${NC}"
            log_message "Warning: MariaDB connection test failed"
        fi
    fi
    
    # Show version
    local current_version=$(mysql --version 2>/dev/null | grep -oP 'Distrib \K[0-9]+\.[0-9]+' || echo "Unknown")
    echo -e "${GREEN}MariaDB version: $current_version${NC}"
    log_message "MariaDB version: $current_version"
}

# Function to change MariaDB version
change_mariadb_version() {
    local version="$1"
    local backup_dir=""
    
    echo -e "\n${CYAN}Changing MariaDB to version $version...${NC}"
    log_message "Changing MariaDB to version $version"
    
    # Check current version
    check_current_mariadb
    
    # Create backup
    backup_dir=$(backup_mariadb_data)
    
    # Get MySQL password
    local mysql_password=""
    if [[ -f /etc/cyberpanel/mysqlPassword ]]; then
        mysql_password=$(cat /etc/cyberpanel/mysqlPassword)
        echo -e "${GREEN}Found existing MySQL password${NC}"
    else
        mysql_password="NKJtcsPqm22m0y"  # Default password
        echo -e "${YELLOW}Using default MySQL password${NC}"
    fi
    
    # Remove existing installation
    remove_existing_mariadb
    
    # Add repository
    add_mariadb_repository "$version"
    
    # Install MariaDB
    install_mariadb "$version"
    
    # Start service
    start_mariadb_service
    
    # Secure installation
    secure_mariadb "$mysql_password"
    
    # Verify installation
    verify_mariadb
    
    echo -e "\n${GREEN}MariaDB version $version installed successfully!${NC}"
    echo -e "${BLUE}Backup location: $backup_dir${NC}"
    log_message "MariaDB version $version installed successfully"
}

# Function to show help
show_help() {
    echo -e "${CYAN}Enhanced MariaDB Version Manager for CyberPanel${NC}"
    echo -e ""
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  $0 [version] [options]"
    echo -e ""
    echo -e "${BLUE}Arguments:${NC}"
    echo -e "  version     MariaDB version to install (e.g., 10.11, 11.0, 11.4)"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  --status    Show current MariaDB status"
    echo -e "  --list      List available MariaDB versions"
    echo -e "  --help      Show this help message"
    echo -e ""
    echo -e "${BLUE}Examples:${NC}"
    echo -e "  $0 10.11           # Install MariaDB 10.11"
    echo -e "  $0 11.4            # Install MariaDB 11.4"
    echo -e "  $0 --status        # Show current MariaDB status"
    echo -e "  $0 --list          # List available versions"
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
    echo -e "${PURPLE}  Enhanced MariaDB Version Manager${NC}"
    echo -e "${PURPLE}========================================${NC}"
    
    while true; do
        echo -e "\n${CYAN}Please choose an option:${NC}"
        echo -e "1. Change MariaDB version"
        echo -e "2. Show MariaDB status"
        echo -e "3. List available versions"
        echo -e "4. Exit"
        echo -e ""
        printf "%s" "Please enter number [1-4]: "
        read choice
        
        case $choice in
            1)
                list_available_versions
                printf "%s" "Enter MariaDB version (e.g., 10.11): "
                read version
                if [[ "$version" =~ ^[0-9]+\.[0-9]+$ ]]; then
                    change_mariadb_version "$version"
                else
                    echo -e "${RED}Invalid version format. Please use format like 10.11${NC}"
                fi
                ;;
            2) check_current_mariadb ;;
            3) list_available_versions ;;
            4) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Please enter a valid number [1-4]${NC}" ;;
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
            check_current_mariadb
            exit 0
            ;;
        --list)
            list_available_versions
            exit 0
            ;;
        "")
            interactive_mode
            ;;
        *)
            # Direct version change
            if [[ "$1" =~ ^[0-9]+\.[0-9]+$ ]]; then
                change_mariadb_version "$1"
            else
                echo -e "${RED}Invalid version: $1${NC}"
                echo -e "${YELLOW}Please use format like 10.11 or 11.4${NC}"
                show_help
                exit 1
            fi
            ;;
    esac
}

# Run main function
main "$@"
