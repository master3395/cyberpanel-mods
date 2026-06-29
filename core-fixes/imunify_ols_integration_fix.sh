#!/bin/bash

# ImunifyAV / Imunify360 + OpenLiteSpeed Integration Fix for CyberPanel
# ---------------------------------------------------------------------------
# Fixes (self-contained, no fork files required):
#   1. ImunifyAV UI shows "NO RESULT FOUND" / no users or scan history
#      (GitHub usmannasir/cyberpanel#1825) — integration.conf was missing the
#      [integration_scripts] hooks that feed CyberPanel users/domains to Imunify.
#   2. ImunifyAV cannot be installed after upgrade/uninstall
#      (GitHub usmannasir/cyberpanel#1826) — manual imav-deploy.sh aborts with
#      "PANEL=" because integration.conf must exist *before* the deploy script.
#   3. "cat: /home/cyberpanel/switchLSWSStatus: No such file" in the UI — the
#      install-progress status file did not exist, breaking progress polling.
#   4. OpenLiteSpeed :8090 panel vhost served /static/ from the wrong path and
#      had no lsphp context for /imunifyav/ and /imunify/ (blank/broken UI).
#   5. CSRF 403 on every panel POST behind the OLS reverse proxy (duplicated
#      Origin header) — ensures the OriginDedupe middleware + CSRF trusted
#      origins are present so logins/forms work.
#
# Safe to re-run (idempotent). Backs up every file it modifies.
#
# Supported: AlmaLinux 8/9/10, RockyLinux 8/9, RHEL 8/9, CentOS 7/9,
#            CloudLinux 7/8, Ubuntu 20.04-24.04 (CyberPanel + OpenLiteSpeed).

set -uo pipefail

# --- Colors ----------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Paths -----------------------------------------------------------------
CYBERCP="/usr/local/CyberCP"
LSWS_ROOT="/usr/local/lsws"
VHOST_DIR="$LSWS_ROOT/conf/vhosts/CyberPanel"
VHOST_CONF="$VHOST_DIR/vhost.conf"
VHOST_TXT="$VHOST_DIR/vhost.conf.txt"
INTEGRATION_CONF="/etc/sysconfig/imunify360/integration.conf"
CLSCRIPT_DIR="$CYBERCP/CLScript"
IMUNIFY_AV_UI="$CYBERCP/public/imunifyav"
IMUNIFY_360_UI="$CYBERCP/public/imunify"
STATUS_FILE="/home/cyberpanel/switchLSWSStatus"
SETTINGS="$CYBERCP/CyberCP/settings.py"
MIDDLEWARE="$CYBERCP/CyberCP/originDedupeMiddleware.py"
LOG_FILE="/var/log/cyberpanel_imunify_ols_fix.log"
TS="$(date +%Y%m%d_%H%M%S)"

RESTART_NEEDED=0

# --- Logging ---------------------------------------------------------------
log_message() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

backup_file() {
    local f="$1"
    if [[ -f "$f" ]]; then
        cp -a "$f" "${f}.bak-imunify-ols-${TS}" 2>/dev/null \
            && log_message "Backed up $f -> ${f}.bak-imunify-ols-${TS}"
    fi
}

# --- Pre-flight ------------------------------------------------------------
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}ERROR: This script must be run as root.${NC}"
        exit 1
    fi
}

check_cyberpanel() {
    if [[ ! -d "$CYBERCP" ]] || [[ ! -f /etc/cyberpanel/machineIP ]]; then
        echo -e "${RED}ERROR: CyberPanel not detected at $CYBERCP.${NC}"
        echo -e "${YELLOW}Install CyberPanel first, then run this fix.${NC}"
        exit 1
    fi
    echo -e "${GREEN}CyberPanel installation detected.${NC}"
}

detect_python() {
    PYBIN=""
    for p in "$CYBERCP/bin/python" "$CYBERCP/bin/python3" /usr/bin/python3; do
        [[ -x "$p" ]] && PYBIN="$p" && break
    done
    if [[ -z "$PYBIN" ]]; then
        echo -e "${RED}ERROR: No usable Python interpreter for CyberPanel.${NC}"
        exit 1
    fi
    log_message "Using Python: $PYBIN"
}

