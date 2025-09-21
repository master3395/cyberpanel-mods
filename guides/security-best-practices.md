# 🛡️ CyberPanel Security Best Practices

This comprehensive security guide will help you secure your CyberPanel installation using the enhanced security scripts and best practices.

## 🔒 Security Overview

CyberPanel security involves multiple layers of protection:

1. **System Security** - Operating system hardening
2. **Application Security** - CyberPanel and web application security
3. **Network Security** - Firewall and network protection
4. **Database Security** - MariaDB/MySQL security
5. **SSL/TLS Security** - Certificate and encryption security
6. **Access Control** - User authentication and authorization

## 🚀 Quick Security Setup

### Automated Security Hardening

Run the comprehensive security script to apply all security measures:

```bash
# Run all security fixes
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash

# Or run specific security measures
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash -- --firewall --fail2ban --modsecurity
```

## 📋 Available Security Scripts

### 🛡️ Enhanced Security Scripts

#### Comprehensive Security Hardening
- **cyberpanel_security_enhanced.sh** - Complete security hardening suite
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash
  ```
  
  **Features:**
  - Firewall configuration (UFW/iptables)
  - Fail2ban installation and configuration
  - ModSecurity setup and rules
  - SSL/TLS hardening
  - Database security
  - File permission hardening
  - 2FA management
  - Security headers
  - Log monitoring

### 🔐 Individual Security Scripts

#### Authentication & Access Control
- **disable_2fa.sh** - Disable two-factor authentication when access is lost
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/disable_2fa.sh | bash
  ```

- **reset_ols_adminpassword** - Reset OpenLiteSpeed admin password
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/reset_ols_adminpassword | bash
  ```

#### File & Permission Security
- **fix_permissions.sh** - Restore correct CyberPanel file permissions
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix_permissions.sh | bash
  ```

#### SSL/TLS Security
- **fix_ssl_missing_context.sh** - Fix missing acme-challenge context for SSL certificates
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix_ssl_missing_context.sh | bash
  ```

- **selfsigned_fixer.sh** - Fix self-signed certificate issues
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/selfsigned_fixer.sh | bash
  ```

### 📚 Security Reference Files

#### Permission Reference
- **cp_permissions.txt** - Complete CyberPanel permissions reference
  - Contains all file and directory permissions for CyberPanel
  - Useful for manual permission restoration
  - Reference for security auditing

### 🔧 Core Security Fixes

#### Core Fixes with Security Focus
- **cyberpanel_core_fixes_enhanced.sh** - Includes security-related core fixes
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash
  ```
  
  **Security-related fixes:**
  - File permission corrections
  - SSL context fixes
  - Service security hardening
  - Database security improvements

### 🛠️ Security Utilities

#### System Security Utilities
- **cyberpanel_utility_enhanced.sh** - Includes security management features
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/cyberpanel_utility_enhanced.sh | bash
  ```

- **os_compatibility_checker.sh** - Check system security compatibility
  ```bash
  curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash
  ```

### 🔄 Security Script Usage Patterns

#### Complete Security Setup
```bash
# 1. Check system compatibility
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash

# 2. Run core fixes (includes security fixes)
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash

# 3. Apply comprehensive security hardening
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash

# 4. Fix any remaining permission issues
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix_permissions.sh | bash
```

#### Emergency Security Recovery
```bash
# If locked out due to 2FA issues
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/disable_2fa.sh | bash

# If OpenLiteSpeed admin password is lost
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/reset_ols_adminpassword | bash

# If SSL certificates are broken
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix_ssl_missing_context.sh | bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/selfsigned_fixer.sh | bash
```

#### Targeted Security Fixes
```bash
# Fix only file permissions
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix_permissions.sh | bash

# Fix only SSL issues
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix_ssl_missing_context.sh | bash

# Fix only self-signed certificates
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/selfsigned_fixer.sh | bash
```

## 🔐 Authentication Security

### 1. Strong Passwords

#### CyberPanel Admin Password
```bash
# Generate strong password
openssl rand -base64 32

# Change admin password in CyberPanel
# Go to Admin Panel > Admin Users > Change Password
```

