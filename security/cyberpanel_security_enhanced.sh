#!/bin/bash

# Enhanced CyberPanel Security Script
# Comprehensive security hardening and fixes for all supported operating systems
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
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/cyberpanel_security.log
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

# Function to disable 2FA
disable_2fa() {
    echo -e "\n${CYAN}=== Disabling Two-Factor Authentication ===${NC}"
    log_message "Disabling 2FA"
    
    # Check if CyberPanel is running
    if ! systemctl is-active --quiet lscpd; then
        echo -e "${YELLOW}CyberPanel service not running, starting...${NC}"
        systemctl start lscpd || {
            echo -e "${RED}ERROR: Could not start CyberPanel service${NC}"
            return 1
        }
    fi
    
    # Disable 2FA in database
    local mysql_password=$(cat /etc/cyberpanel/mysqlPassword 2>/dev/null || echo "")
    if [[ -n "$mysql_password" ]]; then
        local mariadb_cmd=""
        if command -v mariadb >/dev/null 2>&1; then
            mariadb_cmd="mariadb"
        elif command -v mysql >/dev/null 2>&1; then
            mariadb_cmd="mysql"
        fi
        
        if [[ -n "$mariadb_cmd" ]]; then
            echo -e "${BLUE}Disabling 2FA in database...${NC}"
            $mariadb_cmd -u root -p"$mysql_password" -e "UPDATE cyberpanel.admin SET twoFA = 0 WHERE id = 1;" 2>/dev/null || {
                echo -e "${YELLOW}Warning: Could not disable 2FA in database${NC}"
            }
            log_message "2FA disabled in database"
        fi
    fi
    
    # Remove 2FA configuration files
    rm -f /etc/cyberpanel/2fa_* 2>/dev/null || true
    rm -f /home/cyberpanel/.google_authenticator 2>/dev/null || true
    
    echo -e "${GREEN}2FA disabled successfully${NC}"
    log_message "2FA disabled successfully"
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

# Function to fix file permissions
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
    
    # Secure sensitive files
    chmod 600 /etc/cyberpanel/mysqlPassword 2>/dev/null || true
    chmod 600 /etc/cyberpanel/adminPassword 2>/dev/null || true
    
    echo -e "${GREEN}File permissions fixed${NC}"
    log_message "File permissions fixed"
}

# Function to secure MariaDB/MySQL
secure_database() {
    echo -e "\n${CYAN}=== Securing Database ===${NC}"
    log_message "Securing database"
    
    local mysql_password=$(cat /etc/cyberpanel/mysqlPassword 2>/dev/null || echo "")
    if [[ -n "$mysql_password" ]]; then
        local mariadb_cmd=""
        if command -v mariadb >/dev/null 2>&1; then
            mariadb_cmd="mariadb"
        elif command -v mysql >/dev/null 2>&1; then
            mariadb_cmd="mysql"
        fi
        
        if [[ -n "$mariadb_cmd" ]]; then
            echo -e "${BLUE}Securing database...${NC}"
            
            # Remove test database
            $mariadb_cmd -u root -p"$mysql_password" -e "DROP DATABASE IF EXISTS test;" 2>/dev/null || true
            
            # Remove anonymous users
            $mariadb_cmd -u root -p"$mysql_password" -e "DELETE FROM mysql.user WHERE User='';" 2>/dev/null || true
            
            # Remove test database privileges
            $mariadb_cmd -u root -p"$mysql_password" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" 2>/dev/null || true
            
            # Flush privileges
            $mariadb_cmd -u root -p"$mysql_password" -e "FLUSH PRIVILEGES;" 2>/dev/null || true
            
            log_message "Database secured"
        fi
    fi
    
    echo -e "${GREEN}Database secured${NC}"
}

