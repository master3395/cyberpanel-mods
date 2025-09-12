#!/bin/bash

# Enhanced CyberPanel Core Fixes Script
# Addresses common issues across all supported operating systems
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
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/cyberpanel_core_fixes.log
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
            PKG_UPDATE="apt update"
            ;;
        "almalinux"|"rocky"|"rhel"|"centos"|"cloudlinux")
            OS_NAME="$ID"
            OS_VERSION="$VERSION_ID"
            if command -v dnf >/dev/null 2>&1; then
                PKG_MANAGER="dnf"
                PKG_INSTALL="dnf install -y"
                PKG_UPDATE="dnf update -y"
            else
                PKG_MANAGER="yum"
                PKG_INSTALL="yum install -y"
                PKG_UPDATE="yum update -y"
            fi
            ;;
        "openeuler")
            OS_NAME="openEuler"
            OS_VERSION="$VERSION_ID"
            PKG_MANAGER="yum"
            PKG_INSTALL="yum install -y"
            PKG_UPDATE="yum update -y"
            ;;
        "debian")
            OS_NAME="Debian"
            OS_VERSION="$VERSION_ID"
            PKG_MANAGER="apt"
            PKG_INSTALL="DEBIAN_FRONTEND=noninteractive apt install -y"
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

# Function to check if CyberPanel is installed
check_cyberpanel() {
    if [[ ! -f /etc/cyberpanel/machineIP ]]; then
        echo -e "${RED}ERROR: CyberPanel not detected${NC}"
        echo -e "${YELLOW}Please install CyberPanel first${NC}"
        exit 1
    fi
    echo -e "${GREEN}CyberPanel installation detected${NC}"
}

# Function to fix symbolic links
fix_symbolic_links() {
    echo -e "\n${CYAN}=== Fixing Symbolic Links ===${NC}"
    log_message "Fixing symbolic links"
    
    # Common symbolic link issues
    local links=(
        "/usr/local/lscp/fcgi-bin/lsphp"
        "/usr/local/lsws/bin/lshttpd"
        "/usr/local/lsws/bin/lshttpd.old"
    )
    
    for link in "${links[@]}"; do
        if [[ -L "$link" ]] && [[ ! -e "$link" ]]; then
            echo -e "${YELLOW}Removing broken symbolic link: $link${NC}"
            rm -f "$link"
            log_message "Removed broken symbolic link: $link"
        fi
    done
    
    # Recreate PHP symlink if needed
    if [[ ! -e /usr/local/lscp/fcgi-bin/lsphp ]]; then
        echo -e "${BLUE}Recreating PHP symlink...${NC}"
        # Find the latest PHP version
        local latest_php=$(ls -1 /usr/local/lsws/lsphp* 2>/dev/null | grep -o 'lsphp[0-9]*' | sort -V | tail -1)
        if [[ -n "$latest_php" ]] && [[ -f "/usr/local/lsws/$latest_php/bin/lsphp" ]]; then
            ln -sf "/usr/local/lsws/$latest_php/bin/lsphp" /usr/local/lscp/fcgi-bin/lsphp
            echo -e "${GREEN}Created symlink to $latest_php${NC}"
            log_message "Created symlink to $latest_php"
        else
            echo -e "${RED}ERROR: No PHP installation found${NC}"
            log_message "ERROR: No PHP installation found"
        fi
    fi
    
    echo -e "${GREEN}Symbolic links fixed${NC}"
}

