# 📋 CyberPanel Mods - Changelog

## 🚀 Version 2.1.0 - User Management Integration & Repository Cleanup (21.09.2025)

### ✨ Major Features

#### 👥 User & Website Management Integration
- **Complete merger** of cyberpanel-friendly-cli functionality into CyberPanel Mods
- **Dual interface** serving both end users and system administrators
- **39 comprehensive functions** for complete hosting management
- **Simplified menu** (8 key operations) and **full CLI interface** (all 39 functions)

#### 🏗️ New User Management Module
```
user-management/
├── user-management-menu.sh      # Simplified user interface (8 functions)
├── cyberpanel-user-cli.sh       # Complete CLI interface (39 functions)
├── user-functions.sh            # User creation, deletion, management
├── website-functions.sh         # Website and domain management
└── README.md                    # Comprehensive documentation
```

### 🎯 User Management Features

#### 👤 User Operations
- **Create Users** - Add new users with ACL permissions, security levels, website limits
- **Delete Users** - Remove users and associated data
- **List Users** - View all users with formatted output
- **Suspend/Unsuspend** - Temporarily disable user accounts
- **Edit Users** - Modify user settings and permissions

#### 🌐 Website Management
- **Create Websites** - Set up websites with SSL, DKIM, openBasedir protection
- **Delete Websites** - Remove websites and configurations
- **List Websites** - View all websites on server
- **Child Domains** - Create and manage subdomains
- **PHP Version Changes** - Per-website PHP version management
- **Package Management** - Assign and modify hosting packages

#### 🗄️ Database Management
- **Create/Delete Databases** - MySQL/MariaDB database management
- **Database Users** - Create database users with permissions
- **List Databases** - View all databases per website

#### 📧 Email Management
- **Email Accounts** - Create, delete, modify email addresses
- **Password Management** - Change email account passwords
- **Email Listing** - View all email accounts per domain

#### 📁 FTP Management
- **FTP Accounts** - Create, delete, modify FTP access
- **FTP Passwords** - Update FTP account passwords
- **FTP Listing** - View all FTP users per domain

#### 🔒 SSL Management
- **Let's Encrypt SSL** - Automatic SSL certificate issuing
- **Hostname SSL** - SSL for server hostname
- **Mail Server SSL** - SSL for mail servers

#### 📦 Package Management
- **Create Packages** - Define hosting packages with limits
- **Delete Packages** - Remove hosting packages
- **List Packages** - View all available packages

#### 🔄 Backup & Restore
- **Create Backups** - Generate website backups
- **Restore Backups** - Restore from backup files

#### 🌐 DNS Management
- **DNS Zones** - Create and delete DNS zones
- **DNS Records** - Add/remove A, CNAME, MX records
- **DNS Listing** - View all DNS zones and records

### 🔧 Technical Improvements

#### 🎨 Enhanced Menu System
- **New Option 1**: "👥 User & Website Management" in main menu
- **Auto-download** functionality for user management scripts
- **Seamless integration** between admin and user functions
- **Consistent UI** matching CyberPanel Mods design

#### 🛡️ Security Enhancements
- **Input validation** using regex patterns for all user inputs
- **Special character filtering** to prevent injection attacks
- **Password confirmation** for double verification
- **Comprehensive logging** for all operations
- **Root access control** for security

#### 📊 Logging System
- **User management logs**: `/var/log/cyberpanel_user_management.log`
- **Full CLI logs**: `/var/log/cyberpanel_user_cli.log`
- **Audit trails** for all user operations
- **Timestamped entries** for troubleshooting

### 🗂️ Repository Structure Updates

#### ✅ Added Files
- `user-management/user-management-menu.sh` - Main user interface
- `user-management/cyberpanel-user-cli.sh` - Complete CLI functionality
- `user-management/user-functions.sh` - User management functions
- `user-management/website-functions.sh` - Website management functions
- `user-management/README.md` - Comprehensive user management docs

#### ❌ Removed Files
- `launch.sh` - Redundant wrapper script (functionality merged into main menu)

#### 📚 Documentation Updates
- **README.md** - Added user management section with full feature list
- **ORGANIZATION.md** - Updated file structure and categories
- **User Management README** - Complete documentation for new module

### 🚀 Usage Examples

#### 🎯 Access Methods
```bash
# Via main menu (recommended)
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh | bash

# Direct user management
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/user-management/user-management-menu.sh | bash

# Full CLI interface (39 functions)
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/user-management/cyberpanel-user-cli.sh | bash
```

