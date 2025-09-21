# 🔧 CyberPanel Mods Troubleshooting Guide

This comprehensive troubleshooting guide will help you resolve common issues when using CyberPanel Mods.

## 🚨 Quick Diagnosis

### Step 1: Run Compatibility Check

First, always run the compatibility checker to identify potential issues:

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash
```

### Step 2: Check System Status

```bash
# Check CyberPanel status
systemctl status lscpd

# Check database status
systemctl status mariadb || systemctl status mysqld || systemctl status mysql

# Check disk space
df -h

# Check memory usage
free -h
```

## 📋 Available Scripts for Troubleshooting

### 🔧 Core Fixes Scripts
- **cyberpanel_core_fixes_enhanced.sh** - Comprehensive core fixes
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash
  ```
- **cyberpanel_fix_symbolic_links.sh** - Fix symbolic links
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_fix_symbolic_links.sh | bash
  ```
- **fix_503_service_unavailable.sh** - Fix 503 errors
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/fix_503_service_unavailable.sh | bash
  ```
- **fix_missing_wp_cli.sh** - Install WP-CLI
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/fix_missing_wp_cli.sh | bash
  ```
- **fixperms.sh** - Fix file permissions
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/fixperms.sh | bash
  ```

### 🔄 Version Manager Scripts
- **php_version_manager_enhanced.sh** - PHP version management
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/php_version_manager_enhanced.sh | bash
  ```
- **mariadb_version_manager_enhanced.sh** - MariaDB version management
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/mariadb_version_manager_enhanced.sh | bash
  ```

### 🛡️ Security Scripts
- **cyberpanel_security_enhanced.sh** - Comprehensive security fixes
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash
  ```
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

### 🛠️ Utility Scripts
- **cyberpanel_utility_enhanced.sh** - Enhanced CyberPanel utility
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility_enhanced.sh | bash
  ```
- **os_compatibility_checker.sh** - OS compatibility checker
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash
  ```

### 💾 Backup & Restore Scripts
- **restore_cyberpanel_database.sh** - Restore CyberPanel database
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/restore_cyberpanel_database.sh | bash
  ```

### 🖥️ OS-Specific Scripts
- **cyberpanel_almalinux9_upgrade_fix.sh** - AlmaLinux 9 upgrade fix
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/cyberpanel_almalinux9_upgrade_fix.sh | bash
  ```
- **installCyberPanel_almalinux9_patch.py** - AlmaLinux 9 patch
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/os-specific/installCyberPanel_almalinux9_patch.py | python3
  ```

## 🐛 Common Issues and Solutions

### 1. Permission Denied Errors

#### Problem
```bash
bash: [script-name]: Permission denied
```

#### Solution
```bash
# Make script executable
chmod +x [script-name]

# Or run with bash explicitly
bash [script-name]

# Ensure you're running as root
sudo su -
```

### 2. CyberPanel Not Detected

#### Problem
```bash
ERROR: CyberPanel not detected
```

#### Solution
```bash
# Check if CyberPanel is installed
ls -la /etc/cyberpanel/

# Check CyberPanel service
systemctl status lscpd

# If not installed, install CyberPanel first
curl -sSL https://cyberpanel.sh/install.sh | bash
```

### 3. Package Manager Issues

#### Problem
```bash
ERROR: No supported package manager found
```

#### Solution
```bash
# Ubuntu/Debian
apt update && apt install curl wget

# RHEL-based (CentOS, AlmaLinux, RockyLinux)
yum update && yum install curl wget

# Modern RHEL-based
dnf update && dnf install curl wget
```

### 4. Database Connection Issues

#### Problem
```bash
ERROR: Database connection failed
```

#### Solution
```bash
# Check database service
systemctl status mariadb || systemctl status mysqld || systemctl status mysql

# Start database service
systemctl start mariadb || systemctl start mysqld || systemctl start mysql

# Check database password
cat /etc/cyberpanel/mysqlPassword

# Test database connection
mysql -u root -p$(cat /etc/cyberpanel/mysqlPassword) -e "SELECT 1;"
```

### 5. Service Issues

#### Problem
```bash
ERROR: Service not running
```

#### Solution
```bash
# Restart CyberPanel services
systemctl restart lscpd
systemctl restart gunicorn

# Check service status
systemctl status lscpd
systemctl status gunicorn

# Enable services
systemctl enable lscpd
systemctl enable gunicorn
```

