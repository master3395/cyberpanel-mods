# CyberPanel AlmaLinux 10 Installation Guide

## Overview

This guide provides step-by-step instructions to install CyberPanel on AlmaLinux 10, addressing the compatibility issues that prevent successful installation.

## Issues Fixed

1. **EPEL Repository**: Missing EPEL 10 support
2. **remi-release Version Conflict**: Wrong version (9 instead of 10) for AlmaLinux 10
3. **MariaDB Repository**: Using RHEL9 repository instead of RHEL10
4. **GPG Key Issues**: LiteSpeed GPG key import failures
5. **Boost Libraries**: Missing libboost_program_options.so.1.75.0 for galera-4
6. **Package Dependencies**: Missing essential packages for AlmaLinux 10

## Prerequisites

- AlmaLinux 10 (x86_64 or aarch64)
- Root access
- Internet connection
- At least 2GB RAM (for Free Start license)

## Installation Methods

### Method 1: Automated Fix Script (Recommended)

1. **Download and run the fix script:**
   ```bash
   curl -sS https://raw.githubusercontent.com/your-repo/cyberpanel-mods/main/core-fixes/almalinux10-cyberpanel-fix.sh | bash
   ```

2. **Install CyberPanel:**
   ```bash
   sh <(curl https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh || wget -O - https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh)
   ```

### Method 2: Manual Fix

1. **Fix EPEL repository:**
   ```bash
   dnf remove -y epel-release
   dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
   dnf config-manager --set-enabled epel
   ```

2. **Fix remi repository:**
   ```bash
   dnf remove -y remi-release
   dnf install -y https://rpms.remirepo.net/enterprise/remi-release-10.rpm
   ```

3. **Fix MariaDB repository:**
   ```bash
   rm -f /etc/yum.repos.d/MariaDB.repo
   cat <<EOF >/etc/yum.repos.d/MariaDB.repo
   [mariadb]
   name = MariaDB
   baseurl = http://yum.mariadb.org/10.11/rhel10-amd64/
   module_hotfixes=1
   gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
   enabled=1
   gpgcheck=1
   EOF
   ```

4. **Fix boost libraries:**
   ```bash
   dnf install -y boost-devel boost-program-options
   # Create symlink for galera-4 compatibility
   BOOST_VERSION=$(find /usr/lib64 -name "libboost_program_options.so.*" | head -1 | sed 's/.*libboost_program_options\.so\.//')
   ln -sf /usr/lib64/libboost_program_options.so.$BOOST_VERSION /usr/lib64/libboost_program_options.so.1.75.0
   ```

5. **Fix LiteSpeed GPG key:**
   ```bash
   rpm --import https://rpms.litespeedtech.com/centos/RPM-GPG-KEY-litespeed
   ```

6. **Install missing packages:**
   ```bash
   dnf install -y wget curl which htop python3 python3-pip dnf-plugins-core
   dnf config-manager --set-enabled crb
   dnf clean all
   dnf makecache
   ```

7. **Install CyberPanel:**
   ```bash
   sh <(curl https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh || wget -O - https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh)
   ```

## Verification

After installation, verify that CyberPanel is working:

1. **Check services:**
   ```bash
   systemctl status lscpd
   systemctl status mariadb
   ```

2. **Access CyberPanel:**
   - Open your browser and go to `https://your-server-ip:8090`
   - Use the credentials provided during installation

## Troubleshooting

### Common Issues

1. **GPG Key Import Failed:**
   ```bash
   rpm --import https://rpms.litespeedtech.com/centos/RPM-GPG-KEY-litespeed
   ```

2. **MariaDB Installation Failed:**
   ```bash
   dnf clean all
   dnf makecache
   dnf install -y MariaDB-server MariaDB-client
   ```

3. **Boost Library Missing:**
   ```bash
   dnf install -y boost-devel boost-program-options
   ```

4. **EPEL Repository Issues:**
   ```bash
   dnf remove -y epel-release
   dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
   ```

### Log Files

Check these log files for detailed error information:
- `/var/log/cyberpanel_debug.log`
- `/var/log/mariadb/mariadb.log`
- `/usr/local/lscpd/logs/error.log`

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review the log files
3. Ensure all prerequisites are met
4. Try the manual fix method if automated script fails

## Changelog

- **v1.0**: Initial release with AlmaLinux 10 compatibility fixes
- Fixed EPEL repository setup
- Fixed remi-release version conflict
- Fixed MariaDB repository configuration
- Fixed boost library dependencies
- Fixed GPG key import issues

## License

This fix is provided under the same license as CyberPanel.
