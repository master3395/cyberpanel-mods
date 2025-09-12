# 🖥️ OS-Specific Notes and Compatibility

This document provides detailed information about CyberPanel Mods compatibility and specific considerations for each supported operating system.

## 📋 OS-Specific Scripts and Fixes

### 🖥️ OS-Specific Scripts (`os-specific/`)

#### AlmaLinux 9 Fixes
- **cyberpanel_almalinux9_upgrade_fix.sh** - Fix MariaDB issues during CyberPanel upgrade
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/cyberpanel_almalinux9_upgrade_fix.sh | bash
  ```
  
  **What it fixes:**
  - MariaDB compatibility issues during CyberPanel upgrade
  - Service startup problems
  - Database connection issues
  - Package dependency conflicts

- **installCyberPanel_almalinux9_patch.py** - Python patch for installCyberPanel.py
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/installCyberPanel_almalinux9_patch.py | python3
  ```
  
  **What it patches:**
  - installCyberPanel.py compatibility issues
  - Package installation problems
  - Service configuration issues
  - Python dependency conflicts

### 🔧 OS-Aware Core Fixes

#### Enhanced Core Fixes with OS Detection
- **cyberpanel_core_fixes_enhanced.sh** - OS-aware comprehensive fixes
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash
  ```
  
  **OS-specific features:**
  - Automatic OS detection
  - Package manager detection (APT, YUM, DNF)
  - Service name detection (systemd, sysvinit)
  - Path detection for different OS versions
  - OS-specific error handling

### 🔄 OS-Aware Version Managers

#### PHP Version Manager with OS Support
- **php_version_manager_enhanced.sh** - OS-aware PHP version management
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/php_version_manager_enhanced.sh | bash
  ```
  
  **OS-specific features:**
  - Package manager detection
  - OS-specific PHP package names
  - Service management for different OS versions
  - Path detection for PHP installations

#### MariaDB Version Manager with OS Support
- **mariadb_version_manager_enhanced.sh** - OS-aware MariaDB version management
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/mariadb_version_manager_enhanced.sh | bash
  ```
  
  **OS-specific features:**
  - Package manager detection
  - OS-specific MariaDB package names
  - Service management for different OS versions
  - Database path detection

### 🛠️ OS-Aware Utilities

#### System Compatibility Checker
- **os_compatibility_checker.sh** - Comprehensive OS compatibility verification
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash
  ```
  
  **OS detection features:**
  - Operating system identification
  - Version detection
  - Package manager detection
  - Service manager detection
  - Architecture detection
  - Compatibility scoring

#### Enhanced CyberPanel Utility
- **cyberpanel_utility_enhanced.sh** - OS-aware CyberPanel utility
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility_enhanced.sh | bash
  ```
  
  **OS-specific features:**
  - OS detection and adaptation
  - Package manager-specific commands
  - Service management for different OS versions
  - OS-specific troubleshooting

### 🛡️ OS-Aware Security Scripts

#### Comprehensive Security Hardening
- **cyberpanel_security_enhanced.sh** - OS-aware security hardening
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash
  ```
  
  **OS-specific security features:**
  - Firewall configuration (UFW for Ubuntu, iptables for RHEL-based)
  - Package manager-specific security updates
  - OS-specific service hardening
  - OS-specific log file locations

### 🔄 OS-Specific Usage Patterns

#### Ubuntu/Debian Systems
```bash
# Check compatibility
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash

# Run core fixes
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash

# Apply security hardening
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash
```

#### RHEL-based Systems (AlmaLinux, RockyLinux, RHEL, CentOS)
```bash
# Check compatibility
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash

# Run core fixes
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash

# Apply security hardening
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash
```

#### AlmaLinux 9 Specific
```bash
# Run AlmaLinux 9 specific fixes
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/cyberpanel_almalinux9_upgrade_fix.sh | bash

# Apply Python patch if needed
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/installCyberPanel_almalinux9_patch.py | python3
```

