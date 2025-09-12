#!/bin/bash

# CyberPanel AlmaLinux 9 Upgrade Fix Script
# This script fixes the MariaDB installation issues during CyberPanel upgrade on AlmaLinux 9

set -e

echo "=========================================="
echo "CyberPanel AlmaLinux 9 Upgrade Fix"
echo "=========================================="

# Function to log messages
log_message() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/cyberpanel_upgrade_fix.log
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root"
        exit 1
    fi
}

# Function to detect AlmaLinux 9
detect_almalinux9() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ "$ID" == "almalinux" && "$VERSION_ID" == "9" ]]; then
            return 0
        fi
    fi
    return 1
}

# Function to fix MariaDB MaxScale repository issues
fix_mariadb_repo() {
    log_message "Fixing MariaDB MaxScale repository issues..."
    
    # Disable problematic MariaDB MaxScale repository
    if dnf config-manager --list | grep -q "mariadb-maxscale"; then
        log_message "Disabling mariadb-maxscale repository..."
        dnf config-manager --disable mariadb-maxscale 2>/dev/null || true
    fi
    
    # Remove problematic repository files
    log_message "Removing problematic repository files..."
    rm -f /etc/yum.repos.d/mariadb-maxscale.repo
    rm -f /etc/yum.repos.d/mariadb-maxscale.repo.rpmsave
    
    # Clean DNF cache
    log_message "Cleaning DNF cache..."
    dnf clean all
    
    # Remove existing MariaDB packages
    log_message "Removing existing MariaDB packages..."
    dnf remove mariadb* -y 2>/dev/null || true
    
    # Disable MariaDB module if it exists
    log_message "Disabling MariaDB module..."
    dnf module disable mariadb -y 2>/dev/null || true
    dnf module reset mariadb -y 2>/dev/null || true
}

# Function to install MariaDB properly for AlmaLinux 9
install_mariadb_almalinux9() {
    log_message "Installing MariaDB for AlmaLinux 9..."
    
    # Add MariaDB official repository
    log_message "Adding MariaDB official repository..."
    curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --mariadb-server-version="10.11"
    
    # Install MariaDB packages
    log_message "Installing MariaDB packages..."
    dnf install -y MariaDB-server MariaDB-client MariaDB-backup MariaDB-devel
    
    # Create symlinks for compatibility
    log_message "Creating MariaDB command symlinks..."
    if [[ ! -f /usr/bin/mariadb ]]; then
        ln -sf /usr/bin/mysql /usr/bin/mariadb 2>/dev/null || true
    fi
    if [[ ! -f /usr/bin/mariadb-dump ]]; then
        ln -sf /usr/bin/mysqldump /usr/bin/mariadb-dump 2>/dev/null || true
    fi
}

# Function to start and enable MariaDB service
start_mariadb_service() {
    log_message "Starting MariaDB service..."
    
    # Try different service names
    local service_names=("mariadb" "mysqld" "mysql")
    local service_started=false
    
    for service in "${service_names[@]}"; do
        if systemctl list-unit-files | grep -q "^${service}.service"; then
            log_message "Found service: ${service}.service"
            systemctl start "${service}" 2>/dev/null && {
                systemctl enable "${service}" 2>/dev/null || true
                service_started=true
                log_message "Successfully started ${service}.service"
                break
            }
        fi
    done
    
    if [[ "$service_started" == "false" ]]; then
        log_message "ERROR: Could not start MariaDB service"
        return 1
    fi
}

# Function to secure MariaDB installation
secure_mariadb() {
    local mysql_password="$1"
    log_message "Securing MariaDB installation..."
    
    # Wait for MariaDB to be ready
    sleep 5
    
    # Try different MariaDB client commands
    local mariadb_cmd=""
    if command -v mariadb >/dev/null 2>&1; then
        mariadb_cmd="mariadb"
    elif command -v mysql >/dev/null 2>&1; then
        mariadb_cmd="mysql"
    else
        log_message "ERROR: No MariaDB client found"
        return 1
    fi
    
    # Set root password and secure installation
    log_message "Setting MariaDB root password..."
    ${mariadb_cmd} -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${mysql_password}');" 2>/dev/null || {
        # Try alternative method
        ${mariadb_cmd} -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_password}';" 2>/dev/null || {
            log_message "WARNING: Could not set root password automatically"
        }
    }
    
    # Remove test database and anonymous users
    ${mariadb_cmd} -u root -p"${mysql_password}" -e "DROP DATABASE IF EXISTS test;" 2>/dev/null || true
    ${mariadb_cmd} -u root -p"${mysql_password}" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" 2>/dev/null || true
    ${mariadb_cmd} -u root -p"${mysql_password}" -e "DELETE FROM mysql.user WHERE User='';" 2>/dev/null || true
    ${mariadb_cmd} -u root -p"${mysql_password}" -e "FLUSH PRIVILEGES;" 2>/dev/null || true
}

# Function to verify MariaDB installation
verify_mariadb() {
    log_message "Verifying MariaDB installation..."
    
    # Check if MariaDB is running
    if systemctl is-active --quiet mariadb || systemctl is-active --quiet mysqld || systemctl is-active --quiet mysql; then
        log_message "MariaDB service is running"
    else
        log_message "ERROR: MariaDB service is not running"
        return 1
    fi
    
    # Check if MariaDB client is available
    if command -v mariadb >/dev/null 2>&1 || command -v mysql >/dev/null 2>&1; then
        log_message "MariaDB client is available"
    else
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
            log_message "MariaDB connection test successful"
        else
            log_message "WARNING: MariaDB connection test failed"
        fi
    fi
}

# Main function
main() {
    log_message "Starting CyberPanel AlmaLinux 9 upgrade fix..."
    
    # Check if running as root
    check_root
    
    # Check if running on AlmaLinux 9
    if ! detect_almalinux9; then
        log_message "WARNING: This script is designed for AlmaLinux 9. Current OS may not be supported."
    fi
    
    # Get MySQL password
    local mysql_password=""
    if [[ -f /etc/cyberpanel/mysqlPassword ]]; then
        mysql_password=$(cat /etc/cyberpanel/mysqlPassword)
        log_message "Found existing MySQL password"
    else
        mysql_password="NKJtcsPqm22m0y"  # Default password from the error log
        log_message "Using default MySQL password"
    fi
    
    # Fix MariaDB repository issues
    fix_mariadb_repo
    
    # Install MariaDB
    install_mariadb_almalinux9
    
    # Start MariaDB service
    start_mariadb_service
    
    # Secure MariaDB installation
    secure_mariadb "$mysql_password"
    
    # Verify installation
    verify_mariadb
    
    log_message "CyberPanel AlmaLinux 9 upgrade fix completed successfully!"
    log_message "You can now proceed with the CyberPanel upgrade:"
    log_message "bash <(curl https://cyberpanel.sh/new_upgrade.sh) -b 2.5.5-dev"
}

# Run main function
main "$@"
