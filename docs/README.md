# 📚 CyberPanel Mods Documentation

Welcome to the comprehensive documentation for CyberPanel Mods. This documentation provides detailed guides, troubleshooting information, and best practices for using the enhanced CyberPanel mods repository.

## 📖 Documentation Index

### 🚀 Getting Started
- **[Installation Guide](installation-guide.md)** - Complete installation and setup guide
- **[Quick Start](quick-start.md)** - Quick setup for experienced users
- **[Compatibility Check](compatibility-check.md)** - System compatibility verification

### 🔧 User Guides
- **[Core Fixes Guide](core-fixes-guide.md)** - Using core fixes and repairs
- **[Version Management](version-management.md)** - Managing PHP and MariaDB versions
- **[Security Hardening](security-hardening.md)** - Security configuration and hardening
- **[Backup and Restore](backup-restore.md)** - Backup and recovery procedures

### 🛡️ Security
- **[Security Best Practices](security-best-practices.md)** - Comprehensive security guide
- **[Firewall Configuration](firewall-configuration.md)** - Network security setup
- **[SSL/TLS Setup](ssl-tls-setup.md)** - Certificate and encryption configuration
- **[Access Control](access-control.md)** - User authentication and authorization

### 🖥️ Operating Systems
- **[OS-Specific Notes](os-specific-notes.md)** - Detailed OS compatibility information
- **[Ubuntu Guide](ubuntu-guide.md)** - Ubuntu-specific setup and configuration
- **[RHEL-based Guide](rhel-guide.md)** - AlmaLinux, RockyLinux, RHEL configuration
- **[CloudLinux Guide](cloudlinux-guide.md)** - CloudLinux-specific considerations

### 🔍 Troubleshooting
- **[Troubleshooting Guide](troubleshooting-guide.md)** - Common issues and solutions
- **[Error Codes](error-codes.md)** - Error code reference and solutions
- **[Log Analysis](log-analysis.md)** - Understanding and analyzing logs
- **[Performance Tuning](performance-tuning.md)** - Optimizing CyberPanel performance

### 📦 Advanced Topics
- **[Custom Scripts](custom-scripts.md)** - Creating custom mods and scripts
- **[API Integration](api-integration.md)** - Integrating with external APIs
- **[Monitoring Setup](monitoring-setup.md)** - Setting up monitoring and alerting
- **[Disaster Recovery](disaster-recovery.md)** - Complete disaster recovery procedures

### 🤝 Contributing
- **[Contributing Guide](CONTRIBUTING.md)** - How to contribute to the project
- **[Development Setup](development-setup.md)** - Setting up development environment
- **[Testing Guide](testing-guide.md)** - Testing mods and scripts
- **[Code Style](code-style.md)** - Coding standards and conventions

## 🚀 Quick Start

### 1. Check Compatibility
```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash
```

### 2. Install Enhanced Utility
```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility_enhanced.sh | bash
```

### 3. Run Core Fixes
```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash
```

### 4. Apply Security Hardening
```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash
```

## 📋 Complete Repository Structure

### 📁 Script Categories

#### 🔧 Core Fixes (`core-fixes/`)
- **cyberpanel_core_fixes_enhanced.sh** - Comprehensive core fixes
- **cyberpanel_fix_symbolic_links.sh** - Fix symbolic links
- **fix_503_service_unavailable.sh** - Fix 503 errors
- **fix_missing_wp_cli.sh** - Install WP-CLI
- **fixperms.sh** - Fix file permissions

#### 🔄 Version Managers (`version-managers/`)
- **php_version_manager_enhanced.sh** - Enhanced PHP version manager
- **phpmod.sh** - Original PHP version changer
- **phpmod_v2.sh** - PHP version changer v2
- **mariadb_version_manager_enhanced.sh** - Enhanced MariaDB version manager
- **mariadb_v_changer.sh** - Original MariaDB version changer
- **snappymail_v_changer.sh** - Snappymail version changer
- **phpmyadmin_v_changer.sh** - phpMyAdmin version changer
- **modsec_rules_v_changer.sh** - ModSecurity rules changer

#### 🛡️ Security (`security/`)
- **cyberpanel_security_enhanced.sh** - Comprehensive security hardening
- **disable_2fa.sh** - Disable two-factor authentication
- **fix_permissions.sh** - Fix file permissions
- **fix_ssl_missing_context.sh** - Fix SSL context issues
- **reset_ols_adminpassword** - Reset OpenLiteSpeed admin password
- **selfsigned_fixer.sh** - Fix self-signed certificates
- **cp_permissions.txt** - CyberPanel permissions reference

#### 🛠️ Utilities (`utilities/`)
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

#### 💾 Backup & Restore (`backup-restore/`)
- **cyberpanel.sql** - CyberPanel database schema
- **rclone_backup_cronjob.sh** - RClone backup cronjob
- **rclone_sqlbackup_cronjob.sh** - SQL backup cronjob
- **restore_cyberpanel_database.sh** - Database restore script

#### 🖥️ OS-Specific (`os-specific/`)
- **cyberpanel_almalinux9_upgrade_fix.sh** - AlmaLinux 9 upgrade fix
- **installCyberPanel_almalinux9_patch.py** - AlmaLinux 9 patch

