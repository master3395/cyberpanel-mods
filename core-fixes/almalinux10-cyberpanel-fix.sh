#!/bin/bash

# CyberPanel AlmaLinux 10 Compatibility Fix
# This script fixes the installation issues on AlmaLinux 10
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

# Check if running on AlmaLinux 10
check_almalinux10() {
    if ! grep -q "AlmaLinux-10" /etc/os-release; then
        error "This script is designed for AlmaLinux 10 only"
        exit 1
    fi
    log "AlmaLinux 10 detected - proceeding with fixes"
}

# Fix EPEL repository setup
fix_epel_repo() {
    log "Fixing EPEL repository for AlmaLinux 10"
    
    # Remove existing EPEL if present
    dnf remove -y epel-release 2>/dev/null || true
    rm -f /etc/yum.repos.d/epel.repo
    rm -f /etc/yum.repos.d/epel.repo.rpmsave
    
    # Install EPEL 10
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
    dnf config-manager --set-enabled epel
    
    log "EPEL repository fixed"
}

# Fix remi repository
fix_remi_repo() {
    log "Fixing remi repository for AlmaLinux 10"
    
    # Remove existing remi repositories
    dnf remove -y remi-release 2>/dev/null || true
    rm -f /etc/yum.repos.d/remi.repo
    rm -f /etc/yum.repos.d/remi.repo.rpmsave
    
    # Install remi-release for RHEL 10 (which AlmaLinux 10 is based on)
    dnf install -y https://rpms.remirepo.net/enterprise/remi-release-10.rpm
    
    log "remi repository fixed"
}

# Fix MariaDB repository
fix_mariadb_repo() {
    log "Fixing MariaDB repository for AlmaLinux 10"
    
    # Remove existing MariaDB repository
    rm -f /etc/yum.repos.d/MariaDB.repo
    rm -f /etc/yum.repos.d/MariaDB.repo.rpmsave
    
    # Create proper MariaDB repository for RHEL 10
    cat <<EOF >/etc/yum.repos.d/MariaDB.repo
# MariaDB 10.11 RHEL10 repository list
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
    
    log "MariaDB repository fixed"
}

# Fix boost libraries dependency
fix_boost_dependencies() {
    log "Fixing boost libraries for galera-4 compatibility"
    
    # Install boost libraries
    dnf install -y boost-devel boost-program-options
    
    # Create symlink for the specific version required by galera-4
    if [ ! -f /usr/lib64/libboost_program_options.so.1.75.0 ]; then
        # Find the available boost version
        BOOST_VERSION=$(find /usr/lib64 -name "libboost_program_options.so.*" | head -1 | sed 's/.*libboost_program_options\.so\.//')
        if [ -n "$BOOST_VERSION" ]; then
            ln -sf /usr/lib64/libboost_program_options.so.$BOOST_VERSION /usr/lib64/libboost_program_options.so.1.75.0
            log "Created symlink for boost libraries: $BOOST_VERSION -> 1.75.0"
        else
            warning "Could not find boost libraries, galera-4 may not work properly"
        fi
    fi
}

# Fix LiteSpeed GPG key
fix_litespeed_gpg() {
    log "Fixing LiteSpeed GPG key"
    
    # Import LiteSpeed GPG key with proper handling
    rpm --import https://cyberpanel.sh/rpms.litespeedtech.com/centos/RPM-GPG-KEY-litespeed || {
        warning "Failed to import LiteSpeed GPG key from primary source, trying alternative"
        rpm --import https://rpms.litespeedtech.com/centos/RPM-GPG-KEY-litespeed || {
            error "Failed to import LiteSpeed GPG key from all sources"
            return 1
        }
    }
    
    log "LiteSpeed GPG key fixed"
}

# Install missing packages
install_missing_packages() {
    log "Installing missing packages for AlmaLinux 10"
    
    # Update system first
    dnf update -y
    
    # Install essential packages
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
        openssl-devel
    
    log "Missing packages installed"
}

# Fix repository priorities
fix_repository_priorities() {
    log "Fixing repository priorities"
    
    # Ensure CRB (CodeReady Builder) is enabled
    dnf config-manager --set-enabled crb
    
    # Clean and update repositories
    dnf clean all
    dnf makecache
    
    log "Repository priorities fixed"
}

# Main installation function
main() {
    log "Starting AlmaLinux 10 compatibility fixes for CyberPanel"
    
    check_almalinux10
    fix_epel_repo
    fix_remi_repo
    fix_mariadb_repo
    fix_boost_dependencies
    fix_litespeed_gpg
    install_missing_packages
    fix_repository_priorities
    
    log "All AlmaLinux 10 compatibility fixes completed successfully!"
    log "You can now proceed with the CyberPanel installation"
    
    echo ""
    info "To install CyberPanel, run:"
    echo "sh <(curl https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh || wget -O - https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh)"
}

# Run main function
main "$@"
