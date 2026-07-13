#!/usr/bin/env bash
# Repair CyberPanel SnappyMail data path and permissions after RainLoop/SnappyMail upgrades.
# Idempotent: safe to run multiple times.

set -euo pipefail

CYBER="${CYBER_CP_ROOT:-/usr/local/CyberCP}"
LSCP="${LSCP_ROOT:-/usr/local/lscp/cyberpanel}"
SNAPPY_DATA="${LSCP}/snappymail/data"
RAINLOOP_DATA="${LSCP}/rainloop/data"
INCLUDE="${CYBER}/public/snappymail/include.php"
VERSION_INCLUDES=("${CYBER}"/public/snappymail/snappymail/v/*/include.php)
STAMP="$(date +%Y%m%d_%H%M%S)"

log() { printf '[snappymail-data-fix] %s\n' "$*"; }

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root." >&2
  exit 1
fi

mkdir -p \
  "${SNAPPY_DATA}/_data_/_default_/configs" \
  "${SNAPPY_DATA}/_data_/_default_/domains" \
  "${SNAPPY_DATA}/_data_/_default_/storage" \
  "${SNAPPY_DATA}/_data_/_default_/temp" \
  "${SNAPPY_DATA}/_data_/_default_/cache"

if [[ -d "$RAINLOOP_DATA" ]]; then
  mkdir -p "$RAINLOOP_DATA"
  log "Preserving legacy RainLoop data directory for compatibility."
fi

patch_include() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  if grep -q '/usr/local/lscp/cyberpanel/rainloop/data' "$file" || grep -q 'rainloop/data' "$file"; then
    cp -a "$file" "${file}.bak.snappymail_data_${STAMP}"
    sed -i \
      -e 's|/usr/local/lscp/cyberpanel/rainloop/data|/usr/local/lscp/cyberpanel/snappymail/data|g' \
      -e 's|rainloop/data|snappymail/data|g' \
      "$file"
    log "Patched $file"
  fi
}

patch_include "$INCLUDE"
for inc in "${VERSION_INCLUDES[@]}"; do
  patch_include "$inc"
done

for dir in "$SNAPPY_DATA" "$RAINLOOP_DATA"; do
  [[ -d "$dir" ]] || continue
  chown -R lscpd:lscpd "$dir"
  chmod -R u+rwX,g+rwX,o-rwx "$dir"
  log "Fixed ownership and permissions on $dir"
done

if command -v restorecon >/dev/null 2>&1; then
  restorecon -R "$SNAPPY_DATA" "$RAINLOOP_DATA" 2>/dev/null || true
fi

if [[ -d "${CYBER}/public/snappymail" ]]; then
  chown -R root:root "${CYBER}/public/snappymail" 2>/dev/null || true
  find "${CYBER}/public/snappymail" -type d -exec chmod 755 {} + 2>/dev/null || true
  find "${CYBER}/public/snappymail" -type f -exec chmod 644 {} + 2>/dev/null || true
fi

if systemctl is-active --quiet lscpd; then
  systemctl restart lscpd
  log "Restarted lscpd."
elif systemctl is-active --quiet lsws; then
  systemctl restart lsws
  log "Restarted lsws."
else
  log "No CyberPanel web service restart was needed or detected."
fi

log "Done. Open /snappymail/ and confirm the data folder error is gone."
