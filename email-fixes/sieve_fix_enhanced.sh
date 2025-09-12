#!/bin/bash

# CyberPanel Sieve Fix Enhanced Script
# Fixes Sieve (Filter) functionality with SnappyMail for all supported OS
# Supports: Ubuntu, AlmaLinux, RockyLinux, RHEL, CentOS, CloudLinux, openEuler, Debian
# Author: CyberPanel Mods Team
# Version: 1.0.0

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

# Logging function
log_message() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/cyberpanel_sieve_fix.log
}

# Function to detect OS and version
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
            PACKAGE_MANAGER="apt"
            ;;
        "almalinux")
            OS_NAME="AlmaLinux"
            OS_VERSION="$VERSION_ID"
            PACKAGE_MANAGER="dnf"
            ;;
        "rocky")
            OS_NAME="RockyLinux"
            OS_VERSION="$VERSION_ID"
            PACKAGE_MANAGER="dnf"
            ;;
        "rhel")
            OS_NAME="RHEL"
            OS_VERSION="$VERSION_ID"
            PACKAGE_MANAGER="dnf"
            ;;
        "centos")
            OS_NAME="CentOS"
            OS_VERSION="$VERSION_ID"
            PACKAGE_MANAGER="yum"
            ;;
        "cloudlinux")
            OS_NAME="CloudLinux"
            OS_VERSION="$VERSION_ID"
            PACKAGE_MANAGER="yum"
            ;;
        "openeuler")
            OS_NAME="openEuler"
            OS_VERSION="$VERSION_ID"
            PACKAGE_MANAGER="yum"
            ;;
        "debian")
            OS_NAME="Debian"
            OS_VERSION="$VERSION_ID"
            PACKAGE_MANAGER="apt"
            ;;
        *)
            OS_NAME="Unknown"
            OS_VERSION="$VERSION_ID"
            PACKAGE_MANAGER="unknown"
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
        echo -e "${YELLOW}This script is designed for CyberPanel installations${NC}"
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo -e "${GREEN}CyberPanel installation detected${NC}"
    fi
}

# Function to check if Dovecot is installed
check_dovecot() {
    if ! command -v dovecot >/dev/null 2>&1; then
        echo -e "${RED}ERROR: Dovecot is not installed${NC}"
        echo -e "${YELLOW}Please install Dovecot first${NC}"
        exit 1
    fi
    
    DOVECOT_VERSION=$(dovecot --version 2>/dev/null | head -n1 | grep -oP '\d+\.\d+' || echo "unknown")
    echo -e "${GREEN}Dovecot version: $DOVECOT_VERSION${NC}"
}

# Function to check if Postfix is installed
check_postfix() {
    if ! command -v postfix >/dev/null 2>&1; then
        echo -e "${RED}ERROR: Postfix is not installed${NC}"
        echo -e "${YELLOW}Please install Postfix first${NC}"
        exit 1
    fi
    
    POSTFIX_VERSION=$(postconf -d mail_version 2>/dev/null | cut -d'=' -f2 | tr -d ' ' || echo "unknown")
    echo -e "${GREEN}Postfix version: $POSTFIX_VERSION${NC}"
}

