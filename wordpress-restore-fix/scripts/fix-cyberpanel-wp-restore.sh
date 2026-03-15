#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  echo "This script must be run with bash."
  echo "Run: sudo bash ./scripts/fix-cyberpanel-wp-restore.sh"
  exit 1
fi

set -u
umask 022

timestamp="$(date +%Y%m%d-%H%M%S)"
DRY_RUN="${DRY_RUN:-0}"
DOMAIN="${DOMAIN:-}"
AUTO_YES=0
CLI_SITES=""
CLI_EXCLUDE=""
LOG_FILE="/var/log/cyberpanel-wp-restore-fix-${timestamp}.log"
STATE_FILE="/var/log/cyberpanel-wp-restore-fix-${timestamp}.state"

declare -a SITE_PATHS=()
declare -a SITE_NAMES=()
declare -a TARGET_INDEXES=()
declare -a SUCCESS_SITES=()
declare -a SKIPPED_SITES=()
declare -a FAILED_SITES=()

CURRENT_SITE=""
CURRENT_STEP="initializing"

if [ -t 1 ]; then
  C_RESET="\033[0m"
  C_RED="\033[31m"
  C_GREEN="\033[32m"
  C_YELLOW="\033[33m"
  C_BLUE="\033[34m"
  C_CYAN="\033[36m"
else
  C_RESET=""
  C_RED=""
  C_GREEN=""
  C_YELLOW=""
  C_BLUE=""
  C_CYAN=""
fi

usage() {
  cat <<'EOF'
Usage:
  ./scripts/fix-cyberpanel-wp-restore.sh [--yes] [--sites 1,2,5] [--exclude 3,4] [--help]

Environment variables:
  DRY_RUN=1          Preview actions without making changes
  DOMAIN=example.com Run only for one domain

Options:
  --yes              Do not prompt for confirmation
  --sites LIST       Run only the listed site numbers
  --exclude LIST     Exclude the listed site numbers
  --help             Show this help
EOF
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --yes) AUTO_YES=1; shift ;;
      --sites) [ $# -ge 2 ] || { echo "--sites requires a value"; exit 1; }; CLI_SITES="$2"; shift 2 ;;
      --exclude) [ $# -ge 2 ] || { echo "--exclude requires a value"; exit 1; }; CLI_EXCLUDE="$2"; shift 2 ;;
      --help|-h) usage; exit 0 ;;
      *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
  done
}

log() {
  local level="$1"; shift
  local msg="$*"; local color=""
  case "$level" in
    INFO) color="$C_BLUE" ;;
    OK) color="$C_GREEN" ;;
    WARN) color="$C_YELLOW" ;;
    ERROR) color="$C_RED" ;;
    DRYRUN) color="$C_CYAN" ;;
  esac
  printf '%b[%s] [%s] %s%b\n' "$color" "$(date '+%F %T')" "$level" "$msg" "$C_RESET" | tee -a "$LOG_FILE"
}

update_state() {
  printf 'timestamp=%s\ncurrent_site=%s\ncurrent_step=%s\n' "$timestamp" "$CURRENT_SITE" "$CURRENT_STEP" > "$STATE_FILE"
}

print_summary() {
  echo
  echo "==================== Summary ===================="
  printf 'Successful: %d\n' "${#SUCCESS_SITES[@]}"
  local item
  for item in "${SUCCESS_SITES[@]:-}"; do [ -n "$item" ] && printf '  + %s\n' "$item"; done
  printf '\nSkipped: %d\n' "${#SKIPPED_SITES[@]}"
  for item in "${SKIPPED_SITES[@]:-}"; do [ -n "$item" ] && printf '  - %s\n' "$item"; done
  printf '\nFailed: %d\n' "${#FAILED_SITES[@]}"
  for item in "${FAILED_SITES[@]:-}"; do [ -n "$item" ] && printf '  ! %s\n' "$item"; done
  echo "================================================="
  echo
}