## 🌐 Supported Operating Systems

### ✅ Fully Supported

#### Ubuntu 24.04.3 LTS (Noble Numbat)
- **Support Until**: April 2029
- **Package Manager**: APT
- **Default PHP**: 8.3
- **Default MariaDB**: 10.11
- **Special Notes**: 
  - Latest LTS release with extended support
  - All mods fully tested and compatible
  - Recommended for new installations

#### Ubuntu 22.04 LTS (Jammy Jellyfish)
- **Support Until**: April 2027
- **Package Manager**: APT
- **Default PHP**: 8.1
- **Default MariaDB**: 10.6
- **Special Notes**:
  - Stable and widely used
  - Excellent compatibility with all mods
  - Good choice for production environments

#### Ubuntu 20.04 LTS (Focal Fossa)
- **Support Until**: April 2025
- **Package Manager**: APT
- **Default PHP**: 8.0
- **Default MariaDB**: 10.3
- **Special Notes**:
  - Legacy support ending soon
  - Some newer mods may have limited features
  - Consider upgrading to newer LTS

#### AlmaLinux 10
- **Support Until**: May 2030
- **Package Manager**: DNF
- **Default PHP**: 8.3
- **Default MariaDB**: 10.11
- **Special Notes**:
  - Latest RHEL-compatible release
  - Excellent enterprise support
  - All mods fully compatible

#### AlmaLinux 9
- **Support Until**: May 2032
- **Package Manager**: DNF
- **Default PHP**: 8.1
- **Default MariaDB**: 10.5
- **Special Notes**:
  - Long-term support until 2032
  - Some MariaDB compatibility issues (see fixes below)
  - Recommended for enterprise use

#### AlmaLinux 8
- **Support Until**: May 2029
- **Package Manager**: YUM/DNF
- **Default PHP**: 7.4
- **Default MariaDB**: 10.3
- **Special Notes**:
  - Stable and reliable
  - Good compatibility with all mods
  - Suitable for production environments

#### RockyLinux 9
- **Support Until**: May 2032
- **Package Manager**: DNF
- **Default PHP**: 8.1
- **Default MariaDB**: 10.5
- **Special Notes**:
  - Community-driven RHEL alternative
  - Excellent compatibility with mods
  - Good choice for cost-conscious deployments

#### RockyLinux 8
- **Support Until**: May 2029
- **Package Manager**: YUM/DNF
- **Default PHP**: 7.4
- **Default MariaDB**: 10.3
- **Special Notes**:
  - Stable and reliable
  - Good compatibility with all mods
  - Suitable for production environments

#### RHEL 9
- **Support Until**: May 2032
- **Package Manager**: DNF
- **Default PHP**: 8.1
- **Default MariaDB**: 10.5
- **Special Notes**:
  - Enterprise-grade support
  - All mods fully compatible
  - Requires Red Hat subscription

#### RHEL 8
- **Support Until**: May 2029
- **Package Manager**: YUM/DNF
- **Default PHP**: 7.4
- **Default MariaDB**: 10.3
- **Special Notes**:
  - Enterprise-grade support
  - Good compatibility with mods
  - Requires Red Hat subscription

#### CentOS 9
- **Support Until**: May 2027
- **Package Manager**: DNF
- **Default PHP**: 8.1
- **Default MariaDB**: 10.5
- **Special Notes**:
  - Limited support period
  - Consider migrating to AlmaLinux or RockyLinux
  - Mods compatible but not recommended for new installations

#### CloudLinux 8
- **Support Until**: May 2029
- **Package Manager**: YUM
- **Default PHP**: 7.4
- **Default MariaDB**: 10.3
- **Special Notes**:
  - Optimized for shared hosting
  - Good compatibility with mods
  - Requires CloudLinux license

### 🔧 Community Supported

#### Debian 12 (Bookworm)
- **Package Manager**: APT
- **Default PHP**: 8.2
- **Default MariaDB**: 10.11
- **Special Notes**:
  - Community support only
  - May work with Ubuntu-compatible packages
  - Test thoroughly before production use

