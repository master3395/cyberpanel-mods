#!/bin/bash
#
# Rebuild LSCP / WebAdmin runtime for CyberPanel
# ---------------------------------------------------------------------------
# Fixes missing /usr/local/lscp/conf (and related WebAdmin :8090 failures)
# after a corrupted repair attempt — without a full reinstall.
#
# Addresses: GitHub usmannasir/cyberpanel#1839
#
# Safe scope (does NOT touch):
#   - Website document roots (/home/*/public_html)
#   - MariaDB / MySQL data
#   - OpenLiteSpeed vhosts or site configs
#   - User email / FTP account data
#
# Do NOT run the full CyberPanel install.sh for this failure mode. Existing
# ftpgroup/ftpuser (groupadd abort) is normal on a live server and is unrelated
# to this recovery.
#
# Usage (one-liner):
#   curl -fsSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/rebuild_lscp_webadmin.sh | bash
#
# Supported: Ubuntu 20.04–26.04, AlmaLinux/Rocky/RHEL/CloudLinux 8/9/10, etc.
#            wherever CyberPanel + lscpd are installed.

set -uo pipefail

# --- Colors ----------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Paths -----------------------------------------------------------------
CYBERCP="${CYBERCP:-/usr/local/CyberCP}"
LSCP_ROOT="/usr/local/lscp"
LOG_FILE="/var/log/cyberpanel_rebuild_lscp.log"
TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="/usr/local/lscp-backup-${TS}"
TMP_TAR=""

log() {
    local level="$1"; shift
    local msg="$*"
    local line="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $msg"
    echo -e "$line" | tee -a "$LOG_FILE"
}

info()  { echo -e "${CYAN}$*${NC}" | tee -a "$LOG_FILE"; }
ok()    { echo -e "${GREEN}$*${NC}" | tee -a "$LOG_FILE"; }
warn()  { echo -e "${YELLOW}$*${NC}" | tee -a "$LOG_FILE"; }
err()   { echo -e "${RED}$*${NC}" | tee -a "$LOG_FILE"; }

cleanup() {
    if [[ -n "$TMP_TAR" && -f "$TMP_TAR" ]]; then
        rm -f "$TMP_TAR"
    fi
}
trap cleanup EXIT

# --- Preconditions ---------------------------------------------------------
if [[ $(id -u) -ne 0 ]]; then
    err "ERROR: Must run as root."
    exit 1
fi

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
chmod 600 "$LOG_FILE" 2>/dev/null || true

echo ""
echo -e "$BLUE╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Rebuild LSCP / WebAdmin runtime (issue #1839)               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
info "This restores /usr/local/lscp conf + certs + lscpd only."
info "Websites, MariaDB, and OpenLiteSpeed vhosts are left untouched."
info "Log: $LOG_FILE"
echo ""

if [[ ! -d "$CYBERCP" ]]; then
    err "ERROR: CyberPanel not found at $CYBERCP"
    exit 1
fi

# --- Detect upstream branch for archive download ---------------------------
detect_branch() {
    local ver_file="$CYBERCP/version.txt"
    local version="" build=""
    if [[ -f "$ver_file" ]]; then
        version=$(python3 -c "import json; d=json.load(open('$ver_file')); print(d.get('version',''))" 2>/dev/null || true)
        build=$(python3 -c "import json; d=json.load(open('$ver_file')); print(d.get('build',''))" 2>/dev/null || true)
    fi
    if [[ -n "$version" ]]; then
        # e.g. 2.4.8 + build 8 -> v2.4.8 ; 2.5.5 + build dev -> v2.5.5-dev
        if [[ "$build" == "dev" ]]; then
            echo "v${version}-dev"
            return
        fi
        echo "v${version}"
        return
    fi
    echo "v2.4.8"
}

