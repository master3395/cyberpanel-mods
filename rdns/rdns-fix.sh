#!/bin/bash

###############################################################################
# CyberPanel rDNS System Fix for v2.4.4
# Standalone script that can be run via: 
# sh <(curl https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/rdns/rdns-fix.sh || wget -O - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/rdns/rdns-fix.sh)
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# CyberPanel paths
CYBERCP_PATH="/usr/local/CyberCP"
MAIL_UTILITIES="${CYBERCP_PATH}/plogical/mailUtilities.py"
VIRTUAL_HOST_UTILITIES="${CYBERCP_PATH}/plogical/virtualHostUtilities.py"

# Backup directory
BACKUP_DIR="${CYBERCP_PATH}/backup_rdns_fix_$(date +%Y%m%d_%H%M%S)"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CyberPanel rDNS System Fix v1.0${NC}"
echo -e "${GREEN}For CyberPanel 2.4.4${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Check if CyberPanel is installed
if [ ! -d "$CYBERCP_PATH" ]; then
    echo -e "${RED}CyberPanel not found at ${CYBERCP_PATH}${NC}"
    exit 1
fi

# Check if files exist
if [ ! -f "$MAIL_UTILITIES" ]; then
    echo -e "${RED}File not found: ${MAIL_UTILITIES}${NC}"
    exit 1
fi

if [ ! -f "$VIRTUAL_HOST_UTILITIES" ]; then
    echo -e "${RED}File not found: ${VIRTUAL_HOST_UTILITIES}${NC}"
    exit 1
fi

# Create backup directory
echo -e "${YELLOW}Creating backup...${NC}"
mkdir -p "$BACKUP_DIR"
cp "$MAIL_UTILITIES" "${BACKUP_DIR}/mailUtilities.py"
cp "$VIRTUAL_HOST_UTILITIES" "${BACKUP_DIR}/virtualHostUtilities.py"
echo -e "${GREEN}Backup created at: ${BACKUP_DIR}${NC}"
echo ""

# Check if file has syntax errors (from previous failed run)
echo -e "${YELLOW}Checking for existing syntax errors...${NC}"
if python3 -m py_compile "$MAIL_UTILITIES" 2>/dev/null; then
    echo -e "${GREEN}✓ mailUtilities.py syntax is valid${NC}"
else
    echo -e "${RED}✗ mailUtilities.py has syntax errors!${NC}"
    echo -e "${YELLOW}Restoring from backup if available...${NC}"
    # Try to find and restore from most recent backup
    LATEST_BACKUP=$(ls -td ${CYBERCP_PATH}/backup_rdns_fix_* 2>/dev/null | head -1)
    if [ -n "$LATEST_BACKUP" ] && [ -f "${LATEST_BACKUP}/mailUtilities.py" ]; then
        cp "${LATEST_BACKUP}/mailUtilities.py" "$MAIL_UTILITIES"
        echo -e "${GREEN}✓ Restored from ${LATEST_BACKUP}${NC}"
    else
        echo -e "${RED}✗ No backup found. You may need to restore manually.${NC}"
        echo -e "${YELLOW}Continuing with fix attempt...${NC}"
    fi
fi
echo ""

# Check if file has syntax errors (from previous failed run)
echo -e "${YELLOW}Checking for existing syntax errors...${NC}"
if python3 -m py_compile "$MAIL_UTILITIES" 2>/dev/null; then
    echo -e "${GREEN}✓ mailUtilities.py syntax is valid${NC}"
else
    echo -e "${RED}✗ mailUtilities.py has syntax errors!${NC}"
    echo -e "${YELLOW}Restoring from backup if available...${NC}"
    # Try to find and restore from most recent backup
    LATEST_BACKUP=$(ls -td ${CYBERCP_PATH}/backup_rdns_fix_* 2>/dev/null | head -1)
    if [ -n "$LATEST_BACKUP" ] && [ -f "${LATEST_BACKUP}/mailUtilities.py" ]; then
        cp "${LATEST_BACKUP}/mailUtilities.py" "$MAIL_UTILITIES"
        echo -e "${GREEN}✓ Restored from ${LATEST_BACKUP}${NC}"
    else
        echo -e "${RED}✗ No backup found. You may need to restore manually.${NC}"
        echo -e "${YELLOW}Continuing with fix attempt...${NC}"
    fi