detect_lsphp() {
    LSPHP_PATH=""
    for ver in 85 84 83 82 81 80; do
        if [[ -x "$LSWS_ROOT/lsphp${ver}/bin/lsphp" ]]; then
            LSPHP_PATH="$LSWS_ROOT/lsphp${ver}/bin/lsphp"
            break
        fi
    done
    [[ -z "$LSPHP_PATH" ]] && LSPHP_PATH="$LSWS_ROOT/lsphp83/bin/lsphp"
    log_message "lsphp: $LSPHP_PATH"
}

# --- Fix 1: switchLSWSStatus progress file ---------------------------------
ensure_status_file() {
    echo -e "\n${CYAN}=== Ensuring install status file ===${NC}"
    mkdir -p /home/cyberpanel 2>/dev/null || true
    if [[ ! -e "$STATUS_FILE" ]]; then
        : > "$STATUS_FILE"
        log_message "Created $STATUS_FILE"
    fi
    if id cyberpanel >/dev/null 2>&1; then
        chown cyberpanel:cyberpanel "$STATUS_FILE" 2>/dev/null || true
    fi
    chmod 644 "$STATUS_FILE" 2>/dev/null || true
    echo -e "${GREEN}Status file ready.${NC}"
}

# --- Fix 2/3: integration.conf with CLScript hooks -------------------------
clscripts_block() {
    cat <<EOF

[integration_scripts]

panel_info = $CLSCRIPT_DIR/panel_info.py
users = $CLSCRIPT_DIR/CloudLinuxUsers.py
domains = $CLSCRIPT_DIR/CloudLinuxDomains.py
packages = $CLSCRIPT_DIR/CloudLinuxPackages.py
resellers = $CLSCRIPT_DIR/CloudLinuxResellers.py
admins = $CLSCRIPT_DIR/CloudLinuxAdmins.py
db_info = $CLSCRIPT_DIR/CloudLinuxDB.py
EOF
}

malware_block() {
    cat <<'EOF'

[malware]
basedir = /home
pattern_to_watch = ^/home/.+?/(public_html|public_ftp|private_html)(/.*)?$
EOF
}

web_server_block() {
    cat <<'EOF'

[web_server]
server_type = litespeed
graceful_restart_script = /usr/local/lsws/bin/lswsctrl restart
modsec_audit_log = /usr/local/lsws/logs/auditmodsec.log
modsec_audit_logdir = /usr/local/lsws/logs/
EOF
}

write_av_integration_conf() {
    {
        echo "[paths]"
        echo "ui_path = $IMUNIFY_AV_UI"
        echo "ui_path_owner = lscpd:lscpd"
        clscripts_block
        malware_block
        web_server_block
    } > "$INTEGRATION_CONF"
}

write_360_integration_conf() {
    {
        echo "[paths]"
        echo "ui_path =$IMUNIFY_360_UI"
        clscripts_block
        malware_block
        web_server_block
    } > "$INTEGRATION_CONF"
}

ensure_clscripts_executable() {
    [[ -d "$CLSCRIPT_DIR" ]] || return 0
    for f in panel_info.py CloudLinuxUsers.py CloudLinuxDomains.py \
             CloudLinuxPackages.py CloudLinuxResellers.py \
             CloudLinuxAdmins.py CloudLinuxDB.py; do
        [[ -f "$CLSCRIPT_DIR/$f" ]] && chmod 755 "$CLSCRIPT_DIR/$f" 2>/dev/null || true
    done
}

chmod_execute_files() {
    local root="$1"
    [[ -d "$root" ]] || return 0
    find "$root" -type f -name execute.py -exec chmod 755 {} \; 2>/dev/null || true
}

# True (0) when integration.conf is missing the user-feeding hooks.
integration_needs_repair() {
    [[ -f "$INTEGRATION_CONF" ]] || return 0
    grep -q '\[integration_scripts\]' "$INTEGRATION_CONF" || return 0
    grep -q 'CloudLinuxUsers.py' "$INTEGRATION_CONF" || return 0
    return 1
}