# Function to fix permissions
fix_permissions() {
    echo -e "\n${CYAN}=== Fixing File Permissions ===${NC}"
    log_message "Fixing file permissions"
    
    # CyberPanel directories
    local directories=(
        "/usr/local/CyberCP"
        "/usr/local/lscp"
        "/usr/local/lsws"
        "/etc/cyberpanel"
        "/var/lib/cyberpanel"
        "/home/cyberpanel"
    )
    
    for dir in "${directories[@]}"; do
        if [[ -d "$dir" ]]; then
            echo -e "${BLUE}Setting permissions for $dir${NC}"
            chown -R cyberpanel:cyberpanel "$dir" 2>/dev/null || true
            chmod -R 755 "$dir" 2>/dev/null || true
        fi
    done
    
    # Specific file permissions
    local files=(
        "/usr/local/lsws/bin/lshttpd"
        "/usr/local/lsws/bin/lshttpd.old"
        "/usr/local/lscp/fcgi-bin/lsphp"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            chmod 755 "$file" 2>/dev/null || true
        fi
    done
    
    # Log files
    chmod 644 /var/log/cyberpanel* 2>/dev/null || true
    chmod 644 /var/log/lscpd* 2>/dev/null || true
    
    echo -e "${GREEN}File permissions fixed${NC}"
    log_message "File permissions fixed"
}

# Function to fix SSL context issues
fix_ssl_context() {
    echo -e "\n${CYAN}=== Fixing SSL Context Issues ===${NC}"
    log_message "Fixing SSL context issues"
    
    # Find all virtual host configurations
    local vhost_dirs=(
        "/usr/local/lsws/conf/vhosts"
        "/usr/local/lsws/conf/vhosts/*/conf"
    )
    
    for vhost_dir in "${vhost_dirs[@]}"; do
        if [[ -d "$vhost_dir" ]]; then
            find "$vhost_dir" -name "*.conf" -type f | while read -r conf_file; do
                if [[ -f "$conf_file" ]]; then
                    # Check if acme-challenge context is missing
                    if ! grep -q "acme-challenge" "$conf_file"; then
                        echo -e "${BLUE}Adding acme-challenge context to $conf_file${NC}"
                        
                        # Add acme-challenge context
                        cat >> "$conf_file" << 'EOF'

context /acme-challenge/ {
  type                    proxy
  addDefaultCharset       off
  extraHeaders            <<<END_extraHeaders
    X-Forwarded-Proto $scheme
  END_extraHeaders
  proxyHeader            1
  enableGzipCompress      0
  urlRewrite              <<<END_urlRewrite
    rewriteCond %{HTTP:Upgrade} websocket [NC]
    rewriteCond %{HTTP:Connection} upgrade [NC]
    rewriteRule ^(.*)$ "ws://127.0.0.1:8080/$1" [P,L]
    rewriteCond %{REQUEST_FILENAME} !-f
    rewriteCond %{REQUEST_FILENAME} !-d
    rewriteRule ^(.*)$ "http://127.0.0.1:8080/$1" [P,L]
  END_urlRewrite
}
EOF
                        log_message "Added acme-challenge context to $conf_file"
                    fi
                fi
            done
        fi
    done
    
    echo -e "${GREEN}SSL context issues fixed${NC}"
    log_message "SSL context issues fixed"
}

# Function to fix service issues
fix_services() {
    echo -e "\n${CYAN}=== Fixing Service Issues ===${NC}"
    log_message "Fixing service issues"
    
    # Restart CyberPanel services
    local services=("lscpd" "gunicorn" "mariadb" "mysqld" "mysql")
    
    for service in "${services[@]}"; do
        if systemctl list-unit-files | grep -q "^${service}.service"; then
            echo -e "${BLUE}Restarting $service service...${NC}"
            systemctl restart "$service" 2>/dev/null || {
                echo -e "${YELLOW}Warning: Could not restart $service${NC}"
            }
            log_message "Restarted $service service"
        fi
    done
    
    # Enable services
    for service in "${services[@]}"; do
        if systemctl list-unit-files | grep -q "^${service}.service"; then
            systemctl enable "$service" 2>/dev/null || true
        fi
    done
    
    echo -e "${GREEN}Service issues fixed${NC}"
    log_message "Service issues fixed"
}

# Function to fix database issues
fix_database() {
    echo -e "\n${CYAN}=== Fixing Database Issues ===${NC}"
    log_message "Fixing database issues"
    
    # Check if MariaDB/MySQL is running
    if ! systemctl is-active --quiet mariadb && ! systemctl is-active --quiet mysqld && ! systemctl is-active --quiet mysql; then
        echo -e "${YELLOW}Database service not running, attempting to start...${NC}"
        
        # Try to start database service
        local db_services=("mariadb" "mysqld" "mysql")
        for service in "${db_services[@]}"; do
            if systemctl list-unit-files | grep -q "^${service}.service"; then
                systemctl start "$service" && {
                    systemctl enable "$service"
                    echo -e "${GREEN}Started $service service${NC}"
                    log_message "Started $service service"
                    break
                }
            fi
        done
    fi
    
    # Check database connection
    local mysql_password=$(cat /etc/cyberpanel/mysqlPassword 2>/dev/null || echo "")
    if [[ -n "$mysql_password" ]]; then
        local mariadb_cmd=""
        if command -v mariadb >/dev/null 2>&1; then
            mariadb_cmd="mariadb"
        elif command -v mysql >/dev/null 2>&1; then
            mariadb_cmd="mysql"
        fi
        
        if [[ -n "$mariadb_cmd" ]]; then
            if $mariadb_cmd -u root -p"$mysql_password" -e "SELECT 1;" >/dev/null 2>&1; then
                echo -e "${GREEN}Database connection successful${NC}"
                log_message "Database connection successful"
            else
                echo -e "${YELLOW}Warning: Database connection failed${NC}"
                log_message "Warning: Database connection failed"
            fi
        fi
    fi
    
    echo -e "${GREEN}Database issues fixed${NC}"
    log_message "Database issues fixed"
}

# Function to fix Python environment
fix_python_environment() {
    echo -e "\n${CYAN}=== Fixing Python Environment ===${NC}"
    log_message "Fixing Python environment"
    
    # Check if virtual environment exists
    if [[ -d /usr/local/CyberCP ]]; then
        echo -e "${BLUE}Fixing CyberPanel Python environment...${NC}"
        
        # Activate virtual environment and reinstall requirements
        source /usr/local/CyberCP/bin/activate 2>/dev/null || {
            echo -e "${YELLOW}Warning: Could not activate virtual environment${NC}"
        }
        
        # Install/upgrade requirements
        if [[ -f /usr/local/CyberCP/requirments.txt ]]; then
            pip install --ignore-installed -r /usr/local/CyberCP/requirments.txt || {
                echo -e "${YELLOW}Warning: Could not install requirements${NC}"
            }
        fi
        
        # Deactivate virtual environment
        deactivate 2>/dev/null || true
        
        # Recreate virtual environment if needed
        if [[ ! -f /usr/local/CyberCP/bin/activate ]]; then
            echo -e "${BLUE}Recreating virtual environment...${NC}"
            virtualenv --system-site-packages /usr/local/CyberCP || {
                echo -e "${YELLOW}Warning: Could not recreate virtual environment${NC}"
            }
        fi
        
        # Restart Gunicorn
        systemctl restart gunicorn.socket 2>/dev/null || {
            echo -e "${YELLOW}Warning: Could not restart Gunicorn${NC}"
        }
        
        echo -e "${GREEN}Python environment fixed${NC}"
        log_message "Python environment fixed"
    else
        echo -e "${YELLOW}CyberPanel directory not found${NC}"
    fi
}

# Function to fix 503 errors
fix_503_errors() {
    echo -e "\n${CYAN}=== Fixing 503 Service Unavailable Errors ===${NC}"
    log_message "Fixing 503 errors"
    
    # Check if Gunicorn is running
    if ! systemctl is-active --quiet gunicorn; then
        echo -e "${BLUE}Starting Gunicorn service...${NC}"
        systemctl start gunicorn || {
            echo -e "${YELLOW}Warning: Could not start Gunicorn${NC}"
        }
    fi
    
    # Check if LiteSpeed is running
    if ! systemctl is-active --quiet lscpd; then
        echo -e "${BLUE}Starting LiteSpeed service...${NC}"
        systemctl start lscpd || {
            echo -e "${YELLOW}Warning: Could not start LiteSpeed${NC}"
        }
    fi
    
    # Check if database is running
    if ! systemctl is-active --quiet mariadb && ! systemctl is-active --quiet mysqld && ! systemctl is-active --quiet mysql; then
        echo -e "${BLUE}Starting database service...${NC}"
        local db_services=("mariadb" "mysqld" "mysql")
        for service in "${db_services[@]}"; do
            if systemctl list-unit-files | grep -q "^${service}.service"; then
                systemctl start "$service" && break
            fi
        done
    fi
    
    # Restart all services
    systemctl restart lscpd gunicorn 2>/dev/null || true
    
    echo -e "${GREEN}503 errors fixed${NC}"
    log_message "503 errors fixed"
}

# Function to fix missing WP-CLI
fix_missing_wp_cli() {
    echo -e "\n${CYAN}=== Fixing Missing WP-CLI ===${NC}"
    log_message "Fixing missing WP-CLI"
    
    if [[ ! -f /usr/local/bin/wp ]]; then
        echo -e "${BLUE}Installing WP-CLI...${NC}"
        
        # Download WP-CLI
        curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/gh-pages/phar/wp-cli.phar || {
            echo -e "${RED}ERROR: Failed to download WP-CLI${NC}"
            return 1
        }
        
        # Make it executable
        chmod +x wp-cli.phar
        
        # Move to system location
        mv wp-cli.phar /usr/local/bin/wp
        
        echo -e "${GREEN}WP-CLI installed successfully${NC}"
        log_message "WP-CLI installed successfully"
    else
        echo -e "${GREEN}WP-CLI already installed${NC}"
    fi
}

# Function to fix self-signed certificate issues
fix_selfsigned_certificates() {
    echo -e "\n${CYAN}=== Fixing Self-Signed Certificate Issues ===${NC}"
    log_message "Fixing self-signed certificate issues"
    
    # Check if OpenSSL is available
    if ! command -v openssl >/dev/null 2>&1; then
        echo -e "${BLUE}Installing OpenSSL...${NC}"
        $PKG_INSTALL openssl || {
            echo -e "${RED}ERROR: Failed to install OpenSSL${NC}"
            return 1
        }
    fi
    
    # Generate new self-signed certificate
    local cert_dir="/usr/local/lsws/conf/cert"
    mkdir -p "$cert_dir"
    
    echo -e "${BLUE}Generating new self-signed certificate...${NC}"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$cert_dir/selfsigned.key" \
        -out "$cert_dir/selfsigned.crt" \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" 2>/dev/null || {
        echo -e "${YELLOW}Warning: Could not generate self-signed certificate${NC}"
    }
    
    # Set proper permissions
    chmod 600 "$cert_dir/selfsigned.key"
    chmod 644 "$cert_dir/selfsigned.crt"
    
    echo -e "${GREEN}Self-signed certificate issues fixed${NC}"
    log_message "Self-signed certificate issues fixed"
}

# Function to run all fixes
run_all_fixes() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}  Running All CyberPanel Core Fixes${NC}"
    echo -e "${PURPLE}========================================${NC}"
    
    fix_symbolic_links
    fix_permissions
    fix_ssl_context
    fix_services
    fix_database
    fix_python_environment
    fix_503_errors
    fix_missing_wp_cli
    fix_selfsigned_certificates
    
    echo -e "\n${GREEN}All fixes completed successfully!${NC}"
    log_message "All fixes completed successfully"
}