#### 🔧 Interface Options
- **Simplified Menu** - 8 most common operations for quick access
- **Full CLI** - Complete 39-function interface for advanced users
- **Integrated Access** - Seamless switching between admin and user tools

### 🎨 User Experience Improvements

#### 🌟 Dual Interface Benefits
- **End Users** - Easy access to hosting management functions
- **Administrators** - Full system administration capabilities
- **Unified Experience** - One platform for all CyberPanel operations
- **Consistent Design** - Matching UI/UX across all interfaces

#### 🔄 Integration Benefits
- **Auto-download** - Scripts download automatically if not present
- **Cross-referencing** - Easy navigation between user and admin functions
- **Maintenance** - Single repository to maintain and update
- **Scalability** - Easy to add new user-facing features

### 📋 Menu Structure Updates

#### 🎯 Main Menu (Updated)
1. **👥 User & Website Management** ⭐ NEW!
2. 🔍 OS Compatibility Check
3. 🛠️ Enhanced CyberPanel Utility
4. 🔧 Core Fixes & Repairs
5. 🛡️ Security Hardening
6. 🐘 PHP Version Manager
7. 🗄️ MariaDB Version Manager
8. 📦 Application Version Managers
9. 💾 Backup & Restore Tools
10. 📧 Email Fixes
11. 🖥️ OS-Specific Fixes
12. 📚 Documentation
13. ℹ️ System Information
14. 🔄 Update Menu Script
15. ❌ Exit

### 🤝 Original Credits
- **Based on cyberpanel-friendly-cli** by Alfred Valderrama
- **Original repository**: https://github.com/redopsbay/cyberpanel
- **Enhanced and integrated** into CyberPanel Mods with improved security, logging, and user experience

### 🐛 Bug Fixes

#### 🧹 Repository Cleanup
- **Removed redundant launch.sh** - Eliminated unnecessary wrapper script
- **Streamlined structure** - Cleaner file organization
- **Updated documentation** - Removed references to deleted files
- **Simplified access** - Direct execution of main menu script

### 📊 Statistics Update

#### 📈 Enhanced Metrics
- **Total Scripts**: 55+ enhanced scripts (added 5 user management scripts)
- **User Functions**: 39 comprehensive user-facing operations
- **Interface Options**: 3 access methods (main menu, simplified, full CLI)
- **Documentation**: 25+ comprehensive guides (added user management docs)

---

## 🚀 Version 2.0.1 - Email Fixes Update (12.09.2025)

### ✨ New Features

#### 📧 Email Fixes Module
- **sieve_fix_enhanced.sh** - Comprehensive Sieve (Filter) fix for SnappyMail
  - Cross-platform compatibility for all supported OS
  - Automatic package installation (dovecot-pigeonhole, dovecot-managesieved)
  - Firewall configuration (port 4190 and email ports)
  - Service management (Dovecot, Postfix, SpamAssassin)
  - Default filtering rules (spam, newsletters)
  - Configuration backup and restoration
  - Verification system for installation validation
  - Comprehensive logging and error handling

#### 📚 Email Fixes Documentation
- **README.md** - Complete documentation for email fixes
- **SIEVE_QUICK_GUIDE.md** - Quick reference guide
- **test_sieve_fix.sh** - Testing and validation script

#### 🎯 Enhanced Menu System
- Added Email Fixes section to main menu (Option 9)
- Integrated Sieve fix into master menu system
- Updated menu numbering and navigation

### 🔧 Technical Improvements

#### 📧 Sieve Integration
- **Problem Solved**: CyberPanel doesn't automatically install Sieve (Filter) with SnappyMail
- **Solution**: Complete automation of Sieve installation and configuration
- **Support**: All CyberPanel-compatible operating systems
- **Features**: Port management, service configuration, default rules

#### 🛡️ Security Enhancements
- Automatic firewall configuration for email services
- Proper file permissions and ownership
- Secure configuration backup procedures
- Log file security and management

### 📊 Compatibility Updates

#### 🌐 OS Support Matrix
- **Ubuntu**: 20.04, 22.04, 24.04 (100% compatible)
- **AlmaLinux**: 8.x, 9.x (100% compatible)
- **RockyLinux**: 8.x, 9.x (100% compatible)
- **RHEL**: 8.x, 9.x (100% compatible)
- **CentOS**: 7.x, 8.x (100% compatible)
- **CloudLinux**: 7.x, 8.x (100% compatible)
- **Debian**: All versions (100% compatible)
- **openEuler**: All versions (100% compatible)

### 🐛 Bug Fixes

