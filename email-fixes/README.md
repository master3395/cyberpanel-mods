# CyberPanel Email Fixes

This directory contains email-related fixes and enhancements for CyberPanel installations.

## Available Fixes

### 1. Sieve (Filter) Fix for SnappyMail

**Script:** `sieve_fix_enhanced.sh`

**Description:** Installs and configures Sieve (Filter) functionality for SnappyMail in CyberPanel installations. This fix addresses the issue where CyberPanel doesn't automatically install Sieve filtering capabilities with SnappyMail.

## Features

- ✅ **Cross-platform compatibility** - Works on all CyberPanel-supported operating systems
- ✅ **Automatic OS detection** - Detects and adapts to your specific OS and version
- ✅ **Comprehensive package installation** - Installs all required Sieve packages
- ✅ **Firewall configuration** - Automatically configures firewall rules
- ✅ **Service management** - Properly starts and configures all required services
- ✅ **Configuration backup** - Backs up existing configurations before making changes
- ✅ **Log file management** - Creates and configures proper log files
- ✅ **Default filtering rules** - Creates basic email filtering rules
- ✅ **Verification system** - Verifies installation and configuration

## Supported Operating Systems

- **Ubuntu** (all versions)
- **AlmaLinux** 8.x, 9.x
- **RockyLinux** 8.x, 9.x
- **RHEL** 8.x, 9.x
- **CentOS** 7.x, 8.x
- **CloudLinux** 7.x, 8.x
- **openEuler**
- **Debian** (all versions)

## What the Sieve Fix Does

### 1. Package Installation
- Installs `dovecot-pigeonhole` (Sieve implementation for Dovecot)
- Installs `dovecot-managesieved` (Sieve management protocol)
- Installs required Postfix packages for LMTP delivery
- Installs additional dependencies as needed

### 2. Firewall Configuration
- Opens port 4190 for Sieve management
- Configures email-related ports (25, 587, 465, 143, 993, 110, 995)
- Supports firewalld, iptables, and ufw

### 3. Directory and Log Setup
- Creates `/etc/dovecot/sieve/global/` directory
- Creates necessary log files in `/var/log/`
- Sets proper ownership and permissions

### 4. Configuration
- Configures Dovecot for Sieve support
- Configures Postfix for LMTP delivery
- Creates default Sieve filtering rules
- Enables proper service integration

### 5. Service Management
- Restarts Dovecot and Postfix services
- Enables services to start on boot
- Restarts SpamAssassin if present

## Usage

### From CyberPanel Mods Menu
1. Run the main CyberPanel Mods menu: `./cyberpanel-mods-menu.sh`
2. Select option 9: "📧 Email Fixes"
3. Select option 1: "Sieve (Filter) Fix for SnappyMail"
4. Follow the prompts to complete installation

### Direct Execution
```bash
# Make executable (if needed)
chmod +x email-fixes/sieve_fix_enhanced.sh

# Run the fix
./email-fixes/sieve_fix_enhanced.sh

# Or with options
./email-fixes/sieve_fix_enhanced.sh --help    # Show help
./email-fixes/sieve_fix_enhanced.sh --verify  # Verify installation
./email-fixes/sieve_fix_enhanced.sh --force   # Force reinstallation
```

## Prerequisites

- Root or sudo access
- CyberPanel installation (recommended)
- Dovecot installed and configured
- Postfix installed and configured
- Internet connection for package downloads

## Verification

After installation, you can verify the setup:

### 1. Check Services
```bash
systemctl status dovecot
systemctl status postfix
```

### 2. Check Ports
```bash
netstat -tulpn | grep :4190
```

### 3. Check Sieve Configuration
```bash
dovecot -n | grep sieve
```

### 4. Test Sieve Syntax
```bash
sievec -t /etc/dovecot/sieve/global/default.sieve
```

## Default Filtering Rules

The script creates basic filtering rules in `/etc/dovecot/sieve/global/default.sieve`:

- **Spam filtering**: Moves emails marked as spam to "Junk" folder
- **Newsletter filtering**: Moves newsletters to "Newsletters" folder

You can customize these rules or add new ones as needed.

## Troubleshooting

### Common Issues

1. **Port 4190 not listening**
   - Check if Dovecot is running: `systemctl status dovecot`
   - Check firewall rules: `firewall-cmd --list-ports`

2. **Sieve not working in SnappyMail**
   - Verify Dovecot configuration: `dovecot -n | grep sieve`
   - Check log files: `tail -f /var/log/dovecot-sieve.log`

3. **Permission errors**
   - Check ownership: `ls -la /etc/dovecot/sieve/`
   - Fix ownership: `chown -R vmail:vmail /etc/dovecot/sieve/`

### Log Files

- `/var/log/cyberpanel_sieve_fix.log` - Installation log
- `/var/log/dovecot-sieve.log` - Sieve processing log
- `/var/log/dovecot-sieve-errors.log` - Sieve error log
- `/var/log/dovecot-lda.log` - Local delivery log
- `/var/log/dovecot-lmtp.log` - LMTP delivery log

## Advanced Configuration

### Custom Sieve Rules

You can create custom Sieve rules by editing:
- `/etc/dovecot/sieve/global/default.sieve` - Global rules
- User-specific rules in their home directories

### Example Custom Rule
```sieve
require ["fileinto", "mailbox"];

# Move emails from specific domain to folder
if header :contains "From" "@example.com" {
    fileinto "Example Folder";
    stop;
}

# Forward important emails
if header :contains "Subject" "URGENT" {
    redirect "admin@example.com";
}
```

## Security Considerations

- The script runs with root privileges
- Firewall rules are configured automatically
- Log files are created with proper permissions
- Configuration files are backed up before modification

## Support

For issues and support:
- GitHub Issues: [CyberPanel Mods Repository](https://github.com/master3395/cyberpanel-mods/issues)
- Community: [CyberPanel Community Forum](https://community.cyberpanel.net/)

## Changelog

### Version 1.0.0
- Initial release
- Cross-platform compatibility
- Comprehensive installation and configuration
- Automatic service management
- Default filtering rules
- Verification system

## License

This project is part of the CyberPanel Mods collection and follows the same licensing terms.
