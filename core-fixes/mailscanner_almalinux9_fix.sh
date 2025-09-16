#!/bin/bash

# CyberPanel MailScanner AlmaLinux 9 Fix Script
# This script fixes MailScanner installation issues on AlmaLinux 9
# Author: CyberPanel Mods
# Version: 1.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log_message() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a /var/log/cyberpanel_mailscanner_fix.log
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
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

# Function to backup original MailScanner installer
backup_original() {
    log_message "Backing up original MailScanner installer..."
    
    if [[ -f /usr/local/CyberCP/CPScripts/mailscannerinstaller.sh ]]; then
        cp /usr/local/CyberCP/CPScripts/mailscannerinstaller.sh /usr/local/CyberCP/CPScripts/mailscannerinstaller.sh.backup.$(date +%Y%m%d_%H%M%S)
        log_message "Original installer backed up"
    else
        warning "Original MailScanner installer not found at expected location"
    fi
}

# Function to patch MailScanner installer for AlmaLinux 9
patch_mailscanner_installer() {
    log_message "Patching MailScanner installer for AlmaLinux 9 support..."
    
    local installer_path="/usr/local/CyberCP/CPScripts/mailscannerinstaller.sh"
    
    if [[ ! -f "$installer_path" ]]; then
        error "MailScanner installer not found at $installer_path"
        return 1
    fi
    
    # Create a temporary file with the patch
    cat > /tmp/mailscanner_almalinux9_patch.txt << 'EOF'
# Add AlmaLinux 9 support after CentOS 8 section
elif [[ $Server_OS = "CentOS" ]] && [[ "$Server_OS_Version" = "9" ]] ; then

  setenforce 0
  dnf install -y perl dnf-utils perl-CPAN
  dnf --enablerepo=crb install -y perl-IO-stringy
  dnf install -y gcc cpp perl bzip2 zip make patch automake rpm-build perl-Archive-Zip perl-Filesys-Df perl-OLE-Storage_Lite perl-Net-CIDR perl-DBI perl-MIME-tools perl-DBD-SQLite binutils glibc-devel perl-Filesys-Df zlib unzip zlib-devel wget mlocate clamav clamav-update "perl(DBD::mysql)"

  # Install unrar for AlmaLinux 9 (using EPEL)
  dnf install -y unrar

  export PERL_MM_USE_DEFAULT=1
  curl -L https://cpanmin.us | perl - App::cpanminus

  perl -MCPAN -e 'install Encoding::FixLatin'
  perl -MCPAN -e 'install Digest::SHA1'
  perl -MCPAN -e 'install Geo::IP'
  perl -MCPAN -e 'install Razor2::Client::Agent'
  perl -MCPAN -e 'install Sys::Hostname::Long'
  perl -MCPAN -e 'install Sys::SigAction'
  perl -MCPAN -e 'install Net::Patricia'

  freshclam -v

EOF

    # Find the insertion point (after CentOS 8 section)
    local insert_line=$(grep -n "elif \[ \"\$CLNVERSION\" = \"ID=\\\"cloudlinux\\\"\" \]; then" "$installer_path" | cut -d: -f1)
    
    if [[ -z "$insert_line" ]]; then
        error "Could not find insertion point in MailScanner installer"
        return 1
    fi
    
    # Insert the AlmaLinux 9 section
    sed -i "${insert_line}i\\$(cat /tmp/mailscanner_almalinux9_patch.txt)" "$installer_path"
    
    # Clean up temporary file
    rm -f /tmp/mailscanner_almalinux9_patch.txt
    
    log_message "MailScanner installer patched for AlmaLinux 9 support"
}

# Function to install required packages for AlmaLinux 9
install_almalinux9_packages() {
    log_message "Installing required packages for AlmaLinux 9..."
    
    # Update system
    dnf update -y
    
    # Install EPEL if not present
    if ! rpm -q epel-release >/dev/null 2>&1; then
        log_message "Installing EPEL repository..."
        dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
    fi
    
    # Enable CRB repository
    dnf config-manager --set-enabled crb
    
    # Install required packages
    log_message "Installing MailScanner dependencies..."
    dnf install -y perl dnf-utils perl-CPAN
    dnf --enablerepo=crb install -y perl-IO-stringy
    dnf install -y gcc cpp perl bzip2 zip make patch automake rpm-build \
        perl-Archive-Zip perl-Filesys-Df perl-OLE-Storage_Lite perl-Net-CIDR \
        perl-DBI perl-MIME-tools perl-DBD-SQLite binutils glibc-devel \
        perl-Filesys-Df zlib unzip zlib-devel wget mlocate clamav clamav-update \
        "perl(DBD::mysql)" unrar
    
    # Install Perl modules via CPAN
    log_message "Installing Perl modules..."
    export PERL_MM_USE_DEFAULT=1
    curl -L https://cpanmin.us | perl - App::cpanminus
    
    perl -MCPAN -e 'install Encoding::FixLatin'
    perl -MCPAN -e 'install Digest::SHA1'
    perl -MCPAN -e 'install Geo::IP'
    perl -MCPAN -e 'install Razor2::Client::Agent'
    perl -MCPAN -e 'install Sys::Hostname::Long'
    perl -MCPAN -e 'install Sys::SigAction'
    perl -MCPAN -e 'install Net::Patricia'
    
    # Update ClamAV
    log_message "Updating ClamAV virus definitions..."
    freshclam -v
    
    log_message "Package installation completed"
}