### 6. PHP Version Issues

#### Problem
```bash
ERROR: PHP version not found
```

#### Solution
```bash
# Check installed PHP versions
ls -la /usr/local/lsws/lsphp*

# Install PHP version
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/php_version_manager_enhanced.sh | bash

# Check current PHP version
/usr/local/lscp/fcgi-bin/lsphp -v
```

### 7. MariaDB Version Issues

#### Problem
```bash
ERROR: MariaDB version not found
```

#### Solution
```bash
# Check MariaDB version
mysql --version

# Install MariaDB version
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/version-managers/mariadb_version_manager_enhanced.sh | bash

# Check MariaDB service
systemctl status mariadb || systemctl status mysqld
```

### 8. SSL Certificate Issues

#### Problem
```bash
ERROR: SSL certificate issues
```

#### Solution
```bash
# Fix SSL context
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash -- --ssl-context

# Check certificate files
ls -la /usr/local/lsws/conf/cert/

# Generate new self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /usr/local/lsws/conf/cert/selfsigned.key \
    -out /usr/local/lsws/conf/cert/selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
```

### 9. File Permission Issues

#### Problem
```bash
ERROR: Permission denied for file operations
```

#### Solution
```bash
# Fix file permissions
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash -- --permissions

# Manual permission fix
chown -R cyberpanel:cyberpanel /usr/local/CyberCP
chown -R cyberpanel:cyberpanel /usr/local/lscp
chown -R cyberpanel:cyberpanel /usr/local/lsws
chmod -R 755 /usr/local/CyberCP
chmod -R 755 /usr/local/lscp
chmod -R 755 /usr/local/lsws
```

### 10. Network Connectivity Issues

#### Problem
```bash
ERROR: Failed to download script
```

#### Solution
```bash
# Check internet connectivity
ping -c 4 google.com

# Check DNS resolution
nslookup github.com

# Try alternative download methods
wget https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/[script-path]

# Or use curl with different options
curl -L -o [script-name] https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/[script-path]
```

## 📊 Log Analysis

### Check Log Files

```bash
# Compatibility checker logs
tail -f /var/log/cyberpanel_mods_compatibility.log

# Utility script logs
tail -f /var/log/cyberpanel_utility.log

# Core fixes logs
tail -f /var/log/cyberpanel_core_fixes.log

# Security script logs
tail -f /var/log/cyberpanel_security.log

# PHP version manager logs
tail -f /var/log/php_version_manager.log

# MariaDB version manager logs
tail -f /var/log/mariadb_version_manager.log

# System logs
tail -f /var/log/messages
tail -f /var/log/syslog
```

### Common Log Patterns

#### Error Patterns
```bash
# Look for ERROR messages
grep -i "error" /var/log/cyberpanel_*.log

# Look for WARNING messages
grep -i "warning" /var/log/cyberpanel_*.log

# Look for FAILED messages
grep -i "failed" /var/log/cyberpanel_*.log
```

#### Success Patterns
```bash
# Look for SUCCESS messages
grep -i "success" /var/log/cyberpanel_*.log

# Look for COMPLETED messages
grep -i "completed" /var/log/cyberpanel_*.log
```

## 🔍 Advanced Troubleshooting

### 1. System Resource Issues

#### Check System Resources
```bash
# Check CPU usage
top -bn1 | grep "Cpu(s)"

# Check memory usage
free -h

# Check disk usage
df -h

# Check disk I/O
iostat -x 1 5
```

#### Solutions
```bash
# Free up disk space
apt autoremove -y  # Ubuntu/Debian
yum autoremove -y  # RHEL-based

# Clear package cache
apt clean  # Ubuntu/Debian
yum clean all  # RHEL-based

# Clear log files
journalctl --vacuum-time=7d
```

### 2. Service Dependencies

#### Check Service Dependencies
```bash
# Check CyberPanel dependencies
systemctl list-dependencies lscpd

# Check database dependencies
systemctl list-dependencies mariadb

# Check service status
systemctl status lscpd gunicorn mariadb
```

#### Solutions
```bash
# Restart all services in order
systemctl restart mariadb
systemctl restart lscpd
systemctl restart gunicorn

# Enable services
systemctl enable mariadb lscpd gunicorn
```

