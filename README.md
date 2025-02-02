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

### 🔄 [phpmod.sh](https://github.com/master3395/cyberpanel-mods/blob/main/phpmod.sh)
phpMyAdmin + Snappymail version changer. Enter PHP version without dot (e.g., for PHP 8.1 enter `81`).

```bash
# Change PHP version
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/phpmod.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/phpmod.sh)
```

### 🔥 [modsec_rules_v_changer.sh](https://github.com/master3395/cyberpanel-mods/blob/main/modsec_rules_v_changer.sh)
OWASP ModSecurity rules version changer. Input the version you want to change to (e.g., 3.3.4).

```bash
# Change OWASP ModSecurity rules version
bash <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/modsec_rules_v_changer.sh) || bash <(wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/modsec_rules_v_changer.sh)
```

### 📧 [snappymail_v_changer.sh](https://github.com/master3395/cyberpanel-mods/blob/main/snappymail_v_changer.sh)
Snappymail version changer. Input the version you want to change to (e.g., 2.18.2).

```bash
# Change Snappymail version
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/snappymail_v_changer.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/snappymail_v_changer.sh)
```

### 🗂️ [phpmyadmin_v_changer.sh](https://github.com/master3395/cyberpanel-mods/blob/main/phpmyadmin_v_changer.sh)
phpMyAdmin version changer. Input the version you want to change to (e.g., 5.2.0).

```bash
# Change phpMyAdmin version
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/phpmyadmin_v_changer.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/phpmyadmin_v_changer.sh)
```


# cyberpanel-mods
Small changes to cyberpanel core installation

phpMyAdmin + Snappymail version changer. Enter php version without "."

# For php8.1 write choose "81" in the script.
```
sh <(curl https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/phpmod.sh || wget -O - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/phpmod.sh)
```
![](https://community.cyberpanel.net/uploads/default/original/2X/0/00feaa708386036ce807b7d7b67c57230f2dfe45.png)

______________________________
# OWSAP modsecurity rules version changer
Input version you want to change to e.g 3.3.4
```
bash <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/modsec_rules_v_changer.sh) || bash <(wget -O - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/modsec_rules_v_changer.sh) 
```
![imagem](https://github.com/tbaldur/cyberpanel-mods/assets/97204751/a94ab169-6333-40ab-9e11-8632b38aba90)

______________________________

# Snappymail version changer
Input version you want to change to e.g 2.18.2
```
sh <(curl https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/snappymail_v_changer.sh || wget -O - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/snappymail_v_changer.sh)
```
![imagem](https://user-images.githubusercontent.com/97204751/192609788-355a24ec-e0cf-407a-91b7-51bb4121e5f4.png)

______________________________
# phpMyAdmin version changer
Input version you want to change to e.g 5.2.0
```
sh <(curl https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/phpmyadmin_v_changer.sh || wget -O - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/phpmyadmin_v_changer.sh)
```
![imagem](https://user-images.githubusercontent.com/97204751/208486782-a0205d4f-8698-4cdb-bad1-9f47e19bf5ba.png)

______________________________
# Fix missing acme-challenge context on all vhosts config
```
sh <(curl https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/fix_ssl_missing_context.sh || wget -O - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/fix_ssl_missing_context.sh)
```
![imagem](https://user-images.githubusercontent.com/97204751/186309709-30e11069-4833-4d05-b118-d7ba55960b56.png)

_____________________________
# Remove two-step authentication when you lost it
```
sh <(curl https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/disable_2fa.sh || wget -O - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/disable_2fa.sh)
```
![imagem](https://user-images.githubusercontent.com/97204751/186309709-30e11069-4833-4d05-b118-d7ba55960b56.png)

_____________________________
# Install cyberpanel core database in case you deleted it
```
sh <(curl https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/restore_cyberpanel_database.sh || wget -O - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/restore_cyberpanel_database.sh)
```

______________________________
# ALPHA FEATURES BELOW! NEEDS PROPER TESTING! USE AT YOUR OWN RISK!
## CyberPanel core permissions fix

Run in case you messed your CyberPanel permissions. 
```
sh <(curl https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/fix_permissions.sh || wget -O - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/fix_permissions.sh)
```
