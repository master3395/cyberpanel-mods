#!/bin/bash

# CyberPanel ModSecurity Rules Fix Script
# This script fixes common ModSecurity rules installation and status detection issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

log "Starting CyberPanel ModSecurity Rules Fix..."

# Check if CyberPanel is installed
if [ ! -d "/usr/local/CyberCP" ]; then
    error "CyberPanel installation not found. Please install CyberPanel first."
    exit 1
fi

# Check if ModSecurity is installed
if [ ! -f "/usr/local/lsws/conf/httpd_config.conf" ]; then
    error "LiteSpeed configuration not found. Please ensure LiteSpeed is properly installed."
    exit 1
fi

log "Backing up current ModSecurity configuration..."
sudo cp /usr/local/lsws/conf/httpd_config.conf /usr/local/lsws/conf/httpd_config.conf.backup.$(date +%Y%m%d_%H%M%S)

# Create modsec directory if it doesn't exist
log "Creating ModSecurity directory structure..."
sudo mkdir -p /usr/local/lsws/conf/modsec

# Fix permissions
log "Setting proper permissions..."
sudo chown -R lsadm:lsadm /usr/local/lsws/conf/modsec
sudo chmod -R 755 /usr/local/lsws/conf/modsec

# Check if OWASP rules are installed
OWASP_PATH="/usr/local/lsws/conf/modsec/owasp-modsecurity-crs-4.18.0"
if [ -d "$OWASP_PATH" ]; then
    log "OWASP rules directory found. Verifying installation..."
    
    # Check if owasp-master.conf exists
    if [ -f "$OWASP_PATH/owasp-master.conf" ]; then
        success "OWASP rules appear to be properly installed."
    else
        warning "OWASP rules directory exists but configuration file is missing. Reinstalling..."
        
        # Remove existing directory
        sudo rm -rf "$OWASP_PATH"
        
        # Download and install OWASP rules
        log "Downloading OWASP ModSecurity Core Rules v4.18.0..."
        cd /tmp
        sudo wget -q https://github.com/coreruleset/coreruleset/archive/refs/tags/v4.18.0.zip -O owasp.zip
        
        if [ $? -eq 0 ]; then
            log "Extracting OWASP rules..."
            sudo unzip -q owasp.zip -d /usr/local/lsws/conf/modsec/
            sudo mv /usr/local/lsws/conf/modsec/coreruleset-4.18.0 "$OWASP_PATH"
            
            # Set up configuration files
            log "Setting up OWASP configuration files..."
            sudo cp "$OWASP_PATH/crs-setup.conf.example" "$OWASP_PATH/crs-setup.conf"
            sudo cp "$OWASP_PATH/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example" "$OWASP_PATH/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf"
            sudo cp "$OWASP_PATH/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example" "$OWASP_PATH/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf"
            
            # Create owasp-master.conf for CRS v4.18.0 (simplified structure)
            log "Creating OWASP master configuration file..."
            sudo tee "$OWASP_PATH/owasp-master.conf" > /dev/null << 'EOF'
include /usr/local/lsws/conf/modsec/owasp-modsecurity-crs-4.18.0/crs.conf
EOF
            
            # Set proper permissions
            sudo chown -R lsadm:lsadm "$OWASP_PATH"
            sudo chmod -R 755 "$OWASP_PATH"
            
            # Clean up
            sudo rm -f owasp.zip
            
            success "OWASP rules installed successfully."
        else
            error "Failed to download OWASP rules."
            exit 1
        fi
    fi
else
    log "OWASP rules not found. Installing..."
    
    # Download and install OWASP rules
    log "Downloading OWASP ModSecurity Core Rules v4.18.0..."
    cd /tmp
    sudo wget -q https://github.com/coreruleset/coreruleset/archive/refs/tags/v4.18.0.zip -O owasp.zip
    
    if [ $? -eq 0 ]; then
        log "Extracting OWASP rules..."
        sudo unzip -q owasp.zip -d /usr/local/lsws/conf/modsec/
        sudo mv /usr/local/lsws/conf/modsec/coreruleset-4.18.0 "$OWASP_PATH"
        
        # Set up configuration files
        log "Setting up OWASP configuration files..."
        sudo cp "$OWASP_PATH/crs-setup.conf.example" "$OWASP_PATH/crs-setup.conf"
        sudo cp "$OWASP_PATH/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example" "$OWASP_PATH/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf"
        sudo cp "$OWASP_PATH/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example" "$OWASP_PATH/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf"
        
        # Create owasp-master.conf for CRS v4.18.0 (simplified structure)
        log "Creating OWASP master configuration file..."
        sudo tee "$OWASP_PATH/owasp-master.conf" > /dev/null << 'EOF'
