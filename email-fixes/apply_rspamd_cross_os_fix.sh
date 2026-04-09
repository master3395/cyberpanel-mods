#!/bin/bash
# Reproducible CyberPanel Rspamd fixes (cross-OS installer + Email Premium UI + /Rspamd/ui proxy).
# Run as root. Backs up targets under /usr/local/CyberCP before overwriting.
set -euo pipefail

CYBER="${CYBER_CP_ROOT:-/usr/local/CyberCP}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENDOR="${SCRIPT_DIR}/vendor"
STAMP="$(date +%Y%m%d_%H%M%S)"
export RSPAMD_FIX_SCRIPT_DIR="$SCRIPT_DIR"

log() { echo "[rspamd-fix] $*"; }

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root." >&2
  exit 1
fi

for f in "${VENDOR}/mailUtilities.py" "${VENDOR}/processUtilities.py" "${VENDOR}/Rspamd.html" \
         "${VENDOR}/emailPremium_urls.py" "${VENDOR}/rspamd_ui_proxy_addon.py"; do
  if [[ ! -f "$f" ]]; then
    echo "Missing vendor file: $f" >&2
    exit 1
  fi
done

backup_copy() {
  local target="$1"
  if [[ -f "$target" ]]; then
    cp -a "$target" "${target}.bak.rspamdfix_${STAMP}"
    log "Backed up $target"
  fi
}

backup_copy "${CYBER}/plogical/mailUtilities.py"
backup_copy "${CYBER}/plogical/processUtilities.py"
backup_copy "${CYBER}/emailPremium/templates/emailPremium/Rspamd.html"
backup_copy "${CYBER}/emailPremium/views.py"
backup_copy "${CYBER}/emailPremium/urls.py"

install -m 0644 "${VENDOR}/mailUtilities.py" "${CYBER}/plogical/mailUtilities.py"
install -m 0644 "${VENDOR}/processUtilities.py" "${CYBER}/plogical/processUtilities.py"
install -m 0644 "${VENDOR}/Rspamd.html" "${CYBER}/emailPremium/templates/emailPremium/Rspamd.html"
install -m 0644 "${VENDOR}/emailPremium_urls.py" "${CYBER}/emailPremium/urls.py"
log "Installed patched mailUtilities.py, processUtilities.py, Rspamd.html, emailPremium/urls.py"

# views.py: IP read + rspamd_ui_url context + rspamd_ui_proxy (idempotent)
python3 <<'PY'
from pathlib import Path
import os
import sys

cyber = Path(os.environ.get("CYBER_CP_ROOT", "/usr/local/CyberCP"))
script_dir = Path(os.environ["RSPAMD_FIX_SCRIPT_DIR"])
views = cyber / "emailPremium" / "views.py"
text = views.read_text(encoding="utf-8", errors="replace")

if "import http.client" not in text:
    text = text.replace("import time\n", "import time\nimport http.client\n", 1)
if "csrf_exempt" not in text:
    text = text.replace(
        "from django.http import HttpResponse, JsonResponse\n",
        "from django.http import HttpResponse, JsonResponse\n"
        "from django.views.decorators.csrf import csrf_exempt\n",
        1,
    )

old_ip = """    checkIfRspamdInstalled = 0

    ipFile = "/etc/cyberpanel/machineIP"
    f = open(ipFile)
    ipData = f.read()
    ipAddress = ipData.split('\\n', 1)[0]

    if mailUtilities.checkIfRspamdInstalled() == 1:"""
new_ip = """    checkIfRspamdInstalled = 0

    ipAddress = '127.0.0.1'
    try:
        ipFile = "/etc/cyberpanel/machineIP"
        with open(ipFile, 'r') as f:
            ipData = f.read()
        first_line = ipData.split('\\n', 1)[0].strip()
        if first_line:
            ipAddress = first_line
    except (OSError, IOError, IndexError):
        pass

    if mailUtilities.checkIfRspamdInstalled() == 1:"""
if old_ip in text:
    text = text.replace(old_ip, new_ip, 1)
    print("[rspamd-fix] Patched emailPremium/views.py (machineIP read)")
elif "ipAddress = '127.0.0.1'" in text and "def Rspamd(request)" in text:
    print("[rspamd-fix] views.py already has safe IP read; skipping IP block")
else:
    print("[rspamd-fix] ERROR: Rspamd IP block in views.py does not match expected stock pattern.", file=sys.stderr)
    sys.exit(1)

old_proc = """    proc = httpProc(request, 'emailPremium/Rspamd.html',
                    {'checkIfRspamdInstalled': checkIfRspamdInstalled, 'ipAddress': ipAddress}, 'admin')"""
new_proc = """    rspamd_ui_url = request.build_absolute_uri('/emailPremium/Rspamd/ui/')
    proc = httpProc(request, 'emailPremium/Rspamd.html',
                    {
                        'checkIfRspamdInstalled': checkIfRspamdInstalled,
                        'ipAddress': ipAddress,
                        'rspamd_ui_url': rspamd_ui_url,
                    }, 'admin')"""
if "rspamd_ui_url" not in text and old_proc in text:
    text = text.replace(old_proc, new_proc, 1)
    print("[rspamd-fix] Patched Rspamd view context (rspamd_ui_url)")
elif "rspamd_ui_url" in text:
    print("[rspamd-fix] rspamd_ui_url already present; skipping context patch")
elif old_proc not in text:
    print("[rspamd-fix] WARN: could not find stock httpProc Rspamd block to add rspamd_ui_url", file=sys.stderr)

if "def rspamd_ui_proxy" not in text:
    addon = (script_dir / "vendor" / "rspamd_ui_proxy_addon.py").read_text(encoding="utf-8")
    needle = "\n\ndef installRspamd(request):"
    if needle not in text:
        print("[rspamd-fix] ERROR: cannot find anchor for rspamd_ui_proxy insert.", file=sys.stderr)
        sys.exit(1)
    text = text.replace(needle, "\n\n" + addon.rstrip() + needle, 1)
    print("[rspamd-fix] Inserted rspamd_ui_proxy block into views.py")
else:
    print("[rspamd-fix] rspamd_ui_proxy already present; skipping insert")

views.write_text(text, encoding="utf-8")
PY

python3 -m py_compile "${CYBER}/plogical/mailUtilities.py" "${CYBER}/plogical/processUtilities.py" \
  "${CYBER}/emailPremium/views.py" "${CYBER}/emailPremium/urls.py"
log "Python syntax OK (mailUtilities, processUtilities, emailPremium views, urls)"

log "Done. Restart LiteSpeed/OpenLiteSpeed (lscpd) if the panel does not pick up template changes immediately."
log "Rspamd admin page: https://YOUR_PANEL:PORT/emailPremium/Rspamd"
log "Rspamd web UI (proxied): https://YOUR_PANEL:PORT/emailPremium/Rspamd/ui/"