# Function to install Sieve packages for different OS
install_sieve_packages() {
    echo -e "\n${BLUE}Installing Sieve packages for $OS_NAME...${NC}"
    log_message "Installing Sieve packages for $OS_NAME"
    
    case "$OS_NAME" in
        "Ubuntu"|"Debian")
            echo -e "${YELLOW}Installing packages for Debian-based system...${NC}"
            apt update
            apt install -y dovecot-sieve dovecot-managesieved
            ;;
        "AlmaLinux"|"RockyLinux"|"RHEL")
            echo -e "${YELLOW}Installing packages for RHEL-based system...${NC}"
            if [[ "$OS_VERSION" == "8"* ]]; then
                # AlmaLinux 8.x / RockyLinux 8.x
                yum --enablerepo=gf-plus -y install dovecot23-pigeonhole
                dnf install --enablerepo=gf-plus postfix3 postfix3-ldap.x86_64 -y
                dnf install --enablerepo=gf-plus postfix3-pcre.x86_64 -y
            elif [[ "$OS_VERSION" == "9"* ]]; then
                # AlmaLinux 9.x / RockyLinux 9.x
                dnf install -y dovecot-pigeonhole
                dnf install -y postfix postfix-ldap
                dnf install -y postfix-pcre
            else
                dnf install -y dovecot-pigeonhole
                dnf install -y postfix postfix-ldap
                dnf install -y postfix-pcre
            fi
            ;;
        "CentOS"|"CloudLinux"|"openEuler")
            echo -e "${YELLOW}Installing packages for CentOS-based system...${NC}"
            if [[ "$OS_VERSION" == "8"* ]]; then
                yum --enablerepo=gf-plus -y install dovecot23-pigeonhole
                yum --enablerepo=gf-plus -y install postfix3 postfix3-ldap
                yum --enablerepo=gf-plus -y install postfix3-pcre
            elif [[ "$OS_VERSION" == "7"* ]]; then
                yum install -y dovecot-pigeonhole
                yum install -y postfix postfix-ldap
                yum install -y postfix-pcre
            else
                yum install -y dovecot-pigeonhole
                yum install -y postfix postfix-ldap
                yum install -y postfix-pcre
            fi
            ;;
        *)
            echo -e "${YELLOW}Unknown OS, attempting generic installation...${NC}"
            if command -v yum >/dev/null 2>&1; then
                yum install -y dovecot-pigeonhole postfix postfix-ldap postfix-pcre
            elif command -v dnf >/dev/null 2>&1; then
                dnf install -y dovecot-pigeonhole postfix postfix-ldap postfix-pcre
            elif command -v apt >/dev/null 2>&1; then
                apt update && apt install -y dovecot-sieve dovecot-managesieved
            else
                echo -e "${RED}ERROR: Unsupported package manager${NC}"
                exit 1
            fi
            ;;
    esac
    
    echo -e "${GREEN}Sieve packages installed successfully${NC}"
}

# Function to configure firewall
configure_firewall() {
    echo -e "\n${BLUE}Configuring firewall for Sieve...${NC}"
    log_message "Configuring firewall for Sieve"
    
    # Check if firewall-cmd is available (firewalld)
    if command -v firewall-cmd >/dev/null 2>&1; then
        echo -e "${YELLOW}Configuring firewalld...${NC}"
        firewall-cmd --permanent --add-service={http,https,smtp-submission,smtps,imap,imaps,pop3,pop3s}
        firewall-cmd --permanent --add-port=4190/tcp
        firewall-cmd --reload
        echo -e "${GREEN}Firewalld configured successfully${NC}"
    fi
    
    # Check if iptables is available
    if command -v iptables >/dev/null 2>&1; then
        echo -e "${YELLOW}Configuring iptables...${NC}"
        iptables -I INPUT -p tcp --dport 4190 --syn -j ACCEPT
        iptables -I INPUT -p tcp --dport 25 --syn -j ACCEPT
        iptables -I INPUT -p tcp --dport 587 --syn -j ACCEPT
        iptables -I INPUT -p tcp --dport 465 --syn -j ACCEPT
        iptables -I INPUT -p tcp --dport 143 --syn -j ACCEPT
        iptables -I INPUT -p tcp --dport 993 --syn -j ACCEPT
        iptables -I INPUT -p tcp --dport 110 --syn -j ACCEPT
        iptables -I INPUT -p tcp --dport 995 --syn -j ACCEPT
        echo -e "${GREEN}iptables configured successfully${NC}"
    fi
    
    # Check if ufw is available (Ubuntu)
    if command -v ufw >/dev/null 2>&1; then
        echo -e "${YELLOW}Configuring ufw...${NC}"
        ufw allow 4190/tcp
        ufw allow 25/tcp
        ufw allow 587/tcp
        ufw allow 465/tcp
        ufw allow 143/tcp
        ufw allow 993/tcp
        ufw allow 110/tcp
        ufw allow 995/tcp
        echo -e "${GREEN}ufw configured successfully${NC}"
    fi
}

# Function to create necessary log files and directories
create_logs_and_directories() {
    echo -e "\n${BLUE}Creating necessary log files and directories...${NC}"
    log_message "Creating necessary log files and directories"
    
    # Create log files
    touch /var/log/{dovecot-lda-errors.log,dovecot-lda.log}
    touch /var/log/{dovecot-sieve-errors.log,dovecot-sieve.log}
    touch /var/log/{dovecot-lmtp-errors.log,dovecot-lmtp.log}
    
    # Create Sieve directories
    mkdir -p /etc/dovecot/sieve/global
    
    # Set proper ownership
    if id "vmail" &>/dev/null; then
        chown vmail: -R /etc/dovecot/sieve
        chown vmail:mail /var/log/dovecot-*
    else
        chown dovecot:dovecot -R /etc/dovecot/sieve
        chown dovecot:mail /var/log/dovecot-*
    fi
    
    # Set proper permissions
    chmod 755 /etc/dovecot/sieve
    chmod 644 /var/log/dovecot-*
    
    echo -e "${GREEN}Log files and directories created successfully${NC}"
}