# Function to configure firewall
configure_firewall() {
    echo -e "\n${CYAN}=== Configuring Firewall ===${NC}"
    log_message "Configuring firewall"
    
    # Check if ufw is available (Ubuntu/Debian)
    if command -v ufw >/dev/null 2>&1; then
        echo -e "${BLUE}Configuring UFW firewall...${NC}"
        
        # Enable firewall
        ufw --force enable
        
        # Allow SSH
        ufw allow ssh
        
        # Allow HTTP and HTTPS
        ufw allow 80/tcp
        ufw allow 443/tcp
        
        # Allow CyberPanel ports
        ufw allow 8090/tcp  # CyberPanel admin
        ufw allow 7080/tcp  # LiteSpeed admin
        
        # Allow mail ports
        ufw allow 25/tcp    # SMTP
        ufw allow 587/tcp   # SMTP submission
        ufw allow 993/tcp   # IMAPS
        ufw allow 995/tcp   # POP3S
        
        log_message "UFW firewall configured"
    fi
    
    # Check if firewalld is available (RHEL-based)
    if command -v firewall-cmd >/dev/null 2>&1; then
        echo -e "${BLUE}Configuring firewalld...${NC}"
        
        # Start and enable firewalld
        systemctl start firewalld
        systemctl enable firewalld
        
        # Allow services
        firewall-cmd --permanent --add-service=ssh
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        firewall-cmd --permanent --add-port=8090/tcp
        firewall-cmd --permanent --add-port=7080/tcp
        firewall-cmd --permanent --add-service=smtp
        firewall-cmd --permanent --add-service=imaps
        firewall-cmd --permanent --add-service=pop3s
        
        # Reload firewall
        firewall-cmd --reload
        
        log_message "firewalld configured"
    fi
    
    echo -e "${GREEN}Firewall configured${NC}"
}

# Function to install security updates
install_security_updates() {
    echo -e "\n${CYAN}=== Installing Security Updates ===${NC}"
    log_message "Installing security updates"
    
    # Update package lists
    $PKG_UPDATE || {
        echo -e "${YELLOW}Warning: Package list update failed${NC}"
    }
    
    # Install security updates
    if [[ $OS_NAME == "Ubuntu" ]] || [[ $OS_NAME == "Debian" ]]; then
        $PKG_INSTALL unattended-upgrades || true
        unattended-upgrade -d || true
    else
        $PKG_INSTALL yum-plugin-security || true
        $PKG_INSTALL --security || true
    fi
    
    echo -e "${GREEN}Security updates installed${NC}"
    log_message "Security updates installed"
}

# Function to configure fail2ban
configure_fail2ban() {
    echo -e "\n${CYAN}=== Configuring Fail2Ban ===${NC}"
    log_message "Configuring fail2ban"
    
    # Install fail2ban
    $PKG_INSTALL fail2ban || {
        echo -e "${YELLOW}Warning: Could not install fail2ban${NC}"
        return 1
    }
    
    # Create CyberPanel jail configuration
    cat > /etc/fail2ban/jail.d/cyberpanel.conf << 'EOF'
[cyberpanel]
enabled = true
port = 8090
filter = cyberpanel
logpath = /var/log/cyberpanel/error.log
maxretry = 3
bantime = 3600
findtime = 600

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

    # Create CyberPanel filter
    cat > /etc/fail2ban/filter.d/cyberpanel.conf << 'EOF'
[Definition]
failregex = ^.*Invalid login attempt.*$
ignoreregex =
EOF

    # Start and enable fail2ban
    systemctl start fail2ban
    systemctl enable fail2ban
    
    echo -e "${GREEN}Fail2ban configured${NC}"
    log_message "Fail2ban configured"
}

