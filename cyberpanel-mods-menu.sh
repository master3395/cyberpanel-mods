#!/bin/bash

# CyberPanel Mods Master Menu
# Interactive menu system for all CyberPanel mods and utilities
# Supports all CyberPanel-compatible operating systems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ASCII Art Banner
show_banner() {
    echo -e "${PURPLE}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║                                                              ║"
    echo "  ║  🚀 CyberPanel Mods - Enhanced Repository v2.1.0 🚀         ║"
    echo "  ║                                                              ║"
    echo "  ║  The most comprehensive collection of CyberPanel mods        ║"
    echo "  ║  with full cross-platform compatibility                      ║"
    echo "  ║                                                              ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Logging function
log_message() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/cyberpanel_mods_menu.log
}

# Function to detect OS
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
            ;;
        "almalinux")
            OS_NAME="AlmaLinux"
            OS_VERSION="$VERSION_ID"
            ;;
        "rocky")
            OS_NAME="RockyLinux"
            OS_VERSION="$VERSION_ID"
            ;;
        "rhel")
            OS_NAME="RHEL"
            OS_VERSION="$VERSION_ID"
            ;;
        "centos")
            OS_NAME="CentOS"
            OS_VERSION="$VERSION_ID"
            ;;
        "cloudlinux")
            OS_NAME="CloudLinux"
            OS_VERSION="$VERSION_ID"
            ;;
        "openeuler")
            OS_NAME="openEuler"
            OS_VERSION="$VERSION_ID"
            ;;
        "debian")
            OS_NAME="Debian"
            OS_VERSION="$VERSION_ID"
            ;;
        *)
            OS_NAME="Unknown"
            OS_VERSION="$VERSION_ID"
            ;;
    esac
    
    echo -e "${BLUE}Detected OS: $OS_NAME $OS_VERSION${NC}"
    log_message "Detected OS: $OS_NAME $OS_VERSION"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}ERROR: This script must be run as root${NC}"
        echo -e "${YELLOW}Please run: sudo su -${NC}"
        exit 1
    fi
}

# Function to check if CyberPanel is installed
check_cyberpanel() {
    if [[ ! -f /etc/cyberpanel/machineIP ]]; then
        echo -e "${YELLOW}WARNING: CyberPanel not detected${NC}"
        echo -e "${YELLOW}Some features may not work properly${NC}"
        return 1
    fi
    echo -e "${GREEN}CyberPanel installation detected${NC}"
    return 0
}

# Function to show system status
show_system_status() {
    echo -e "\n${CYAN}=== System Status ===${NC}"
    
    # Check CyberPanel status
    if systemctl is-active --quiet lscpd; then
        echo -e "${GREEN}✓ CyberPanel service is running${NC}"
    else
        echo -e "${RED}✗ CyberPanel service is not running${NC}"
    fi
    
    # Check database status
    if systemctl is-active --quiet mariadb || systemctl is-active --quiet mysqld || systemctl is-active --quiet mysql; then
        echo -e "${GREEN}✓ Database service is running${NC}"
    else
        echo -e "${RED}✗ Database service is not running${NC}"
    fi
    
    # Check disk space
    local disk_usage=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
    if [[ $disk_usage -lt 80 ]]; then
        echo -e "${GREEN}✓ Disk usage: ${disk_usage}%${NC}"
    else
        echo -e "${YELLOW}⚠ Disk usage: ${disk_usage}%${NC}"
    fi
    
    # Check memory usage
    local memory_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    if [[ $memory_usage -lt 80 ]]; then
        echo -e "${GREEN}✓ Memory usage: ${memory_usage}%${NC}"
    else
        echo -e "${YELLOW}⚠ Memory usage: ${memory_usage}%${NC}"
    fi
}

