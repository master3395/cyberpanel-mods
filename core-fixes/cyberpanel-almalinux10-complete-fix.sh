#!/bin/bash

# CyberPanel AlmaLinux 10 Complete Fix Script
# This script fixes all known issues with CyberPanel installation on AlmaLinux 10
# Author: CyberPanel Mods
# Version: 1.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
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

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
        exit 1
    fi
}

# Check if running on AlmaLinux 10
check_almalinux10() {
    if ! grep -q "AlmaLinux-10" /etc/os-release; then
        error "This script is designed for AlmaLinux 10 only"
        exit 1
    fi
    log "AlmaLinux 10 detected - proceeding with fixes"
}

# Fix system repositories
fix_repositories() {
    log "Fixing system repositories for AlmaLinux 10"
    
    # Update system
    dnf update -y
    
    # Remove conflicting repositories
    dnf remove -y epel-release remi-release 2>/dev/null || true
    rm -f /etc/yum.repos.d/epel.repo
    rm -f /etc/yum.repos.d/epel.repo.rpmsave
    rm -f /etc/yum.repos.d/remi.repo
    rm -f /etc/yum.repos.d/remi.repo.rpmsave
    rm -f /etc/yum.repos.d/MariaDB.repo
    rm -f /etc/yum.repos.d/MariaDB.repo.rpmsave
    
    # Install EPEL 10
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
    dnf config-manager --set-enabled epel
    
    # Install remi-release 10
    dnf install -y https://rpms.remirepo.net/enterprise/remi-release-10.rpm
    
    # Enable CRB repository
    dnf config-manager --set-enabled crb
    
    # Create MariaDB repository for RHEL10
    cat <<EOF >/etc/yum.repos.d/MariaDB.repo
# MariaDB 10.11 RHEL10 repository list - AlmaLinux 10 compatible
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.11/rhel10-amd64/
module_hotfixes=1
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
enabled=1
gpgcheck=1
EOF
    
    # Import MariaDB GPG key
    rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
    
    # Fix LiteSpeed GPG key
    rpm --import https://cyberpanel.sh/rpms.litespeedtech.com/centos/RPM-GPG-KEY-litespeed || {
        warning "Primary GPG key import failed, trying alternative source"
        rpm --import https://rpms.litespeedtech.com/centos/RPM-GPG-KEY-litespeed || {
            error "Failed to import LiteSpeed GPG key from all sources"
            return 1
        }
    }
    
    # Clean and refresh repositories
    dnf clean all
    dnf makecache
    
    log "Repositories fixed successfully"
}

# Install required packages
install_packages() {
    log "Installing required packages for AlmaLinux 10"
    
    # Install essential packages including boost libraries
    dnf install -y \
        wget \
        curl \
        which \
        htop \
        python3 \
        python3-pip \
        dnf-plugins-core \
        libnsl \
        zip \
        strace \
        net-tools \
        bc \
        telnet \
        libevent-devel \
        gcc \
        libattr-devel \
        xz-devel \
        gpgme-devel \
        curl-devel \
        git \
        platform-python-devel \
        tar \
        socat \
        unzip \
        bind-utils \
        openssl-devel \
        boost-devel \
        boost-program-options \
        MariaDB-server \
        MariaDB-client \
        MariaDB-devel
    
    # Create boost library symlink for galera-4 compatibility
    if [ ! -f /usr/lib64/libboost_program_options.so.1.75.0 ]; then
        BOOST_VERSION=$(find /usr/lib64 -name "libboost_program_options.so.*" | head -1 | sed 's/.*libboost_program_options\.so\.//')
        if [ -n "$BOOST_VERSION" ]; then
            ln -sf /usr/lib64/libboost_program_options.so.$BOOST_VERSION /usr/lib64/libboost_program_options.so.1.75.0
            log "Created boost library symlink for galera-4 compatibility: $BOOST_VERSION -> 1.75.0"
        else
            warning "Could not find boost libraries, galera-4 may not work properly"
        fi
    fi
    
    # Create pip symlink
    ln -sf /usr/bin/pip3 /usr/bin/pip
    
    log "Required packages installed successfully"
}