repair_integration_conf() {
    echo -e "\n${CYAN}=== Repairing Imunify integration.conf ===${NC}"

    if [[ ! -d "$CLSCRIPT_DIR" ]]; then
        echo -e "${YELLOW}CLScript dir missing ($CLSCRIPT_DIR); skipping integration repair.${NC}"
        log_message "WARN: $CLSCRIPT_DIR missing, cannot wire integration_scripts"
        return 0
    fi

    mkdir -p "$(dirname "$INTEGRATION_CONF")" 2>/dev/null || true
    mkdir -p "$IMUNIFY_AV_UI" "$IMUNIFY_360_UI" 2>/dev/null || true

    local product="none"
    if [[ -f "$INTEGRATION_CONF" ]]; then
        if grep -q 'imunifyav' "$INTEGRATION_CONF"; then
            product="av"
        elif grep -q '/public/imunify' "$INTEGRATION_CONF"; then
            product="360"
        fi
    fi

    # If no conf yet, default to AV when its UI dir already exists, else 360.
    if [[ "$product" == "none" ]]; then
        if [[ -d "$IMUNIFY_AV_UI" ]]; then product="av"; else product="360"; fi
    fi

    if integration_needs_repair; then
        backup_file "$INTEGRATION_CONF"
        if [[ "$product" == "360" ]]; then
            write_360_integration_conf
            log_message "Rewrote integration.conf for Imunify360 with CLScript hooks"
        else
            write_av_integration_conf
            log_message "Rewrote integration.conf for ImunifyAV with CLScript hooks"
        fi
        chmod 644 "$INTEGRATION_CONF" 2>/dev/null || true
        echo -e "${GREEN}integration.conf rewritten ($product) with user/domain hooks.${NC}"
    else
        echo -e "${GREEN}integration.conf already has integration_scripts; leaving as-is.${NC}"
    fi

    ensure_clscripts_executable
    chmod_execute_files "$IMUNIFY_AV_UI"
    chmod_execute_files "$IMUNIFY_360_UI"
    chown -R lscpd:lscpd "$IMUNIFY_AV_UI" 2>/dev/null || true
    chown -R lscpd:lscpd /etc/sysconfig/imunify360 2>/dev/null || true
}

restart_imunify_agent() {
    if command -v imunify-antivirus >/dev/null 2>&1; then
        echo -e "${BLUE}Reloading ImunifyAV agent to pick up integration changes...${NC}"
        systemctl restart imunify-antivirus 2>/dev/null \
            || service imunify-antivirus restart 2>/dev/null || true
        log_message "Requested imunify-antivirus restart"
    elif command -v imunify360 >/dev/null 2>&1; then
        systemctl restart imunify360 2>/dev/null || true
        log_message "Requested imunify360 restart"
    else
        echo -e "${YELLOW}Imunify agent not installed yet; integration.conf is staged for next install.${NC}"
    fi
}

# --- Fix 4: OLS panel vhost (static path + imunify contexts) ---------------
build_panel_vhost() {
    local lf='%h %l %u %t "%r" %>s %b "%{Referer}i" "%{User-Agent}i"'
    cat <<EOF
docRoot                   \$VH_ROOT
vhDomain                  \$VH_NAME
vhAliases                 *
adminEmails               root@localhost
enableGzip                1
enableIpGeo               1

errorlog \$VH_ROOT/logs/error.log {
  useServer               0
  logLevel                DEBUG
  rollingSize             10M
}

accesslog \$VH_ROOT/logs/access.log {
  useServer               0
  logFormat               "${lf}"
  logHeaders              5
  rollingSize             10M
  keepDays                30
  compressArchive         1
}

scripthandler  {
  add                     lsapi:cyberpanelphp php
}

extprocessor cyberpanelphp {
  type                    lsapi
  address                 UDS://tmp/lshttpd/cyberpanelphp.sock
  maxConns                10
  env                     LSAPI_CHILDREN=10
  initTimeout             60
  retryTimeout            0
  persistConn             1
  respBuffer              0
  autoStart               2
  path                    ${LSPHP_PATH}
  extUser                 lscpd
  extGroup                lscpd
  memSoftLimit            2047M
  memHardLimit            2047M
  procSoftLimit           400
  procHardLimit           500
}

extprocessor cyberpanel {
  type                    proxy
  address                 127.0.0.1:5003
  maxConns                100
  pcKeepAliveTimeout      60
  initTimeout             60
  retryTimeout            0
  respBuffer              0
}

context /phpmyadmin/ {
  location                ${CYBERCP}/public/phpmyadmin/
  allowBrowse             1
  indexFiles              index.php
  addDefaultCharset       off
  scripthandler  {
    add                     lsapi:cyberpanelphp php
  }
}

context /snappymail/ {
  location                ${CYBERCP}/public/snappymail/
  allowBrowse             1
  indexFiles              index.php
  addDefaultCharset       off
  scripthandler  {
    add                     lsapi:cyberpanelphp php
  }
}

context /imunifyav/ {
  location                ${IMUNIFY_AV_UI}/
  allowBrowse             1
  indexFiles              index.php
  addDefaultCharset       off
  scripthandler  {
    add                     lsapi:cyberpanelphp php
  }
}

context /imunify/ {
  location                ${IMUNIFY_360_UI}/
  allowBrowse             1
  indexFiles              index.php
  addDefaultCharset       off
  scripthandler  {
    add                     lsapi:cyberpanelphp php
  }
}

context /static/ {
  type                    null
  location                ${CYBERCP}/public/static/
  allowBrowse             1
}

context / {
  type                    proxy
  handler                 cyberpanel
  addDefaultCharset       off
}
EOF
}

