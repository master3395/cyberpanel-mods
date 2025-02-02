# CyberPanel Mods 🚀

This repository contains scripts and utilities for CyberPanel to help with common tasks, fixes, and optimizations.

## Overview

These scripts were created and contributed by the following users:  
- [tbaldur](https://github.com/tbaldur)  
- [mehdiakram](https://github.com/mehdiakram)  

## How to Use ⚡

To use these scripts, copy the respective command and run it directly in your terminal. The commands use `curl` or `wget` to download and execute the scripts dynamically.

---

## 📜 Scripts and Commands

### 🌐 [cloudflare_to_powerdns.sh](https://github.com/master3395/cyberpanel-mods/blob/main/cloudflare_to_powerdns.sh)
Migrates DNS records from Cloudflare to PowerDNS.

```bash
# Migrate Cloudflare DNS records to PowerDNS
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cloudflare_to_powerdns.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cloudflare_to_powerdns.sh)
```

### 🛡️ [crowdsec_update.sh](https://github.com/master3395/cyberpanel-mods/blob/main/crowdsec_update.sh)
Updates CrowdSec and manages configurations.

```bash
# Update CrowdSec and apply configurations
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/crowdsec_update.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/crowdsec_update.sh)
```

### 🔗 [cyberpanel_fix_symbolic_links.sh](https://github.com/master3395/cyberpanel-mods/blob/main/cyberpanel_fix_symbolic_links.sh)
Fixes symbolic link issues in CyberPanel.

```bash
# Fix symbolic link issues in CyberPanel
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel_fix_symbolic_links.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel_fix_symbolic_links.sh)
```

### 🗑️ [cyberpanel_sessions.sh](https://github.com/master3395/cyberpanel-mods/blob/main/cyberpanel_sessions.sh)
Manages and clears old CyberPanel sessions.

```bash
# Clear old CyberPanel sessions
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel_sessions.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel_sessions.sh)
```

### 🔄 [cyberpanel_sessions_cronjob.sh](https://github.com/master3395/cyberpanel-mods/blob/main/cyberpanel_sessions_cronjob.sh)
Automates session cleanup with a cronjob.

```bash
# Schedule CyberPanel session cleanup via cronjob
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel_sessions_cronjob.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel_sessions_cronjob.sh)
```

### 🌍 [defaultwebsitepage.sh](https://github.com/master3395/cyberpanel-mods/blob/main/defaultwebsitepage.sh)
Sets a custom default webpage for new websites.

```bash
# Set custom default webpage
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/defaultwebsitepage.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/defaultwebsitepage.sh)
```

### 🔓 [disable_2fa.sh](https://github.com/master3395/cyberpanel-mods/blob/main/disable_2fa.sh)
Disables two-factor authentication in CyberPanel.

```bash
# Disable CyberPanel 2FA
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/disable_2fa.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/disable_2fa.sh)
```

### 🚨 [fix_503_service_unavailable.sh](https://github.com/master3395/cyberpanel-mods/blob/main/fix_503_service_unavailable.sh)
Fixes 503 Service Unavailable errors in CyberPanel.

```bash
# Fix CyberPanel 503 errors
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/fix_503_service_unavailable.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/fix_503_service_unavailable.sh)
```

### 🔧 [fix_missing_wp_cli.sh](https://github.com/master3395/cyberpanel-mods/blob/main/fix_missing_wp_cli.sh)
Installs or repairs missing WP-CLI (WordPress Command-Line Interface).

```bash
# Install or fix WP-CLI
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/fix_missing_wp_cli.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/fix_missing_wp_cli.sh)
```

### 📂 [install_pureftpd.sh](https://github.com/master3395/cyberpanel-mods/blob/main/install_pureftpd.sh)
Installs and configures Pure-FTPd.

```bash
# Install Pure-FTPd
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/install_pureftpd.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/install_pureftpd.sh)
```

### 📂 [install_vsftpd.sh](https://github.com/master3395/cyberpanel-mods/blob/main/install_vsftpd.sh)
Installs and configures VSFTPD.

```bash
# Install VSFTPD
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/install_vsftpd.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/install_vsftpd.sh)
```

### 🔄 [mariadb_v_changer.sh](https://github.com/master3395/cyberpanel-mods/blob/main/mariadb_v_changer.sh)
Changes the MariaDB version.

```bash
# Change MariaDB version
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/mariadb_v_changer.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/mariadb_v_changer.sh)
```

### 🔥 [modsec_rules_v_changer.sh](https://github.com/master3395/cyberpanel-mods/blob/main/modsec_rules_v_changer.sh)
Changes the OWASP ModSecurity rules version.

```bash
# Update ModSecurity rules
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/modsec_rules_v_changer.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/modsec_rules_v_changer.sh)
```