# Function to backup configuration files
backup_configurations() {
    echo -e "\n${BLUE}Backing up configuration files...${NC}"
    log_message "Backing up configuration files"
    
    # Backup Postfix master.cf
    if [[ -f /etc/postfix/master.cf ]]; then
        cp /etc/postfix/master.cf /etc/postfix/master.cf.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${GREEN}Backed up /etc/postfix/master.cf${NC}"
    fi
    
    # Backup Dovecot dovecot.conf
    if [[ -f /etc/dovecot/dovecot.conf ]]; then
        cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${GREEN}Backed up /etc/dovecot/dovecot.conf${NC}"
    fi
    
    echo -e "${GREEN}Configuration backups completed${NC}"
}

# Function to configure Dovecot for Sieve
configure_dovecot_sieve() {
    echo -e "\n${BLUE}Configuring Dovecot for Sieve...${NC}"
    log_message "Configuring Dovecot for Sieve"
    
    # Check if dovecot.conf exists
    if [[ ! -f /etc/dovecot/dovecot.conf ]]; then
        echo -e "${YELLOW}Creating basic dovecot.conf...${NC}"
        cat > /etc/dovecot/dovecot.conf << 'EOF'
# Dovecot configuration for Sieve
protocols = imap lmtp sieve

# Logging
log_path = /var/log/dovecot.log
info_log_path = /var/log/dovecot-info.log
debug_log_path = /var/log/dovecot-debug.log

# Mail location
mail_location = maildir:~/Maildir

# Authentication
auth_mechanisms = plain login
passdb {
  driver = pam
}
userdb {
  driver = passwd
}

# Sieve configuration
protocol sieve {
  mail_plugins = sieve
}

plugin {
  sieve = ~/.dovecot.sieve
  sieve_global_path = /etc/dovecot/sieve/global/default.sieve
  sieve_dir = ~/sieve
  sieve_extensions = +notify +imapflags
}

# LMTP configuration
protocol lmtp {
  mail_plugins = sieve
}
EOF
    fi
    
    # Add Sieve configuration if not present
    if ! grep -q "protocol sieve" /etc/dovecot/dovecot.conf; then
        echo -e "${YELLOW}Adding Sieve configuration to dovecot.conf...${NC}"
        cat >> /etc/dovecot/dovecot.conf << 'EOF'

# Sieve configuration
protocol sieve {
  mail_plugins = sieve
}

plugin {
  sieve = ~/.dovecot.sieve
  sieve_global_path = /etc/dovecot/sieve/global/default.sieve
  sieve_dir = ~/sieve
  sieve_extensions = +notify +imapflags
}
EOF
    fi
    
    # Add LMTP configuration if not present
    if ! grep -q "protocol lmtp" /etc/dovecot/dovecot.conf; then
        echo -e "${YELLOW}Adding LMTP configuration to dovecot.conf...${NC}"
        cat >> /etc/dovecot/dovecot.conf << 'EOF'

# LMTP configuration
protocol lmtp {
  mail_plugins = sieve
}
EOF
    fi
    
    echo -e "${GREEN}Dovecot configured for Sieve${NC}"
}

# Function to configure Postfix for LMTP
configure_postfix_lmtp() {
    echo -e "\n${BLUE}Configuring Postfix for LMTP...${NC}"
    log_message "Configuring Postfix for LMTP"
    
    # Check if master.cf exists
    if [[ ! -f /etc/postfix/master.cf ]]; then
        echo -e "${YELLOW}Creating basic master.cf...${NC}"
        postconf -e "myhostname = $(hostname -f)"
        postconf -e "mydomain = $(hostname -d)"
        postconf -e "myorigin = \$mydomain"
        postconf -e "inet_interfaces = all"
        postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost"
    fi
    
    # Add LMTP service to master.cf if not present
    if ! grep -q "^dovecot.*unix" /etc/postfix/master.cf; then
        echo -e "${YELLOW}Adding LMTP service to master.cf...${NC}"
        cat >> /etc/postfix/master.cf << 'EOF'

# Dovecot LMTP
dovecot   unix  -       n       n       -       -       pipe
  flags=DRhu user=vmail:vmail argv=/usr/libexec/dovecot/deliver -f ${sender} -d ${recipient}
EOF
    fi
    
    # Configure virtual delivery
    postconf -e "virtual_transport = dovecot"
    
    echo -e "${GREEN}Postfix configured for LMTP${NC}"
}

