# 🚀 CyberPanel Mods Installation Guide

This comprehensive guide will help you install and use the CyberPanel Mods repository on all supported operating systems.

## 📋 Prerequisites

Before installing any mods, ensure you have:

- ✅ **Root access** to your server
- ✅ **CyberPanel installed** and running
- ✅ **Internet connection** for downloading scripts
- ✅ **Supported operating system** (see compatibility list below)
- ✅ **Backup** of your current system (recommended)

## 🌐 Supported Operating Systems

### ✅ Fully Supported
- **Ubuntu 24.04.3** - Supported until April 2029 ⭐ NEW!
- **Ubuntu 22.04** - Supported until April 2027
- **Ubuntu 20.04** - Supported until April 2025
- **AlmaLinux 10** - Supported until May 2030 ⭐ NEW!
- **AlmaLinux 9** - Supported until May 2032
- **AlmaLinux 8** - Supported until May 2029
- **RockyLinux 9** - Supported until May 2032
- **RockyLinux 8** - Supported until May 2029
- **RHEL 9** - Supported until May 2032
- **RHEL 8** - Supported until May 2029
- **CloudLinux 8** - Supported until May 2029
- **CentOS 9** - Supported until May 2027

### 🔧 Community Supported
- **Debian** - Limited testing, may work with Ubuntu-compatible packages
- **openEuler** - Community-supported with limited testing

## 🔍 Step 1: System Compatibility Check

Before installing any mods, check your system compatibility:

```bash
# Download and run the compatibility checker
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash
```

This script will:
- ✅ Detect your operating system
- ✅ Check CyberPanel installation
- ✅ Verify package managers
- ✅ Check system requirements
- ✅ Provide compatibility recommendations

## 🛠️ Step 2: Install Enhanced CyberPanel Utility

The enhanced utility provides a comprehensive interface for managing CyberPanel:

```bash
# Download and run the enhanced utility
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility_enhanced.sh | bash
```

**Features:**
- 🔄 CyberPanel upgrades
- 📦 Addon management (Redis, Memcached, PHP extensions)
- 🐕 WatchDog management
- ❓ FAQ and help system
- 🔍 OS compatibility detection
- 🛡️ Enhanced error handling

## 🔧 Step 3: Install Core Fixes

Fix common CyberPanel issues across all supported OS versions:

```bash
# Run all core fixes
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash

# Or run specific fixes
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash -- --symbolic-links --permissions
```

**Available fixes:**
- 🔗 Symbolic links
- 📁 File permissions
- 🔒 SSL context issues
- ⚙️ Service problems
- 🗄️ Database connectivity
- 🐍 Python environment
- ❌ 503 error resolution
- 📝 WP-CLI installation
- 🔐 Self-signed certificates

## 🛡️ Step 4: Security Hardening

Enhance your CyberPanel security:

```bash
# Run all security fixes
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash

# Or run specific security fixes
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash -- --firewall --fail2ban
```

**Security features:**
- 🔐 2FA management
- 🔒 SSL context fixes
- 📁 Permission hardening
- 🗄️ Database security
- 🔥 Firewall configuration
- 🔄 Security updates
- 🚫 Fail2ban protection
- 🛡️ ModSecurity setup

## 🔄 Step 5: Version Management

### PHP Version Manager

Manage PHP versions (7.1-8.4) with ease:

```bash
# Interactive mode
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/php_version_manager_enhanced.sh | bash

# Direct version change
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/php_version_manager_enhanced.sh | bash 81

# Check current status
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/php_version_manager_enhanced.sh | bash -- --status
```

### MariaDB Version Manager

Manage MariaDB versions (10.3-11.4) with backup support:

```bash
# Interactive mode
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/mariadb_version_manager_enhanced.sh | bash

# Install specific version
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/mariadb_version_manager_enhanced.sh | bash 10.11

# Check current status
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/mariadb_version_manager_enhanced.sh | bash -- --status
```

## 📦 Step 6: Additional Components

### Snappymail Version Changer

Update Snappymail to specific versions:

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/snappymail_v_changer.sh | bash
```

### phpMyAdmin Version Changer

Update phpMyAdmin to specific versions:

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/phpmyadmin_v_changer.sh | bash
```

### ModSecurity Rules Changer

Update OWASP ModSecurity rules:

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/modsec_rules_v_changer.sh | bash
```

## 🔄 Step 7: Backup and Restore

### Automated Backup Setup

Set up automated backups using RClone:

```bash
# SQL backup cronjob
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/rclone_sqlbackup_cronjob.sh | bash

# Full backup cronjob
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/rclone_backup_cronjob.sh | bash
```

### Database Restore

Restore CyberPanel core database if needed:

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/restore_cyberpanel_database.sh | bash
```

## 🖥️ Step 8: OS-Specific Fixes

