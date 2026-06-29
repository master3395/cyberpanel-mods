# 🛡️ ImunifyAV/360 + OpenLiteSpeed Integration Fix

Self-contained, idempotent fix for the most common **ImunifyAV / Imunify360**
and **OpenLiteSpeed panel** problems on CyberPanel.

- **Script:** [`core-fixes/imunify_ols_integration_fix.sh`](../core-fixes/imunify_ols_integration_fix.sh)
- **Master menu:** Core Fixes → **8. ImunifyAV/360 + OpenLiteSpeed Integration Fix**
- **Log file:** `/var/log/cyberpanel_imunify_ols_fix.log`

---

## 🚀 Quick Start

Run directly from this repository:

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/imunify_ols_integration_fix.sh | bash
```

Or via the master menu:

```bash
sh <(curl https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh || wget -O - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh)
```

Then choose **Core Fixes & Repairs → 8**.

The script must run as **root** on a host where **CyberPanel is installed**. It is
safe to run multiple times — every modified file is backed up with a timestamped
`.bak-imunify-ols-<timestamp>` suffix.

---

## 🐛 Problems It Fixes

| # | Symptom | Root cause |
|---|---------|------------|
| 1 | ImunifyAV UI opens but shows **no websites / no scan history** (upstream [#1825](https://github.com/usmannasir/cyberpanel/issues/1825)) | `integration.conf` missing the `[integration_scripts]` hooks that feed CyberPanel users/domains to Imunify |
| 2 | **Cannot install ImunifyAV** after upgrade/uninstall; `imav-deploy.sh` aborts with `PANEL=` (upstream [#1826](https://github.com/usmannasir/cyberpanel/issues/1826)) | Imunify's generic-panel detection needs a valid `integration.conf` **before** the deploy script runs |
| 3 | `cat: /home/cyberpanel/switchLSWSStatus: No such file` in the UI | The install-progress status file did not exist |
| 4 | Broken/blank panel assets, ImunifyAV/360 UI not loading on `:8090` | OLS vhost served `/static/` from the wrong path and had no lsphp context for `/imunifyav/` and `/imunify/` |
| 5 | **CSRF 403** on every panel POST (login/forms) behind the OLS reverse proxy | OpenLiteSpeed forwards a duplicated `Origin` header; Django's CSRF origin check fails |

---

## 🔧 What It Changes

All steps are idempotent and create timestamped backups.

1. **Status file** — creates `/home/cyberpanel/switchLSWSStatus` owned by
   `cyberpanel:cyberpanel`.
2. **`integration.conf`** — writes `/etc/sysconfig/imunify360/integration.conf`
   for the detected product (ImunifyAV or Imunify360) with:
   - `[paths]` → UI path under `/usr/local/CyberCP/public/`
   - `[integration_scripts]` → wired to `CyberCP/CLScript/*.py`
     (`panel_info`, `users`, `domains`, `packages`, `resellers`, `admins`, `db_info`)
   - `[malware]` and `[web_server]` (LiteSpeed) sections
   - makes the referenced CLScript and `execute.py` files executable
3. **OLS panel vhost** — rewrites
   `/usr/local/lsws/conf/vhosts/CyberPanel/vhost.conf` so `/static/` points to
   `public/static/` and adds lsphp contexts for `/phpmyadmin/`, `/snappymail/`,
   `/imunifyav/`, `/imunify/`. If a **custom** panel vhost is detected, only the
   `/static/` path is patched in place.
4. **CSRF middleware** — installs `CyberCP/originDedupeMiddleware.py` and
   registers `OriginDedupeMiddleware` immediately before `CsrfViewMiddleware`.
5. **Restart** — restarts `cyberpanel` + OpenLiteSpeed only when something
   changed and reloads the Imunify agent if it is installed.

---

## ✅ Compatibility

AlmaLinux 8/9/10 · RockyLinux 8/9 · RHEL 8/9 · CentOS 7/9 · CloudLinux 7/8 ·
Ubuntu 20.04–24.04.

On **LiteSpeed Enterprise** or non-OLS servers the vhost step is skipped
gracefully (the rest of the fixes still apply).

---

## 🔁 Rolling Back

Every modified file has a timestamped backup next to it, e.g.:

```bash
ls -la /usr/local/lsws/conf/vhosts/CyberPanel/vhost.conf.bak-imunify-ols-*
ls -la /etc/sysconfig/imunify360/integration.conf.bak-imunify-ols-*
```

Restore with `cp -a <backup> <original>` and restart OpenLiteSpeed.

---

## 🧪 Verification

After running, the script prints a summary and you can confirm manually:

```bash
# integration hooks present
grep CloudLinuxUsers.py /etc/sysconfig/imunify360/integration.conf

# vhost static path + imunify context
grep -E 'public/static|context /imunifyav/' /usr/local/lsws/conf/vhosts/CyberPanel/vhost.conf

# panel responds (302 = login redirect)
curl -sk -o /dev/null -w '%{http_code}\n' https://127.0.0.1:8090/firewall/imunifyAV
```

Then open **Security → ImunifyAV** in CyberPanel. If Imunify was not installed
yet, click **Install Now** — it will now complete successfully.
