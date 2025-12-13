#!/bin/bash

###############################################################################
# Restore CyberPanel files from rDNS fix backup
# Use this if the fix script caused issues
###############################################################################

CYBERCP_PATH="/usr/local/CyberCP"
MAIL_UTILITIES="${CYBERCP_PATH}/plogical/mailUtilities.py"
VIRTUAL_HOST_UTILITIES="${CYBERCP_PATH}/plogical/virtualHostUtilities.py"

echo "=========================================="
echo "CyberPanel rDNS Fix - Restore from Backup"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Find latest backup
LATEST_BACKUP=$(ls -td ${CYBERCP_PATH}/backup_rdns_fix_* 2>/dev/null | head -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "No backup found in ${CYBERCP_PATH}/backup_rdns_fix_*"
    echo ""
    echo "Available backups:"
    ls -la ${CYBERCP_PATH}/backup_rdns_fix_* 2>/dev/null || echo "None found"
    exit 1
fi

echo "Found backup: $LATEST_BACKUP"
echo ""

# Restore files
if [ -f "${LATEST_BACKUP}/mailUtilities.py" ]; then
    cp "${LATEST_BACKUP}/mailUtilities.py" "$MAIL_UTILITIES"
    echo "✓ Restored mailUtilities.py"
else
    echo "✗ mailUtilities.py not found in backup"
fi

if [ -f "${LATEST_BACKUP}/virtualHostUtilities.py" ]; then
    cp "${LATEST_BACKUP}/virtualHostUtilities.py" "$VIRTUAL_HOST_UTILITIES"
    echo "✓ Restored virtualHostUtilities.py"
else
    echo "✗ virtualHostUtilities.py not found in backup"
fi

# Validate syntax
echo ""
echo "Validating restored files..."
if python3 -m py_compile "$MAIL_UTILITIES" 2>/dev/null; then
    echo "✓ mailUtilities.py syntax is valid"
else
    echo "✗ mailUtilities.py still has syntax errors"
fi

if python3 -m py_compile "$VIRTUAL_HOST_UTILITIES" 2>/dev/null; then
    echo "✓ virtualHostUtilities.py syntax is valid"
else
    echo "✗ virtualHostUtilities.py still has syntax errors"
fi

# Restart CyberPanel
echo ""
echo "Restarting CyberPanel..."
if systemctl restart lscpd 2>/dev/null; then
    echo "✓ CyberPanel restarted"
elif systemctl restart cyberpanel 2>/dev/null; then
    echo "✓ CyberPanel restarted"
else
    echo "⚠ Could not restart CyberPanel automatically"
fi

echo ""
echo "=========================================="
echo "Restore complete!"
echo "=========================================="