### AlmaLinux 9 Upgrade Fix

Fix MariaDB issues during CyberPanel upgrade on AlmaLinux 9:

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/cyberpanel_almalinux9_upgrade_fix.sh | bash
```

### AlmaLinux 9 Patch

Apply Python patch for installCyberPanel.py:

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/installCyberPanel_almalinux9_patch.py | python3
```

## 📋 Complete Script Reference

### 🔧 Core Fixes (`core-fixes/`)

#### Enhanced Core Fixes
- **cyberpanel_core_fixes_enhanced.sh** - Comprehensive core fixes for all OS versions
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash
  ```

#### Individual Core Fixes
- **cyberpanel_fix_symbolic_links.sh** - Fix symbolic links
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_fix_symbolic_links.sh | bash
  ```
- **fix_503_service_unavailable.sh** - Fix 503 service unavailable errors
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/fix_503_service_unavailable.sh | bash
  ```
- **fix_missing_wp_cli.sh** - Install WP-CLI if missing
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/fix_missing_wp_cli.sh | bash
  ```
- **fixperms.sh** - Fix file permissions
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/fixperms.sh | bash
  ```

### 🔄 Version Managers (`version-managers/`)

#### Enhanced Version Managers
- **php_version_manager_enhanced.sh** - Enhanced PHP version manager (7.1-8.4)
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/php_version_manager_enhanced.sh | bash
  ```
- **mariadb_version_manager_enhanced.sh** - Enhanced MariaDB version manager (10.3-11.4)
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/mariadb_version_manager_enhanced.sh | bash
  ```

#### Original Version Managers
- **phpmod.sh** - Original PHP version changer
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/phpmod.sh | bash
  ```
- **phpmod_v2.sh** - PHP version changer v2
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/phpmod_v2.sh | bash
  ```
- **mariadb_v_changer.sh** - Original MariaDB version changer
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/mariadb_v_changer.sh | bash
  ```

#### Application Version Managers
- **snappymail_v_changer.sh** - Snappymail version changer
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/snappymail_v_changer.sh | bash
  ```
- **phpmyadmin_v_changer.sh** - phpMyAdmin version changer
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/phpmyadmin_v_changer.sh | bash
  ```
- **modsec_rules_v_changer.sh** - ModSecurity rules changer
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/modsec_rules_v_changer.sh | bash
  ```

### 🛡️ Security (`security/`)

#### Enhanced Security
- **cyberpanel_security_enhanced.sh** - Comprehensive security hardening
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash
  ```

#### Individual Security Scripts
- **disable_2fa.sh** - Disable two-factor authentication
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/disable_2fa.sh | bash
  ```
- **fix_permissions.sh** - Fix file permissions
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix_permissions.sh | bash
  ```
- **fix_ssl_missing_context.sh** - Fix SSL context issues
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix_ssl_missing_context.sh | bash
  ```
- **reset_ols_adminpassword** - Reset OpenLiteSpeed admin password
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/reset_ols_adminpassword | bash
  ```
- **selfsigned_fixer.sh** - Fix self-signed certificates
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/selfsigned_fixer.sh | bash
  ```

#### Security References
- **cp_permissions.txt** - CyberPanel permissions reference file

### 🛠️ Utilities (`utilities/`)

#### Enhanced Utilities
- **cyberpanel_utility_enhanced.sh** - Enhanced CyberPanel utility
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility_enhanced.sh | bash
  ```
- **os_compatibility_checker.sh** - OS compatibility checker
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash
  ```

#### Original Utilities
- **cyberpanel_utility.sh** - Original CyberPanel utility
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility.sh | bash
  ```

#### System Utilities
- **cloudflare_to_powerdns.sh** - DNS migration tool
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cloudflare_to_powerdns.sh | bash
  ```
- **crowdsec_update.sh** - CrowdSec updater
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/crowdsec_update.sh | bash
  ```
- **cyberpanel_sessions_cronjob.sh** - Sessions cleanup cronjob
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_sessions_cronjob.sh | bash
  ```
- **cyberpanel_sessions.sh** - Sessions cleanup script
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_sessions.sh | bash
  ```

#### Web Utilities
- **defaultwebsitepage.html** - Default website page template
- **defaultwebsitepage.sh** - Default website page installer
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/defaultwebsitepage.sh | bash
  ```
- **loader-wizard.php** - Loader wizard
- **wp** - WordPress CLI wrapper

#### FTP Utilities
- **install_pureftpd.sh** - PureFTPd installer
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/install_pureftpd.sh | bash
  ```