#### Database Password
```bash
# Generate strong database password
openssl rand -base64 32

# Update database password
mysql -u root -p$(cat /etc/cyberpanel/mysqlPassword) -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'NEW_STRONG_PASSWORD';"
echo "NEW_STRONG_PASSWORD" > /etc/cyberpanel/mysqlPassword
chmod 600 /etc/cyberpanel/mysqlPassword
```

### 2. Two-Factor Authentication (2FA)

#### Enable 2FA
```bash
# Enable 2FA in CyberPanel admin panel
# Go to Admin Panel > Admin Users > Enable 2FA
```

#### Disable 2FA (if needed)
```bash
# Disable 2FA using security script
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash -- --disable-2fa
```

### 3. SSH Security

#### Secure SSH Configuration
```bash
# Edit SSH configuration
nano /etc/ssh/sshd_config

# Add/update these settings:
Port 22
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
```

#### Restart SSH Service
```bash
systemctl restart sshd
```

## 🔥 Firewall Configuration

### 1. UFW (Ubuntu/Debian)

#### Basic UFW Setup
```bash
# Enable UFW
ufw --force enable

# Allow SSH
ufw allow ssh

# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Allow CyberPanel admin
ufw allow 8090/tcp

# Allow LiteSpeed admin
ufw allow 7080/tcp

# Allow mail ports
ufw allow 25/tcp    # SMTP
ufw allow 587/tcp   # SMTP submission
ufw allow 993/tcp   # IMAPS
ufw allow 995/tcp   # POP3S

# Check status
ufw status verbose
```

#### Advanced UFW Rules
```bash
# Rate limiting for SSH
ufw limit ssh

# Allow specific IP for admin access
ufw allow from YOUR_IP to any port 8090

# Deny all other access to admin port
ufw deny 8090
```

### 2. Firewalld (RHEL-based)

#### Basic Firewalld Setup
```bash
# Start and enable firewalld
systemctl start firewalld
systemctl enable firewalld

# Allow services
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=8090/tcp
firewall-cmd --permanent --add-port=7080/tcp
firewall-cmd --permanent --add-service=smtp
firewall-cmd --permanent --add-service=imaps
firewall-cmd --permanent --add-service=pop3s

# Reload firewall
firewall-cmd --reload

# Check status
firewall-cmd --list-all
```

## 🚫 Intrusion Prevention

### 1. Fail2ban Configuration

#### Install and Configure Fail2ban
```bash
# Install fail2ban
apt install fail2ban -y  # Ubuntu/Debian
yum install fail2ban -y  # RHEL-based

# Create CyberPanel jail
cat > /etc/fail2ban/jail.d/cyberpanel.conf << 'EOF'
[cyberpanel]
enabled = true
port = 8090
filter = cyberpanel
logpath = /var/log/cyberpanel/error.log
maxretry = 3
bantime = 3600
findtime = 600

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

# Create CyberPanel filter
cat > /etc/fail2ban/filter.d/cyberpanel.conf << 'EOF'
[Definition]
failregex = ^.*Invalid login attempt.*$
ignoreregex =
EOF

# Start and enable fail2ban
systemctl start fail2ban
systemctl enable fail2ban

# Check status
fail2ban-client status
```

### 2. ModSecurity Configuration

#### Install ModSecurity
```bash
# Ubuntu/Debian
apt install libapache2-mod-security2 -y

# RHEL-based
yum install mod_security -y
```

#### Configure OWASP Core Rule Set
```bash
# Create ModSecurity directory
mkdir -p /usr/local/lsws/conf/modsec/rules

# Download OWASP CRS
cd /usr/local/lsws/conf/modsec/rules
wget https://github.com/coreruleset/coreruleset/archive/v3.3.4.tar.gz
tar -xzf v3.3.4.tar.gz
mv coreruleset-3.3.4/* .
rm -rf coreruleset-3.3.4 v3.3.4.tar.gz

# Configure CRS
cp crs-setup.conf.example crs-setup.conf
sed -i 's/SecDefaultAction "phase:1,log,auditlog,pass"/SecDefaultAction "phase:1,log,auditlog,deny,status:403"/' crs-setup.conf
sed -i 's/SecDefaultAction "phase:2,log,auditlog,pass"/SecDefaultAction "phase:2,log,auditlog,deny,status:403"/' crs-setup.conf
```

## 🔒 SSL/TLS Security

### 1. SSL Certificate Management