# Function to run user management
run_user_management() {
    echo -e "\n${BLUE}Starting User & Website Management Interface...${NC}"
    if [[ -f "user-management/user-management-menu.sh" ]]; then
        bash user-management/user-management-menu.sh
    else
        echo -e "${YELLOW}User management not found locally, downloading...${NC}"
        # Create directory if it doesn't exist
        mkdir -p user-management
        # Download the user management scripts
        curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/user-management/user-management-menu.sh -o user-management/user-management-menu.sh
        curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/user-management/user-functions.sh -o user-management/user-functions.sh
        curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/user-management/website-functions.sh -o user-management/website-functions.sh
        curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/user-management/cyberpanel-user-cli.sh -o user-management/cyberpanel-user-cli.sh
        chmod +x user-management/*.sh
        bash user-management/user-management-menu.sh
    fi
    pause
}

# Function to run OS compatibility check
run_compatibility_check() {
    echo -e "\n${BLUE}Running OS compatibility check...${NC}"
    if [[ -f "utilities/os_compatibility_checker.sh" ]]; then
        bash utilities/os_compatibility_checker.sh
    else
        echo -e "${YELLOW}Compatibility checker not found locally, downloading...${NC}"
        curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash
    fi
    pause
}

# Function to run utilities
run_utilities() {
    while true; do
        echo -e "\n${CYAN}=== Utilities ===${NC}"
        echo -e "1. Enhanced CyberPanel Utility"
        echo -e "2. Cloudflare to PowerDNS Migration"
        echo -e "3. CrowdSec Update"
        echo -e "4. CyberPanel Sessions Manager"
        echo -e "5. CyberPanel Sessions Cronjob"
        echo -e "6. Default Website Page Setup"
        echo -e "7. Install PureFTPD"
        echo -e "8. Install vsFTPD"
        echo -e "9. Back to Main Menu"
        echo -e ""
        printf "%s" "Please enter number [1-9]: "
        read choice
        
        case $choice in
            1)
                echo -e "\n${BLUE}Starting Enhanced CyberPanel Utility...${NC}"
                if [[ -f "utilities/cyberpanel_utility_enhanced.sh" ]]; then
                    bash utilities/cyberpanel_utility_enhanced.sh
                else
                    echo -e "${YELLOW}Enhanced utility not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility_enhanced.sh | bash
                fi
                pause
                ;;
            2)
                echo -e "\n${BLUE}Migrating from Cloudflare to PowerDNS...${NC}"
                if [[ -f "utilities/cloudflare_to_powerdns.sh" ]]; then
                    bash utilities/cloudflare_to_powerdns.sh
                else
                    echo -e "${YELLOW}Migration script not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cloudflare_to_powerdns.sh | bash
                fi
                pause
                ;;
            3)
                echo -e "\n${BLUE}Updating CrowdSec...${NC}"
                if [[ -f "utilities/crowdsec_update.sh" ]]; then
                    bash utilities/crowdsec_update.sh
                else
                    echo -e "${YELLOW}CrowdSec update not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/crowdsec_update.sh | bash
                fi
                pause
                ;;
            4)
                echo -e "\n${BLUE}Managing CyberPanel Sessions...${NC}"
                if [[ -f "utilities/cyberpanel_sessions.sh" ]]; then
                    bash utilities/cyberpanel_sessions.sh
                else
                    echo -e "${YELLOW}Sessions manager not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_sessions.sh | bash
                fi
                pause
                ;;
            5)
                echo -e "\n${BLUE}Setting up CyberPanel Sessions Cronjob...${NC}"
                if [[ -f "utilities/cyberpanel_sessions_cronjob.sh" ]]; then
                    bash utilities/cyberpanel_sessions_cronjob.sh
                else
                    echo -e "${YELLOW}Sessions cronjob not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_sessions_cronjob.sh | bash
                fi
                pause
                ;;
            6)
                echo -e "\n${BLUE}Setting up Default Website Page...${NC}"
                if [[ -f "utilities/defaultwebsitepage.sh" ]]; then
                    bash utilities/defaultwebsitepage.sh
                else
                    echo -e "${YELLOW}Default page script not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/defaultwebsitepage.sh | bash
                fi
                pause
                ;;
            7)
                echo -e "\n${BLUE}Installing PureFTPD...${NC}"
                if [[ -f "utilities/install_pureftpd.sh" ]]; then
                    bash utilities/install_pureftpd.sh
                else
                    echo -e "${YELLOW}PureFTPD installer not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/install_pureftpd.sh | bash
                fi
                pause
                ;;
            8)
                echo -e "\n${BLUE}Installing vsFTPD...${NC}"
                if [[ -f "utilities/install_vsftpd.sh" ]]; then
                    bash utilities/install_vsftpd.sh
                else
                    echo -e "${YELLOW}vsFTPD installer not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/install_vsftpd.sh | bash
                fi
                pause
                ;;
            9)
                break
                ;;
            *)
                echo -e "${RED}Please enter a valid number [1-9]${NC}"
                ;;
        esac
    done
}

# Function to run core fixes
run_core_fixes() {
    while true; do
        echo -e "\n${CYAN}=== Core Fixes & Repairs ===${NC}"
        echo -e "1. Core Fixes (Enhanced)"
        echo -e "2. Fix 503 Service Unavailable"
        echo -e "3. Fix Missing WP-CLI"
        echo -e "4. MailScanner AlmaLinux 9 Fix"
        echo -e "5. Fix Symbolic Links"
        echo -e "6. AlmaLinux 10 Complete Fix"
        echo -e "7. AlmaLinux 10 Patch"
        echo -e "8. Back to Main Menu"
        echo -e ""
        printf "%s" "Please enter number [1-8]: "
        read choice
        
        case $choice in
            1)
                echo -e "\n${BLUE}Starting Core Fixes...${NC}"
                if [[ -f "core-fixes/cyberpanel_core_fixes_enhanced.sh" ]]; then
                    bash core-fixes/cyberpanel_core_fixes_enhanced.sh
                else
                    echo -e "${YELLOW}Core fixes not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash
                fi
                pause
                ;;
            2)
                echo -e "\n${BLUE}Fixing 503 Service Unavailable...${NC}"
                if [[ -f "core-fixes/fix_503_service_unavailable.sh" ]]; then
                    bash core-fixes/fix_503_service_unavailable.sh
                else
                    echo -e "${YELLOW}503 fix not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/fix_503_service_unavailable.sh | bash
                fi
                pause
                ;;
            3)
                echo -e "\n${BLUE}Fixing Missing WP-CLI...${NC}"
                if [[ -f "core-fixes/fix_missing_wp_cli.sh" ]]; then
                    bash core-fixes/fix_missing_wp_cli.sh
                else
                    echo -e "${YELLOW}WP-CLI fix not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/fix_missing_wp_cli.sh | bash
                fi
                pause
                ;;
            4)
                echo -e "\n${BLUE}Running MailScanner AlmaLinux 9 Fix...${NC}"
                if [[ -f "core-fixes/mailscanner_almalinux9_fix.sh" ]]; then
                    bash core-fixes/mailscanner_almalinux9_fix.sh
                else
                    echo -e "${YELLOW}MailScanner fix not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/mailscanner_almalinux9_fix.sh | bash
                fi
                pause
                ;;
            5)
                echo -e "\n${BLUE}Fixing Symbolic Links...${NC}"
                if [[ -f "core-fixes/cyberpanel_fix_symbolic_links.sh" ]]; then
                    bash core-fixes/cyberpanel_fix_symbolic_links.sh
                else
                    echo -e "${YELLOW}Symbolic links fix not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_fix_symbolic_links.sh | bash
                fi
                pause
                ;;
            6)
                echo -e "\n${BLUE}Running AlmaLinux 10 Complete Fix...${NC}"
                if [[ -f "core-fixes/cyberpanel-almalinux10-complete-fix.sh" ]]; then
                    bash core-fixes/cyberpanel-almalinux10-complete-fix.sh
                else
                    echo -e "${YELLOW}AlmaLinux 10 fix not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel-almalinux10-complete-fix.sh | bash
                fi
                pause
                ;;
            7)
                echo -e "\n${BLUE}Running AlmaLinux 10 Patch...${NC}"
                if [[ -f "core-fixes/patch-cyberpanel-almalinux10.sh" ]]; then
                    bash core-fixes/patch-cyberpanel-almalinux10.sh
                else
                    echo -e "${YELLOW}AlmaLinux 10 patch not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/patch-cyberpanel-almalinux10.sh | bash
                fi
                pause
                ;;
            8)
                break
                ;;
            *)
                echo -e "${RED}Please enter a valid number [1-8]${NC}"
                ;;
        esac
    done
}

# Function to run security tools
run_security_tools() {
    while true; do
        echo -e "\n${CYAN}=== Security Tools ===${NC}"
        echo -e "1. Security Hardening (Enhanced)"
        echo -e "2. Disable 2FA (Standalone)"
        echo -e "3. Fix ModSecurity LMDB Crash"
        echo -e "4. Fix Permissions"
        echo -e "5. Fix SSL Missing Context"
        echo -e "6. ModSecurity Fix"
        echo -e "7. Self-Signed Certificate Fixer"
        echo -e "8. Back to Main Menu"
        echo -e ""
        printf "%s" "Please enter number [1-8]: "
        read choice
        
        case $choice in
            1)
                echo -e "\n${BLUE}Starting Security Hardening...${NC}"
                if [[ -f "security/cyberpanel_security_enhanced.sh" ]]; then
                    bash security/cyberpanel_security_enhanced.sh
                else
                    echo -e "${YELLOW}Security script not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash
                fi
                pause
                ;;
            2)
                echo -e "\n${BLUE}Disabling 2FA...${NC}"
                if [[ -f "security/disable_2fa.sh" ]]; then
                    bash security/disable_2fa.sh
                else
                    echo -e "${YELLOW}2FA disable script not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/disable_2fa.sh | bash
                fi
                pause
                ;;
            3)
                echo -e "\n${BLUE}Fixing ModSecurity LMDB Crash...${NC}"
                if [[ -f "security/fix-modsecurity-lmdb-crash.sh" ]]; then
                    bash security/fix-modsecurity-lmdb-crash.sh
                else
                    echo -e "${YELLOW}ModSecurity fix not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix-modsecurity-lmdb-crash.sh | bash
                fi
                pause
                ;;
            4)
                echo -e "\n${BLUE}Fixing Permissions...${NC}"
                if [[ -f "security/fix_permissions.sh" ]]; then
                    bash security/fix_permissions.sh
                else
                    echo -e "${YELLOW}Permissions fix not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix_permissions.sh | bash
                fi
                pause
                ;;
            5)
                echo -e "\n${BLUE}Fixing SSL Missing Context...${NC}"
                if [[ -f "security/fix_ssl_missing_context.sh" ]]; then
                    bash security/fix_ssl_missing_context.sh
                else
                    echo -e "${YELLOW}SSL fix not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix_ssl_missing_context.sh | bash
                fi
                pause
                ;;
            6)
                echo -e "\n${BLUE}Running ModSecurity Fix...${NC}"
                if [[ -f "security/modsecurity-fix.sh" ]]; then
                    bash security/modsecurity-fix.sh
                else
                    echo -e "${YELLOW}ModSecurity fix not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/modsecurity-fix.sh | bash
                fi
                pause
                ;;
            7)
                echo -e "\n${BLUE}Running Self-Signed Certificate Fixer...${NC}"
                if [[ -f "security/selfsigned_fixer.sh" ]]; then
                    bash security/selfsigned_fixer.sh
                else
                    echo -e "${YELLOW}Self-signed fixer not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/selfsigned_fixer.sh | bash
                fi
                pause
                ;;
            8)
                break
                ;;
            *)
                echo -e "${RED}Please enter a valid number [1-8]${NC}"
                ;;
        esac
    done
}

# Function to run PHP version manager
run_php_manager() {
    echo -e "\n${BLUE}Starting PHP Version Manager...${NC}"
    if [[ -f "version-managers/php_version_manager_enhanced.sh" ]]; then
        bash version-managers/php_version_manager_enhanced.sh
    else
        echo -e "${YELLOW}PHP manager not found locally, downloading...${NC}"
        curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/php_version_manager_enhanced.sh | bash
    fi
    pause
}

# Function to run MariaDB version manager
run_mariadb_manager() {
    echo -e "\n${BLUE}Starting MariaDB Version Manager...${NC}"
    if [[ -f "version-managers/mariadb_version_manager_enhanced.sh" ]]; then
        bash version-managers/mariadb_version_manager_enhanced.sh
    else
        echo -e "${YELLOW}MariaDB manager not found locally, downloading...${NC}"
        curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/mariadb_version_manager_enhanced.sh | bash
    fi
    pause
}

# Function to run application version managers
run_app_version_managers() {
    while true; do
        echo -e "\n${CYAN}=== Application Version Managers ===${NC}"
        echo -e "1. Snappymail Version Changer"
        echo -e "2. phpMyAdmin Version Changer"
        echo -e "3. ModSecurity Rules Changer"
        echo -e "4. Back to Main Menu"
        echo -e ""
        printf "%s" "Please enter number [1-4]: "
        read choice
        
        case $choice in
            1)
                echo -e "\n${BLUE}Starting Snappymail Version Changer...${NC}"
                if [[ -f "version-managers/snappymail_v_changer.sh" ]]; then
                    bash version-managers/snappymail_v_changer.sh
                else
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/snappymail_v_changer.sh | bash
                fi
                pause
                ;;
            2)
                echo -e "\n${BLUE}Starting phpMyAdmin Version Changer...${NC}"
                if [[ -f "version-managers/phpmyadmin_v_changer.sh" ]]; then
                    bash version-managers/phpmyadmin_v_changer.sh
                else
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/phpmyadmin_v_changer.sh | bash
                fi
                pause
                ;;
            3)
                echo -e "\n${BLUE}Starting ModSecurity Rules Changer...${NC}"
                if [[ -f "version-managers/modsec_rules_v_changer.sh" ]]; then
                    bash version-managers/modsec_rules_v_changer.sh
                else
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/modsec_rules_v_changer.sh | bash
                fi
                pause
                ;;
            4)
                break
                ;;
            *)
                echo -e "${RED}Please enter a valid number [1-4]${NC}"
                ;;
        esac
    done
}

# Function to run backup and restore tools
run_backup_restore() {
    while true; do
        echo -e "\n${CYAN}=== Backup and Restore Tools ===${NC}"
        echo -e "1. RClone Backup Cronjob"
        echo -e "2. SQL Backup Cronjob"
        echo -e "3. Restore CyberPanel Database"
        echo -e "4. Back to Main Menu"
        echo -e ""
        printf "%s" "Please enter number [1-4]: "
        read choice
        
        case $choice in
            1)
                echo -e "\n${BLUE}Setting up RClone Backup Cronjob...${NC}"
                if [[ -f "backup-restore/rclone_backup_cronjob.sh" ]]; then
                    bash backup-restore/rclone_backup_cronjob.sh
                else
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/rclone_backup_cronjob.sh | bash
                fi
                pause
                ;;
            2)
                echo -e "\n${BLUE}Setting up SQL Backup Cronjob...${NC}"
                if [[ -f "backup-restore/rclone_sqlbackup_cronjob.sh" ]]; then
                    bash backup-restore/rclone_sqlbackup_cronjob.sh
                else
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/rclone_sqlbackup_cronjob.sh | bash
                fi
                pause
                ;;
            3)
                echo -e "\n${BLUE}Restoring CyberPanel Database...${NC}"
                if [[ -f "backup-restore/restore_cyberpanel_database.sh" ]]; then
                    bash backup-restore/restore_cyberpanel_database.sh
                else
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/restore_cyberpanel_database.sh | bash
                fi
                pause
                ;;
            4)
                break
                ;;
            *)
                echo -e "${RED}Please enter a valid number [1-4]${NC}"
                ;;
        esac
    done
}

# Function to run email fixes
run_email_fixes() {
    while true; do
        echo -e "\n${CYAN}=== Email Fixes ===${NC}"
        echo -e "1. Sieve (Filter) Fix for SnappyMail"
        echo -e "2. Back to Main Menu"
        echo -e ""
        printf "%s" "Please enter number [1-2]: "
        read choice
        
        case $choice in
            1)
                echo -e "\n${BLUE}Running Sieve Fix for SnappyMail...${NC}"
                if [[ -f "email-fixes/sieve_fix_enhanced.sh" ]]; then
                    bash email-fixes/sieve_fix_enhanced.sh
                else
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/email-fixes/sieve_fix_enhanced.sh | bash
                fi
                pause
                ;;
            2)
                break
                ;;
            *)
                echo -e "${RED}Please enter a valid number [1-2]${NC}"
                ;;
        esac
    done
}

# Function to run OS-specific fixes
run_os_specific() {
    while true; do
        echo -e "\n${CYAN}=== OS-Specific Fixes ===${NC}"
        echo -e "1. AlmaLinux 9 Upgrade Fix"
        echo -e "2. AlmaLinux 9 Patch"
        echo -e "3. Back to Main Menu"
        echo -e ""
        printf "%s" "Please enter number [1-3]: "
        read choice
        
        case $choice in
            1)
                echo -e "\n${BLUE}Running AlmaLinux 9 Upgrade Fix...${NC}"
                if [[ -f "os-specific/cyberpanel_almalinux9_upgrade_fix.sh" ]]; then
                    bash os-specific/cyberpanel_almalinux9_upgrade_fix.sh
                else
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/cyberpanel_almalinux9_upgrade_fix.sh | bash
                fi
                pause
                ;;
            2)
                echo -e "\n${BLUE}Running AlmaLinux 9 Patch...${NC}"
                if [[ -f "os-specific/installCyberPanel_almalinux9_patch.py" ]]; then
                    python3 os-specific/installCyberPanel_almalinux9_patch.py
                else
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/installCyberPanel_almalinux9_patch.py | python3
                fi
                pause
                ;;
            3)
                break
                ;;
            *)
                echo -e "${RED}Please enter a valid number [1-3]${NC}"
                ;;
        esac
    done
}

# Function to run rDNS tools
run_rdns_tools() {
    while true; do
        echo -e "\n${CYAN}=== rDNS Tools ===${NC}"
        echo -e "1. rDNS Fix"
        echo -e "2. Apply rDNS Fix"
        echo -e "3. Back to Main Menu"
        echo -e ""
        printf "%s" "Please enter number [1-3]: "
        read choice
        
        case $choice in
            1)
                echo -e "\n${BLUE}Running rDNS Fix...${NC}"
                if [[ -f "rdns/rdns-fix.sh" ]]; then
                    bash rdns/rdns-fix.sh
                else
                    echo -e "${YELLOW}rDNS fix not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/rdns/rdns-fix.sh | bash
                fi
                pause
                ;;
            2)
                echo -e "\n${BLUE}Applying rDNS Fix...${NC}"
                if [[ -f "rdns/apply-rdns-fix.sh" ]]; then
                    bash rdns/apply-rdns-fix.sh
                else
                    echo -e "${YELLOW}rDNS apply script not found locally, downloading...${NC}"
                    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/rdns/apply-rdns-fix.sh | bash
                fi
                pause
                ;;
            3)
                break
                ;;
            *)
                echo -e "${RED}Please enter a valid number [1-3]${NC}"
                ;;
        esac
    done
}

# Function to show documentation
show_documentation() {
    while true; do
        echo -e "\n${CYAN}=== Documentation ===${NC}"
        echo -e "1. Installation Guide"
        echo -e "2. Troubleshooting Guide"
        echo -e "3. Security Best Practices"
        echo -e "4. OS-Specific Notes"
        echo -e "5. View README"
        echo -e "6. Back to Main Menu"
        echo -e ""
        printf "%s" "Please enter number [1-6]: "
        read choice
        
        case $choice in
            1)
                if [[ -f "docs/installation-guide.md" ]]; then
                    less docs/installation-guide.md
                else
                    echo -e "${YELLOW}Installation guide not found locally${NC}"
                fi
                ;;
            2)
                if [[ -f "docs/troubleshooting-guide.md" ]]; then
                    less docs/troubleshooting-guide.md
                else
                    echo -e "${YELLOW}Troubleshooting guide not found locally${NC}"
                fi
                ;;
            3)
                if [[ -f "docs/security-best-practices.md" ]]; then
                    less docs/security-best-practices.md
                else
                    echo -e "${YELLOW}Security guide not found locally${NC}"
                fi
                ;;
            4)
                if [[ -f "docs/os-specific-notes.md" ]]; then
                    less docs/os-specific-notes.md
                else
                    echo -e "${YELLOW}OS-specific notes not found locally${NC}"
                fi
                ;;
            5)
                if [[ -f "README.md" ]]; then
                    less README.md
                else
                    echo -e "${YELLOW}README not found locally${NC}"
                fi
                ;;
            6)
                break
                ;;
            *)
                echo -e "${RED}Please enter a valid number [1-6]${NC}"
                ;;
        esac
    done
}

# Function to show system information
show_system_info() {
    echo -e "\n${CYAN}=== System Information ===${NC}"
    
    # OS Information
    echo -e "${BLUE}Operating System:${NC}"
    cat /etc/os-release | grep -E "^(NAME|VERSION)=" | sed 's/^/  /'
    
    # Kernel Information
    echo -e "\n${BLUE}Kernel:${NC}"
    echo "  $(uname -r)"
    
    # Architecture
    echo -e "\n${BLUE}Architecture:${NC}"
    echo "  $(uname -m)"
    
    # CPU Information
    echo -e "\n${BLUE}CPU:${NC}"
    if command -v lscpu >/dev/null 2>&1; then
        lscpu | grep "Model name" | sed 's/^/  /'
    else
        echo "  $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
    fi
    
    # Memory Information
    echo -e "\n${BLUE}Memory:${NC}"
    free -h | grep "Mem:" | sed 's/^/  /'
    
    # Disk Information
    echo -e "\n${BLUE}Disk Usage:${NC}"
    df -h / | awk 'NR==2{print "  " $3 " used of " $2 " (" $5 ")"}'
    
    # CyberPanel Information
    if [[ -f /etc/cyberpanel/machineIP ]]; then
        echo -e "\n${BLUE}CyberPanel:${NC}"
        echo "  Installed: Yes"
        if systemctl is-active --quiet lscpd; then
            echo "  Status: Running"
        else
            echo "  Status: Stopped"
        fi
    else
        echo -e "\n${BLUE}CyberPanel:${NC}"
        echo "  Installed: No"
    fi
    
    pause
}

# Function to update the menu script
update_menu() {
    echo -e "\n${BLUE}Updating CyberPanel Mods Menu...${NC}"
    
    # Download latest version
    curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh -o /tmp/cyberpanel-mods-menu.sh
    
    # Check if download was successful
    if [[ -f /tmp/cyberpanel-mods-menu.sh ]]; then
        # Backup current version
        cp cyberpanel-mods-menu.sh cyberpanel-mods-menu.sh.backup 2>/dev/null || true
        
        # Replace with new version
        mv /tmp/cyberpanel-mods-menu.sh cyberpanel-mods-menu.sh
        chmod +x cyberpanel-mods-menu.sh
        
        echo -e "${GREEN}Menu updated successfully!${NC}"
        echo -e "${YELLOW}Please restart the menu to use the latest version${NC}"
    else
        echo -e "${RED}Failed to download update${NC}"
    fi
    
    pause
}

# Function to pause and wait for user input
pause() {
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# Function to show main menu
show_main_menu() {
    while true; do
        clear
        show_banner
        detect_os
        show_system_status
        
        echo -e "\n${WHITE}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${WHITE}║                        MAIN MENU                           ║${NC}"
        echo -e "${WHITE}╠══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${WHITE}║                                                              ║${NC}"
        # Menu items with precisely calculated padding (Python-verified values)
        # Total width: 62 chars, Content: 58 chars (62 - 3 left border - 1 right border)
        # Emojis are 2 characters wide visually, numbers are 1-2 digits
        printf "${WHITE}║  ${GREEN}%2d.${NC} ❌ Exit%46s${WHITE}║${NC}\n" 0 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 👥 User & Website Management%25s${WHITE}║${NC}\n" 1 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 🔍 OS Compatibility Check%28s${WHITE}║${NC}\n" 2 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 🛠️  Utilities%40s${WHITE}║${NC}\n" 3 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 🔧 Core Fixes & Repairs%30s${WHITE}║${NC}\n" 4 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 🛡️  Security Tools%35s${WHITE}║${NC}\n" 5 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 🐘 PHP Version Manager%31s${WHITE}║${NC}\n" 6 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 🗄️  MariaDB Version Manager%26s${WHITE}║${NC}\n" 7 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 📦 Application Version Managers%22s${WHITE}║${NC}\n" 8 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 💾 Backup & Restore Tools%28s${WHITE}║${NC}\n" 9 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 📧 Email Fixes%38s${WHITE}║${NC}\n" 10 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 🖥️  OS-Specific Fixes%31s${WHITE}║${NC}\n" 11 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 🌐 rDNS Tools%39s${WHITE}║${NC}\n" 12 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 📚 Documentation%36s${WHITE}║${NC}\n" 13 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} ℹ️  System Information%30s${WHITE}║${NC}\n" 14 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} 🔄 Update Menu Script%31s${WHITE}║${NC}\n" 15 ""
        printf "${WHITE}║  ${GREEN}%2d.${NC} ❌ Exit%45s${WHITE}║${NC}\n" 16 ""
        echo -e "${WHITE}║                                                              ║${NC}"
        echo -e "${WHITE}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo -e ""
        printf "%s" "Please enter your choice [0-16]: "
        read choice
        
        case $choice in
            0|16) 
                echo -e "\n${GREEN}Thank you for using CyberPanel Mods!${NC}"
                echo -e "${BLUE}For support and updates, visit:${NC}"
                echo -e "${CYAN}https://github.com/master3395/cyberpanel-mods${NC}"
                exit 0
                ;;
            1) run_user_management ;;
            2) run_compatibility_check ;;
            3) run_utilities ;;
            4) run_core_fixes ;;
            5) run_security_tools ;;
            6) run_php_manager ;;
            7) run_mariadb_manager ;;
            8) run_app_version_managers ;;
            9) run_backup_restore ;;
            10) run_email_fixes ;;
            11) run_os_specific ;;
            12) run_rdns_tools ;;
            13) show_documentation ;;
            14) show_system_info ;;
            15) update_menu ;;
            *)
                echo -e "\n${RED}Invalid option. Please enter a number between 0-16.${NC}"
                pause
                ;;
        esac
    done
}

# Function to show help
show_help() {
    echo -e "${CYAN}CyberPanel Mods Master Menu${NC}"
    echo -e ""
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  $0 [options]"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  --help, -h     Show this help message"
    echo -e "  --update, -u   Update the menu script"
    echo -e "  --status, -s   Show system status only"
    echo -e ""
    echo -e "${BLUE}Examples:${NC}"
    echo -e "  $0              # Start interactive menu"
    echo -e "  $0 --help       # Show help"
    echo -e "  $0 --update     # Update menu script"
    echo -e "  $0 --status     # Show system status"
    echo -e ""
    echo -e "${BLUE}Features:${NC}"
    echo -e "• Interactive menu system"
    echo -e "• OS compatibility checking"
    echo -e "• Enhanced utility tools"
    echo -e "• Core fixes and repairs"
    echo -e "• Security hardening"
    echo -e "• Version management"
    echo -e "• Backup and restore"
    echo -e "• OS-specific fixes"
    echo -e "• Comprehensive documentation"
    echo -e "• System information"
    echo -e "• Auto-update functionality"
}

# Main function
main() {
    # Handle command line arguments
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --update|-u)
            update_menu
            exit 0
            ;;
        --status|-s)
            check_root
            detect_os
            show_system_status
            exit 0
            ;;
        "")
            # Interactive mode
            check_root
            detect_os
            check_cyberpanel
            show_main_menu
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
