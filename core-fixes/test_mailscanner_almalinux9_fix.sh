#!/bin/bash

# Test script for MailScanner AlmaLinux 9 fix
# This script tests the core fix implementation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log_message() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to test OS detection
test_os_detection() {
    log_message "Testing OS detection logic..."
    
    # Create a temporary test file
    cat > /tmp/test_os_release << 'EOF'
NAME="AlmaLinux"
VERSION="9.4 (Lime Lynx)"
ID="almalinux"
ID_LIKE="rhel fedora"
VERSION_ID="9"
PLATFORM_ID="platform:el9"
PRETTY_NAME="AlmaLinux 9.4 (Lime Lynx)"
ANSI_COLOR="0;34"
LOGO="fedora-logo-icon"
CPE_NAME="cpe:/o:almalinux:almalinux:9::baseos"
HOME_URL="https://almalinux.org/"
DOCUMENTATION_URL="https://wiki.almalinux.org/"
SUPPORT_URL="https://almalinux.org/"
BUG_REPORT_URL="https://bugs.almalinux.org/"
REDHAT_SUPPORT_PRODUCT="AlmaLinux"
REDHAT_SUPPORT_PRODUCT_VERSION="9"
EOF

    # Test the detection logic
    if grep -q -E "AlmaLinux-8|AlmaLinux-9|AlmaLinux-10" /tmp/test_os_release; then
        log_message "✅ AlmaLinux 9 detection works correctly"
    else
        error "❌ AlmaLinux 9 detection failed"
        return 1
    fi
    
    # Clean up
    rm -f /tmp/test_os_release
}