### 📁 Documentation Structure

#### 📚 Core Documentation
- **Installation Guide** - Step-by-step installation instructions
- **Troubleshooting Guide** - Common issues and solutions
- **Security Best Practices** - Comprehensive security guide
- **OS-Specific Notes** - Operating system compatibility details
- **Menu Demo** - Master menu demonstration guide

#### 📚 User Guides
- **Core Fixes Guide** - Using core fixes and repairs
- **Version Management** - Managing software versions
- **Security Hardening** - Security configuration
- **Backup and Restore** - Backup procedures

#### 📚 Advanced Topics
- **Custom Scripts** - Creating custom mods
- **API Integration** - External API integration
- **Monitoring Setup** - Monitoring configuration
- **Disaster Recovery** - Recovery procedures

## 🔍 Finding Information

### By Category
- **Installation** - Setup and installation guides
- **Configuration** - System configuration guides
- **Security** - Security-related documentation
- **Troubleshooting** - Problem-solving guides
- **Advanced** - Advanced topics and customization

### By Operating System
- **Ubuntu** - Ubuntu-specific guides
- **RHEL-based** - AlmaLinux, RockyLinux, RHEL guides
- **CloudLinux** - CloudLinux-specific guides
- **Debian** - Debian-specific guides

### By Task
- **Getting Started** - Initial setup and configuration
- **Daily Operations** - Routine maintenance tasks
- **Problem Solving** - Troubleshooting and fixes
- **Optimization** - Performance tuning and optimization

## 📚 Reading Recommendations

### For New Users
1. Start with the [Installation Guide](installation-guide.md)
2. Read the [Quick Start](quick-start.md) guide
3. Review [Security Best Practices](security-best-practices.md)
4. Keep the [Troubleshooting Guide](troubleshooting-guide.md) handy

### For Experienced Users
1. Check [OS-Specific Notes](os-specific-notes.md) for your system
2. Review [Advanced Topics](advanced-topics.md) for customization
3. Read [Contributing Guide](CONTRIBUTING.md) to contribute
4. Explore [Custom Scripts](custom-scripts.md) for automation

### For System Administrators
1. Study [Security Best Practices](security-best-practices.md) thoroughly
2. Review [Monitoring Setup](monitoring-setup.md) for production
3. Read [Disaster Recovery](disaster-recovery.md) procedures
4. Check [Performance Tuning](performance-tuning.md) for optimization

## 🔄 Keeping Documentation Updated

### Documentation Updates
- Documentation is updated with each release
- Check the [Changelog](CHANGELOG.md) for recent changes
- Subscribe to [GitHub notifications](https://github.com/master3395/cyberpanel-mods) for updates

### Contributing to Documentation
- Report documentation issues via [GitHub Issues](https://github.com/master3395/cyberpanel-mods/issues)
- Submit documentation improvements via [Pull Requests](https://github.com/master3395/cyberpanel-mods/pulls)
- Follow the [Contributing Guide](CONTRIBUTING.md) for guidelines

## 📞 Getting Help

### Documentation Issues
- **Missing Information** - [Open an issue](https://github.com/master3395/cyberpanel-mods/issues)
- **Incorrect Information** - [Submit a fix](https://github.com/master3395/cyberpanel-mods/pulls)
- **Suggestions** - [Start a discussion](https://github.com/master3395/cyberpanel-mods/discussions)

### Technical Support
- **Installation Issues** - Check [Installation Guide](installation-guide.md)
- **Configuration Problems** - Review [Troubleshooting Guide](troubleshooting-guide.md)
- **Security Questions** - Read [Security Best Practices](security-best-practices.md)
- **OS-Specific Issues** - Check [OS-Specific Notes](os-specific-notes.md)

## 📊 Documentation Statistics

### Coverage
- **Operating Systems**: 12+ supported systems
- **Scripts**: 50+ enhanced scripts
- **Guides**: 20+ comprehensive guides
- **Languages**: English (primary)

### Quality
- **Accuracy**: Regularly tested and updated
- **Completeness**: Comprehensive coverage of all features
- **Clarity**: Clear, step-by-step instructions
- **Examples**: Practical examples and use cases

## 🔗 External Resources

### Official Documentation
- [CyberPanel Documentation](https://docs.cyberpanel.net/)
- [LiteSpeed Documentation](https://docs.litespeedtech.com/)
- [MariaDB Documentation](https://mariadb.org/documentation/)

### Community Resources
- [CyberPanel Forums](https://forums.cyberpanel.net/)
- [GitHub Discussions](https://github.com/master3395/cyberpanel-mods/discussions)
- [Discord Community](https://discord.gg/cyberpanel)

### Security Resources
- [OWASP](https://owasp.org/) - Web application security
- [CVE](https://cve.mitre.org/) - Common vulnerabilities
- [NIST](https://www.nist.gov/) - Security standards

---

**Need help?** Check our [Troubleshooting Guide](troubleshooting-guide.md) or [open an issue](https://github.com/master3395/cyberpanel-mods/issues) for assistance.
