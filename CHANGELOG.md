# 📋 CyberPanel Mods - Changelog

## 🔧 Version 2.4.0 - Rebuild LSCP / WebAdmin (21.07.2026)

### ✨ New Mod: `core-fixes/rebuild_lscp_webadmin.sh`

Restores CyberPanel WebAdmin (`lscpd` / LSCP) when `/usr/local/lscp/conf` is
missing or corrupted, without a full reinstall. Addresses upstream
[usmannasir/cyberpanel#1839](https://github.com/usmannasir/cyberpanel/issues/1839).

#### 🐛 Issues Addressed
- Panel `:8090` (or custom bind.conf port) down after a bad repair
- Missing `/usr/local/lscp/conf` while sites, OLS, and MariaDB still work
- Full `install.sh` aborting on existing `ftpgroup` / `ftpuser` (wrong path)

#### 🔧 What It Does
- Uses local `CyberCP/install/lscp.tar.gz` when present, else downloads from
  `usmannasir/cyberpanel` (version-matched, fallback `v2.4.8`) with HTTP checks
- Timestamped backup of any existing `/usr/local/lscp` before extract
- Restores conf, certs, `pythonenv.conf`, and the matching `lscpd` binary
  (Ubuntu 22/24/26 → `lscpd.0.4.0`)
- Restarts `lscpd` and verifies listen + HTTPS probe
- Does **not** touch websites, MariaDB, or OLS vhosts

#### 📍 Access
- Master menu: Core Fixes → option 9
- One-liner:
  `curl -fsSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/rebuild_lscp_webadmin.sh | bash`
- Guide: `guides/REBUILD_LSCP_WEBADMIN.md`

---

## 📧 Version 2.3.1 - SnappyMail Data Path/Permissions Fix (13.07.2026)

### ✨ New Mod: `email-fixes/snappymail_data_path_fix.sh`

- Repairs SnappyMail upgrades where `public/snappymail/include.php` still points
  at the legacy RainLoop data folder.
- Recreates the expected SnappyMail data directory structure.
- Fixes `lscpd:lscpd` ownership and write permissions on SnappyMail/RainLoop
  data directories.
- Restarts the CyberPanel web service when present.
- Added to the master menu under Email Fixes.

---


## 🛡️ Version 2.3.0 - ImunifyAV/360 + OpenLiteSpeed Integration Fix (29.06.2026)

### ✨ New Mod: `core-fixes/imunify_ols_integration_fix.sh`

A single, self-contained, idempotent fix for the most common ImunifyAV/Imunify360
and OpenLiteSpeed panel problems on CyberPanel. Runnable directly from this repo
or via the master menu (Core Fixes → option 8).

#### 🐛 Issues Addressed
- **ImunifyAV UI shows no users / no scan history** (upstream issue #1825) —
  `integration.conf` was missing the `[integration_scripts]` hooks
  (`users`, `domains`, `panel_info`, …) that feed CyberPanel data to Imunify.
- **Cannot install ImunifyAV after upgrade/uninstall** (upstream issue #1826) —
  manual `imav-deploy.sh` aborts with `PANEL=` because `integration.conf` must
  exist (generic-panel detection) **before** the deploy script runs.
- **`cat: /home/cyberpanel/switchLSWSStatus: No such file`** — the install
  progress status file did not exist, breaking the UI progress polling.
- **Broken/blank panel assets on OpenLiteSpeed** — `:8090` vhost served
  `/static/` from the wrong path and lacked lsphp contexts for `/imunifyav/`
  and `/imunify/`.
- **CSRF 403 on every panel POST behind the OLS reverse proxy** — duplicated
  `Origin` header; ensures the `OriginDedupe` middleware is present/registered.

#### 🔧 What It Does (all idempotent, with timestamped backups)
- Creates `/home/cyberpanel/switchLSWSStatus` with correct ownership.
- Writes a complete `integration.conf` (AV or 360, auto-detected) wired to the
  CyberPanel `CLScript/*.py` helpers, and makes those scripts executable.
- Rewrites the CyberPanel OLS panel vhost: `/static/` → `public/static/`, plus
  `/phpmyadmin/`, `/snappymail/`, `/imunifyav/`, `/imunify/` lsphp contexts
  (in-place `/static/` patch only when a custom vhost is detected).
- Installs/registers `OriginDedupeMiddleware` before `CsrfViewMiddleware`.
- Restarts `cyberpanel` + OpenLiteSpeed only when something changed, reloads the
  Imunify agent if installed, and prints a verification summary.

#### ✅ Compatibility
AlmaLinux 8/9/10, RockyLinux 8/9, RHEL 8/9, CentOS 7/9, CloudLinux 7/8,
Ubuntu 20.04–24.04. Skips the OLS vhost step gracefully on LiteSpeed Enterprise
or non-OLS servers.

---

## 🚀 Version 2.2.1 - Master Menu POSIX Shell Fix (29/06/2026)

### 🐛 Bug Fixes

#### Master menu (`cyberpanel-mods-menu.sh`)
- **Fixed** `Syntax error: Bad for loop variable` when running via `sh <(curl ...)` on AlmaLinux/RHEL (bash POSIX mode)
- Replaced bash-only C-style `for ((...))` padding loop with a POSIX `while` loop in `print_menu_item`

---

## 🚀 Version 2.2.0 - Documentation Reorganization & README Optimization (12.10.2025)

### ✨ Major Features

#### 📚 Complete Documentation Restructure
- **README.md ultra-streamlined** from 578 lines to 124 lines (-79% reduction)
- **All detailed commands** moved to appropriate guides in `guides/` folder
- **Quick Guide Reference** tables added for easy navigation
- **Clean hub structure** - README as overview, guides for details

#### 🗂️ New Documentation Files
```
guides/
├── README_REORGANIZATION.md        # Technical reorganization details
└── README.md                       # Updated with reorganization note

to-do/
├── README_REORGANIZATION_SUMMARY.md    # Executive summary
└── README_STRUCTURE_COMPARISON.md      # Before/after comparison
```

### 📊 Documentation Improvements

#### 🎯 README.md Optimization
**Removed sections** (moved to guides):
- ❌ Detailed OS compatibility list (20+ lines)
- ❌ Complete repository structure tree (85+ lines)
- ❌ Master Menu System details (20+ lines)
- ❌ User & Website Management details (20+ lines)
- ❌ Available Mods & Fixes details (25+ lines)
- ❌ Version Managers details (20+ lines)
- ❌ Security & Utilities details (20+ lines)
- ❌ Backup & Restore details (10+ lines)
- ❌ OS-Specific Fixes details (10+ lines)

**Kept in README** (essentials only):
- ✅ Header with quick navigation links
- ✅ Features overview
- ✅ Quick Start with master menu
- ✅ 3 essential quick access commands
- ✅ Documentation section with organized guide links
- ✅ Requirements and important notes
- ✅ Quick Guide Reference tables
- ✅ Contributing and support information

#### 📖 Enhanced Navigation
- **Quick navigation bar** at top with links to key guides
- **Quick Guide Reference** section with comprehensive tables
- **Essential Guides table** - 5 most important guides
- **Technical Guides table** - 7 advanced topic guides
- **Direct links** throughout to appropriate guides

### 🔧 Technical Improvements

#### 📏 File Size Metrics
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| README.md lines | 578 | 124 | -79% |
| Commands in README | 40+ | 3 | -92% |
| Guide references | 8 | 25+ | +213% |
| Detail sections | 15 | 0 | -100% |

#### 🗂️ Information Architecture
**Previous structure** (Linear):
- All information in one 578-line file
- Mixed overview and detailed commands
- Difficult navigation and overwhelming

**New structure** (Hub & Spoke):
- README as central hub (124 lines)
- Guides folder with detailed information
- Clear navigation with direct links
- Easy to find specific information

#### 📚 Guide Organization
**All commands now in guides:**
- `installation-guide.md` - All installation commands
- `troubleshooting-guide.md` - All troubleshooting commands
- `security-best-practices.md` - All security commands
- `os-specific-notes.md` - All OS-specific commands
- `menu-demo.md` - Menu system details

### 🎨 User Experience Enhancements

#### 👥 For New Users
- ✅ No longer overwhelming (79% shorter)
- ✅ Clear starting point with Quick Start
- ✅ Immediate access to 3 essential commands
- ✅ Guide links clearly marked with 📖

#### 👨‍💻 For Experienced Users
- ✅ Quick Guide Reference tables for fast navigation
- ✅ Direct links to specific guides
- ✅ Better organized information
- ✅ Faster access to what they need

#### 🛠️ For Maintainers
- ✅ Update guides, not README
- ✅ Clear structure for adding features
- ✅ Scalable (add guides without cluttering README)
- ✅ Separated concerns (overview vs details)

### 📝 Documentation Updates

#### 🆕 New Documentation Files
1. **README_REORGANIZATION.md** (guides/)
   - Complete technical documentation
   - Detailed section-by-section changes
   - Maintenance guidelines
   - Migration notes

2. **README_REORGANIZATION_SUMMARY.md** (to-do/)
   - Executive summary of changes
   - Statistics and metrics
   - Navigation map
   - Success metrics

3. **README_STRUCTURE_COMPARISON.md** (to-do/)
   - Visual before/after comparison
   - Section-by-section analysis
   - Information flow improvements
   - User experience benefits

#### 📖 Updated Documentation
- **README.md** - Reorganized and streamlined
- **guides/README.md** - Added reorganization note
- **All guides preserved** - No information lost

### 🔄 Migration Guide

#### 📍 Where to Find Things Now

**In README.md** (Quick Access):
- Project overview and features
- Master menu command
- 3 essential commands only
- Quick Guide Reference tables
- Basic information

**In guides/ folder** (Detailed Info):
- All installation commands
- All troubleshooting steps
- All security commands
- All OS-specific information
- All technical details

### 🎯 Key Improvements

#### 📊 Metrics Summary
- **79% reduction** in README length
- **92% reduction** in commands in README
- **213% increase** in guide references
- **100% information preservation**

#### 🌟 Benefits Summary
- **Easier onboarding** for new users
- **Faster navigation** for experienced users
- **Cleaner structure** for maintainability
- **Better scalability** for future growth

### 🐛 Bug Fixes

#### 📝 Documentation Fixes
- Fixed markdown linting issues
- Added proper code block language specifications
- Fixed table formatting for better readability
- Corrected link references

### 📋 Structure Changes

#### ❌ Removed from README
- Detailed OS compatibility lists
- Full repository structure trees
- Extensive feature descriptions
- Multiple command examples
- Redundant section details

#### ✅ Added to README
- Quick navigation bar at top
- Quick Guide Reference section
- Essential Guides table
- Technical Guides table
- Enhanced footer with quick links

### 🎯 Future Improvements

#### 📝 Recommended Next Steps
- Add screenshots to menu-demo.md
- Create FAQ guide
- Add more cross-links between guides
- Consider command cheatsheet
- Video tutorials (optional)

---

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
- **Total Scripts**: 55+ enhanced scripts
- **Supported OS**: 12+ operating systems
- **Documentation**: 28+ comprehensive guides (added 3 reorganization docs)
- **Security Features**: 15+ security enhancements
- **Version Managers**: 8+ version management tools
- **User Functions**: 39 comprehensive user-facing operations
- **Interface Options**: 3 access methods (main menu, simplified, full CLI)
- **README Size**: 124 lines (79% reduction from original)

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

## 📝 Version History Summary

- **Version 2.2.0** (12.10.2025) - Documentation reorganization with 79% README reduction
- **Version 2.1.0** (21.09.2025) - User management integration with 39 functions
- **Version 2.0.1** (12.09.2025) - Email fixes and Sieve integration
- **Version 2.0.0** (12.01.2025) - Complete repository overhaul with cross-platform support

**The CyberPanel Mods repository provides enterprise-grade functionality with comprehensive cross-platform compatibility, extensive documentation, and a streamlined user experience.**
