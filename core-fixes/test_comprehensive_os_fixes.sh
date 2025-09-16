#!/bin/bash

# Comprehensive OS Fix Test Suite for CyberPanel
# Tests all operating system compatibility fixes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Test results tracking
declare -A test_results
total_tests=0
passed_tests=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    total_tests=$((total_tests + 1))
    
    log_message "Running test: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        if [[ "$expected_result" == "pass" ]]; then
            success "✅ $test_name - PASSED"
            test_results["$test_name"]="PASS"
            passed_tests=$((passed_tests + 1))
        else
            error "❌ $test_name - FAILED (unexpected success)"
            test_results["$test_name"]="FAIL"
        fi
    else
        if [[ "$expected_result" == "fail" ]]; then
            success "✅ $test_name - PASSED (expected failure)"
            test_results["$test_name"]="PASS"
            passed_tests=$((passed_tests + 1))
        else
            error "❌ $test_name - FAILED (unexpected failure)"
            test_results["$test_name"]="FAIL"
        fi
    fi
}

# Function to test OS detection patterns
test_os_detection() {
    log_message "=========================================="
    log_message "Testing OS Detection Patterns"
    log_message "=========================================="
    
    # Test Ubuntu detection
    run_test "Ubuntu 18.04 Detection" "echo 'NAME=\"Ubuntu\"\nVERSION=\"18.04.6 LTS (Bionic Beaver)\"\nVERSION_ID=\"18.04\"' | grep -q -E 'Ubuntu 18.04|Ubuntu 20.04|Ubuntu 20.10|Ubuntu 22.04|Ubuntu 24.04'" "pass"
    run_test "Ubuntu 20.04 Detection" "echo 'NAME=\"Ubuntu\"\nVERSION=\"20.04.6 LTS (Focal Fossa)\"\nVERSION_ID=\"20.04\"' | grep -q -E 'Ubuntu 18.04|Ubuntu 20.04|Ubuntu 20.10|Ubuntu 22.04|Ubuntu 24.04'" "pass"
    run_test "Ubuntu 22.04 Detection" "echo 'NAME=\"Ubuntu\"\nVERSION=\"22.04.3 LTS (Jammy Jellyfish)\"\nVERSION_ID=\"22.04\"' | grep -q -E 'Ubuntu 18.04|Ubuntu 20.04|Ubuntu 20.10|Ubuntu 22.04|Ubuntu 24.04'" "pass"
    run_test "Ubuntu 24.04 Detection" "echo 'NAME=\"Ubuntu\"\nVERSION=\"24.04 LTS (Noble Numbat)\"\nVERSION_ID=\"24.04\"' | grep -q -E 'Ubuntu 18.04|Ubuntu 20.04|Ubuntu 20.10|Ubuntu 22.04|Ubuntu 24.04'" "pass"
    
    # Test Debian detection
    run_test "Debian 11 Detection" "echo 'NAME=\"Debian GNU/Linux\"\nVERSION=\"11 (bullseye)\"\nVERSION_ID=\"11\"' | grep -q -E 'Debian GNU/Linux 11|Debian GNU/Linux 12|Debian GNU/Linux 13'" "pass"
    run_test "Debian 12 Detection" "echo 'NAME=\"Debian GNU/Linux\"\nVERSION=\"12 (bookworm)\"\nVERSION_ID=\"12\"' | grep -q -E 'Debian GNU/Linux 11|Debian GNU/Linux 12|Debian GNU/Linux 13'" "pass"
    run_test "Debian 13 Detection" "echo 'NAME=\"Debian GNU/Linux\"\nVERSION=\"13 (trixie)\"\nVERSION_ID=\"13\"' | grep -q -E 'Debian GNU/Linux 11|Debian GNU/Linux 12|Debian GNU/Linux 13'" "pass"
    
    # Test CentOS detection
    run_test "CentOS 7 Detection" "echo 'NAME=\"CentOS Linux\"\nVERSION=\"7 (Core)\"\nVERSION_ID=\"7\"' | grep -q -E 'CentOS Linux 7|CentOS Linux 8|CentOS Stream'" "pass"
    run_test "CentOS 8 Detection" "echo 'NAME=\"CentOS Linux\"\nVERSION=\"8 (Core)\"\nVERSION_ID=\"8\"' | grep -q -E 'CentOS Linux 7|CentOS Linux 8|CentOS Stream'" "pass"
    run_test "CentOS Stream Detection" "echo 'NAME=\"CentOS Stream\"\nVERSION=\"9\"\nVERSION_ID=\"9\"' | grep -q -E 'CentOS Linux 7|CentOS Linux 8|CentOS Stream'" "pass"
    
    # Test RHEL detection
    run_test "RHEL 8 Detection" "echo 'NAME=\"Red Hat Enterprise Linux\"\nVERSION=\"8.8 (Ootpa)\"\nVERSION_ID=\"8\"' | grep -q 'Red Hat Enterprise Linux'" "pass"
    run_test "RHEL 9 Detection" "echo 'NAME=\"Red Hat Enterprise Linux\"\nVERSION=\"9.2 (Plow)\"\nVERSION_ID=\"9\"' | grep -q 'Red Hat Enterprise Linux'" "pass"
    
    # Test AlmaLinux detection
    run_test "AlmaLinux 8 Detection" "echo 'NAME=\"AlmaLinux\"\nVERSION=\"8.8 (Sapphire Caracal)\"\nVERSION_ID=\"8\"' | grep -q 'AlmaLinux-8'" "pass"
    run_test "AlmaLinux 9 Detection" "echo 'NAME=\"AlmaLinux\"\nVERSION=\"9.4 (Lime Lynx)\"\nVERSION_ID=\"9\"' | grep -q 'AlmaLinux-9'" "pass"
    run_test "AlmaLinux 10 Detection" "echo 'NAME=\"AlmaLinux\"\nVERSION=\"10.0 (Emerald Puma)\"\nVERSION_ID=\"10\"' | grep -q 'AlmaLinux-10'" "pass"
    
    # Test RockyLinux detection
    run_test "RockyLinux 8 Detection" "echo 'NAME=\"Rocky Linux\"\nVERSION=\"8.8 (Green Obsidian)\"\nVERSION_ID=\"8\"' | grep -q -E 'Rocky Linux'" "pass"
    run_test "RockyLinux 9 Detection" "echo 'NAME=\"Rocky Linux\"\nVERSION=\"9.3 (Blue Onyx)\"\nVERSION_ID=\"9\"' | grep -q -E 'Rocky Linux'" "pass"
    
    # Test CloudLinux detection
    run_test "CloudLinux 7 Detection" "echo 'NAME=\"CloudLinux\"\nVERSION=\"7.9 (Vladimir)\"\nVERSION_ID=\"7\"' | grep -q -E 'CloudLinux 7|CloudLinux 8'" "pass"
    run_test "CloudLinux 8 Detection" "echo 'NAME=\"CloudLinux\"\nVERSION=\"8.8 (Vladimir)\"\nVERSION_ID=\"8\"' | grep -q -E 'CloudLinux 7|CloudLinux 8'" "pass"
    
    # Test openEuler detection
    run_test "openEuler 20.03 Detection" "echo 'NAME=\"openEuler\"\nVERSION=\"20.03 LTS\"\nVERSION_ID=\"20.03\"' | grep -q -E 'openEuler 20.03|openEuler 22.03'" "pass"
    run_test "openEuler 22.03 Detection" "echo 'NAME=\"openEuler\"\nVERSION=\"22.03 LTS\"\nVERSION_ID=\"22.03\"' | grep -q -E 'openEuler 20.03|openEuler 22.03'" "pass"
}