### 3. Configuration Issues

#### Check Configuration Files
```bash
# Check CyberPanel configuration
ls -la /usr/local/lscp/conf/

# Check LiteSpeed configuration
ls -la /usr/local/lsws/conf/

# Check database configuration
ls -la /etc/my.cnf*
```

#### Solutions
```bash
# Restore default configurations
cp /usr/local/lscp/conf/httpd_config.conf.backup /usr/local/lscp/conf/httpd_config.conf

# Regenerate configurations
/usr/local/lscp/bin/lshttpd -t
```

### 4. Port Conflicts

#### Check Port Usage
```bash
# Check which ports are in use
netstat -tulpn | grep LISTEN

# Check specific ports
netstat -tulpn | grep :8090  # CyberPanel
netstat -tulpn | grep :7080  # LiteSpeed
netstat -tulpn | grep :3306  # MariaDB
```

#### Solutions
```bash
# Kill conflicting processes
kill -9 $(lsof -t -i:8090)
kill -9 $(lsof -t -i:7080)

# Restart services
systemctl restart lscpd
```

## 🛠️ Recovery Procedures

### 1. Complete System Recovery

If CyberPanel is completely broken:

```bash
# Stop all services
systemctl stop lscpd gunicorn mariadb

# Backup important data
cp -r /home/cyberpanel /backup/cyberpanel-$(date +%Y%m%d)
cp -r /var/lib/mysql /backup/mysql-$(date +%Y%m%d)

# Reinstall CyberPanel
curl -sSL https://cyberpanel.sh/install.sh | bash

# Restore data
cp -r /backup/cyberpanel-$(date +%Y%m%d)/* /home/cyberpanel/
cp -r /backup/mysql-$(date +%Y%m%d)/* /var/lib/mysql/

# Restart services
systemctl start mariadb lscpd gunicorn
```

### 2. Database Recovery

If database is corrupted:

```bash
# Stop database service
systemctl stop mariadb

# Check database integrity
mysqlcheck -r -u root -p$(cat /etc/cyberpanel/mysqlPassword) --all-databases

# Repair database
mysqlrepair -u root -p$(cat /etc/cyberpanel/mysqlPassword) --all-databases

# Start database service
systemctl start mariadb
```

### 3. Configuration Recovery

If configurations are corrupted:

```bash
# Stop CyberPanel
systemctl stop lscpd

# Restore from backup
cp /usr/local/lscp/conf/httpd_config.conf.backup /usr/local/lscp/conf/httpd_config.conf

# Test configuration
/usr/local/lscp/bin/lshttpd -t

# Start CyberPanel
systemctl start lscpd
```

## 📞 Getting Help

### 1. Self-Help Resources

- **Documentation**: Check the docs/ directory
- **Logs**: Review relevant log files
- **Compatibility**: Run the compatibility checker
- **Community**: Check GitHub discussions

### 2. Reporting Issues

When reporting issues, include:

1. **Operating System**: `cat /etc/os-release`
2. **CyberPanel Version**: Check in the admin panel
3. **Error Messages**: Copy the exact error message
4. **Log Files**: Attach relevant log files
5. **Steps to Reproduce**: What you did before the error
6. **Expected Behavior**: What should have happened

### 3. Community Support

- **GitHub Issues**: [Open an issue](https://github.com/master3395/cyberpanel-mods/issues)
- **GitHub Discussions**: [Ask questions](https://github.com/master3395/cyberpanel-mods/discussions)
- **CyberPanel Community**: [Official forum](https://forums.cyberpanel.net)

## 🔄 Prevention

### 1. Regular Maintenance

```bash
# Run compatibility check weekly
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash

# Run core fixes monthly
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash

# Run security fixes monthly
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash
```

### 2. Monitoring

```bash
# Set up monitoring for services
systemctl status lscpd gunicorn mariadb

# Monitor disk space
df -h

# Monitor memory usage
free -h

# Monitor log files
tail -f /var/log/cyberpanel_*.log
```

### 3. Backups

```bash
# Set up automated backups
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/rclone_backup_cronjob.sh | bash

# Test backup restoration
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/backup-restore/restore_cyberpanel_database.sh | bash
```

---

**Still having issues?** Check our [Installation Guide](installation-guide.md) or [open an issue](https://github.com/master3395/cyberpanel-mods/issues) for help.