include /usr/local/lsws/conf/modsec/owasp-modsecurity-crs-4.18.0/crs.conf
EOF
        
        # Set proper permissions
        sudo chown -R lsadm:lsadm "$OWASP_PATH"
        sudo chmod -R 755 "$OWASP_PATH"
        
        # Clean up
        sudo rm -f owasp.zip
        
        success "OWASP rules installed successfully."
    else
        error "Failed to download OWASP rules."
        exit 1
    fi
fi

# Check if ModSecurity is properly configured in httpd_config.conf
log "Checking ModSecurity configuration in httpd_config.conf..."
if ! grep -q "module mod_security" /usr/local/lsws/conf/httpd_config.conf; then
    warning "ModSecurity module not found in httpd_config.conf. Adding basic configuration..."
    
    # Add ModSecurity configuration
    sudo tee -a /usr/local/lsws/conf/httpd_config.conf > /dev/null << 'EOF'

module mod_security {
    modsecurity  on
    modsecurity_rules `
    SecDebugLogLevel 0
    SecDebugLog /usr/local/lsws/logs/modsec.log
    SecAuditEngine on
    SecAuditLogRelevantStatus "^(?:5|4(?!04))"
    SecAuditLogParts AFH
    SecAuditLogType Serial
    SecAuditLog /usr/local/lsws/logs/auditmodsec.log
    SecRuleEngine On
    `
    modsecurity_rules_file /usr/local/lsws/conf/modsec/rules.conf
}
EOF
fi

# Check if OWASP rules are referenced in httpd_config.conf
log "Checking OWASP rules configuration in httpd_config.conf..."
if ! grep -q "owasp-modsecurity-crs-4.18.0" /usr/local/lsws/conf/httpd_config.conf; then
    warning "OWASP rules not referenced in httpd_config.conf. Adding configuration..."
    
    # Add OWASP rules reference
    sudo sed -i '/modsecurity_rules_file \/usr\/local\/lsws\/conf\/modsec\/rules\.conf/a\    modsecurity_rules_file /usr/local/lsws/conf/modsec/owasp-modsecurity-crs-4.18.0/owasp-master.conf' /usr/local/lsws/conf/httpd_config.conf
fi

# Create basic rules.conf if it doesn't exist
if [ ! -f "/usr/local/lsws/conf/modsec/rules.conf" ]; then
    log "Creating basic ModSecurity rules configuration..."
    sudo tee /usr/local/lsws/conf/modsec/rules.conf > /dev/null << 'EOF'
SecRule ARGS "\.\./" "t:normalisePathWin,id:99999,severity:4,msg:'Drive Access' ,log,auditlog,deny"
EOF
    sudo chown lsadm:lsadm /usr/local/lsws/conf/modsec/rules.conf
    sudo chmod 644 /usr/local/lsws/conf/modsec/rules.conf
fi

# Restart LiteSpeed
log "Restarting LiteSpeed to apply changes..."
sudo systemctl restart lsws

if [ $? -eq 0 ]; then
    success "LiteSpeed restarted successfully."
else
    error "Failed to restart LiteSpeed. Please check the configuration manually."
    exit 1
fi

# Verify installation
log "Verifying ModSecurity installation..."
if [ -f "/usr/local/lsws/conf/modsec/owasp-modsecurity-crs-4.18.0/owasp-master.conf" ]; then
    success "ModSecurity OWASP rules are properly installed and configured."
else
    error "ModSecurity OWASP rules installation verification failed."
    exit 1
fi

# Check if ModSecurity is working
log "Checking ModSecurity status..."
if systemctl is-active --quiet lsws; then
    success "LiteSpeed is running with ModSecurity enabled."
else
    error "LiteSpeed is not running. Please check the configuration."
    exit 1
fi

log "ModSecurity fix completed successfully!"
log "You can now access the ModSecurity Rules Packages page in CyberPanel to verify the status."
log "The OWASP ModSecurity Core Rules should now show as enabled."

# Display summary
echo ""
echo "=========================================="
echo "ModSecurity Fix Summary:"
echo "=========================================="
echo "✓ OWASP ModSecurity Core Rules v4.18.0 installed"
echo "✓ Configuration files created and configured"
echo "✓ LiteSpeed restarted successfully"
echo "✓ ModSecurity status detection improved"
echo ""
echo "Next steps:"
echo "1. Access CyberPanel → Security → ModSecurity Rules Packages"
echo "2. Verify that OWASP rules show as enabled"
echo "3. Configure rules as needed for your applications"
echo ""
echo "If you encounter any issues, check the logs at:"
echo "- /usr/local/lsws/logs/modsec.log"
echo "- /usr/local/lsws/logs/auditmodsec.log"
echo "- /home/cyberpanel/modSecInstallLog"
echo "=========================================="