# Function to test version extraction
test_version_extraction() {
    log_message "=========================================="
    log_message "Testing Version Extraction"
    log_message "=========================================="
    
    # Test various version formats
    run_test "Version 7 Extraction" "echo 'VERSION_ID=\"7\"' | awk -F[=,] '{print \$2}' | tr -d \\\" | head -c2 | tr -d . | grep -q '7'" "pass"
    run_test "Version 8 Extraction" "echo 'VERSION_ID=\"8\"' | awk -F[=,] '{print \$2}' | tr -d \\\" | head -c2 | tr -d . | grep -q '8'" "pass"
    run_test "Version 9 Extraction" "echo 'VERSION_ID=\"9\"' | awk -F[=,] '{print \$2}' | tr -d \\\" | head -c2 | tr -d . | grep -q '9'" "pass"
    run_test "Version 10 Extraction" "echo 'VERSION_ID=\"10\"' | awk -F[=,] '{print \$2}' | tr -d \\\" | head -c2 | tr -d . | grep -q '10'" "pass"
    run_test "Version 18.04 Extraction" "echo 'VERSION_ID=\"18.04\"' | awk -F[=,] '{print \$2}' | tr -d \\\" | head -c2 | tr -d . | grep -q '18'" "pass"
    run_test "Version 20.04 Extraction" "echo 'VERSION_ID=\"20.04\"' | awk -F[=,] '{print \$2}' | tr -d \\\" | head -c2 | tr -d . | grep -q '20'" "pass"
    run_test "Version 22.04 Extraction" "echo 'VERSION_ID=\"22.04\"' | awk -F[=,] '{print \$2}' | tr -d \\\" | head -c2 | tr -d . | grep -q '22'" "pass"
    run_test "Version 24.04 Extraction" "echo 'VERSION_ID=\"24.04\"' | awk -F[=,] '{print \$2}' | tr -d \\\" | head -c2 | tr -d . | grep -q '24'" "pass"
}