fix_panel_vhost() {
    echo -e "\n${CYAN}=== Fixing OpenLiteSpeed panel vhost ===${NC}"

    if [[ ! -d "$LSWS_ROOT" ]]; then
        echo -e "${YELLOW}OpenLiteSpeed not found ($LSWS_ROOT); skipping vhost fix (LSE/other server).${NC}"
        log_message "WARN: $LSWS_ROOT missing; skipped panel vhost rewrite"
        return 0
    fi

    # Only rewrite when the panel vhost looks like the stock CyberPanel one.
    if [[ -f "$VHOST_CONF" ]] && ! grep -q 'handler                 cyberpanel' "$VHOST_CONF"; then
        echo -e "${YELLOW}Custom panel vhost detected; only patching /static/ path in place.${NC}"
        if grep -q "location                ${CYBERCP}/static/" "$VHOST_CONF"; then
            backup_file "$VHOST_CONF"
            sed -i "s#location                ${CYBERCP}/static/#location                ${CYBERCP}/public/static/#g" "$VHOST_CONF"
            RESTART_NEEDED=1
            log_message "Patched /static/ path in custom vhost"
        fi
        return 0
    fi

    mkdir -p "$VHOST_DIR/logs" 2>/dev/null || true
    backup_file "$VHOST_CONF"
    backup_file "$VHOST_TXT"
    local content
    content="$(build_panel_vhost)"
    echo "$content" > "$VHOST_CONF"
    echo "$content" > "$VHOST_TXT"
    RESTART_NEEDED=1
    log_message "Rewrote $VHOST_CONF (public/static + imunify contexts)"
    echo -e "${GREEN}Panel vhost updated (public/static, phpMyAdmin, SnappyMail, ImunifyAV/360 contexts).${NC}"
}