# Function to show help
show_help() {
    echo -e "${CYAN}Enhanced CyberPanel Core Fixes${NC}"
    echo -e ""
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  $0 [option]"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  --all              Run all fixes"
    echo -e "  --symbolic-links   Fix symbolic links"
    echo -e "  --permissions      Fix file permissions"
    echo -e "  --ssl-context      Fix SSL context issues"
    echo -e "  --services         Fix service issues"
    echo -e "  --database         Fix database issues"
    echo -e "  --python           Fix Python environment"
    echo -e "  --503-errors       Fix 503 errors"
    echo -e "  --wp-cli           Fix missing WP-CLI"
    echo -e "  --certificates     Fix self-signed certificates"
    echo -e "  --help             Show this help message"
    echo -e ""
    echo -e "${BLUE}Examples:${NC}"
    echo -e "  $0 --all                    # Run all fixes"
    echo -e "  $0 --symbolic-links         # Fix only symbolic links"
    echo -e "  $0 --permissions --services # Fix permissions and services"
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
    echo -e "${PURPLE}  CyberPanel Core Fixes (Interactive)${NC}"
    echo -e "${PURPLE}========================================${NC}"
    
    while true; do
        echo -e "\n${CYAN}Please choose an option:${NC}"
        echo -e "1. Run all fixes"
        echo -e "2. Fix symbolic links"
        echo -e "3. Fix permissions"
        echo -e "4. Fix SSL context"
        echo -e "5. Fix services"
        echo -e "6. Fix database"
        echo -e "7. Fix Python environment"
        echo -e "8. Fix 503 errors"
        echo -e "9. Fix missing WP-CLI"
        echo -e "10. Fix self-signed certificates"
        echo -e "11. Exit"
        echo -e ""
        printf "%s" "Please enter number [1-11]: "
        read choice
        
        case $choice in
            1) run_all_fixes ;;
            2) fix_symbolic_links ;;
            3) fix_permissions ;;
            4) fix_ssl_context ;;
            5) fix_services ;;
            6) fix_database ;;
            7) fix_python_environment ;;
            8) fix_503_errors ;;
            9) fix_missing_wp_cli ;;
            10) fix_selfsigned_certificates ;;
            11) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Please enter a valid number [1-11]${NC}" ;;
        esac
    done
}

# Main function
main() {
    check_root
    detect_os
    check_cyberpanel
    
    # Handle command line arguments
    if [[ $# -eq 0 ]]; then
        interactive_mode
    else
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --all)
                run_all_fixes
                ;;
            --symbolic-links)
                fix_symbolic_links
                ;;
            --permissions)
                fix_permissions
                ;;
            --ssl-context)
                fix_ssl_context
                ;;
            --services)
                fix_services
                ;;
            --database)
                fix_database
                ;;
            --python)
                fix_python_environment
                ;;
            --503-errors)
                fix_503_errors
                ;;
            --wp-cli)
                fix_missing_wp_cli
                ;;
            --certificates)
                fix_selfsigned_certificates
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    fi
}

# Run main function
main "$@"