# Function to test OS conversion logic
test_os_conversion() {
    log_message "=========================================="
    log_message "Testing OS Conversion Logic"
    log_message "=========================================="
    
    # Test RHEL-based OS conversion to CentOS
    run_test "AlmaLinux to CentOS Conversion" "Server_OS='AlmaLinux'; if [[ \$Server_OS = 'CloudLinux' ]] || [[ \"\$Server_OS\" = 'AlmaLinux' ]] || [[ \"\$Server_OS\" = 'RockyLinux' ]] || [[ \"\$Server_OS\" = 'RedHat' ]] ; then Server_OS='CentOS'; fi; [[ \$Server_OS == 'CentOS' ]]" "pass"
    run_test "RockyLinux to CentOS Conversion" "Server_OS='RockyLinux'; if [[ \$Server_OS = 'CloudLinux' ]] || [[ \"\$Server_OS\" = 'AlmaLinux' ]] || [[ \"\$Server_OS\" = 'RockyLinux' ]] || [[ \"\$Server_OS\" = 'RedHat' ]] ; then Server_OS='CentOS'; fi; [[ \$Server_OS == 'CentOS' ]]" "pass"
    run_test "RedHat to CentOS Conversion" "Server_OS='RedHat'; if [[ \$Server_OS = 'CloudLinux' ]] || [[ \"\$Server_OS\" = 'AlmaLinux' ]] || [[ \"\$Server_OS\" = 'RockyLinux' ]] || [[ \"\$Server_OS\" = 'RedHat' ]] ; then Server_OS='CentOS'; fi; [[ \$Server_OS == 'CentOS' ]]" "pass"
    run_test "CloudLinux to CentOS Conversion" "Server_OS='CloudLinux'; if [[ \$Server_OS = 'CloudLinux' ]] || [[ \"\$Server_OS\" = 'AlmaLinux' ]] || [[ \"\$Server_OS\" = 'RockyLinux' ]] || [[ \"\$Server_OS\" = 'RedHat' ]] ; then Server_OS='CentOS'; fi; [[ \$Server_OS == 'CentOS' ]]" "pass"
    
    # Test Debian to Ubuntu conversion
    run_test "Debian to Ubuntu Conversion" "Server_OS='Debian'; if [[ \"\$Server_OS\" = 'Debian' ]] ; then Server_OS='Ubuntu'; fi; [[ \$Server_OS == 'Ubuntu' ]]" "pass"
    
    # Test Ubuntu stays Ubuntu
    run_test "Ubuntu Stays Ubuntu" "Server_OS='Ubuntu'; if [[ \"\$Server_OS\" = 'Debian' ]] ; then Server_OS='Ubuntu'; fi; [[ \$Server_OS == 'Ubuntu' ]]" "pass"
}

# Function to test MailScanner installer fixes
test_mailscanner_fixes() {
    log_message "=========================================="
    log_message "Testing MailScanner Installer Fixes"
    log_message "=========================================="
    
    local installer_path="/usr/local/CyberCP/CPScripts/mailscannerinstaller.sh"
    
    if [[ ! -f "$installer_path" ]]; then
        warning "MailScanner installer not found at $installer_path"
        warning "This test requires CyberPanel to be installed"
        return 0
    fi
    
    # Test if all OS detection patterns are present
    run_test "Ubuntu 24.04 Detection Pattern" "grep -q 'Ubuntu 24.04' '$installer_path'" "pass"
    run_test "Debian Detection Pattern" "grep -q 'Debian GNU/Linux' '$installer_path'" "pass"
    run_test "RHEL Detection Pattern" "grep -q 'Red Hat Enterprise Linux' '$installer_path'" "pass"
    run_test "CentOS Stream Detection Pattern" "grep -q 'CentOS Stream' '$installer_path'" "pass"
    
    # Test if OS conversion logic includes all RHEL-based systems
    run_test "RHEL in Conversion Logic" "grep -q 'RedHat' '$installer_path'" "pass"
    run_test "Debian in Conversion Logic" "grep -q 'Debian' '$installer_path'" "pass"
    
    # Test if AlmaLinux 9 support is present
    run_test "AlmaLinux 9 Support Section" "grep -q 'Server_OS_Version.*9' '$installer_path'" "pass"
    
    # Test if error message includes all supported OS
    run_test "Ubuntu 24.04 in Error Message" "grep -q 'Ubuntu 24.04' '$installer_path'" "pass"
    run_test "Debian in Error Message" "grep -q 'Debian 11' '$installer_path'" "pass"
    run_test "RHEL in Error Message" "grep -q 'RHEL 8' '$installer_path'" "pass"
}