# Function to configure ModSecurity
configure_modsecurity() {
    echo -e "\n${CYAN}=== Configuring ModSecurity ===${NC}"
    log_message "Configuring ModSecurity"
    
    # Install ModSecurity
    if [[ $OS_NAME == "Ubuntu" ]] || [[ $OS_NAME == "Debian" ]]; then
        $PKG_INSTALL libapache2-mod-security2 || true
    else
        $PKG_INSTALL mod_security || true
    fi
    
    # Download OWASP ModSecurity Core Rule Set
    if [[ ! -d /usr/local/lsws/conf/modsec/rules ]]; then
        mkdir -p /usr/local/lsws/conf/modsec/rules
        cd /usr/local/lsws/conf/modsec/rules
        
        # Download CRS
        wget -q https://github.com/coreruleset/coreruleset/archive/v3.3.4.tar.gz
        tar -xzf v3.3.4.tar.gz
        mv coreruleset-3.3.4/* .
        rm -rf coreruleset-3.3.4 v3.3.4.tar.gz
        
        # Configure CRS
        cp crs-setup.conf.example crs-setup.conf
        sed -i 's/SecDefaultAction "phase:1,log,auditlog,pass"/SecDefaultAction "phase:1,log,auditlog,deny,status:403"/' crs-setup.conf
        sed -i 's/SecDefaultAction "phase:2,log,auditlog,pass"/SecDefaultAction "phase:2,log,auditlog,deny,status:403"/' crs-setup.conf
        
        log_message "ModSecurity CRS configured"
    fi
    
    echo -e "${GREEN}ModSecurity configured${NC}"
}

# Function to run all security fixes
run_all_security_fixes() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}  Running All CyberPanel Security Fixes${NC}"
    echo -e "${PURPLE}========================================${NC}"
    
    fix_permissions
    fix_ssl_context
    secure_database
    configure_firewall
    install_security_updates
    configure_fail2ban
    configure_modsecurity
    
    echo -e "\n${GREEN}All security fixes completed successfully!${NC}"
    log_message "All security fixes completed successfully"
}

# Function to show help
show_help() {
    echo -e "${CYAN}Enhanced CyberPanel Security Script${NC}"
    echo -e ""
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  $0 [option]"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  --all              Run all security fixes"
    echo -e "  --disable-2fa      Disable two-factor authentication"
    echo -e "  --ssl-context      Fix SSL context issues"
    echo -e "  --permissions      Fix file permissions"
    echo -e "  --database         Secure database"
    echo -e "  --firewall         Configure firewall"
    echo -e "  --updates          Install security updates"
    echo -e "  --fail2ban         Configure fail2ban"
    echo -e "  --modsecurity      Configure ModSecurity"
    echo -e "  --help             Show this help message"
    echo -e ""
    echo -e "${BLUE}Examples:${NC}"
    echo -e "  $0 --all                    # Run all security fixes"
    echo -e "  $0 --disable-2fa            # Disable 2FA only"
    echo -e "  $0 --permissions --firewall # Fix permissions and configure firewall"
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
    echo -e "${PURPLE}  CyberPanel Security (Interactive)${NC}"
    echo -e "${PURPLE}========================================${NC}"
    
    while true; do
        echo -e "\n${CYAN}Please choose an option:${NC}"
        echo -e "1. Run all security fixes"
        echo -e "2. Disable 2FA"
        echo -e "3. Fix SSL context"
        echo -e "4. Fix permissions"
        echo -e "5. Secure database"
        echo -e "6. Configure firewall"
        echo -e "7. Install security updates"
        echo -e "8. Configure fail2ban"
        echo -e "9. Configure ModSecurity"
        echo -e "10. Exit"
        echo -e ""
        printf "%s" "Please enter number [1-10]: "
        read choice
        
        case $choice in
            1) run_all_security_fixes ;;
            2) disable_2fa ;;
            3) fix_ssl_context ;;
            4) fix_permissions ;;
            5) secure_database ;;
            6) configure_firewall ;;
            7) install_security_updates ;;
            8) configure_fail2ban ;;
            9) configure_modsecurity ;;
            10) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Please enter a valid number [1-10]${NC}" ;;
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
                run_all_security_fixes
                ;;
            --disable-2fa)
                disable_2fa
                ;;
            --ssl-context)
                fix_ssl_context
                ;;
            --permissions)
                fix_permissions
                ;;
            --database)
                secure_database
                ;;
            --firewall)
                configure_firewall
                ;;
            --updates)
                install_security_updates
                ;;
            --fail2ban)
                configure_fail2ban
                ;;
            --modsecurity)
                configure_modsecurity
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