# --- Find or download lscp.tar.gz ------------------------------------------
download_lscp_tar() {
    local branch="$1"
    local url="https://raw.githubusercontent.com/usmannasir/cyberpanel/${branch}/install/lscp.tar.gz"
    local fallback="https://raw.githubusercontent.com/usmannasir/cyberpanel/v2.4.8/install/lscp.tar.gz"
    local out="/tmp/lscp-rebuild-${TS}.tar.gz"
    local code

    info "Downloading lscp.tar.gz from usmannasir/cyberpanel (${branch})..."
    code=$(curl -fsSL --retry 3 --retry-delay 5 -w '%{http_code}' -o "$out" "$url" 2>/dev/null || echo "000")
    if [[ "$code" != "200" ]] || [[ ! -s "$out" ]]; then
        warn "Download from ${branch} failed (HTTP ${code}); trying v2.4.8..."
        rm -f "$out"
        code=$(curl -fsSL --retry 3 --retry-delay 5 -w '%{http_code}' -o "$out" "$fallback" 2>/dev/null || echo "000")
    fi
    if [[ "$code" != "200" ]] || [[ ! -s "$out" ]]; then
        rm -f "$out"
        err "ERROR: Failed to download lscp.tar.gz (HTTP ${code})."
        err "GitHub raw may be rate-limited (429). Retry later, or place"
        err "install/lscp.tar.gz under $CYBERCP/install/ and re-run."
        return 1
    fi
    # Basic sanity: gzip magic
    if ! gzip -t "$out" 2>/dev/null; then
        err "ERROR: Downloaded file is not a valid gzip archive (possible HTML error page)."
        rm -f "$out"
        return 1
    fi
    TMP_TAR="$out"
    echo "$out"
    return 0
}