#### Debian 11 (Bullseye)
- **Package Manager**: APT
- **Default PHP**: 7.4
- **Default MariaDB**: 10.5
- **Special Notes**:
  - Community support only
  - Some compatibility issues with newer mods
  - Consider upgrading to Debian 12

#### openEuler 22.03 LTS
- **Package Manager**: YUM/DNF
- **Default PHP**: 8.0
- **Default MariaDB**: 10.3
- **Special Notes**:
  - Community support only
  - Limited testing
  - May require manual package installation

## 🔧 OS-Specific Fixes and Considerations

### AlmaLinux 9 MariaDB Issues

#### Problem
AlmaLinux 9 has known issues with MariaDB installation and service management during CyberPanel upgrades.

#### Solution
Use the AlmaLinux 9 specific fixes:

```bash
# Run AlmaLinux 9 upgrade fix
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/cyberpanel_almalinux9_upgrade_fix.sh | bash

# Apply Python patch
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/installCyberPanel_almalinux9_patch.py | python3
```

#### Manual Fix
```bash
# Disable problematic MariaDB MaxScale repository
dnf config-manager --disable mariadb-maxscale

# Remove problematic repository files
rm -f /etc/yum.repos.d/mariadb-maxscale.repo

# Clean DNF cache
dnf clean all

# Install MariaDB from official repository
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --mariadb-server-version="10.11"
dnf install -y MariaDB-server MariaDB-client MariaDB-backup MariaDB-devel
```

### Ubuntu 24.04 PHP 8.4 Support

#### New Features
Ubuntu 24.04 includes PHP 8.4 support with enhanced performance and security features.

#### Installation
```bash
# Install PHP 8.4
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/php_version_manager_enhanced.sh | bash 84

# Or use the enhanced utility
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility_enhanced.sh | bash
```

### RHEL-based Systems SELinux

#### SELinux Configuration
RHEL-based systems have SELinux enabled by default, which may cause issues with CyberPanel.

#### Solution
```bash
# Check SELinux status
sestatus

# Temporarily disable SELinux (not recommended for production)
setenforce 0

# Permanently disable SELinux (edit /etc/selinux/config)
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# Or configure SELinux for CyberPanel
setsebool -P httpd_can_network_connect 1
setsebool -P httpd_can_network_connect_db 1
```

### CloudLinux CageFS

#### CageFS Configuration
CloudLinux uses CageFS for user isolation, which may affect some CyberPanel functions.

#### Solution
```bash
# Check CageFS status
cagefsctl --status

# Enable CageFS for CyberPanel user
cagefsctl --enable cyberpanel

# Update CageFS
cagefsctl --update
```

## 📦 Package Manager Specific Commands

### APT (Ubuntu/Debian)

#### Basic Commands
```bash
# Update package lists
apt update

# Install packages
apt install package-name

# Upgrade packages
apt upgrade

# Remove packages
apt remove package-name

# Clean package cache
apt clean
apt autoremove
```

#### CyberPanel Specific
```bash
# Install PHP extensions
apt install lsphp81-redis lsphp81-memcached

# Install MariaDB
apt install mariadb-server mariadb-client

# Install additional tools
apt install curl wget unzip
```

### YUM/DNF (RHEL-based)

#### Basic Commands
```bash
# Update packages
yum update
dnf update

# Install packages
yum install package-name
dnf install package-name

# Remove packages
yum remove package-name
dnf remove package-name

# Clean cache
yum clean all
dnf clean all
```

#### CyberPanel Specific
```bash
# Install PHP extensions
yum install lsphp81-redis lsphp81-memcached

# Install MariaDB
yum install MariaDB-server MariaDB-client

# Install additional tools
yum install curl wget unzip
```

## 🔧 Service Management

### Systemd Services