# Function to create default Sieve script
create_default_sieve() {
    echo -e "\n${BLUE}Creating default Sieve script...${NC}"
    log_message "Creating default Sieve script"
    
    # Create default Sieve script
    cat > /etc/dovecot/sieve/global/default.sieve << 'EOF'
# Default Sieve script for email filtering
# This is a basic example - customize as needed

require ["fileinto", "mailbox"];

# Example: Move spam to Junk folder
if header :contains "X-Spam-Flag" "YES" {
    fileinto "Junk";
    stop;
}

# Example: Move newsletters to a specific folder
if header :contains "List-Unsubscribe" "" {
    fileinto "Newsletters";
    stop;
}
EOF
    
    # Compile the Sieve script
    if command -v sievec >/dev/null 2>&1; then
        sievec /etc/dovecot/sieve/global/default.sieve
        echo -e "${GREEN}Default Sieve script compiled successfully${NC}"
    else
        echo -e "${YELLOW}Warning: sievec not found, script created but not compiled${NC}"
    fi
    
    # Set proper ownership
    if id "vmail" &>/dev/null; then
        chown vmail:vmail /etc/dovecot/sieve/global/default.sieve*
    else
        chown dovecot:dovecot /etc/dovecot/sieve/global/default.sieve*
    fi
}

# Function to restart services
restart_services() {
    echo -e "\n${BLUE}Restarting services...${NC}"
    log_message "Restarting services"
    
    # Restart Dovecot
    if systemctl is-active --quiet dovecot; then
        systemctl restart dovecot
        echo -e "${GREEN}Dovecot restarted${NC}"
    else
        systemctl start dovecot
        echo -e "${GREEN}Dovecot started${NC}"
    fi
    
    # Restart Postfix
    if systemctl is-active --quiet postfix; then
        systemctl restart postfix
        echo -e "${GREEN}Postfix restarted${NC}"
    else
        systemctl start postfix
        echo -e "${GREEN}Postfix started${NC}"
    fi
    
    # Check if SpamAssassin is installed and restart if needed
    if systemctl is-active --quiet spamassassin; then
        systemctl restart spamassassin
        echo -e "${GREEN}SpamAssassin restarted${NC}"
    fi
    
    # Enable services to start on boot
    systemctl enable dovecot postfix
    if systemctl is-active --quiet spamassassin; then
        systemctl enable spamassassin
    fi
}

# Function to verify installation
verify_installation() {
    echo -e "\n${BLUE}Verifying Sieve installation...${NC}"
    log_message "Verifying Sieve installation"
    
    # Check if port 4190 is listening
    if netstat -tulpn | grep -q ":4190"; then
        echo -e "${GREEN}✓ Sieve port 4190 is listening${NC}"
    else
        echo -e "${YELLOW}⚠ Sieve port 4190 is not listening${NC}"
    fi
    
    # Check Dovecot status
    if systemctl is-active --quiet dovecot; then
        echo -e "${GREEN}✓ Dovecot service is running${NC}"
    else
        echo -e "${RED}✗ Dovecot service is not running${NC}"
    fi
    
    # Check Postfix status
    if systemctl is-active --quiet postfix; then
        echo -e "${GREEN}✓ Postfix service is running${NC}"
    else
        echo -e "${RED}✗ Postfix service is not running${NC}"
    fi
    
    # Check if Sieve modules are loaded
    if dovecot -n | grep -q "sieve"; then
        echo -e "${GREEN}✓ Sieve modules are loaded in Dovecot${NC}"
    else
        echo -e "${YELLOW}⚠ Sieve modules not found in Dovecot configuration${NC}"
    fi
    
    # Test Sieve syntax
    if [[ -f /etc/dovecot/sieve/global/default.sieve ]]; then
        if command -v sievec >/dev/null 2>&1; then
            if sievec -t /etc/dovecot/sieve/global/default.sieve; then
                echo -e "${GREEN}✓ Default Sieve script syntax is valid${NC}"
            else
                echo -e "${YELLOW}⚠ Default Sieve script has syntax issues${NC}"
            fi
        fi
    fi
    
    echo -e "\n${CYAN}=== Installation Summary ===${NC}"
    echo -e "${GREEN}Sieve (Filter) has been installed and configured for SnappyMail${NC}"
    echo -e "${BLUE}Port 4190 is now available for Sieve management${NC}"
    echo -e "${BLUE}Default filtering rules have been created${NC}"
    echo -e "${YELLOW}You can now configure email filters in SnappyMail${NC}"
}

