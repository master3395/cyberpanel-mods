#!/bin/bash
################################################################################
# ModSecurity LMDB Dependency Crash Fix
# 
# Fixes: https://github.com/usmannasir/cyberpanel/issues/1626
# Issue: undefined symbol: mdb_env_create (LMDB dependency crash)
# 
# This script fixes the ModSecurity crash issue by ensuring compatible
# ModSecurity binary is always used after installation, preventing
# LMDB dependency crashes that cause OpenLiteSpeed to crash with SIGSEGV.
#
# Compatible with: CyberPanel 2.4.4, 2.5.5-dev
# OS Support: Ubuntu 24.04, RHEL 8/9 (AlmaLinux, RockyLinux), Debian 11/12
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MODSEC_PATH="/usr/local/lsws/modules/mod_security.so"
MODSEC_BACKUP_PATH="${MODSEC_PATH}.backup-$(date +%Y%m%d-%H%M%S)"
CYBERCP_PATH="/usr/local/CyberCP"
MODSEC_PY="${CYBERCP_PATH}/plogical/modSec.py"
MODSEC_PY_BACKUP="${MODSEC_PY}.backup-$(date +%Y%m%d-%H%M%S)"

# Compatible ModSecurity binaries (SHA256 checksums)
MODSEC_COMPATIBLE=(
    "rhel8:https://cyberpanel.net/mod_security-compatible-rhel8.so:bbbf003bdc7979b98f09b640dffe2cbbe5f855427f41319e4c121403c05837b2"
    "rhel9:https://cyberpanel.net/mod_security-compatible-rhel.so:19deb2ffbaf1334cf4ce4d46d53f747a75b29e835bf5a01f91ebcc0c78e98629"
    "ubuntu:https://cyberpanel.net/mod_security-compatible-ubuntu.so:ed02c813136720bd4b9de5925f6e41bdc8392e494d7740d035479aaca6d1e0cd"
)