#### Common Services
```bash
# CyberPanel services
systemctl status lscpd
systemctl status gunicorn

# Database services
systemctl status mariadb
systemctl status mysqld

# Web server services
systemctl status lsws
systemctl status httpd
systemctl status nginx
```

#### Service Management
```bash
# Start service
systemctl start service-name

# Stop service
systemctl stop service-name

# Restart service
systemctl restart service-name

# Enable service
systemctl enable service-name

# Disable service
systemctl disable service-name
```

### Legacy Service Management

#### SysV Init (Older Systems)
```bash
# Start service
service service-name start

# Stop service
service service-name stop

# Restart service
service service-name restart

# Check status
service service-name status
```

## 🌐 Network Configuration

### Firewall Management

#### UFW (Ubuntu/Debian)
```bash
# Enable UFW
ufw enable

# Allow ports
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8090/tcp

# Check status
ufw status verbose
```

#### Firewalld (RHEL-based)
```bash
# Start firewalld
systemctl start firewalld

# Allow services
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=8090/tcp

# Reload firewall
firewall-cmd --reload

# Check status
firewall-cmd --list-all
```

### Network Interfaces

#### Check Network Configuration
```bash
# List network interfaces
ip addr show

# Check routing table
ip route show

# Test connectivity
ping -c 4 google.com
```

## 🔍 Troubleshooting by OS

### Ubuntu/Debian Issues

#### Common Problems
1. **Package conflicts**
   ```bash
   # Fix package conflicts
   apt --fix-broken install
   dpkg --configure -a
   ```

2. **Service startup issues**
   ```bash
   # Check service logs
   journalctl -u service-name
   
   # Check system logs
   tail -f /var/log/syslog
   ```

### RHEL-based Issues

#### Common Problems
1. **SELinux issues**
   ```bash
   # Check SELinux logs
   ausearch -m AVC -ts recent
   
   # Fix SELinux context
   restorecon -R /usr/local/CyberCP
   ```

2. **Package dependency issues**
   ```bash
   # Resolve dependencies
   yum deplist package-name
   yum install --resolve package-name
   ```

### CloudLinux Issues

#### Common Problems
1. **CageFS issues**
   ```bash
   # Rebuild CageFS
   cagefsctl --rebuild-all
   
   # Check CageFS status
   cagefsctl --status
   ```

2. **Resource limits**
   ```bash
   # Check resource limits
   ulimit -a
   
   # Check CloudLinux limits
   lvectl list
   ```

## 📋 OS-Specific Recommendations

### For New Installations

#### Recommended OS Choices
1. **Ubuntu 24.04 LTS** - Best for new installations
2. **AlmaLinux 10** - Best for enterprise environments
3. **RockyLinux 9** - Best for cost-conscious deployments

#### Avoid These OS
1. **CentOS 9** - Limited support period
2. **Ubuntu 20.04** - Support ending soon
3. **Debian 11** - Outdated packages

### For Existing Installations

#### Upgrade Paths
1. **Ubuntu 20.04 → 22.04 → 24.04**
2. **CentOS 8 → AlmaLinux 8 → AlmaLinux 9**
3. **RHEL 8 → RHEL 9**

#### Migration Considerations
- Test all mods after OS upgrade
- Update package repositories
- Review security configurations
- Update monitoring and backup procedures

## 🔄 Maintenance by OS

### Ubuntu/Debian Maintenance
```bash
# Weekly maintenance
apt update && apt upgrade -y
apt autoremove -y
apt autoclean

# Monthly maintenance
apt dist-upgrade -y
```

### RHEL-based Maintenance
```bash
# Weekly maintenance
yum update -y
yum clean all

# Monthly maintenance
dnf upgrade -y
dnf clean all
```

### CloudLinux Maintenance
```bash
# Weekly maintenance
yum update -y
cagefsctl --update

# Monthly maintenance
lvectl set --save --limit=mem=1024M --limit=cpu=100% --limit=io=1024
```

---

**Note**: Always test mods in a non-production environment before applying to production systems. OS-specific issues may require additional configuration or workarounds.