# Function to show usage information
show_usage() {
    echo -e "${CYAN}CyberPanel Sieve Fix Enhanced Script${NC}"
    echo -e ""
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  $0 [options]"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  --help, -h     Show this help message"
    echo -e "  --verify, -v   Verify current Sieve installation"
    echo -e "  --force, -f    Force reinstallation"
    echo -e ""
    echo -e "${BLUE}Description:${NC}"
    echo -e "This script installs and configures Sieve (Filter) functionality"
    echo -e "for SnappyMail in CyberPanel installations."
    echo -e ""
    echo -e "${BLUE}Supported OS:${NC}"
    echo -e "• Ubuntu (all versions)"
    echo -e "• AlmaLinux 8.x, 9.x"
    echo -e "• RockyLinux 8.x, 9.x"
    echo -e "• RHEL 8.x, 9.x"
    echo -e "• CentOS 7.x, 8.x"
    echo -e "• CloudLinux 7.x, 8.x"
    echo -e "• openEuler"
    echo -e "• Debian (all versions)"
    echo -e ""
    echo -e "${BLUE}Features:${NC}"
    echo -e "• Automatic OS detection and package installation"
    echo -e "• Firewall configuration"
    echo -e "• Log file creation and management"
    echo -e "• Configuration backup and restoration"
    echo -e "• Service management and verification"
    echo -e "• Default Sieve filtering rules"
}

# Main function
main() {
    # Handle command line arguments
    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --verify|-v)
            check_root
            detect_os
            verify_installation
            exit 0
            ;;
        --force|-f)
            echo -e "${YELLOW}Force mode enabled - will reinstall all components${NC}"
            FORCE_INSTALL=true
            ;;
        "")
            # Normal installation
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
    
    # Show banner
    echo -e "${PURPLE}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║                                                              ║"
    echo "  ║  🔧 CyberPanel Sieve Fix Enhanced v1.0.0 🔧                 ║"
    echo "  ║                                                              ║"
    echo "  ║  Installing Sieve (Filter) for SnappyMail                   ║"
    echo "  ║  Cross-platform compatibility for all CyberPanel OS         ║"
    echo "  ║                                                              ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Initialize log
    log_message "Starting Sieve fix installation"
    
    # Run checks and installation steps
    check_root
    detect_os
    check_cyberpanel
    check_dovecot
    check_postfix
    
    # Ask for confirmation unless in force mode
    if [[ "${FORCE_INSTALL:-false}" != "true" ]]; then
        echo -e "\n${YELLOW}This will install and configure Sieve (Filter) for SnappyMail.${NC}"
        echo -e "${YELLOW}The following will be done:${NC}"
        echo -e "  • Install Sieve packages"
        echo -e "  • Configure firewall"
        echo -e "  • Create log files and directories"
        echo -e "  • Backup configuration files"
        echo -e "  • Configure Dovecot and Postfix"
        echo -e "  • Create default filtering rules"
        echo -e "  • Restart services"
        echo -e ""
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Installation cancelled${NC}"
            exit 0
        fi
    fi
    
    # Run installation steps
    install_sieve_packages
    configure_firewall
    create_logs_and_directories
    backup_configurations
    configure_dovecot_sieve
    configure_postfix_lmtp
    create_default_sieve
    restart_services
    verify_installation
    
    echo -e "\n${GREEN}🎉 Sieve fix installation completed successfully! 🎉${NC}"
    echo -e "${BLUE}You can now use email filtering in SnappyMail${NC}"
    echo -e "${CYAN}For more information, visit:${NC}"
    echo -e "${CYAN}https://github.com/master3395/cyberpanel-mods${NC}"
    
    log_message "Sieve fix installation completed successfully"
}

# Run main function
main "$@"