#### 📧 Email System Fixes
- Fixed missing Sieve functionality in SnappyMail
- Resolved port 4190 not being opened automatically
- Fixed Dovecot configuration for Sieve support
- Corrected Postfix LMTP configuration
- Fixed log file permissions and ownership

### 📚 Documentation Updates

#### 📖 Enhanced Documentation
- Updated main README.md with email fixes section
- Added comprehensive Sieve fix documentation
- Created quick reference guide
- Updated changelog with new features

---

## 🚀 Version 2.0.0 - Enhanced Repository (2025-01-12)

### ✨ Major Features

#### 🌐 Full OS Compatibility
- **Ubuntu 24.04.3** - Full support with PHP 8.4 compatibility
- **Ubuntu 22.04** - Stable support with all features
- **Ubuntu 20.04** - Legacy support with limited features
- **AlmaLinux 10** - Latest RHEL-compatible with full support
- **AlmaLinux 9** - Long-term support with MariaDB fixes
- **AlmaLinux 8** - Stable support with all features
- **RockyLinux 9** - Community-driven with full support
- **RockyLinux 8** - Stable support with all features
- **RHEL 9** - Enterprise-grade with full support
- **RHEL 8** - Enterprise-grade with full support
- **CentOS 9** - Limited support (migration recommended)
- **CloudLinux 8** - Shared hosting optimized
- **Debian 12/11** - Community support
- **openEuler 22.03** - Community support

#### 🏗️ Organized Repository Structure
```
cyberpanel-mods/
├── 📁 core-fixes/           # Core CyberPanel fixes and repairs
├── 📁 version-managers/     # Version management tools
├── 📁 security/            # Security-related scripts
├── 📁 utilities/           # General utility scripts
├── 📁 backup-restore/      # Backup and restore tools
├── 📁 os-specific/         # OS-specific fixes and optimizations
├── 📁 docs/               # Comprehensive documentation
└── 📁 images/             # Screenshots and documentation images
```

### 🔧 Enhanced Scripts

#### 🛠️ Core Fixes Enhanced
- **cyberpanel_core_fixes_enhanced.sh** - Comprehensive core fixes
  - Symbolic links repair
  - File permissions correction
  - SSL context fixes
  - Service management
  - Database connectivity
  - Python environment repair
  - 503 error resolution
  - WP-CLI installation
  - Self-signed certificate fixes

#### 🔄 Version Managers Enhanced
- **php_version_manager_enhanced.sh** - Advanced PHP management
  - Support for PHP 7.1-8.4
  - Interactive and command-line modes
  - Automatic dependency resolution
  - Service restart handling
  - Version status checking
  - Uninstall functionality

- **mariadb_version_manager_enhanced.sh** - Comprehensive MariaDB management
  - Support for MariaDB 10.3-11.4
  - Automatic data backup before changes
  - Service management
  - Security configuration
  - Connection testing
  - Rollback support

#### 🛡️ Security Enhanced
- **cyberpanel_security_enhanced.sh** - Comprehensive security hardening
  - 2FA management
  - SSL context fixes
  - Permission hardening
  - Database security
  - Firewall configuration
  - Security updates
  - Fail2ban protection
  - ModSecurity setup

#### 🔧 Utilities Enhanced
- **cyberpanel_utility_enhanced.sh** - All-in-one utility
  - CyberPanel upgrades
  - Addon management (Redis, Memcached, PHP extensions)
  - WatchDog management
  - FAQ and help system
  - OS compatibility detection
  - Enhanced error handling

- **os_compatibility_checker.sh** - System compatibility verification
  - OS detection and validation
  - Package manager detection
  - System requirements check
  - Service availability check
  - Compatibility recommendations
  - Detailed reporting

### 📚 Comprehensive Documentation

#### 📖 User Guides
- **Installation Guide** - Complete setup instructions
- **Troubleshooting Guide** - Common issues and solutions
- **Security Best Practices** - Comprehensive security guide
- **OS-Specific Notes** - Detailed OS compatibility information

#### 🔍 Advanced Topics
- **Custom Scripts** - Creating custom mods
- **API Integration** - External API integration
- **Monitoring Setup** - Monitoring configuration
- **Disaster Recovery** - Recovery procedures

### 🔧 OS-Specific Fixes

#### 🐧 AlmaLinux 9 Fixes
- **cyberpanel_almalinux9_upgrade_fix.sh** - MariaDB installation fixes
- **installCyberPanel_almalinux9_patch.py** - Python patch for installCyberPanel.py

