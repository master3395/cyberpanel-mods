# Sieve Fix Quick Guide

## Quick Start

### 1. Run the Fix
```bash
./email-fixes/sieve_fix_enhanced.sh
```

### 2. Verify Installation
```bash
./email-fixes/sieve_fix_enhanced.sh --verify
```

## What Gets Fixed

- ✅ Installs Sieve packages for your OS
- ✅ Configures firewall (port 4190)
- ✅ Sets up Dovecot for Sieve
- ✅ Configures Postfix for LMTP
- ✅ Creates default filtering rules
- ✅ Restarts all services

## Supported OS

- Ubuntu/Debian
- AlmaLinux 8.x/9.x
- RockyLinux 8.x/9.x
- RHEL 8.x/9.x
- CentOS 7.x/8.x
- CloudLinux 7.x/8.x
- openEuler

## Quick Commands

```bash
# Check if Sieve is working
netstat -tulpn | grep :4190

# Check Dovecot status
systemctl status dovecot

# Check Postfix status
systemctl status postfix

# View Sieve logs
tail -f /var/log/dovecot-sieve.log

# Test Sieve syntax
sievec -t /etc/dovecot/sieve/global/default.sieve
```

## Default Rules Created

- Spam emails → Junk folder
- Newsletters → Newsletters folder

## Customization

Edit `/etc/dovecot/sieve/global/default.sieve` to add your own rules.

## Troubleshooting

1. **Port 4190 not open**: Check firewall rules
2. **Sieve not working**: Check Dovecot configuration
3. **Permission errors**: Fix ownership of `/etc/dovecot/sieve/`

## Need Help?

- Check logs in `/var/log/cyberpanel_sieve_fix.log`
- Run verification: `./sieve_fix_enhanced.sh --verify`
- Visit: https://github.com/master3395/cyberpanel-mods
