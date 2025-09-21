# 👥 User & Website Management

**Comprehensive user-facing operations integrated into CyberPanel Mods**

## 🌟 Overview

The User & Website Management module brings the powerful cyberpanel-friendly-cli functionality directly into CyberPanel Mods, creating a unified interface for both end users and system administrators.

## 📁 Files Structure

```
user-management/
├── 📄 user-management-menu.sh     # Main user management interface
├── 📄 user-functions.sh           # User creation, deletion, and management
├── 📄 website-functions.sh        # Website and domain management
├── 📄 cyberpanel-user-cli.sh      # Complete CLI interface with all functions
└── 📄 README.md                   # This documentation
```

## ✨ Features

### 👤 User Management
- **Create Users** - Add new users with customizable settings
- **Delete Users** - Remove users and their associated data
- **List Users** - View all users in the system
- **Suspend/Unsuspend** - Temporarily disable user accounts
- **Edit Users** - Modify user settings and permissions

### 🌐 Website Management
- **Create Websites** - Set up new websites with SSL, DKIM support
- **Delete Websites** - Remove websites and associated configurations
- **List Websites** - View all websites on the server
- **Child Domains** - Create and manage subdomains
- **PHP Version Management** - Change PHP versions per website
- **Package Management** - Assign and modify hosting packages

### 🗄️ Database Management
- **Create Databases** - Set up MySQL/MariaDB databases
- **Delete Databases** - Remove databases
- **List Databases** - View all databases per website
- **User Management** - Create database users with permissions

### 📧 Email Management
- **Create Email Accounts** - Set up email addresses
- **Delete Email Accounts** - Remove email addresses
- **Change Passwords** - Update email account passwords
- **List Emails** - View all email accounts per domain

### 📁 FTP Management
- **Create FTP Accounts** - Set up FTP access
- **Delete FTP Accounts** - Remove FTP users
- **Change Passwords** - Update FTP passwords
- **List FTP Accounts** - View all FTP users per domain

### 🔒 SSL Management
- **Issue SSL Certificates** - Automatic Let's Encrypt SSL
- **Hostname SSL** - SSL for server hostname
- **Mail Server SSL** - SSL for mail servers

### 📦 Package Management
- **Create Packages** - Define hosting packages with limits
- **Delete Packages** - Remove hosting packages
- **List Packages** - View all available packages

### 🔄 Backup & Restore
- **Create Backups** - Generate website backups
- **Restore Backups** - Restore from backup files

### 🌐 DNS Management
- **Create DNS Zones** - Set up DNS zones
- **Delete DNS Zones** - Remove DNS zones
- **Create DNS Records** - Add A, CNAME, MX records
- **Delete DNS Records** - Remove DNS records
- **List DNS** - View all DNS zones and records

## 🚀 Quick Start

### Access from Main Menu
1. Run the main CyberPanel Mods menu:
   ```bash
   curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh | bash
   ```

2. Select option **1) 👥 User & Website Management**

### Direct Access
Run the user management interface directly:
```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/user-management/user-management-menu.sh | bash
```

### Full CLI Interface
For the complete cyberpanel-friendly-cli experience:
```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/user-management/cyberpanel-user-cli.sh | bash
```

## 📋 Menu Options

### Simplified Menu (user-management-menu.sh)
1. 👤 Create User
2. 🗑️ Delete User
3. 📋 List Users
4. 🌐 Create Website
5. 🗑️ Delete Website
6. 📋 List Websites
7. 🐘 Change PHP Version
8. 📊 Full Menu (All Functions)
9. ↩️ Back to Main Menu
10. ❌ Exit

### Full Menu (cyberpanel-user-cli.sh)
**User Functions (1-7):**
- Automatic Creation, Create/Delete/Suspend/Edit/List Users

**Website Functions (8-14):**
- Create/Delete Websites, Child Domains, PHP/Package Changes

**DNS Functions (15-20):**
- DNS Zone and Record Management

**Backup Functions (21-22):**
- Create and Restore Backups

**Package Functions (23-25):**
- Package Creation and Management

**Database Functions (26-28):**
- Database Creation and Management

**Email Functions (29-32):**
- Email Account Management

**FTP Functions (33-36):**
- FTP Account Management

**SSL Functions (37-39):**
- SSL Certificate Management

## 🛡️ Security Features

- **Input Validation** - All inputs are validated using regex patterns
- **Special Character Filtering** - Prevents injection attacks
- **Password Confirmation** - Double verification for all passwords
- **Logging** - All operations are logged for audit trails
- **Root Access Control** - Requires root privileges for security

## 📝 Logging

All operations are logged to:
- `/var/log/cyberpanel_user_management.log` (Simplified menu)
- `/var/log/cyberpanel_user_cli.log` (Full CLI)

## ⚠️ Requirements

- **Root Access** - Must be run as root user
- **CyberPanel Installed** - Requires working CyberPanel installation
- **CyberPanel CLI** - Command line interface must be functional

## 🔧 Usage Examples

### Create a New User
1. Select "Create User" from menu
2. Enter user details (first name, last name, email)
3. Set username and secure password
4. Choose website limit and ACL permissions
5. Set security level (HIGH/LOW)

### Create a Website
1. Select "Create Website" from menu
2. Choose hosting package
3. Enter domain name and owner
4. Set PHP version
5. Configure SSL, DKIM, and openBasedir protection

### Manage DNS
1. Access full menu (option 8)
2. Use DNS functions (15-20)
3. Create zones and records as needed

## 🎯 Integration Benefits

- **Unified Interface** - One menu for all CyberPanel operations
- **User-Friendly** - Simplified interface for common tasks
- **Admin-Friendly** - Full access to all advanced functions
- **Consistent Experience** - Matches CyberPanel Mods design
- **Auto-Download** - Scripts download automatically if not present

## 🤝 Original Credits

Based on **cyberpanel-friendly-cli** by Alfred Valderrama
- Original repository: https://github.com/redopsbay/cyberpanel
- Enhanced and integrated into CyberPanel Mods

## 📞 Support

- **Issues**: Report issues in the main CyberPanel Mods repository
- **Documentation**: Complete guides available in `/docs` folder
- **Community**: Join discussions on GitHub

---

**🎉 Welcome to the enhanced CyberPanel experience - now serving both users and administrators!**