# --- Fix 5: CSRF origin-dedupe middleware ----------------------------------
ensure_csrf_origin_fix() {
    echo -e "\n${CYAN}=== Ensuring CSRF Origin de-dupe (reverse proxy) ===${NC}"

    if [[ ! -f "$SETTINGS" ]]; then
        echo -e "${YELLOW}settings.py not found; skipping CSRF fix.${NC}"
        return 0
    fi

    # Write the middleware module if missing.
    if [[ ! -f "$MIDDLEWARE" ]]; then
        cat > "$MIDDLEWARE" <<'PYEOF'
# coding=utf-8


class OriginDedupeMiddleware:
    """OpenLiteSpeed's proxy can forward a duplicated Origin header, which WSGI
    joins into 'https://host,https://host'. Django's CSRF origin check then
    matches nothing and 403s every POST. Collapse it to the first value."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        origin = request.META.get('HTTP_ORIGIN')
        if origin and ',' in origin:
            request.META['HTTP_ORIGIN'] = origin.split(',')[0].strip()
        return self.get_response(request)
PYEOF
        log_message "Created $MIDDLEWARE"
        echo -e "${GREEN}OriginDedupe middleware created.${NC}"
    fi

    # Register middleware before CsrfViewMiddleware if not present.
    if ! grep -q 'originDedupeMiddleware.OriginDedupeMiddleware' "$SETTINGS"; then
        backup_file "$SETTINGS"
        if grep -q 'django.middleware.csrf.CsrfViewMiddleware' "$SETTINGS"; then
            sed -i "s#\(\s*\)'django.middleware.csrf.CsrfViewMiddleware',#\1'CyberCP.originDedupeMiddleware.OriginDedupeMiddleware',\n\1'django.middleware.csrf.CsrfViewMiddleware',#" "$SETTINGS"
            RESTART_NEEDED=1
            log_message "Registered OriginDedupeMiddleware in settings.py"
            echo -e "${GREEN}Middleware registered in settings.py.${NC}"
        else
            echo -e "${YELLOW}Could not find CsrfViewMiddleware anchor; register manually.${NC}"
        fi
    else
        echo -e "${GREEN}OriginDedupe middleware already registered.${NC}"
    fi
}

# --- Restart services ------------------------------------------------------
restart_services() {
    echo -e "\n${CYAN}=== Restarting services ===${NC}"
    if systemctl cat cyberpanel.service >/dev/null 2>&1; then
        systemctl restart cyberpanel 2>/dev/null \
            && log_message "Restarted cyberpanel.service" || true
    fi
    if [[ -x "$LSWS_ROOT/bin/lswsctrl" ]]; then
        "$LSWS_ROOT/bin/lswsctrl" restart >/dev/null 2>&1 \
            && log_message "Restarted OpenLiteSpeed" || true
    elif systemctl cat lscpd.service >/dev/null 2>&1; then
        systemctl restart lscpd 2>/dev/null \
            && log_message "Restarted lscpd.service" || true
    fi
    echo -e "${GREEN}Services restarted.${NC}"
}

# --- Verify ----------------------------------------------------------------
verify() {
    echo -e "\n${CYAN}=== Verification ===${NC}"
    local ok=1

    if [[ -f "$INTEGRATION_CONF" ]] && grep -q 'CloudLinuxUsers.py' "$INTEGRATION_CONF"; then
        echo -e "${GREEN}[OK] integration.conf has user/domain hooks${NC}"
    elif [[ -f "$INTEGRATION_CONF" ]]; then
        echo -e "${YELLOW}[WARN] integration.conf present but missing hooks${NC}"; ok=0
    else
        echo -e "${YELLOW}[INFO] integration.conf not present (Imunify not installed yet)${NC}"
    fi

    if [[ -e "$STATUS_FILE" ]]; then
        echo -e "${GREEN}[OK] status file exists${NC}"
    else
        echo -e "${RED}[FAIL] status file missing${NC}"; ok=0
    fi

    if [[ -f "$VHOST_CONF" ]]; then
        if grep -q "${CYBERCP}/public/static/" "$VHOST_CONF"; then
            echo -e "${GREEN}[OK] vhost /static/ points to public/static${NC}"
        else
            echo -e "${YELLOW}[WARN] vhost /static/ not pointing at public/static${NC}"; ok=0
        fi
        if grep -q 'context /imunifyav/' "$VHOST_CONF"; then
            echo -e "${GREEN}[OK] vhost has /imunifyav/ context${NC}"
        else
            echo -e "${YELLOW}[WARN] vhost missing /imunifyav/ context${NC}"; ok=0
        fi
    fi

    if [[ -f "$MIDDLEWARE" ]] && grep -q 'originDedupeMiddleware' "$SETTINGS" 2>/dev/null; then
        echo -e "${GREEN}[OK] CSRF OriginDedupe middleware active${NC}"
    else
        echo -e "${YELLOW}[WARN] CSRF OriginDedupe middleware not fully configured${NC}"
    fi

    [[ $ok -eq 1 ]] && echo -e "\n${GREEN}All applicable fixes verified.${NC}" \
        || echo -e "\n${YELLOW}Completed with warnings; see $LOG_FILE.${NC}"
}

# --- Main ------------------------------------------------------------------
main() {
    echo -e "${CYAN}========================================================${NC}"
    echo -e "${CYAN} CyberPanel ImunifyAV/360 + OpenLiteSpeed Integration Fix${NC}"
    echo -e "${CYAN}========================================================${NC}"
    log_message "=== Starting ImunifyAV/OLS integration fix ==="

    check_root
    check_cyberpanel
    detect_python
    detect_lsphp

    ensure_status_file
    repair_integration_conf
    fix_panel_vhost
    ensure_csrf_origin_fix

    if [[ $RESTART_NEEDED -eq 1 ]]; then
        restart_services
    else
        echo -e "\n${BLUE}No service-impacting changes; skipping restart.${NC}"
    fi

    restart_imunify_agent
    verify

    echo -e "\n${GREEN}Done.${NC} Open ${BLUE}Security > ImunifyAV${NC} in CyberPanel."
    echo -e "If Imunify was not installed yet, click ${BLUE}Install Now${NC} — it will now succeed."
    log_message "=== Finished ImunifyAV/OLS integration fix ==="
}

main "$@"