fi
echo ""

# Apply fixes using Python
echo -e "${YELLOW}Applying comprehensive fixes...${NC}"

python3 << 'PYTHON_FIX'
import re
import sys
import os

# File paths
mail_utils = "/usr/local/CyberCP/plogical/mailUtilities.py"
vhost_utils = "/usr/local/CyberCP/plogical/virtualHostUtilities.py"

def fix_mail_utilities():
    """Fix mailUtilities.py - reverse_dns_lookup function"""
    try:
        with open(mail_utils, 'r') as f:
            content = f.read()
        
        original_content = content
        
        # Fix 1: Replace str(msg) with str(e) - Critical NameError bug
        content = re.sub(
            r"logging\.CyberCPLogFileWriter\.writeToFile\(f'Error in fetch rDNS \{str\(msg\)\}'\)",
            "logging.CyberCPLogFileWriter.writeToFile(f'Error in fetch rDNS {str(e)}')",
            content
        )
        
        # Fix 2: Just fix the critical NameError bug (safer than replacing entire function)
        # This avoids indentation issues that can break the file
        if "str(msg)" in content:
            content = content.replace("str(msg)", "str(e)")
            print("✓ Fixed NameError bug (str(msg) -> str(e))")
        else:
            print("⚠ NameError fix not needed (may already be fixed)")
        
        if content != original_content:
            with open(mail_utils, 'w') as f:
                f.write(content)
            print("✓ mailUtilities.py updated successfully")
            return True
        else:
            print("⚠ No changes needed in mailUtilities.py")
            return False
            
    except Exception as e:
        print(f"✗ Error fixing mailUtilities.py: {e}")
        return False

def fix_virtual_host_utilities():
    """Fix virtualHostUtilities.py - OnBoardingHostName function"""
    try:
        with open(vhost_utils, 'r') as f:
            content = f.read()
        
        original_content = content
        changes_made = False
        
        # Fix 1: Add empty rDNS result check after reverse_dns_lookup call
        # Find the pattern: rDNS = mailUtilities.reverse_dns_lookup(serverIP)
        pattern1 = r'(rDNS = mailUtilities\.reverse_dns_lookup\(serverIP\))\s*\n(\s*except Exception as e:)'
        replacement1 = r'''\1
                # Check if rDNS lookup returned empty results (indicating lookup failure)
                if not rDNS or len(rDNS) == 0:
                    message = f'Failed to perform reverse DNS lookup for server IP {serverIP}. The DNS lookup service may be unavailable or the IP address may not have rDNS configured. Please verify your rDNS settings with your hosting provider or check the "Skip rDNS/PTR Check" option if you do not need email services. [404]'
                    logging.CyberCPLogFileWriter.statusWriter(tempStatusPath, message)
                    logging.CyberCPLogFileWriter.writeToFile(message)
                    return 0
\2'''
        
        if re.search(pattern1, content):
            content = re.sub(pattern1, replacement1, content)
            print("✓ Added empty rDNS result validation")
            changes_made = True
        
        # Fix 2: Improve error message in exception handler
        pattern2 = r"message = f'Failed to perform reverse DNS lookup: \{str\(e\)\} \[404\]'"
        replacement2 = "message = f'Failed to perform reverse DNS lookup for server IP {serverIP}: {str(e)}. Please verify your rDNS settings with your hosting provider or check the \\\"Skip rDNS/PTR Check\\\" option if you do not need email services. [404]'"
        
        if re.search(pattern2, content):
            content = re.sub(pattern2, replacement2, content)
            print("✓ Improved error message in exception handler")
            changes_made = True
        
        # Fix 3: Add validation before domain check and improve error message
        pattern3 = r'(#first check if hostname is already configured as rDNS, if not return error\s*\n\s*\n\s*if Domain not in rDNS:)'
        replacement3 = r'''#first check if hostname is already configured as rDNS, if not return error

            # Validate that we have rDNS results before checking
            if not rDNS or len(rDNS) == 0:
                message = f'Reverse DNS lookup failed for server IP {serverIP}. Unable to verify if domain "{Domain}" is configured as rDNS. Please check your rDNS configuration with your hosting provider or select "Skip rDNS/PTR Check" if you do not need email services. [404]'
                print(message)
                logging.CyberCPLogFileWriter.statusWriter(tempStatusPath, message)
                logging.CyberCPLogFileWriter.writeToFile(message)
                config['hostname'] = Domain
                config['onboarding'] = 3
                config['skipRDNSCheck'] = skipRDNSCheck
                admin.config = json.dumps(config)
                admin.save()
                return 0

            if Domain not in rDNS:'''
        
        if re.search(pattern3, content):
            content = re.sub(pattern3, replacement3, content)
            print("✓ Added rDNS validation before domain check")
            changes_made = True
        
        # Fix 4: Improve domain mismatch error message
        pattern4 = r"message = 'Domain that you have provided is not configured as rDNS for your server IP\. \[404\]'"
        replacement4 = r"""rDNS_list_str = ', '.join(rDNS) if rDNS else 'none'
                message = f'Domain "{Domain}" that you have provided is not configured as rDNS for your server IP {serverIP}. Current rDNS records: {rDNS_list_str}. Please configure rDNS (PTR record) for your IP address to point to "{Domain}" with your hosting provider, or select "Skip rDNS/PTR Check" if you do not need email services. [404]'"""
        
        if re.search(pattern4, content):
            content = re.sub(pattern4, replacement4, content)
            print("✓ Improved domain mismatch error message")
            changes_made = True
        
        if changes_made and content != original_content:
            with open(vhost_utils, 'w') as f:
                f.write(content)
            print("✓ virtualHostUtilities.py updated successfully")
            return True
        else:
            print("⚠ No changes needed in virtualHostUtilities.py")
            return False
            
    except Exception as e:
        print(f"✗ Error fixing virtualHostUtilities.py: {e}")
        return False

