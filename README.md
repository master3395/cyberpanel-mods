# cyberpanel-mods 🚀

small changes to cyberpanel core installation — scripts and utilities for common tasks, fixes, and optimizations.

---

## 👤 contributors

scripts contributed by:  
- [tbaldur](https://github.com/tbaldur)  
- [mehdiakram](https://github.com/mehdiakram)  
- [ethamah](https://github.com/ethamah)

---

## ⚙️ how to use

run the commands in your terminal — scripts use `curl` or `wget` to download and execute live from github.

---

## 📜 scripts and commands

### 🌐 migrate dns: cloudflare ➜ powerdns

```bash
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cloudflare_to_powerdns.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cloudflare_to_powerdns.sh)
```

---

### 🛡️ crowdsec updater

```bash
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/crowdsec_update.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/crowdsec_update.sh)
```

---

### 🔗 fix symbolic links in cyberpanel

```bash
sh <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel_fix_symbolic_links.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel_fix_symbolic_links.sh)
```

---

### 🧰 phpmod.sh — phpmyadmin + snappymail version changer  
> enter php version without dot (e.g. use `81` for php 8.1)

```bash
sh <(curl https://raw.githubusercontent.com/ethamah/cyberpanel-mods/refs/heads/main/phpmod.sh || https://raw.githubusercontent.com/ethamah/cyberpanel-mods/refs/heads/main/phpmod.sh)
```

![phpmod](https://community.cyberpanel.net/uploads/default/original/2X/0/00feaa708386036ce807b7d7b67c57230f2dfe45.png)

---

### 🧪 phpmod v2

```bash
sh <(curl https://raw.githubusercontent.com/ethamah/cyberpanel-mods/refs/heads/main/phpmod_v2.sh || https://raw.githubusercontent.com/ethamah/cyberpanel-mods/refs/heads/main/phpmod_v2.sh)
```

![phpmod-v2](https://raw.githubusercontent.com/ethamah/cyberpanel-mods/refs/heads/main/Screenshot%202025-05-01%20101827.png)

---

### 🔥 owasp modsecurity rules version changer  
> input the version to install, e.g. `3.3.4`

```bash
bash <(curl -s https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/modsec_rules_v_changer.sh) || bash <(wget -O - https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/modsec_rules_v_changer.sh)
```

![modsec](https://github.com/tbaldur/cyberpanel-mods/assets/97204751/a94ab169-6333-40ab-9e11-8632b38aba90)

---

### 📧 snappymail version changer  
> input the version to install, e.g. `2.18.2`

```bash
sh <(curl https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/snappymail_v_changer.sh || wget -O - https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/snappymail_v_changer.sh)
```

![snappymail](https://user-images.githubusercontent.com/97204751/192609788-355a24ec-e0cf-407a-91b7-51bb4121e5f4.png)

---

### 🗂️ phpmyadmin version changer  
> input the version to install, e.g. `5.2.0`

```bash
sh <(curl https://raw.githubusercontent.com/ethamah/cyberpanel-mods/refs/heads/main/phpmyadmin_v_changer.sh || wget -O - https://raw.githubusercontent.com/ethamah/cyberpanel-mods/refs/heads/main/phpmyadmin_v_changer.sh)
```

![phpmyadmin](https://user-images.githubusercontent.com/97204751/208486782-a0205d4f-8698-4cdb-bad1-9f47e19bf5ba.png)

---

### 🔐 fix missing acme-challenge context

```bash
sh <(curl https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/fix_ssl_missing_context.sh || wget -O - https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/fix_ssl_missing_context.sh)
```

![acme](https://user-images.githubusercontent.com/97204751/186309709-30e11069-4833-4d05-b118-d7ba55960b56.png)

---

### 🔓 disable two-step authentication  
> use this if you lose 2fa access to your cyberpanel

```bash
sh <(curl https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/disable_2fa.sh || wget -O - https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/disable_2fa.sh)
```

![2fa](https://user-images.githubusercontent.com/97204751/186309709-30e11069-4833-4d05-b118-d7ba55960b56.png)

---

### 🛠️ restore cyberpanel core database  
> use if the panel db has been deleted

```bash
sh <(curl https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/restore_cyberpanel_database.sh || wget -O - https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/restore_cyberpanel_database.sh)
```

---

## ⚠️ alpha features — use at your own risk

### 🧽 fix_permissions.sh  
> restore correct cyberpanel file permissions

```bash
sh <(curl https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/fix_permissions.sh || wget -O - https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/fix_permissions.sh)
```