# 🚀 CyberPanel Mods - Enhanced Repository

[![OS Support](https://img.shields.io/badge/OS-Ubuntu%2020.04--24.04%20%7C%20AlmaLinux%208--10%20%7C%20RockyLinux%208--9%20%7C%20RHEL%208--9%20%7C%20CentOS%207--9%20%7C%20CloudLinux%207--8-blue)](https://cyberpanel.net)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/master3395/cyberpanel-mods)

> **The most comprehensive collection of CyberPanel modifications, fixes, and utilities with full cross-platform compatibility**

## 🌟 Features

- 🎯 **Master Menu Interface** - Interactive menu system for easy access to all mods
- ✅ **Full OS Compatibility** - Works on all CyberPanel-supported operating systems
- 🔧 **Enhanced Scripts** - Improved error handling, logging, and user experience
- 📚 **Comprehensive Documentation** - Detailed guides and examples
- 🛡️ **Security Focused** - All scripts follow security best practices
- 🔄 **Auto-Update Support** - Scripts can check and update themselves
- 📊 **Detailed Logging** - All operations are logged for troubleshooting
- 🖥️ **System Monitoring** - Built-in system status and information display

## 🌐 Supported Operating Systems

### ✅ Currently Supported
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

### 🔧 Third-Party OS Support
- **Debian** - Community-supported with limited testing
- **openEuler** - Community-supported with limited testing
- **Other RHEL derivatives** - May work with AlmaLinux/RockyLinux packages

## 📁 Repository Structure

```
cyberpanel-mods/
├── 📁 backup-restore/           # Backup and restore tools
│   ├── cyberpanel.sql
│   ├── rclone_backup_cronjob.sh
│   ├── rclone_sqlbackup_cronjob.sh
│   └── restore_cyberpanel_database.sh
│
├── 📁 core-fixes/              # Core CyberPanel fixes and repairs
│   ├── cyberpanel_core_fixes_enhanced.sh
│   ├── cyberpanel_fix_symbolic_links.sh
│   ├── fix_503_service_unavailable.sh
│   ├── fix_missing_wp_cli.sh
│   └── fixperms.sh
│
├── 📁 docs/                    # Comprehensive documentation
│   ├── installation-guide.md
│   ├── menu-demo.md
│   ├── os-specific-notes.md
│   ├── README.md
│   ├── security-best-practices.md
│   └── troubleshooting-guide.md
│
├── 📁 images/                  # Screenshots and documentation images
│   └── (ready for images)
│
├── 📁 os-specific/             # OS-specific fixes and optimizations
│   ├── cyberpanel_almalinux9_upgrade_fix.sh
│   └── installCyberPanel_almalinux9_patch.py
│
├── 📁 security/                # Security-related scripts
│   ├── cp_permissions.txt
│   ├── cyberpanel_security_enhanced.sh
│   ├── disable_2fa.sh
│   ├── fix_permissions.sh
│   ├── fix_ssl_missing_context.sh
│   ├── reset_ols_adminpassword
│   └── selfsigned_fixer.sh
│
├── 📁 utilities/               # General utility scripts
│   ├── cloudflare_to_powerdns.sh
│   ├── crowdsec_update.sh
│   ├── cyberpanel_sessions_cronjob.sh
│   ├── cyberpanel_sessions.sh
│   ├── cyberpanel_utility_enhanced.sh
│   ├── cyberpanel_utility.sh
│   ├── defaultwebsitepage.html
│   ├── defaultwebsitepage.sh
│   ├── install_pureftpd.sh
│   ├── install_vsftpd.sh
│   ├── loader-wizard.php
│   ├── lsmcd
│   ├── os_compatibility_checker.sh
│   └── wp
│
├── 📁 version-managers/        # Version management tools
│   ├── mariadb_v_changer.sh
│   ├── mariadb_version_manager_enhanced.sh
│   ├── modsec_rules_v_changer.sh
│   ├── php_version_manager_enhanced.sh
│   ├── phpmod_v2.sh
│   ├── phpmod.sh
│   ├── phpmyadmin_v_changer.sh
│   └── snappymail_v_changer.sh
│
├── 📄 CHANGELOG.md             # Version history and changes
├── 📄 cyberpanel-mods-menu.sh  # Master menu system
├── 📄 launch.sh                # Simple launcher script
├── 📄 ORGANIZATION.md          # Complete file organization guide
└── 📄 README.md                # Main documentation
```

## 🚀 Quick Start

### 🎯 Master Menu (Recommended)
The easiest way to use all CyberPanel mods is through our interactive master menu:

```bash
# Download and run the master menu
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh | bash
```

The master menu provides:
- 🎯 **Interactive interface** for all mods and utilities
- 🔍 **System status** and compatibility checking
- 🛠️ **One-click access** to all enhanced scripts
- 📚 **Built-in documentation** viewer
- 🔄 **Auto-update** functionality
- 📊 **System information** display

### Alternative: Individual Scripts

#### 1. OS Compatibility Check
Before using any mods, check your system compatibility:

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash
```

#### 2. Enhanced CyberPanel Utility
Use the enhanced utility script for common tasks:

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility_enhanced.sh | bash
```

#### 3. Core Fixes
Fix common CyberPanel issues:

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash
```

## 🎯 Master Menu System

### 🖥️ Interactive Master Menu
The CyberPanel Mods Master Menu provides a beautiful, user-friendly interface to access all mods and utilities:

```bash
# Launch the master menu
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh | bash
```

### ✨ Menu Features
- **🎨 Beautiful Interface** - Color-coded, professional-looking menu system
- **📊 System Status** - Real-time system health monitoring
- **🔍 OS Detection** - Automatic operating system detection and compatibility
- **🛠️ One-Click Access** - Direct access to all enhanced scripts
- **📚 Built-in Documentation** - View documentation without leaving the menu
- **🔄 Auto-Update** - Update the menu script itself
- **ℹ️ System Information** - Detailed system information display
- **⏸️ Pause Function** - Easy navigation with pause between operations

### 📋 Menu Options
1. **🔍 OS Compatibility Check** - Verify system compatibility
2. **🛠️ Enhanced CyberPanel Utility** - All-in-one utility tool
3. **🔧 Core Fixes & Repairs** - Fix common CyberPanel issues
4. **🛡️ Security Hardening** - Comprehensive security setup
5. **🐘 PHP Version Manager** - Manage PHP versions (7.1-8.4)
6. **🗄️ MariaDB Version Manager** - Manage MariaDB versions (10.3-11.4)
7. **📦 Application Version Managers** - Manage Snappymail, phpMyAdmin, ModSecurity
8. **💾 Backup & Restore Tools** - Automated backup and restore
9. **🖥️ OS-Specific Fixes** - Fixes for specific operating systems
10. **📚 Documentation** - View all documentation
11. **ℹ️ System Information** - Detailed system status
12. **🔄 Update Menu Script** - Update to latest version
13. **❌ Exit** - Exit the menu

### 🚀 Quick Commands
```bash
# Show help
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh | bash -- --help

# Show system status only
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh | bash -- --status

# Update menu script
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh | bash -- --update
```

## 📚 Core Fixes

### 🔧 CyberPanel Core Fixes Enhanced
Comprehensive fix for common CyberPanel issues across all supported OS versions.

**Features:**
- Fixes symbolic links
- Corrects file permissions
- Resolves SSL context issues
- Fixes service problems
- Database connectivity fixes
- Python environment repairs
- 503 error resolution
- WP-CLI installation
- Self-signed certificate fixes

**Usage:**
```bash
# Run all fixes
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash

# Run specific fixes
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash -- --symbolic-links --permissions
```

## 🔄 Version Managers

### 🐘 PHP Version Manager Enhanced
Advanced PHP version management with full OS compatibility.

**Features:**
- Install/switch between PHP versions (7.1-8.4)
- Interactive and command-line modes
- Automatic dependency resolution
- Service restart handling
- Version status checking
- Uninstall functionality

**Usage:**
```bash
# Interactive mode
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/php_version_manager_enhanced.sh | bash

# Direct version change
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/php_version_manager_enhanced.sh | bash 81

# Check status
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/php_version_manager_enhanced.sh | bash -- --status
```

### 🗄️ MariaDB Version Manager Enhanced
Comprehensive MariaDB version management with backup support.

**Features:**
- Install/upgrade MariaDB versions (10.3-11.4)
- Automatic data backup before changes
- Service management
- Security configuration
- Connection testing
- Rollback support

**Usage:**
```bash
# Interactive mode
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/mariadb_version_manager_enhanced.sh | bash

# Install specific version
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/mariadb_version_manager_enhanced.sh | bash 10.11

# Check status
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/mariadb_version_manager_enhanced.sh | bash -- --status
```

## 🛡️ Security Scripts

### 🔐 Disable 2FA
Remove two-factor authentication when access is lost.

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/disable_2fa.sh | bash
```

### 🔒 Fix SSL Context
Fix missing acme-challenge context for SSL certificates.

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix_ssl_missing_context.sh | bash
```

### 🛠️ Fix Permissions
Restore correct CyberPanel file permissions.

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix_permissions.sh | bash
```

## 🔧 Utilities

### 🖥️ Enhanced CyberPanel Utility
All-in-one utility for CyberPanel management.

**Features:**
- CyberPanel upgrades
- Addon management (Redis, Memcached, PHP extensions)
- WatchDog management
- FAQ and help system
- OS compatibility detection
- Enhanced error handling

**Usage:**
```bash
# Interactive mode
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility_enhanced.sh | bash

# Direct upgrade
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility_enhanced.sh | bash upgrade
```

### 🔍 OS Compatibility Checker
Comprehensive system compatibility verification.

**Features:**
- OS detection and validation
- Package manager detection
- System requirements check
- Service availability check
- Compatibility recommendations
- Detailed reporting

**Usage:**
```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash
```

## 📦 Version Management

### 📧 Snappymail Version Changer
Update Snappymail to specific versions.

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/snappymail_v_changer.sh | bash
```

### 🗂️ phpMyAdmin Version Changer
Update phpMyAdmin to specific versions.

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/phpmyadmin_v_changer.sh | bash
```

### 🔥 ModSecurity Rules Changer
Update OWASP ModSecurity rules to specific versions.

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/modsec_rules_v_changer.sh | bash
```

## 🔄 Backup & Restore

### 💾 RClone Backup Cronjob
Automated backup using RClone.

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/rclone_backup_cronjob.sh | bash
```

### 🗄️ SQL Backup Cronjob
Automated SQL database backup.

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/rclone_sqlbackup_cronjob.sh | bash
```

### 🔄 Restore CyberPanel Database
Restore CyberPanel core database.

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/restore_cyberpanel_database.sh | bash
```

## 🖥️ OS-Specific Fixes

### 🐧 AlmaLinux 9 Upgrade Fix
Fix MariaDB issues during CyberPanel upgrade on AlmaLinux 9.

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/cyberpanel_almalinux9_upgrade_fix.sh | bash
```

### 🔧 AlmaLinux 9 Patch
Python patch for installCyberPanel.py on AlmaLinux 9.

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/installCyberPanel_almalinux9_patch.py | python3
```

## 📖 Documentation

### 📚 User Guides
- [Installation Guide](docs/installation-guide.md)
- [Troubleshooting Guide](docs/troubleshooting-guide.md)
- [Security Best Practices](docs/security-best-practices.md)
- [OS-Specific Notes](docs/os-specific-notes.md)

### 🖼️ Screenshots
- [PHP Version Manager](images/php-version-manager.png)
- [MariaDB Version Manager](images/mariadb-version-manager.png)
- [OS Compatibility Checker](images/os-compatibility-checker.png)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### 🐛 Reporting Issues
If you find a bug or have a feature request, please [open an issue](https://github.com/master3395/cyberpanel-mods/issues).

### 🔧 Development
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple OS versions
5. Submit a pull request

## 📋 Requirements

- Root access
- Internet connection
- CyberPanel installed
- Supported operating system

## ⚠️ Important Notes

- **Always backup your data** before running any scripts
- **Test in a non-production environment** first
- **Read the documentation** before using any script
- **Check OS compatibility** before installation

## 🔒 Security

All scripts follow security best practices:
- No hardcoded passwords
- Secure file permissions
- Input validation
- Error handling
- Logging for audit trails

## 📞 Support

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/master3395/cyberpanel-mods/issues)
- **Discussions**: [GitHub Discussions](https://github.com/master3395/cyberpanel-mods/discussions)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [CyberPanel Team](https://cyberpanel.net) for the amazing control panel
- [Contributors](https://github.com/master3395/cyberpanel-mods/graphs/contributors) who help improve this project
- Community members who report issues and suggest improvements

---

<div align="center">

**⭐ Star this repository if you find it helpful! ⭐**

[![GitHub stars](https://img.shields.io/github/stars/master3395/cyberpanel-mods?style=social)](https://github.com/master3395/cyberpanel-mods)
[![GitHub forks](https://img.shields.io/github/forks/master3395/cyberpanel-mods?style=social)](https://github.com/master3395/cyberpanel-mods)

</div>