# Apply fixes
print("\nFixing mailUtilities.py...")
fix_mail_utilities()

print("\nFixing virtualHostUtilities.py...")
fix_virtual_host_utilities()

print("\n✓ All fixes applied!")
PYTHON_FIX

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ All fixes applied successfully${NC}"
else
    echo -e "${RED}✗ Some fixes may have failed. Check output above.${NC}"
    exit 1
fi

# Validate Python syntax after fixes
echo ""
echo -e "${YELLOW}Validating Python syntax...${NC}"
if python3 -m py_compile "$MAIL_UTILITIES" 2>/dev/null; then
    echo -e "${GREEN}✓ mailUtilities.py syntax is valid${NC}"
else
    echo -e "${RED}✗ mailUtilities.py has syntax errors after fix!${NC}"
    echo -e "${YELLOW}Restoring from backup...${NC}"
    if [ -f "${BACKUP_DIR}/mailUtilities.py" ]; then
        cp "${BACKUP_DIR}/mailUtilities.py" "$MAIL_UTILITIES"
        echo -e "${GREEN}✓ Restored from backup${NC}"
    fi
    exit 1
fi

if python3 -m py_compile "$VIRTUAL_HOST_UTILITIES" 2>/dev/null; then
    echo -e "${GREEN}✓ virtualHostUtilities.py syntax is valid${NC}"
else
    echo -e "${RED}✗ virtualHostUtilities.py has syntax errors after fix!${NC}"
    echo -e "${YELLOW}Restoring from backup...${NC}"
    if [ -f "${BACKUP_DIR}/virtualHostUtilities.py" ]; then
        cp "${BACKUP_DIR}/virtualHostUtilities.py" "$VIRTUAL_HOST_UTILITIES"
        echo -e "${GREEN}✓ Restored from backup${NC}"
    fi
    exit 1
fi

# Restart CyberPanel
echo ""
echo -e "${YELLOW}Restarting CyberPanel...${NC}"
if systemctl is-active --quiet lscpd 2>/dev/null || systemctl is-active --quiet cyberpanel 2>/dev/null; then
    if systemctl restart lscpd 2>/dev/null; then
        echo -e "${GREEN}✓ CyberPanel restarted${NC}"
    elif systemctl restart cyberpanel 2>/dev/null; then
        echo -e "${GREEN}✓ CyberPanel restarted${NC}"
    else
        echo -e "${YELLOW}⚠ Could not restart CyberPanel automatically. Please restart manually.${NC}"
    fi
else
    echo -e "${YELLOW}⚠ CyberPanel service not running, skipping restart${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Fix applied successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Backup location: ${BACKUP_DIR}${NC}"
echo -e "${YELLOW}Please test the rDNS functionality in CyberPanel onboarding.${NC}"
echo ""