- **install_vsftpd.sh** - vsftpd installer
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/install_vsftpd.sh | bash
  ```

#### System Components
- **lsmcd** - LiteSpeed Memcached

### 💾 Backup & Restore (`backup-restore/`)

#### Database Files
- **cyberpanel.sql** - CyberPanel database schema

#### Backup Scripts
- **rclone_backup_cronjob.sh** - RClone backup cronjob
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/rclone_backup_cronjob.sh | bash
  ```
- **rclone_sqlbackup_cronjob.sh** - SQL backup cronjob
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/rclone_sqlbackup_cronjob.sh | bash
  ```
- **restore_cyberpanel_database.sh** - Database restore script
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/restore_cyberpanel_database.sh | bash
  ```

### 🖥️ OS-Specific (`os-specific/`)

#### AlmaLinux 9 Fixes
- **cyberpanel_almalinux9_upgrade_fix.sh** - AlmaLinux 9 upgrade fix
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/cyberpanel_almalinux9_upgrade_fix.sh | bash
  ```
- **installCyberPanel_almalinux9_patch.py** - AlmaLinux 9 patch
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/installCyberPanel_almalinux9_patch.py | python3
  ```

## 🔧 Installation Methods

### Method 1: Direct Download and Execute

```bash
# Download and run immediately
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/[script-path] | bash
```

### Method 2: Download First, Then Execute

```bash
# Download the script
wget https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/[script-path]

# Make it executable
chmod +x [script-name]

# Run the script
./[script-name]
```

### Method 3: Clone Repository

```bash
# Clone the entire repository
git clone https://github.com/master3395/cyberpanel-mods.git

# Navigate to the directory
cd cyberpanel-mods

# Run scripts from the repository
./[category]/[script-name]
```

## ⚠️ Important Notes

### Before Installation

1. **Always backup your system** before running any scripts
2. **Test in a non-production environment** first
3. **Read the documentation** for each script
4. **Check OS compatibility** before installation
5. **Ensure CyberPanel is installed** and running

### During Installation

1. **Run as root user** - Most scripts require root privileges
2. **Monitor the output** - Watch for any error messages
3. **Don't interrupt** - Let scripts complete their operations
4. **Check logs** - Review log files if issues occur

### After Installation

1. **Verify functionality** - Test the features you installed
2. **Check services** - Ensure all services are running
3. **Review logs** - Check for any warnings or errors
4. **Update documentation** - Keep track of what you've installed

## 🐛 Troubleshooting

### Common Issues

#### Permission Denied
```bash
# Ensure you're running as root
sudo su -

# Check file permissions
ls -la [script-name]
chmod +x [script-name]
```

#### CyberPanel Not Detected
```bash
# Check if CyberPanel is installed
ls -la /etc/cyberpanel/

# Check CyberPanel service
systemctl status lscpd
```

#### Package Manager Issues
```bash
# Update package lists
apt update  # Ubuntu/Debian
yum update  # RHEL-based
dnf update  # Modern RHEL-based

# Install required packages
apt install curl wget  # Ubuntu/Debian
yum install curl wget  # RHEL-based
```

#### Service Issues
```bash
# Restart CyberPanel services
systemctl restart lscpd
systemctl restart gunicorn

# Check service status
systemctl status lscpd
systemctl status gunicorn
```

### Log Files

Check these log files for troubleshooting:

- `/var/log/cyberpanel_mods_compatibility.log` - Compatibility checker logs
- `/var/log/cyberpanel_utility.log` - Utility script logs
- `/var/log/cyberpanel_core_fixes.log` - Core fixes logs
- `/var/log/cyberpanel_security.log` - Security script logs
- `/var/log/php_version_manager.log` - PHP version manager logs
- `/var/log/mariadb_version_manager.log` - MariaDB version manager logs

### Getting Help

1. **Check the logs** - Review relevant log files
2. **Run compatibility check** - Ensure your system is supported
3. **Check documentation** - Review the specific script documentation
4. **Open an issue** - Report bugs on GitHub
5. **Community support** - Ask questions in discussions

## 🔄 Updates

### Auto-Update Scripts

Some scripts support auto-update functionality:

```bash
# The enhanced utility can check for updates
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility_enhanced.sh | bash
```

### Manual Updates

To update scripts manually:

```bash
# Re-download and run the latest version
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/[script-path] | bash
```

## 📚 Next Steps

After installation:

1. **Read the documentation** - Explore the docs/ directory
2. **Configure security** - Run security hardening scripts
3. **Set up backups** - Configure automated backup systems
4. **Monitor performance** - Use monitoring tools
5. **Stay updated** - Keep scripts and CyberPanel updated

## 🤝 Contributing

Want to contribute to this project?

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Test on multiple OS versions**
5. **Submit a pull request**

See our [Contributing Guide](CONTRIBUTING.md) for more details.

---

**Need help?** Check our [Troubleshooting Guide](troubleshooting-guide.md) or [open an issue](https://github.com/master3395/cyberpanel-mods/issues).
