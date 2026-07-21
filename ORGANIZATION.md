# 📁 CyberPanel Mods - File Organization

## 🎯 Complete File Organization

All mods and utilities have been properly organized into logical categories for easy navigation and maintenance.

## 📂 Directory Structure

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
│   └── (empty - ready for images)
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
├── 📁 user-management/         # User and website management tools ⭐ NEW!
│   ├── cyberpanel-user-cli.sh
│   ├── user-functions.sh
│   ├── user-management-menu.sh
│   ├── website-functions.sh
│   └── README.md
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
├── 📄 ORGANIZATION.md          # Complete file organization guide
└── 📄 README.md                # Main documentation
```

## 📋 File Categories

### 🔧 Core Fixes (`core-fixes/`)
- **cyberpanel_core_fixes_enhanced.sh** - Comprehensive core fixes
- **cyberpanel_fix_symbolic_links.sh** - Fix symbolic links
- **fix_503_service_unavailable.sh** - Fix 503 errors
- **fix_missing_wp_cli.sh** - Install WP-CLI
- **fixperms.sh** - Fix file permissions
- **imunify_ols_integration_fix.sh** - ImunifyAV/360 + OLS panel integration
- **rebuild_lscp_webadmin.sh** - Rebuild LSCP / WebAdmin (issue #1839)

### 🔄 Version Managers (`version-managers/`)
- **php_version_manager_enhanced.sh** - Enhanced PHP version manager
- **phpmod.sh** - Original PHP version changer
- **phpmod_v2.sh** - PHP version changer v2
- **mariadb_version_manager_enhanced.sh** - Enhanced MariaDB version manager
- **mariadb_v_changer.sh** - Original MariaDB version changer
- **snappymail_v_changer.sh** - Snappymail version changer
- **phpmyadmin_v_changer.sh** - phpMyAdmin version changer
- **modsec_rules_v_changer.sh** - ModSecurity rules changer

### 🛡️ Security (`security/`)
- **cyberpanel_security_enhanced.sh** - Comprehensive security hardening
- **disable_2fa.sh** - Disable two-factor authentication
- **fix_permissions.sh** - Fix file permissions
- **fix_ssl_missing_context.sh** - Fix SSL context issues
- **reset_ols_adminpassword** - Reset OpenLiteSpeed admin password
- **selfsigned_fixer.sh** - Fix self-signed certificates
- **cp_permissions.txt** - CyberPanel permissions reference

### 👥 User Management (`user-management/`) ⭐ NEW!
- **user-management-menu.sh** - Simplified user management interface
- **cyberpanel-user-cli.sh** - Complete CLI interface (39 functions)
- **user-functions.sh** - User creation, deletion, and management functions
- **website-functions.sh** - Website and domain management functions
- **README.md** - User management documentation

### 🛠️ Utilities (`utilities/`)
- **cyberpanel_utility_enhanced.sh** - Enhanced CyberPanel utility
- **cyberpanel_utility.sh** - Original CyberPanel utility
- **os_compatibility_checker.sh** - OS compatibility checker
- **cloudflare_to_powerdns.sh** - DNS migration tool
- **crowdsec_update.sh** - CrowdSec updater
- **cyberpanel_sessions_cronjob.sh** - Sessions cleanup cronjob
- **cyberpanel_sessions.sh** - Sessions cleanup script
- **defaultwebsitepage.html** - Default website page template
- **defaultwebsitepage.sh** - Default website page installer
- **install_pureftpd.sh** - PureFTPd installer
- **install_vsftpd.sh** - vsftpd installer
- **loader-wizard.php** - Loader wizard
- **lsmcd** - LiteSpeed Memcached
- **wp** - WordPress CLI wrapper

### 💾 Backup & Restore (`backup-restore/`)
- **cyberpanel.sql** - CyberPanel database schema
- **rclone_backup_cronjob.sh** - RClone backup cronjob
- **rclone_sqlbackup_cronjob.sh** - SQL backup cronjob
- **restore_cyberpanel_database.sh** - Database restore script

### 🖥️ OS-Specific (`os-specific/`)
- **cyberpanel_almalinux9_upgrade_fix.sh** - AlmaLinux 9 upgrade fix
- **installCyberPanel_almalinux9_patch.py** - AlmaLinux 9 patch

### 📚 Documentation (`docs/`)
- **README.md** - Documentation index
- **installation-guide.md** - Complete installation guide
- **troubleshooting-guide.md** - Troubleshooting guide
- **security-best-practices.md** - Security best practices
- **os-specific-notes.md** - OS-specific notes
- **menu-demo.md** - Master menu demonstration

## 🎯 Root Directory Files

### 📄 Main Files
- **README.md** - Main project documentation
- **CHANGELOG.md** - Version history and changes
- **cyberpanel-mods-menu.sh** - Master menu system
- **launch.sh** - Simple launcher script

## 🚀 Benefits of Organization

### ✅ **Easy Navigation**
- Logical grouping of related scripts
- Clear folder structure
- Easy to find specific functionality

### ✅ **Maintainability**
- Related scripts grouped together
- Easy to update and maintain
- Clear separation of concerns

### ✅ **User Experience**
- Intuitive folder names
- Easy to understand structure
- Quick access to needed tools

### ✅ **Documentation**
- Comprehensive documentation in docs/
- Clear file descriptions
- Easy to find information

### ✅ **Scalability**
- Easy to add new scripts
- Clear organization pattern
- Extensible structure

## 🔍 Finding Scripts

### By Category
- **Core Issues** → `core-fixes/`
- **Version Management** → `version-managers/`
- **Security** → `security/`
- **General Tools** → `utilities/`
- **Backup/Restore** → `backup-restore/`
- **OS-Specific** → `os-specific/`

### By Function
- **PHP Management** → `version-managers/php*`
- **MariaDB Management** → `version-managers/mariadb*`
- **Security Hardening** → `security/cyberpanel_security_enhanced.sh`
- **Core Fixes** → `core-fixes/cyberpanel_core_fixes_enhanced.sh`
- **System Utilities** → `utilities/cyberpanel_utility_enhanced.sh`

### By Operating System
- **AlmaLinux 9** → `os-specific/cyberpanel_almalinux9_*`
- **General OS** → `utilities/os_compatibility_checker.sh`

## 📋 Maintenance

### Adding New Scripts
1. Determine the appropriate category
2. Place script in the correct folder
3. Update this organization document
4. Update the master menu if needed

### Updating Scripts
1. Locate script in appropriate folder
2. Update the script
3. Test functionality
4. Update documentation if needed

### Removing Scripts
1. Remove from appropriate folder
2. Update this organization document
3. Update master menu if needed
4. Update documentation

---

**All mods and utilities are now properly organized for maximum usability and maintainability!** 🎉