# Logging function
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect platform
detect_platform() {
    if [[ -f /etc/lsb-release ]]; then
        if grep -qi "ubuntu" /etc/lsb-release; then
            echo "ubuntu"
            return 0
        fi
    fi
    
    if [[ -f /etc/debian_version ]]; then
        echo "ubuntu"  # Use Ubuntu binary for Debian
        return 0
    fi
    
    if [[ -f /etc/os-release ]]; then
        local os_id=$(grep -E "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
        local version_id=$(grep -E "^VERSION_ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"' | cut -d'.' -f1)
        
        case "$os_id" in
            "centos"|"rhel"|"rocky"|"almalinux"|"cloudlinux")
                if [[ "$version_id" == "8" ]]; then
                    echo "rhel8"
                elif [[ "$version_id" == "9" ]] || [[ "$version_id" == "10" ]]; then
                    echo "rhel9"
                else
                    echo "rhel9"  # Default to rhel9
                fi
                return 0
                ;;
        esac
    fi
    
    echo "rhel9"  # Default
    return 0
}

# Calculate SHA256 checksum
calculate_sha256() {
    local file="$1"
    if command -v sha256sum &> /dev/null; then
        sha256sum "$file" | cut -d' ' -f1
    elif command -v shasum &> /dev/null; then
        shasum -a 256 "$file" | cut -d' ' -f1
    else
        log_error "No SHA256 tool found (sha256sum or shasum)"
        return 1
    fi
}

# Download compatible ModSecurity binary
download_compatible_modsec() {
    local platform="$1"
    local url=""
    local expected_sha256=""
    
    # Find matching platform configuration
    for config in "${MODSEC_COMPATIBLE[@]}"; do
        IFS=':' read -r config_platform config_url config_sha256 <<< "$config"
        if [[ "$config_platform" == "$platform" ]]; then
            url="$config_url"
            expected_sha256="$config_sha256"
            break
        fi
    done
    
    if [[ -z "$url" ]]; then
        log_error "No compatible ModSecurity binary found for platform: $platform"
        return 1
    fi
    
    log_info "Downloading compatible ModSecurity binary for $platform..."
    log_info "URL: $url"
    
    local tmp_file="/tmp/mod_security-compatible-${platform}.so"
    
    # Download
    if command -v wget &> /dev/null; then
        if ! wget -q -O "$tmp_file" "$url"; then
            log_error "Failed to download compatible ModSecurity binary"
            return 1
        fi
    elif command -v curl &> /dev/null; then
        if ! curl -sSL -o "$tmp_file" "$url"; then
            log_error "Failed to download compatible ModSecurity binary"
            return 1
        fi
    else
        log_error "No download tool found (wget or curl)"
        return 1
    fi
    
    # Verify checksum
    log_info "Verifying checksum..."
    local actual_sha256=$(calculate_sha256 "$tmp_file")
    
    if [[ "$actual_sha256" != "$expected_sha256" ]]; then
        log_error "Checksum mismatch!"
        log_error "Expected: $expected_sha256"
        log_error "Got:      $actual_sha256"
        rm -f "$tmp_file"
        return 1
    fi
    
    log_success "Checksum verified successfully"
    
    # Backup existing binary
    if [[ -f "$MODSEC_PATH" ]]; then
        log_info "Backing up existing ModSecurity binary..."
        cp -f "$MODSEC_PATH" "$MODSEC_BACKUP_PATH"
        log_success "Backup saved to: $MODSEC_BACKUP_PATH"
    fi
    
    # Install compatible binary
    log_info "Installing compatible ModSecurity binary..."
    mv -f "$tmp_file" "$MODSEC_PATH"
    chmod 644 "$MODSEC_PATH"
    chown root:root "$MODSEC_PATH"
    
    log_success "Compatible ModSecurity binary installed successfully"
    return 0
}

# Fix modSec.py to always use compatible binary
fix_modsec_py() {
    log_info "Checking modSec.py configuration..."
    
    if [[ ! -f "$MODSEC_PY" ]]; then
        log_error "modSec.py not found at: $MODSEC_PY"
        return 1
    fi
    
    # Check if already fixed
    if grep -q "Always download and install compatible ModSecurity binary" "$MODSEC_PY"; then
        log_success "modSec.py already contains the fix"
        return 0
    fi
    
    log_info "Backing up modSec.py..."
    cp -f "$MODSEC_PY" "$MODSEC_PY_BACKUP"
    log_success "Backup saved to: $MODSEC_PY_BACKUP"
    
    # Create fixed version
    log_info "Applying fix to modSec.py..."
    
    # Python script to apply the fix
    python3 << 'PYTHON_FIX'
import re
import sys

file_path = "/usr/local/CyberCP/plogical/modSec.py"

try:
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Pattern to find and replace the installModSec method section
    old_pattern = r'(# Check if custom OLS binary is installed - if so, replace with compatible ModSecurity\s+custom_ols_marker = "/usr/local/lsws/modules/cyberpanel_ols\.so"\s+if os\.path\.exists\(custom_ols_marker\):\s+writeToFile = open\(modSec\.installLogPath, \'a\'\)\s+writeToFile\.writelines\("Custom OLS detected, installing compatible ModSecurity\.\.\.\\n"\)\s+writeToFile\.close\(\)\s+platform = modSec\.detectPlatform\(\)\s+if modSec\.downloadCompatibleModSec\(platform\):\s+writeToFile = open\(modSec\.installLogPath, \'a\'\)\s+writeToFile\.writelines\("Compatible ModSecurity installed successfully\.\\n"\)\s+writeToFile\.close\(\)\s+else:\s+writeToFile = open\(modSec\.installLogPath, \'a\'\)\s+writeToFile\.writelines\("WARNING: Could not install compatible ModSecurity\. May experience crashes\.\\n"\)\s+writeToFile\.close\(\))'
    
    new_replacement = '''# Always download and install compatible ModSecurity binary to prevent LMDB dependency crashes
            # This fixes the "undefined symbol: mdb_env_create" error that causes OpenLiteSpeed to crash
            writeToFile = open(modSec.installLogPath, 'a')
            writeToFile.writelines("Downloading compatible ModSecurity binary to prevent LMDB dependency issues...\\n")
            writeToFile.close()
            
            platform = modSec.detectPlatform()
            if modSec.downloadCompatibleModSec(platform):
                writeToFile = open(modSec.installLogPath, 'a')
                writeToFile.writelines("Compatible ModSecurity binary installed successfully.\\n")
                writeToFile.close()
                logging.CyberCPLogFileWriter.writeToFile("Compatible ModSecurity binary installed to prevent LMDB dependency crashes [installModSec]")
            else:
                writeToFile = open(modSec.installLogPath, 'a')
                writeToFile.writelines("WARNING: Could not install compatible ModSecurity binary. Using package-manager binary instead.\\n")
                writeToFile.writelines("WARNING: If you experience crashes (SIGSEGV signal 11), manually download compatible binary.\\n")
                writeToFile.close()
                logging.CyberCPLogFileWriter.writeToFile("WARNING: Could not install compatible ModSecurity binary - may experience LMDB dependency crashes [installModSec]")'''
    
    # Use a more specific approach: find the exact section and replace
    pattern = r'(            else:\s+writeToFile = open\(modSec\.installLogPath, \'a\'\)\s+writeToFile\.writelines\("ModSecurity Installed\.\[200\]\\n"\)\s+writeToFile\.close\(\)\s+)(# Check if custom OLS binary is installed.*?writeToFile\.close\(\))'
    
    replacement = r'\1' + new_replacement
    
    modified_content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    
    if modified_content != content:
        with open(file_path, 'w') as f:
            f.write(modified_content)
        print("SUCCESS: modSec.py fixed successfully")
        sys.exit(0)
    else:
        # Try alternative pattern matching
        # Find line with "Check if custom OLS binary" and replace the entire block
        lines = content.split('\n')
        new_lines = []
        i = 0
        fixed = False
        
        while i < len(lines):
            if '# Check if custom OLS binary is installed' in lines[i] and not fixed:
                # Skip until we find the closing of this block
                while i < len(lines) and 'return 1' not in lines[i]:
                    if 'except BaseException as msg:' in lines[i]:
                        # Add the fix before the except block
                        fix_lines = [
                            '            # Always download and install compatible ModSecurity binary to prevent LMDB dependency crashes',
                            '            # This fixes the "undefined symbol: mdb_env_create" error that causes OpenLiteSpeed to crash',
                            '            writeToFile = open(modSec.installLogPath, \'a\')',
                            '            writeToFile.writelines("Downloading compatible ModSecurity binary to prevent LMDB dependency issues...\\n")',
                            '            writeToFile.close()',
                            '',
                            '            platform = modSec.detectPlatform()',
                            '            if modSec.downloadCompatibleModSec(platform):',
                            '                writeToFile = open(modSec.installLogPath, \'a\')',
                            '                writeToFile.writelines("Compatible ModSecurity binary installed successfully.\\n")',
                            '                writeToFile.close()',
                            '                logging.CyberCPLogFileWriter.writeToFile("Compatible ModSecurity binary installed to prevent LMDB dependency crashes [installModSec]")',
                            '            else:',
                            '                writeToFile = open(modSec.installLogPath, \'a\')',
                            '                writeToFile.writelines("WARNING: Could not install compatible ModSecurity binary. Using package-manager binary instead.\\n")',
                            '                writeToFile.writelines("WARNING: If you experience crashes (SIGSEGV signal 11), manually download compatible binary.\\n")',
                            '                writeToFile.close()',
                            '                logging.CyberCPLogFileWriter.writeToFile("WARNING: Could not install compatible ModSecurity binary - may experience LMDB dependency crashes [installModSec]")',
                            ''
                        ]
                        new_lines.extend(fix_lines)
                        new_lines.append(lines[i])
                        fixed = True
                        i += 1
                        # Skip the old block
                        while i < len(lines) and 'return 1' not in lines[i]:
                            if 'except BaseException as msg:' in lines[i]:
                                break
                            i += 1
                        continue
                    i += 1
            new_lines.append(lines[i])
            i += 1
        
        if fixed:
            with open(file_path, 'w') as f:
                f.write('\n'.join(new_lines))
            print("SUCCESS: modSec.py fixed successfully (alternative method)")
            sys.exit(0)
        else:
            print("ERROR: Could not find the section to replace in modSec.py")
            sys.exit(1)
    
except Exception as e:
    print(f"ERROR: {str(e)}")
    sys.exit(1)
PYTHON_FIX

    if [[ $? -eq 0 ]]; then
        log_success "modSec.py fixed successfully"
        return 0
    else
        log_error "Failed to fix modSec.py. Restoring backup..."
        cp -f "$MODSEC_PY_BACKUP" "$MODSEC_PY"
        return 1
    fi
}

# Main execution
main() {
    log_info "=========================================="
    log_info "ModSecurity LMDB Dependency Crash Fix"
    log_info "=========================================="
    echo ""
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
    
    # Check if CyberPanel is installed
    if [[ ! -d "$CYBERCP_PATH" ]]; then
        log_error "CyberPanel not found at: $CYBERCP_PATH"
        exit 1
    fi
    
    # Detect platform
    log_info "Detecting platform..."
    local platform=$(detect_platform)
    log_success "Platform detected: $platform"
    echo ""
    
    # Step 1: Fix modSec.py
    log_info "Step 1: Fixing modSec.py..."
    if fix_modsec_py; then
        log_success "Step 1 completed successfully"
    else
        log_error "Step 1 failed"
        exit 1
    fi
    echo ""
    
    # Step 2: Download compatible binary if ModSecurity is installed
    if [[ -f "$MODSEC_PATH" ]]; then
        log_info "Step 2: Installing compatible ModSecurity binary..."
        if download_compatible_modsec "$platform"; then
            log_success "Step 2 completed successfully"
        else
            log_warning "Step 2 failed - compatible binary download failed"
            log_warning "The fix in modSec.py will still ensure compatible binary is used on next ModSecurity installation"
        fi
    else
        log_info "Step 2: ModSecurity not yet installed"
        log_info "The fix in modSec.py will ensure compatible binary is used when ModSecurity is installed"
    fi
    echo ""
    
    # Final summary
    log_success "=========================================="
    log_success "Fix Applied Successfully!"
    log_success "=========================================="
    echo ""
    log_info "Summary:"
    log_info "  - modSec.py has been updated to always use compatible ModSecurity binary"
    if [[ -f "$MODSEC_BACKUP_PATH" ]]; then
        log_info "  - Original ModSecurity binary backed up to: $MODSEC_BACKUP_PATH"
    fi
    if [[ -f "$MODSEC_PY_BACKUP" ]]; then
        log_info "  - Original modSec.py backed up to: $MODSEC_PY_BACKUP"
    fi
    echo ""
    log_info "Next steps:"
    log_info "  1. If ModSecurity is already installed, restart OpenLiteSpeed:"
    log_info "     systemctl restart lsws"
    log_info "  2. If ModSecurity is not installed yet, it will use the compatible binary automatically"
    log_info "  3. Verify the fix by checking OpenLiteSpeed logs:"
    log_info "     tail -f /usr/local/lsws/logs/error.log"
    echo ""
}

# Run main function
main "$@"