#### Let's Encrypt Certificates
```bash
# Install certbot
apt install certbot -y  # Ubuntu/Debian
yum install certbot -y  # RHEL-based

# Generate certificate
certbot certonly --webroot -w /home/cyberpanel/public_html -d yourdomain.com

# Auto-renewal
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -
```

#### Self-Signed Certificates
```bash
# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /usr/local/lsws/conf/cert/selfsigned.key \
    -out /usr/local/lsws/conf/cert/selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Set proper permissions
chmod 600 /usr/local/lsws/conf/cert/selfsigned.key
chmod 644 /usr/local/lsws/conf/cert/selfsigned.crt
```

### 2. SSL Configuration

#### Strong SSL Configuration
```bash
# Edit LiteSpeed configuration
nano /usr/local/lscp/conf/httpd_config.conf

# Add these SSL settings:
SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
SSLCipherSuite ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
SSLHonorCipherOrder on
SSLSessionTickets off
```

## 🗄️ Database Security

### 1. MariaDB/MySQL Security

#### Secure Database Installation
```bash
# Run MariaDB secure installation
mysql_secure_installation

# Or use our security script
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash -- --database
```

#### Database User Management
```bash
# Create dedicated database user
mysql -u root -p$(cat /etc/cyberpanel/mysqlPassword) -e "CREATE USER 'cyberpanel'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD';"
mysql -u root -p$(cat /etc/cyberpanel/mysqlPassword) -e "GRANT ALL PRIVILEGES ON *.* TO 'cyberpanel'@'localhost';"
mysql -u root -p$(cat /etc/cyberpanel/mysqlPassword) -e "FLUSH PRIVILEGES;"

# Remove test database
mysql -u root -p$(cat /etc/cyberpanel/mysqlPassword) -e "DROP DATABASE IF EXISTS test;"

# Remove anonymous users
mysql -u root -p$(cat /etc/cyberpanel/mysqlPassword) -e "DELETE FROM mysql.user WHERE User='';"
```

### 2. Database Backup Security

#### Encrypted Backups
```bash
# Create encrypted backup
mysqldump -u root -p$(cat /etc/cyberpanel/mysqlPassword) --all-databases | gpg --cipher-algo AES256 --compress-algo 1 --symmetric --output backup_$(date +%Y%m%d).sql.gpg

# Restore encrypted backup
gpg --decrypt backup_$(date +%Y%m%d).sql.gpg | mysql -u root -p$(cat /etc/cyberpanel/mysqlPassword)
```

## 📁 File System Security

### 1. File Permissions

#### Secure File Permissions
```bash
# Run permission fix script
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash -- --permissions

# Manual permission fixes
chown -R cyberpanel:cyberpanel /usr/local/CyberCP
chown -R cyberpanel:cyberpanel /usr/local/lscp
chown -R cyberpanel:cyberpanel /usr/local/lsws
chmod -R 755 /usr/local/CyberCP
chmod -R 755 /usr/local/lscp
chmod -R 755 /usr/local/lsws

# Secure sensitive files
chmod 600 /etc/cyberpanel/mysqlPassword
chmod 600 /etc/cyberpanel/adminPassword
chmod 600 /etc/ssh/sshd_config
```

### 2. Directory Protection

#### Protect Sensitive Directories
```bash
# Create .htaccess files for sensitive directories
echo "Deny from all" > /usr/local/CyberCP/.htaccess
echo "Deny from all" > /etc/cyberpanel/.htaccess
echo "Deny from all" > /var/lib/cyberpanel/.htaccess
```

## 🔍 Monitoring and Logging

### 1. Log Monitoring

#### Set up Log Monitoring
```bash
# Install log monitoring tools
apt install logwatch -y  # Ubuntu/Debian
yum install logwatch -y  # RHEL-based

# Configure log monitoring
cat > /etc/logwatch/conf/logwatch.conf << 'EOF'
LogDir = /var/log
TmpDir = /var/cache/logwatch
MailTo = admin@yourdomain.com
MailFrom = logwatch@yourdomain.com
Print = No
Save = /var/log/logwatch
Range = yesterday
Detail = Med
Service = All
EOF
```

### 2. Security Monitoring