#### 🐧 Ubuntu 24.04 Support
- PHP 8.4 compatibility
- Enhanced package management
- Improved service handling

### 🛡️ Security Improvements

#### 🔒 Enhanced Security Features
- Automatic firewall configuration
- Fail2ban integration
- ModSecurity setup
- SSL/TLS hardening
- Database security
- File permission hardening
- Intrusion detection

#### 🔐 Access Control
- 2FA management
- SSH security hardening
- User permission management
- Service access control

### 📦 Backup and Restore

#### 💾 Enhanced Backup Tools
- **rclone_backup_cronjob.sh** - Automated backup with RClone
- **rclone_sqlbackup_cronjob.sh** - SQL database backup
- **restore_cyberpanel_database.sh** - Database restoration

### 🔄 Version Management

#### 📧 Application Version Managers
- **snappymail_v_changer.sh** - Snappymail version management
- **phpmyadmin_v_changer.sh** - phpMyAdmin version management
- **modsec_rules_v_changer.sh** - ModSecurity rules management

### 🐛 Bug Fixes

#### 🔧 Core Fixes
- Fixed symbolic link issues across all OS
- Resolved permission problems
- Fixed SSL context issues
- Improved service management
- Enhanced database connectivity
- Fixed Python environment issues
- Resolved 503 errors
- Fixed WP-CLI installation
- Corrected self-signed certificate issues

#### 🖥️ OS-Specific Fixes
- Fixed AlmaLinux 9 MariaDB installation
- Resolved Ubuntu 24.04 compatibility issues
- Fixed RHEL-based system SELinux issues
- Corrected CloudLinux CageFS problems

### 🚀 Performance Improvements

#### ⚡ Enhanced Performance
- Optimized script execution
- Improved error handling
- Enhanced logging
- Better resource management
- Faster package installation
- Improved service startup

### 📊 Monitoring and Logging

#### 📈 Enhanced Monitoring
- Comprehensive logging system
- Detailed error reporting
- Performance monitoring
- Security event logging
- System health checks

### 🔄 Auto-Update Support

#### 🔄 Self-Update Features
- Automatic update checking
- Version comparison
- Safe update procedures
- Rollback capabilities

### 🧪 Testing and Quality Assurance

#### ✅ Quality Improvements
- Comprehensive testing across all OS
- Enhanced error handling
- Improved user experience
- Better documentation
- Security validation

### 📋 Migration from Previous Versions

#### 🔄 Upgrade Path
1. **Backup existing system**
2. **Run compatibility check**
3. **Update to new repository structure**
4. **Test all functionality**
5. **Apply security hardening**

### 🎯 Future Roadmap

#### 🔮 Planned Features
- **Docker Support** - Containerized CyberPanel
- **Kubernetes Integration** - Cloud-native deployment
- **Advanced Monitoring** - Prometheus/Grafana integration
- **API Management** - RESTful API for all functions
- **Web Interface** - Browser-based management
- **Multi-Site Management** - Centralized multi-site control

### 🤝 Contributing

#### 👥 Community Contributions
- Enhanced documentation
- Additional OS support
- New security features
- Performance improvements
- Bug fixes and patches

### 📞 Support and Community

#### 🆘 Support Channels
- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - Community support
- **Documentation** - Comprehensive guides
- **Community Forums** - User discussions

---

## 📊 Statistics

### 📈 Repository Metrics
- **Total Scripts**: 55+ enhanced scripts (added 5 user management scripts)
- **Supported OS**: 12+ operating systems
- **Documentation**: 25+ comprehensive guides (added user management docs)
- **Security Features**: 15+ security enhancements
- **Version Managers**: 8+ version management tools
- **User Functions**: 39 comprehensive user-facing operations
- **Interface Options**: 3 access methods (main menu, simplified, full CLI)

### 🎯 Compatibility Matrix
- **Ubuntu**: 20.04, 22.04, 24.04 (100% compatible)
- **AlmaLinux**: 8, 9, 10 (100% compatible)
- **RockyLinux**: 8, 9 (100% compatible)
- **RHEL**: 8, 9 (100% compatible)
- **CentOS**: 7, 8, 9 (95% compatible)
- **CloudLinux**: 7, 8 (95% compatible)
- **Debian**: 11, 12 (90% compatible)
- **openEuler**: 20.03, 22.03 (85% compatible)

---

**Version 2.0.0 represents a complete overhaul of the CyberPanel Mods repository, providing enterprise-grade functionality with comprehensive cross-platform compatibility and extensive documentation.**