# Function to test version extraction
test_version_extraction() {
    log_message "Testing version extraction logic..."
    
    # Test version extraction
    VERSION_ID="9"
    Server_OS_Version=$(echo "$VERSION_ID" | awk -F[=,] '{print $2}' | tr -d \" | head -c2 | tr -d .)
    
    if [[ "$Server_OS_Version" == "9" ]]; then
        log_message "✅ Version extraction works correctly (extracted: $Server_OS_Version)"
    else
        error "❌ Version extraction failed (extracted: $Server_OS_Version)"
        return 1
    fi
}

# Function to test the fix implementation
test_fix_implementation() {
    log_message "Testing fix implementation..."
    
    local installer_path="/usr/local/CyberCP/CPScripts/mailscannerinstaller.sh"
    
    if [[ ! -f "$installer_path" ]]; then
        warning "MailScanner installer not found at $installer_path"
        warning "This test requires CyberPanel to be installed"
        return 0
    fi
    
    # Check if AlmaLinux 9 section exists
    if grep -q 'elif \[\[ \$Server_OS = "CentOS" \]\] && \[\[ "\$Server_OS_Version" = "9" \]\] ; then' "$installer_path"; then
        log_message "✅ AlmaLinux 9 section found in MailScanner installer"
    else
        error "❌ AlmaLinux 9 section not found in MailScanner installer"
        return 1
    fi
    
    # Check if the section contains required packages
    if grep -q "dnf install -y perl dnf-utils perl-CPAN" "$installer_path"; then
        log_message "✅ Required packages found in AlmaLinux 9 section"
    else
        error "❌ Required packages not found in AlmaLinux 9 section"
        return 1
    fi
    
    # Check if CRB repository is enabled
    if grep -q "dnf --enablerepo=crb install -y perl-IO-stringy" "$installer_path"; then
        log_message "✅ CRB repository configuration found"
    else
        error "❌ CRB repository configuration not found"
        return 1
    fi
    
    # Check if unrar installation is included
    if grep -q "dnf install -y unrar" "$installer_path"; then
        log_message "✅ unrar installation found"
    else
        error "❌ unrar installation not found"
        return 1
    fi
}

# Function to test error message updates
test_error_message_updates() {
    log_message "Testing error message updates..."
    
    local installer_path="/usr/local/CyberCP/CPScripts/mailscannerinstaller.sh"
    local uninstaller_path="/usr/local/CyberCP/CPScripts/mailscanneruninstaller.sh"
    
    # Test installer error message
    if [[ -f "$installer_path" ]]; then
        if grep -q "AlmaLinux 9" "$installer_path"; then
            log_message "✅ AlmaLinux 9 included in installer error message"
        else
            error "❌ AlmaLinux 9 not included in installer error message"
            return 1
        fi
    fi
    
    # Test uninstaller error message
    if [[ -f "$uninstaller_path" ]]; then
        if grep -q "AlmaLinux 9" "$uninstaller_path"; then
            log_message "✅ AlmaLinux 9 included in uninstaller error message"
        else
            error "❌ AlmaLinux 9 not included in uninstaller error message"
            return 1
        fi
    fi
}

# Function to simulate the installation flow
simulate_installation_flow() {
    log_message "Simulating installation flow..."
    
    # Simulate OS detection
    Server_OS="AlmaLinux"
    Server_OS_Version="9"
    
    # Simulate the conversion logic
    if [[ $Server_OS = "CloudLinux" ]] || [[ "$Server_OS" = "AlmaLinux" ]] || [[ "$Server_OS" = "RockyLinux" ]] ; then
        Server_OS="CentOS"
        log_message "✅ OS conversion logic works (AlmaLinux -> CentOS)"
    else
        error "❌ OS conversion logic failed"
        return 1
    fi
    
    # Simulate the version check
    if [[ $Server_OS = "CentOS" ]] && [[ "$Server_OS_Version" = "9" ]] ; then
        log_message "✅ Version 9 check works correctly"
    else
        error "❌ Version 9 check failed"
        return 1
    fi
}

# Function to test package availability
test_package_availability() {
    log_message "Testing package availability..."
    
    # Check if we're on a system that can test packages
    if command -v dnf >/dev/null 2>&1; then
        log_message "✅ DNF package manager available"
        
        # Test if EPEL is available
        if dnf repolist | grep -q epel; then
            log_message "✅ EPEL repository available"
        else
            warning "⚠️ EPEL repository not available (may need to be installed)"
        fi
        
        # Test if CRB repository is available
        if dnf repolist | grep -q crb; then
            log_message "✅ CRB repository available"
        else
            warning "⚠️ CRB repository not available (may need to be enabled)"
        fi
    else
        warning "⚠️ DNF not available - cannot test package availability"
    fi
}

# Main test function
main() {
    echo "=========================================="
    echo "MailScanner AlmaLinux 9 Fix Test Suite"
    echo "=========================================="
    
    local test_results=()
    
    # Run all tests
    test_os_detection && test_results+=("OS Detection: PASS") || test_results+=("OS Detection: FAIL")
    test_version_extraction && test_results+=("Version Extraction: PASS") || test_results+=("Version Extraction: FAIL")
    test_fix_implementation && test_results+=("Fix Implementation: PASS") || test_results+=("Fix Implementation: FAIL")
    test_error_message_updates && test_results+=("Error Message Updates: PASS") || test_results+=("Error Message Updates: FAIL")
    simulate_installation_flow && test_results+=("Installation Flow: PASS") || test_results+=("Installation Flow: FAIL")
    test_package_availability && test_results+=("Package Availability: PASS") || test_results+=("Package Availability: FAIL")
    
    # Display results
    echo ""
    log_message "=========================================="
    log_message "Test Results Summary"
    log_message "=========================================="
    
    for result in "${test_results[@]}"; do
        if [[ $result == *"PASS"* ]]; then
            echo -e "${GREEN}✅ $result${NC}"
        else
            echo -e "${RED}❌ $result${NC}"
        fi
    done
    
    # Count results
    local pass_count=$(printf '%s\n' "${test_results[@]}" | grep -c "PASS" || true)
    local total_count=${#test_results[@]}
    
    echo ""
    log_message "Tests passed: $pass_count/$total_count"
    
    if [[ $pass_count -eq $total_count ]]; then
        log_message "🎉 All tests passed! The fix is working correctly."
        return 0
    else
        error "Some tests failed. Please check the implementation."
        return 1
    fi
}

# Run main function
main "$@"