#### Set up Security Monitoring
```bash
# Monitor failed login attempts
grep "Failed password" /var/log/auth.log | tail -20

# Monitor CyberPanel access
grep "Invalid login attempt" /var/log/cyberpanel/error.log | tail -20

# Monitor database access
grep "Access denied" /var/log/mysql/error.log | tail -20
```

## 🔄 Regular Security Maintenance

### 1. Automated Security Updates

#### Set up Automatic Updates
```bash
# Ubuntu/Debian
apt install unattended-upgrades -y
dpkg-reconfigure -plow unattended-upgrades

# RHEL-based
yum install yum-plugin-security -y
echo "security" >> /etc/yum.conf
```

### 2. Regular Security Scans

#### Weekly Security Scan
```bash
# Create security scan script
cat > /usr/local/bin/security-scan.sh << 'EOF'
#!/bin/bash
echo "=== Security Scan $(date) ===" >> /var/log/security-scan.log

# Check for failed logins
echo "Failed logins:" >> /var/log/security-scan.log
grep "Failed password" /var/log/auth.log | wc -l >> /var/log/security-scan.log

# Check for suspicious activity
echo "Suspicious activity:" >> /var/log/security-scan.log
grep -i "hack\|attack\|exploit" /var/log/cyberpanel/error.log | wc -l >> /var/log/security-scan.log

# Check disk space
echo "Disk usage:" >> /var/log/security-scan.log
df -h >> /var/log/security-scan.log

# Check running processes
echo "Running processes:" >> /var/log/security-scan.log
ps aux | grep -E "(mysql|apache|nginx|litespeed)" >> /var/log/security-scan.log
EOF

chmod +x /usr/local/bin/security-scan.sh

# Add to crontab
echo "0 2 * * 0 /usr/local/bin/security-scan.sh" | crontab -
```

## 🚨 Incident Response

### 1. Security Incident Checklist

#### When a Security Incident Occurs:

1. **Immediate Response**
   ```bash
   # Isolate the system
   iptables -A INPUT -j DROP
   
   # Check running processes
   ps aux | grep -v grep
   
   # Check network connections
   netstat -tulpn
   ```

2. **Investigation**
   ```bash
   # Check logs
   tail -f /var/log/auth.log
   tail -f /var/log/cyberpanel/error.log
   tail -f /var/log/mysql/error.log
   
   # Check file integrity
   find /usr/local/CyberCP -type f -newer /tmp/timestamp -ls
   ```

3. **Recovery**
   ```bash
   # Restore from backup
   systemctl stop lscpd gunicorn mariadb
   cp -r /backup/cyberpanel-$(date +%Y%m%d)/* /usr/local/CyberCP/
   systemctl start mariadb lscpd gunicorn
   ```

### 2. Post-Incident Actions

#### After Resolving an Incident:

1. **Update Security Measures**
   ```bash
   # Run security script
   curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash
   
   # Update all software
   apt update && apt upgrade -y  # Ubuntu/Debian
   yum update -y  # RHEL-based
   ```

2. **Review and Improve**
   - Analyze logs to understand the attack
   - Update security policies
   - Improve monitoring
   - Update documentation

## 📋 Security Checklist

### Daily
- [ ] Check system logs for suspicious activity
- [ ] Monitor disk space and system resources
- [ ] Verify all services are running

### Weekly
- [ ] Run security scan script
- [ ] Check for failed login attempts
- [ ] Review firewall logs
- [ ] Update security signatures

### Monthly
- [ ] Run comprehensive security script
- [ ] Update all software packages
- [ ] Review user accounts and permissions
- [ ] Test backup and recovery procedures

### Quarterly
- [ ] Conduct security audit
- [ ] Review and update security policies
- [ ] Test incident response procedures
- [ ] Update security documentation

## 🔗 Additional Resources

### Security Tools
- **Nmap**: Network scanning and security auditing
- **Lynis**: Security auditing tool
- **Chkrootkit**: Rootkit detection
- **Rkhunter**: Rootkit hunter
- **AIDE**: File integrity monitoring

### Security Websites
- [OWASP](https://owasp.org/) - Web application security
- [CVE](https://cve.mitre.org/) - Common vulnerabilities and exposures
- [NIST](https://www.nist.gov/) - National Institute of Standards and Technology
- [SANS](https://www.sans.org/) - Security training and resources

---

**Remember**: Security is an ongoing process, not a one-time setup. Regularly review and update your security measures to stay protected against evolving threats.