locate_tar() {
    local candidate branch downloaded
    for candidate in \
        "${CYBERCP}/install/lscp.tar.gz" \
        "/usr/local/CyberCP/install/lscp.tar.gz"
    do
        if [[ -f "$candidate" && -s "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done
    branch=$(detect_branch)
    downloaded=$(download_lscp_tar "$branch") || return 1
    echo "$downloaded"
}

TAR=$(locate_tar) || exit 1
ok "Using archive: $TAR"

# --- Backup existing LSCP tree ---------------------------------------------
if [[ -d "$LSCP_ROOT" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp -a "$LSCP_ROOT/." "$BACKUP_DIR/" 2>/dev/null || true
    ok "Backed up existing LSCP to $BACKUP_DIR"
else
    warn "No existing $LSCP_ROOT tree (expected for #1839-style corruption)."
fi

# --- Extract runtime -------------------------------------------------------
mkdir -p /usr/local
info "Extracting LSCP runtime into /usr/local ..."
if ! tar -xzf "$TAR" -C /usr/local; then
    err "ERROR: tar extract failed."
    exit 1
fi

if [[ ! -d "$LSCP_ROOT/conf" ]]; then
    err "ERROR: After extract, $LSCP_ROOT/conf is still missing."
    err "Archive may be incomplete. Restore from backup if needed: $BACKUP_DIR"
    exit 1
fi
ok "Restored $LSCP_ROOT/conf"

# Prefer previously working conf files when extract left empties
if [[ -d "$BACKUP_DIR/conf" ]]; then
    for f in pythonenv.conf bind.conf cert.pem key.pem php.ini mime.properties; do
        if [[ -f "$BACKUP_DIR/conf/$f" ]] && [[ ! -s "$LSCP_ROOT/conf/$f" ]]; then
            cp -a "$BACKUP_DIR/conf/$f" "$LSCP_ROOT/conf/$f"
            info "Restored conf/$f from backup"
        fi
    done
    # Prefer original bind.conf (custom panel port) when present
    if [[ -f "$BACKUP_DIR/conf/bind.conf" ]]; then
        cp -a "$BACKUP_DIR/conf/bind.conf" "$LSCP_ROOT/conf/bind.conf"
        info "Kept previous bind.conf (panel listen port)"
    fi
    if [[ -d "$BACKUP_DIR/conf/ssl" ]] && [[ ! -d "$LSCP_ROOT/conf/ssl" ]]; then
        cp -a "$BACKUP_DIR/conf/ssl" "$LSCP_ROOT/conf/ssl"
    fi
fi

# pythonenv.conf
if [[ ! -f "$LSCP_ROOT/conf/pythonenv.conf" ]]; then
    cat > "$LSCP_ROOT/conf/pythonenv.conf" <<'PYENV'
path=/usr/local/CyberPanel/bin/python
PYENV
    ok "Wrote default pythonenv.conf"
fi

# TLS material
if [[ ! -f "$LSCP_ROOT/conf/cert.pem" ]] || [[ ! -f "$LSCP_ROOT/conf/key.pem" ]]; then
    mkdir -p "$LSCP_ROOT/conf"
    openssl req -x509 -nodes -days 820 -newkey rsa:2048 \
        -keyout "$LSCP_ROOT/conf/key.pem" \
        -out "$LSCP_ROOT/conf/cert.pem" \
        -subj "/CN=cyberpanel.local" >/dev/null 2>&1 || true
    warn "Generated self-signed LSCP certs (issue a hostname SSL from the panel later if needed)"
fi

# Default bind.conf if missing
if [[ ! -f "$LSCP_ROOT/conf/bind.conf" ]]; then
    echo '*:8090' > "$LSCP_ROOT/conf/bind.conf"
    ok "Wrote default bind.conf (*:8090)"
fi

# --- lscpd binary ----------------------------------------------------------
mkdir -p "$LSCP_ROOT/bin"
lscpd_selection='lscpd-0.3.1'
if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    if [[ "${ID:-}" = "ubuntu" || "${ID:-}" = "debian" ]]; then
        ver="${VERSION_ID%%.*}"
        if [[ "$ver" = "22" || "$ver" = "24" || "$ver" = "26" ]]; then
            lscpd_selection='lscpd.0.4.0'
        fi
    fi
fi
if [[ "$(uname -m)" = "aarch64" ]]; then
    lscpd_selection='lscpd.aarch64'
fi

SRC=""
for c in "${CYBERCP}/${lscpd_selection}" "/usr/local/CyberCP/${lscpd_selection}"; do
    if [[ -f "$c" ]]; then SRC="$c"; break; fi
done

# Prefer existing working binary from backup if selection missing
if [[ -z "$SRC" && -x "$BACKUP_DIR/bin/lscpd" ]]; then
    SRC="$BACKUP_DIR/bin/lscpd"
fi
if [[ -z "$SRC" && -x "$LSCP_ROOT/bin/lscpd" ]]; then
    SRC="$LSCP_ROOT/bin/lscpd"
fi

if [[ -n "$SRC" ]]; then
    cp -f "$SRC" "$LSCP_ROOT/bin/lscpd"
    chmod 755 "$LSCP_ROOT/bin/lscpd"
    chown root:root "$LSCP_ROOT/bin/lscpd"
    ok "Installed lscpd from $SRC"
else
    warn "WARNING: Could not find ${lscpd_selection} under $CYBERCP"
    warn "If lscpd fails to start, copy the matching binary from CyberCP install media."
fi

chown -R root:root "$LSCP_ROOT/conf" 2>/dev/null || true
chmod 700 "$LSCP_ROOT/conf" 2>/dev/null || true

# --- Restart and verify ----------------------------------------------------
systemctl daemon-reload 2>/dev/null || true
if [[ -x /usr/local/lscp/bin/lscpdctrl ]]; then
    /usr/local/lscp/bin/lscpdctrl restart 2>/dev/null || systemctl restart lscpd
else
    systemctl restart lscpd
fi
sleep 2

PANEL_PORT="8090"
if [[ -f "$LSCP_ROOT/conf/bind.conf" ]]; then
    # Formats like *:8090 or 0.0.0.0:2087
    PANEL_PORT=$(grep -Eo '[0-9]+$' "$LSCP_ROOT/conf/bind.conf" | head -1 || echo "8090")
fi

if systemctl is-active --quiet lscpd; then
    ok "lscpd is active"
else
    err "WARNING: lscpd failed to start"
    systemctl status lscpd --no-pager || true
    exit 1
fi

# Verify listen
if ss -tlnp 2>/dev/null | grep -q ":${PANEL_PORT} "; then
    ok "Panel is listening on port ${PANEL_PORT}"
else
    warn "Port ${PANEL_PORT} not seen in ss yet; check bind.conf and firewall."
fi

HTTP_CODE=$(curl -sk --max-time 8 -o /dev/null -w '%{http_code}' "https://127.0.0.1:${PANEL_PORT}/" 2>/dev/null || echo "000")
if [[ "$HTTP_CODE" =~ ^(200|301|302|401|403)$ ]]; then
    ok "HTTPS probe to 127.0.0.1:${PANEL_PORT} returned HTTP ${HTTP_CODE}"
else
    warn "HTTPS probe returned HTTP ${HTTP_CODE} (panel may still be starting; check firewall for ${PANEL_PORT}/tcp)"
fi

echo ""
ok "LSCP / WebAdmin rebuild complete."
info "Open: https://YOUR-SERVER-IP:${PANEL_PORT}"
info "Backup (if any): $BACKUP_DIR"
info "Do not re-run full install.sh for this issue (ftpgroup/ftpuser already exist is normal)."
echo ""
exit 0
