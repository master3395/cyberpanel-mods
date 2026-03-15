#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  echo "This script must be run with bash."
  echo "Run: sudo bash ./scripts/restore-wp-config-backups.sh"
  exit 1
fi

set -u
umask 022

timestamp="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/var/log/cyberpanel-wp-restore-rollback-${timestamp}.log"

declare -a SITE_PATHS=()
declare -a SITE_NAMES=()
declare -a TARGET_INDEXES=()

log() {
  local level="$1"; shift
  printf '[%s] [%s] %s\n' "$(date '+%F %T')" "$level" "$*" | tee -a "$LOG_FILE"
}

need_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
  fi
}

scan_sites() {
  SITE_PATHS=(); SITE_NAMES=()
  for d in /home/*; do
    [ -d "$d/public_html" ] || continue
    SITE_PATHS+=("$d")
    SITE_NAMES+=("$(basename "$d")")
  done
  [ "${#SITE_PATHS[@]}" -gt 0 ] || { log "ERROR" "No sites found under /home/*/public_html"; exit 1; }
}

print_sites() {
  echo
  echo "Discovered sites:"
  echo "-----------------"
  local i
  for ((i=0; i<${#SITE_NAMES[@]}; i++)); do printf '%3d) %s\n' "$((i+1))" "${SITE_NAMES[$i]}"; done
  echo
}

parse_number_list() {
  local raw="$1"
  raw="${raw//,/ }"
  local token
  for token in $raw; do [[ "$token" =~ ^[0-9]+$ ]] || continue; printf '%s\n' "$token"; done
}

build_targets_only() {
  local raw="$1"
  TARGET_INDEXES=()
  local n idx seen existing
  while IFS= read -r n; do
    [ -n "$n" ] || continue
    idx=$((n-1))
    if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#SITE_NAMES[@]}" ]; then
      seen=0
      for existing in "${TARGET_INDEXES[@]:-}"; do [ "$existing" = "$idx" ] && seen=1 && break; done
      [ "$seen" -eq 0 ] && TARGET_INDEXES+=("$idx")
    fi
  done < <(parse_number_list "$raw")
}

confirm_or_exit() {
  local answer=""
  read -r -p "Type yes to continue with rollback: " answer
  [ "$answer" = "yes" ] || { log "WARN" "Rollback aborted by user."; exit 0; }
}

main() {
  need_root
  touch "$LOG_FILE"
  log "INFO" "Starting wp-config.php rollback"
  log "INFO" "Log file: $LOG_FILE"
  scan_sites
  print_sites
  local only=""
  read -r -p "Enter site numbers to rollback (e.g. 1 2 5 or 1,2,5): " only
  build_targets_only "$only"
  [ "${#TARGET_INDEXES[@]}" -gt 0 ] || { log "ERROR" "No valid target sites selected for rollback."; exit 1; }
  echo
  echo "Rollback target sites:"
  echo "----------------------"
  local idx
  for idx in "${TARGET_INDEXES[@]}"; do printf ' - %s\n' "${SITE_NAMES[$idx]}"; done
  echo
  echo "Warning: this restores only the latest wp-config.php backup created by the fix script."
  echo "It does not revert permissions, ownership, or cache cleanup."
  echo
  confirm_or_exit
  local site_path site_name wpconfig latest_backup safety_backup
  for idx in "${TARGET_INDEXES[@]}"; do
    site_path="${SITE_PATHS[$idx]}"
    site_name="${SITE_NAMES[$idx]}"
    wpconfig="$site_path/public_html/wp-config.php"
    if [ ! -f "$wpconfig" ]; then log "WARN" "Skipping $site_name: wp-config.php not found"; continue; fi
    latest_backup="$(ls -1t "${wpconfig}.bak.cyberfix-"* 2>/dev/null | head -n 1 || true)"
    if [ -z "$latest_backup" ]; then log "WARN" "Skipping $site_name: no cyberfix backup found"; continue; fi
    safety_backup="${wpconfig}.pre-rollback-${timestamp}"
    cp -a "$wpconfig" "$safety_backup"
    cp -a "$latest_backup" "$wpconfig"
    log "INFO" "Restored $site_name from $(basename "$latest_backup")"
    log "INFO" "Current wp-config backed up as $(basename "$safety_backup")"
  done
  log "INFO" "Restarting OpenLiteSpeed"
  systemctl restart lsws
  log "INFO" "Rollback completed"
}

main "$@"