on_interrupt() {
  CURRENT_STEP="interrupted"
  update_state
  log "WARN" "Script interrupted before completion."
  log "WARN" "Review: $LOG_FILE"
  log "WARN" "State : $STATE_FILE"
  print_summary
  exit 130
}

trap on_interrupt INT TERM

need_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
  fi
}

run_cmd() {
  local description="$1"; shift
  CURRENT_STEP="$description"
  update_state
  log "INFO" "$description"
  if [ "$DRY_RUN" = "1" ]; then
    log "DRYRUN" "$*"
    return 0
  fi
  "$@"
  local rc=$?
  if [ $rc -ne 0 ]; then
    log "ERROR" "Command failed (exit $rc): $*"
    return $rc
  fi
  return 0
}

scan_sites() {
  SITE_PATHS=()
  SITE_NAMES=()
  for d in /home/*; do
    [ -d "$d/public_html" ] || continue
    SITE_PATHS+=("$d")
    SITE_NAMES+=("$(basename "$d")")
  done
  if [ "${#SITE_PATHS[@]}" -eq 0 ]; then
    log "ERROR" "No sites found under /home/*/public_html"
    exit 1
  fi
}

print_sites() {
  echo
  echo "Discovered sites:"
  echo "-----------------"
  local i
  for ((i=0; i<${#SITE_NAMES[@]}; i++)); do
    printf '%3d) %s\n' "$((i+1))" "${SITE_NAMES[$i]}"
  done
  echo
}

parse_number_list() {
  local raw="$1"
  raw="${raw//,/ }"
  local token
  for token in $raw; do
    [[ "$token" =~ ^[0-9]+$ ]] || continue
    printf '%s\n' "$token"
  done
}

build_targets_all() {
  TARGET_INDEXES=()
  local i
  for ((i=0; i<${#SITE_NAMES[@]}; i++)); do TARGET_INDEXES+=("$i"); done
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

build_targets_excluding() {
  local raw="$1"
  TARGET_INDEXES=()
  local i n idx
  declare -A excluded=()
  while IFS= read -r n; do
    [ -n "$n" ] || continue
    idx=$((n-1))
    if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#SITE_NAMES[@]}" ]; then excluded["$idx"]=1; fi
  done < <(parse_number_list "$raw")
  for ((i=0; i<${#SITE_NAMES[@]}; i++)); do [ -n "${excluded[$i]+x}" ] || TARGET_INDEXES+=("$i"); done
}

print_target_summary() {
  echo
  echo "Target sites:"
  echo "-------------"
  local idx
  for idx in "${TARGET_INDEXES[@]}"; do printf ' - %s\n' "${SITE_NAMES[$idx]}"; done
  echo
  printf 'Total target sites: %d\n' "${#TARGET_INDEXES[@]}"
  echo
}

confirm_or_exit() {
  if [ "$AUTO_YES" = "1" ]; then
    log "INFO" "Auto-confirm enabled with --yes"
    return 0
  fi
  local answer=""
  read -r -p "Continue? Type yes to proceed: " answer
  [ "$answer" = "yes" ] || { log "WARN" "Aborted by user before execution."; exit 0; }
}

backup_wp_config() {
  local file="$1"
  local backup="${file}.bak.cyberfix-${timestamp}"
  run_cmd "Backing up $file to $(basename "$backup")" cp -a "$file" "$backup"
}

insert_if_missing() {
  local file="$1" needle="$2" line="$3"
  if grep -Fq "$needle" "$file"; then
    log "INFO" "Already present in $(basename "$file"): $needle"
    return 0
  fi
  if grep -Fq "/* That's all, stop editing! Happy publishing. */" "$file"; then
    run_cmd "Inserting missing constant into $(basename "$file")" sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i $line" "$file" || return 1
  elif grep -Fq "/* That's all, stop editing! */" "$file"; then
    run_cmd "Inserting missing constant into $(basename "$file")" sed -i "/\/\* That's all, stop editing! \*\//i $line" "$file" || return 1
  else
    if [ "$DRY_RUN" = "1" ]; then
      log "DRYRUN" "Would append to $file: $line"
    else
      printf '\n%s\n' "$line" >> "$file" || return 1
      log "OK" "Appended missing constant to $(basename "$file"): $line"
    fi
  fi
  return 0
}

clear_wp_cache_artifacts() {
  local wpcontent="$1"
  run_cmd "Removing stale cache drop-ins in $wpcontent" rm -f "$wpcontent/object-cache.php" "$wpcontent/advanced-cache.php" "$wpcontent/.litespeed_conf.dat" || return 1
  if [ -d "$wpcontent/cache" ]; then
    if [ "$DRY_RUN" = "1" ]; then log "DRYRUN" "Would clear $wpcontent/cache/*"
    else find "$wpcontent/cache" -mindepth 1 -maxdepth 1 -exec rm -rf {} + || return 1; log "OK" "Cleared $wpcontent/cache"; fi
  else
    log "INFO" "Cache directory not present: $wpcontent/cache"
  fi
  if [ -d "$wpcontent/litespeed" ]; then
    if [ "$DRY_RUN" = "1" ]; then log "DRYRUN" "Would clear $wpcontent/litespeed/*"
    else find "$wpcontent/litespeed" -mindepth 1 -maxdepth 1 -exec rm -rf {} + || return 1; log "OK" "Cleared $wpcontent/litespeed"; fi
  else
    log "INFO" "LiteSpeed directory not present: $wpcontent/litespeed"
  fi
  return 0
}

mark_failed() {
  local site_name="$1"
  FAILED_SITES+=("$site_name")
  log "ERROR" "Marked failed: $site_name"
}

process_site() {
  local site_path="$1" site_name="$2" ordinal="$3" total="$4"
  local user wpconfig wpcontent
  CURRENT_SITE="$site_name"
  CURRENT_STEP="starting site"
  update_state
  echo
  log "INFO" "============================================================"
  log "INFO" "[$ordinal/$total] Starting site: $site_name"
  log "INFO" "Path: $site_path/public_html"
  user="$(stat -c '%U' "$site_path")"
  log "INFO" "Detected Linux owner for $site_name: $user"
  run_cmd "Fixing ownership for $site_name" chown -R "$user:$user" "$site_path/public_html" || { mark_failed "$site_name"; return 1; }
  run_cmd "Setting directory permissions (755) for $site_name" find "$site_path/public_html" -type d -exec chmod 755 {} \; || { mark_failed "$site_name"; return 1; }
  run_cmd "Setting file permissions (644) for $site_name" find "$site_path/public_html" -type f -exec chmod 644 {} \; || { mark_failed "$site_name"; return 1; }
  wpconfig="$site_path/public_html/wp-config.php"
  if [ -f "$wpconfig" ]; then
    backup_wp_config "$wpconfig" || { mark_failed "$site_name"; return 1; }
    insert_if_missing "$wpconfig" "define('FS_METHOD', 'direct');" "define('FS_METHOD', 'direct');" || { mark_failed "$site_name"; return 1; }
    insert_if_missing "$wpconfig" "define('FS_CHMOD_DIR', 0755);" "define('FS_CHMOD_DIR', 0755);" || { mark_failed "$site_name"; return 1; }
    insert_if_missing "$wpconfig" "define('FS_CHMOD_FILE', 0644);" "define('FS_CHMOD_FILE', 0644);" || { mark_failed "$site_name"; return 1; }
  else
    SKIPPED_SITES+=("$site_name (missing wp-config.php)")
    log "WARN" "wp-config.php not found for $site_name at $wpconfig"
  fi
  wpcontent="$site_path/public_html/wp-content"
  if [ -d "$wpcontent" ]; then
    clear_wp_cache_artifacts "$wpcontent" || { mark_failed "$site_name"; return 1; }
  else
    SKIPPED_SITES+=("$site_name (missing wp-content)")
    log "WARN" "wp-content not found for $site_name at $wpcontent"
  fi
  CURRENT_STEP="completed site"
  update_state
  SUCCESS_SITES+=("$site_name")
  log "OK" "[$ordinal/$total] Completed site: $site_name"
  return 0
}

interactive_target_selection() {
  print_sites
  echo "Selection mode:"
  echo "  1) Run for all discovered sites"
  echo "  2) Run only selected site numbers"
  echo "  3) Run for all except selected site numbers"
  echo
  local choice=""
  read -r -p "Choose 1, 2, or 3: " choice
  case "$choice" in
    1) build_targets_all ;;
    2) local only=""; read -r -p "Enter site numbers to include (e.g. 1 2 5 or 1,2,5): " only; build_targets_only "$only" ;;
    3) local skip=""; read -r -p "Enter site numbers to exclude (e.g. 1 2 5 or 1,2,5): " skip; build_targets_excluding "$skip" ;;
    *) log "ERROR" "Invalid selection mode."; exit 1 ;;
  esac
  [ "${#TARGET_INDEXES[@]}" -gt 0 ] || { log "ERROR" "No valid target sites selected."; exit 1; }
}

apply_cli_selection() {
  if [ -n "$CLI_SITES" ] && [ -n "$CLI_EXCLUDE" ]; then
    log "ERROR" "Use either --sites or --exclude, not both."
    exit 1
  fi
  if [ -n "$CLI_SITES" ]; then build_targets_only "$CLI_SITES"
  elif [ -n "$CLI_EXCLUDE" ]; then build_targets_excluding "$CLI_EXCLUDE"
  else build_targets_all; fi
  [ "${#TARGET_INDEXES[@]}" -gt 0 ] || { log "ERROR" "No valid target sites selected."; exit 1; }
}

main() {
  parse_args "$@"
  need_root
  touch "$LOG_FILE" "$STATE_FILE"
  log "INFO" "Starting CyberPanel WordPress restore fix"
  log "INFO" "Log file  : $LOG_FILE"
  log "INFO" "State file: $STATE_FILE"
  if [ "$DRY_RUN" = "1" ]; then log "WARN" "Dry-run mode is ENABLED. No changes will be written."
  else log "INFO" "Dry-run mode is DISABLED. Changes will be applied."; fi
  scan_sites
  if [ -n "$DOMAIN" ]; then
    local target="/home/$DOMAIN"
    [ -d "$target/public_html" ] || { log "ERROR" "Requested domain not found: $DOMAIN"; exit 1; }
    TARGET_INDEXES=()
    local i
    for ((i=0; i<${#SITE_NAMES[@]}; i++)); do [ "${SITE_NAMES[$i]}" = "$DOMAIN" ] && TARGET_INDEXES+=("$i") && break; done
    [ "${#TARGET_INDEXES[@]}" -gt 0 ] || { log "ERROR" "Domain found on disk but not in site list: $DOMAIN"; exit 1; }
  elif [ -n "$CLI_SITES" ] || [ -n "$CLI_EXCLUDE" ] || [ "$AUTO_YES" = "1" ]; then
    print_sites
    apply_cli_selection
  else
    interactive_target_selection
  fi
  print_target_summary
  confirm_or_exit
  local total="${#TARGET_INDEXES[@]}" count=0 idx
  for idx in "${TARGET_INDEXES[@]}"; do count=$((count+1)); process_site "${SITE_PATHS[$idx]}" "${SITE_NAMES[$idx]}" "$count" "$total" || true; done
  CURRENT_SITE="all"
  run_cmd "Restarting OpenLiteSpeed" systemctl restart lsws || FAILED_SITES+=("OpenLiteSpeed restart")
  CURRENT_STEP="completed"
  update_state
  log "OK" "Processing finished."
  log "INFO" "If you want to undo wp-config.php edits only, run:"
  log "INFO" "sudo bash ./scripts/restore-wp-config-backups.sh"
  print_summary
}

main "$@"