# Download and patch CyberPanel installation script
download_cyberpanel() {
    log "Downloading CyberPanel installation script"
    
    # Download the original script
    curl -sS https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh > /tmp/cyberpanel_install.sh
    
    # Apply patches
    log "Applying AlmaLinux 10 patches to CyberPanel script"
    
    # Patch EPEL repository setup
    sed -i '/setup_epel_repo() {/,/^}/c\
setup_epel_repo() {\
    case "$Server_OS_Version" in\
        "7")\
            rpm --import https://cyberpanel.sh/dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7\
            yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm\
            Check_Return "yum repo" "no_exit"\
            ;;\
        "8")\
            rpm --import https://cyberpanel.sh/dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8\
            yum install -y https://cyberpanel.sh/dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm\
            Check_Return "yum repo" "no_exit"\
            ;;\
        "9")\
            yum install -y https://cyberpanel.sh/dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm\
            Check_Return "yum repo" "no_exit"\
            ;;\
        "10")\
            # AlmaLinux 10 EPEL support\
            yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm\
            Check_Return "yum repo" "no_exit"\
            ;;\
    esac\
}' /tmp/cyberpanel_install.sh
    
    # Patch MariaDB repository setup
    sed -i '/elif \[\[ "$Server_OS_Version" = "10" \]\] && uname -m | grep -q '\''x86_64'\''; then/,/^EOF/c\
elif [[ "$Server_OS_Version" = "10" ]] && uname -m | grep -q '\''x86_64'\''; then\
        cat <<EOF >/etc/yum.repos.d/MariaDB.repo\
# MariaDB 10.11 RHEL10 repository list - AlmaLinux 10 compatible\
# http://downloads.mariadb.org/mariadb/repositories/\
[mariadb]\
name = MariaDB\
baseurl = http://yum.mariadb.org/10.11/rhel10-amd64/\
module_hotfixes=1\
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB\
enabled=1\
gpgcheck=1\
EOF' /tmp/cyberpanel_install.sh
    
    # Patch remi-release installation
    sed -i 's/yum install -y https:\/\/rpms.remirepo.net\/enterprise\/remi-release-9.rpm/if [[ "$Server_OS_Version" = "9" ]]; then\
                yum install -y https:\/\/rpms.remirepo.net\/enterprise\/remi-release-9.rpm\
            elif [[ "$Server_OS_Version" = "10" ]]; then\
                yum install -y https:\/\/rpms.remirepo.net\/enterprise\/remi-release-10.rpm\
            fi/' /tmp/cyberpanel_install.sh
    
    # Patch GPG key import with fallback
    sed -i 's/rpm --import https:\/\/cyberpanel.sh\/rpms.litespeedtech.com\/centos\/RPM-GPG-KEY-litespeed/rpm --import https:\/\/cyberpanel.sh\/rpms.litespeedtech.com\/centos\/RPM-GPG-KEY-litespeed || {\
            log_warning "Primary GPG key import failed, trying alternative source"\
            rpm --import https:\/\/rpms.litespeedtech.com\/centos\/RPM-GPG-KEY-litespeed || {\
                log_error "Failed to import LiteSpeed GPG key from all sources"\
                return 1\
            }\
        }/' /tmp/cyberpanel_install.sh
    
    # Patch package installation to include boost libraries
    sed -i 's/dnf install -y libnsl zip wget strace net-tools curl which bc telnet htop libevent-devel gcc libattr-devel xz-devel MariaDB-server MariaDB-client MariaDB-devel curl-devel git platform-python-devel tar socat python3 zip unzip bind-utils gpgme-devel openssl-devel/dnf install -y libnsl zip wget strace net-tools curl which bc telnet htop libevent-devel gcc libattr-devel xz-devel MariaDB-server MariaDB-client MariaDB-devel curl-devel git platform-python-devel tar socat python3 zip unzip bind-utils gpgme-devel openssl-devel boost-devel boost-program-options/' /tmp/cyberpanel_install.sh
    
    # Add boost library symlink creation
    sed -i '/Check_Return/a\
    # Fix boost library compatibility for galera-4 on AlmaLinux 10\
    if [[ "$Server_OS_Version" = "10" ]]; then\
      # Create symlink for boost libraries if needed\
      if [ ! -f /usr/lib64/libboost_program_options.so.1.75.0 ]; then\
        BOOST_VERSION=$(find /usr/lib64 -name "libboost_program_options.so.*" | head -1 | sed '\''s/.*libboost_program_options\.so\.//'\'')\
        if [ -n "$BOOST_VERSION" ]; then\
          ln -sf /usr/lib64/libboost_program_options.so.$BOOST_VERSION /usr/lib64/libboost_program_options.so.1.75.0\
          log_info "Created boost library symlink for galera-4 compatibility: $BOOST_VERSION -> 1.75.0"\
        else\
          log_warning "Could not find boost libraries, galera-4 may not work properly"\
        fi\
      fi\
    fi' /tmp/cyberpanel_install.sh
    
    # Make script executable
    chmod +x /tmp/cyberpanel_install.sh
    
    log "CyberPanel installation script downloaded and patched"
}

# Run CyberPanel installation
install_cyberpanel() {
    log "Starting CyberPanel installation"
    
    # Run the patched installation script
    bash /tmp/cyberpanel_install.sh
    
    log "CyberPanel installation completed"
}

# Verify installation
verify_installation() {
    log "Verifying CyberPanel installation"
    
    # Check if services are running
    if systemctl is-active --quiet lscpd; then
        log "LiteSpeed is running"
    else
        warning "LiteSpeed is not running"
    fi
    
    if systemctl is-active --quiet mariadb; then
        log "MariaDB is running"
    else
        warning "MariaDB is not running"
    fi
    
    # Check if CyberPanel is accessible
    if curl -s -k https://localhost:8090 > /dev/null; then
        log "CyberPanel is accessible at https://localhost:8090"
    else
        warning "CyberPanel may not be accessible yet"
    fi
    
    log "Installation verification completed"
}

# Main installation function
main() {
    log "Starting CyberPanel AlmaLinux 10 Complete Fix"
    
    check_root
    check_almalinux10
    fix_repositories
    install_packages
    download_cyberpanel
    
    info "All fixes have been applied successfully!"
    info "You can now run the CyberPanel installation:"
    echo "bash /tmp/cyberpanel_install.sh"
    echo ""
    info "Or run this script again with --install flag to install automatically:"
    echo "bash $0 --install"
    
    if [[ "$1" == "--install" ]]; then
        install_cyberpanel
        verify_installation
    fi
}

# Run main function
main "$@"
