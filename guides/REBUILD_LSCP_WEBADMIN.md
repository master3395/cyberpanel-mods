# Rebuild LSCP / WebAdmin (issue #1839)

Restore CyberPanel WebAdmin when `/usr/local/lscp/conf` is missing or corrupted, without a full reinstall.

Upstream: [usmannasir/cyberpanel#1839](https://github.com/usmannasir/cyberpanel/issues/1839)

## Symptoms

- Panel URL (`https://IP:8090` or your custom port) does not load
- `/usr/local/lscp/conf` is missing or empty
- Sites still work (OpenLiteSpeed, document roots, MariaDB OK)
- Full `install.sh` fails with `ftpgroup` / `ftpuser` already exists (expected on a live server; do not use full install for this)

## One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/rebuild_lscp_webadmin.sh | bash
```

Or from a local clone / master menu: **Core Fixes → 9. Rebuild LSCP / WebAdmin**.

## What it restores

- `/usr/local/lscp` runtime: `conf`, certs, `pythonenv.conf`, `lscpd` binary
- Uses local `/usr/local/CyberCP/install/lscp.tar.gz` when present
- Otherwise downloads from `usmannasir/cyberpanel` (version-matched, fallback `v2.4.8`)
- Timestamped backup under `/usr/local/lscp-backup-YYYYMMDD_HHMMSS`
- Ubuntu 22 / 24 / 26: installs `lscpd.0.4.0`
- Restarts `lscpd` and probes HTTPS on the port from `bind.conf` (default 8090)

## What it does not touch

- Website document roots (`/home/*/public_html`)
- MariaDB / MySQL data
- OpenLiteSpeed vhosts or site configs
- FTP / mail account databases

## Post-checks

```bash
systemctl status lscpd --no-pager
cat /usr/local/lscp/conf/bind.conf
ss -tlnp | grep -E '8090|2087'
curl -skI "https://127.0.0.1:$(grep -Eo '[0-9]+$' /usr/local/lscp/conf/bind.conf | head -1)/" | head -5
```

Open `https://YOUR-SERVER-IP:PORT` in a browser. Log file: `/var/log/cyberpanel_rebuild_lscp.log`.

## Notes

- Prefer a VPS snapshot before any recovery on production.
- If download returns HTTP 429, wait and retry, or copy `install/lscp.tar.gz` into `/usr/local/CyberCP/install/` first.
- Existing `ftpgroup` / `ftpuser` only matters for the full installer, not this script.