# Function to test MailScanner installation
test_mailscanner() {
    log_message "Testing MailScanner installation..."
    
    # Check if MailScanner can be installed
    if command -v perl >/dev/null 2>&1; then
        log_message "Perl is available"
    else
        error "Perl is not available"
        return 1
    fi
    
    if command -v freshclam >/dev/null 2>&1; then
        log_message "ClamAV is available"
    else
        error "ClamAV is not available"
        return 1
    fi
    
    # Test if we can download MailScanner package
    if wget --spider https://github.com/MailScanner/v5/releases/download/5.4.4-1/MailScanner-5.4.4-1.rhel.noarch.rpm 2>/dev/null; then
        log_message "MailScanner package is accessible"
    else
        warning "Cannot access MailScanner package (network issue?)"
    fi
    
    log_message "MailScanner installation test completed"
}

# Function to create a manual installation script
create_manual_install_script() {
    log_message "Creating manual MailScanner installation script for AlmaLinux 9..."
    
    cat > /tmp/install_mailscanner_almalinux9.sh << 'EOF'
#!/bin/bash

# Manual MailScanner installation for AlmaLinux 9
# This script can be run if the CyberPanel interface fails

set -e

echo "Installing MailScanner on AlmaLinux 9..."

# Install MailScanner package
cd /tmp
wget https://github.com/MailScanner/v5/releases/download/5.4.4-1/MailScanner-5.4.4-1.rhel.noarch.rpm
rpm -Uvh MailScanner-5.4.4-1.rhel.noarch.rpm

# Create required directories
mkdir -p /var/spool/MailScanner/spamassassin
mkdir -p /var/run/MailScanner
mkdir -p /var/lock/subsys/MailScanner

# Set proper ownership
chown postfix.mtagroup /var/spool/MailScanner/spamassassin
chown root.mtagroup /var/spool/MailScanner/incoming/
chown postfix.mtagroup /var/spool/MailScanner/milterin
chown postfix.mtagroup /var/spool/MailScanner/milterout
chown postfix.mtagroup /var/spool/postfix/hold
chown postfix.mtagroup /var/spool/postfix/incoming
usermod -a -G mtagroup nobody

# Set proper permissions
chmod g+rx /var/spool/postfix/incoming
chmod g+rx /var/spool/postfix/hold
chmod -R 0775 /var/spool/postfix/incoming
chmod -R 0775 /var/spool/postfix/hold

# Configure MailScanner
sed -i 's/^Run As User =.*/& postfix/' /etc/MailScanner/MailScanner.conf

# Start MailScanner service
systemctl enable mailscanner
systemctl start mailscanner

echo "MailScanner installation completed!"
echo "You can now try installing MailScanner through the CyberPanel interface."
EOF

    chmod +x /tmp/install_mailscanner_almalinux9.sh
    log_message "Manual installation script created at /tmp/install_mailscanner_almalinux9.sh"
}

# Main execution
main() {
    echo "=========================================="
    echo "CyberPanel MailScanner AlmaLinux 9 Fix"
    echo "=========================================="
    
    check_root
    
    if ! detect_almalinux9; then
        error "This script is designed for AlmaLinux 9 only"
        exit 1
    fi
    
    log_message "AlmaLinux 9 detected - proceeding with fixes"
    
    # Step 1: Backup original installer
    backup_original
    
    # Step 2: Install required packages
    install_almalinux9_packages
    
    # Step 3: Patch MailScanner installer
    patch_mailscanner_installer
    
    # Step 4: Test installation
    test_mailscanner
    
    # Step 5: Create manual installation script
    create_manual_install_script
    
    echo ""
    log_message "=========================================="
    log_message "MailScanner AlmaLinux 9 fix completed!"
    log_message "=========================================="
    echo ""
    info "Next steps:"
    echo "1. Try installing MailScanner through the CyberPanel interface"
    echo "2. If that fails, run: /tmp/install_mailscanner_almalinux9.sh"
    echo "3. Check logs at: /var/log/cyberpanel_mailscanner_fix.log"
    echo ""
    warning "Note: You may need to restart CyberPanel services after installation"
}

# Run main function
main "$@"