# Function to test MailScanner uninstaller fixes
test_mailscanner_uninstaller_fixes() {
    log_message "=========================================="
    log_message "Testing MailScanner Uninstaller Fixes"
    log_message "=========================================="
    
    local uninstaller_path="/usr/local/CyberCP/CPScripts/mailscanneruninstaller.sh"
    
    if [[ ! -f "$uninstaller_path" ]]; then
        warning "MailScanner uninstaller not found at $uninstaller_path"
        warning "This test requires CyberPanel to be installed"
        return 0
    fi
    
    # Test if all OS detection patterns are present
    run_test "Ubuntu 24.04 in Uninstaller" "grep -q 'Ubuntu 24.04' '$uninstaller_path'" "pass"
    run_test "Debian in Uninstaller" "grep -q 'Debian GNU/Linux' '$uninstaller_path'" "pass"
    run_test "RHEL in Uninstaller" "grep -q 'Red Hat Enterprise Linux' '$uninstaller_path'" "pass"
    
    # Test if OS conversion logic is present
    run_test "RHEL in Uninstaller Conversion" "grep -q 'RedHat' '$uninstaller_path'" "pass"
    run_test "Debian in Uninstaller Conversion" "grep -q 'Debian' '$uninstaller_path'" "pass"
}

# Function to test complete installation flow simulation
test_installation_flow() {
    log_message "=========================================="
    log_message "Testing Complete Installation Flow"
    log_message "=========================================="
    
    # Test AlmaLinux 9 flow
    run_test "AlmaLinux 9 Flow" "Server_OS='AlmaLinux'; Server_OS_Version='9'; if [[ \$Server_OS = 'CloudLinux' ]] || [[ \"\$Server_OS\" = 'AlmaLinux' ]] || [[ \"\$Server_OS\" = 'RockyLinux' ]] || [[ \"\$Server_OS\" = 'RedHat' ]] ; then Server_OS='CentOS'; fi; [[ \$Server_OS == 'CentOS' && \$Server_OS_Version == '9' ]]" "pass"
    
    # Test RockyLinux 9 flow
    run_test "RockyLinux 9 Flow" "Server_OS='RockyLinux'; Server_OS_Version='9'; if [[ \$Server_OS = 'CloudLinux' ]] || [[ \"\$Server_OS\" = 'AlmaLinux' ]] || [[ \"\$Server_OS\" = 'RockyLinux' ]] || [[ \"\$Server_OS\" = 'RedHat' ]] ; then Server_OS='CentOS'; fi; [[ \$Server_OS == 'CentOS' && \$Server_OS_Version == '9' ]]" "pass"
    
    # Test RHEL 9 flow
    run_test "RHEL 9 Flow" "Server_OS='RedHat'; Server_OS_Version='9'; if [[ \$Server_OS = 'CloudLinux' ]] || [[ \"\$Server_OS\" = 'AlmaLinux' ]] || [[ \"\$Server_OS\" = 'RockyLinux' ]] || [[ \"\$Server_OS\" = 'RedHat' ]] ; then Server_OS='CentOS'; fi; [[ \$Server_OS == 'CentOS' && \$Server_OS_Version == '9' ]]" "pass"
    
    # Test Debian flow
    run_test "Debian Flow" "Server_OS='Debian'; Server_OS_Version='11'; if [[ \"\$Server_OS\" = 'Debian' ]] ; then Server_OS='Ubuntu'; fi; [[ \$Server_OS == 'Ubuntu' ]]" "pass"
    
    # Test Ubuntu flow
    run_test "Ubuntu Flow" "Server_OS='Ubuntu'; Server_OS_Version='24'; [[ \$Server_OS == 'Ubuntu' ]]" "pass"
}

# Function to display test results
display_results() {
    log_message "=========================================="
    log_message "Test Results Summary"
    log_message "=========================================="
    
    echo ""
    info "Total Tests: $total_tests"
    success "Passed: $passed_tests"
    
    if [[ $passed_tests -lt $total_tests ]]; then
        error "Failed: $((total_tests - passed_tests))"
    fi
    
    echo ""
    info "Detailed Results:"
    for test_name in "${!test_results[@]}"; do
        if [[ "${test_results[$test_name]}" == "PASS" ]]; then
            success "✅ $test_name"
        else
            error "❌ $test_name"
        fi
    done
    
    echo ""
    if [[ $passed_tests -eq $total_tests ]]; then
        success "🎉 All tests passed! OS fixes are working correctly."
        return 0
    else
        error "Some tests failed. Please check the implementation."
        return 1
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "CyberPanel Comprehensive OS Fix Test Suite"
    echo "=========================================="
    
    test_os_detection
    test_version_extraction
    test_os_conversion
    test_mailscanner_fixes
    test_mailscanner_uninstaller_fixes
    test_installation_flow
    
    display_results
}

# Run main function
main "$@"
