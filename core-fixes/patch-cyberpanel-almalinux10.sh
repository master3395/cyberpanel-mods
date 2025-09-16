#!/bin/bash

# Direct patch for CyberPanel installation script to support AlmaLinux 10
# This script modifies the actual CyberPanel script in place

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if running on AlmaLinux 10
if ! grep -q "AlmaLinux-10" /etc/os-release; then
    error "This script is designed for AlmaLinux 10 only"
    exit 1
fi

log "Patching CyberPanel installation script for AlmaLinux 10 compatibility"

# Download the original script
log "Downloading CyberPanel installation script"
curl -sS https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh > /tmp/cyberpanel_original.sh

# Create backup
cp /tmp/cyberpanel_original.sh /tmp/cyberpanel_original.sh.backup

# Apply patches
log "Applying AlmaLinux 10 patches"

# Patch 1: Fix EPEL repository setup function
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
}' /tmp/cyberpanel_original.sh

# Patch 2: Fix MariaDB repository setup function
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
EOF' /tmp/cyberpanel_original.sh

# Patch 3: Fix remi-release installation for AlmaLinux 10
sed -i 's/yum install -y https:\/\/rpms.remirepo.net\/enterprise\/remi-release-9.rpm/if [[ "$Server_OS_Version" = "9" ]]; then\
                yum install -y https:\/\/rpms.remirepo.net\/enterprise\/remi-release-9.rpm\
            elif [[ "$Server_OS_Version" = "10" ]]; then\
                yum install -y https:\/\/rpms.remirepo.net\/enterprise\/remi-release-10.rpm\
            fi/' /tmp/cyberpanel_original.sh

# Patch 4: Fix GPG key import with fallback
sed -i 's/rpm --import https:\/\/cyberpanel.sh\/rpms.litespeedtech.com\/centos\/RPM-GPG-KEY-litespeed/rpm --import https:\/\/cyberpanel.sh\/rpms.litespeedtech.com\/centos\/RPM-GPG-KEY-litespeed || {\
            warning "Primary GPG key import failed, trying alternative source"\
            rpm --import https:\/\/rpms.litespeedtech.com\/centos\/RPM-GPG-KEY-litespeed || {\
                error "Failed to import LiteSpeed GPG key from all sources"\
                return 1\
            }\
        }/' /tmp/cyberpanel_original.sh

# Patch 5: Add boost libraries for AlmaLinux 10
sed -i 's/dnf install -y libnsl zip wget strace net-tools curl which bc telnet htop libevent-devel gcc libattr-devel xz-devel MariaDB-server MariaDB-client MariaDB-devel curl-devel git platform-python-devel tar socat python3 zip unzip bind-utils gpgme-devel openssl-devel/dnf install -y libnsl zip wget strace net-tools curl which bc telnet htop libevent-devel gcc libattr-devel xz-devel MariaDB-server MariaDB-client MariaDB-devel curl-devel git platform-python-devel tar socat python3 zip unzip bind-utils gpgme-devel openssl-devel boost-devel boost-program-options/' /tmp/cyberpanel_original.sh

# Patch 6: Add boost library symlink creation for galera-4 compatibility
sed -i '/Check_Return/a\
            # Fix boost library compatibility for galera-4 on AlmaLinux 10\
            if [[ "$Server_OS_Version" = "10" ]]; then\
                # Create symlink for boost libraries if needed\
                if [ ! -f /usr/lib64/libboost_program_options.so.1.75.0 ]; then\
                    BOOST_VERSION=$(find /usr/lib64 -name "libboost_program_options.so.*" | head -1 | sed '\''s/.*libboost_program_options\.so\.//'\'')\
                    if [ -n "$BOOST_VERSION" ]; then\
                        ln -sf /usr/lib64/libboost_program_options.so.$BOOST_VERSION /usr/lib64/libboost_program_options.so.1.75.0\
                        log_info "Created boost library symlink for galera-4 compatibility"\
                    fi\
                fi\
            fi' /tmp/cyberpanel_original.sh

# Make the patched script executable
chmod +x /tmp/cyberpanel_original.sh

log "CyberPanel installation script patched successfully!"
log "Patched script saved as: /tmp/cyberpanel_original.sh"

echo ""
echo "To install CyberPanel on AlmaLinux 10, run:"
echo "bash /tmp/cyberpanel_original.sh"
echo ""
echo "The script has been patched with the following fixes:"
echo "- Added EPEL 10 repository support"
echo "- Fixed MariaDB repository for RHEL10"
echo "- Fixed remi-release version for AlmaLinux 10"
echo "- Added GPG key import fallback"
echo "- Added boost libraries for galera-4 compatibility"
echo "- Added boost library symlink creation"
