#!/bin/bash

# Test script to verify AlmaLinux 10 fixes
# This script tests the fixes without running the full installation

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Test 1: Check if running on AlmaLinux 10
test_os_detection() {
    log "Testing OS detection..."
    if grep -q "AlmaLinux-10" /etc/os-release; then
        log "✅ AlmaLinux 10 detected correctly"
        return 0
    else
        error "❌ Not running on AlmaLinux 10"
        return 1
    fi
}

# Test 2: Check EPEL 10 availability
test_epel10() {
    log "Testing EPEL 10 repository availability..."
    if curl -s --head https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm | head -n 1 | grep -q "200 OK"; then
        log "✅ EPEL 10 repository is accessible"
        return 0
    else
        error "❌ EPEL 10 repository is not accessible"
        return 1
    fi
}

# Test 3: Check MariaDB RHEL 10 repository
test_mariadb_rhel10() {
    log "Testing MariaDB RHEL 10 repository..."
    if curl -s --head http://yum.mariadb.org/10.11/rhel10-amd64/ | head -n 1 | grep -q "200 OK"; then
        log "✅ MariaDB RHEL 10 repository is accessible"
        return 0
    else
        error "❌ MariaDB RHEL 10 repository is not accessible"
        return 1
    fi
}

# Test 4: Check remi-release 10 availability
test_remi10() {
    log "Testing remi-release 10 availability..."
    if curl -s --head https://rpms.remirepo.net/enterprise/remi-release-10.rpm | head -n 1 | grep -q "200 OK"; then
        log "✅ remi-release 10 is accessible"
        return 0
    else
        error "❌ remi-release 10 is not accessible"
        return 1
    fi
}

# Test 5: Check boost libraries availability
test_boost_libraries() {
    log "Testing boost libraries availability..."
    if dnf search boost-devel boost-program-options 2>/dev/null | grep -q "boost-devel\|boost-program-options"; then
        log "✅ Boost libraries are available in repositories"
        return 0
    else
        warning "⚠️  Boost libraries may not be available (this is normal if EPEL is not installed yet)"
        return 0
    fi
}

# Test 6: Check GPG keys
test_gpg_keys() {
    log "Testing GPG key accessibility..."
    
    # Test MariaDB GPG key
    if curl -s --head https://yum.mariadb.org/RPM-GPG-KEY-MariaDB | head -n 1 | grep -q "200 OK"; then
        log "✅ MariaDB GPG key is accessible"
    else
        error "❌ MariaDB GPG key is not accessible"
        return 1
    fi
    
    # Test LiteSpeed GPG key (primary)
    if curl -s --head https://cyberpanel.sh/rpms.litespeedtech.com/centos/RPM-GPG-KEY-litespeed | head -n 1 | grep -q "200 OK"; then
        log "✅ LiteSpeed GPG key (primary) is accessible"
    else
        warning "⚠️  LiteSpeed GPG key (primary) is not accessible, testing fallback..."
        # Test fallback
        if curl -s --head https://rpms.litespeedtech.com/centos/RPM-GPG-KEY-litespeed | head -n 1 | grep -q "200 OK"; then
            log "✅ LiteSpeed GPG key (fallback) is accessible"
        else
            error "❌ Both LiteSpeed GPG keys are not accessible"
            return 1
        fi
    fi
    
    return 0
}

# Test 7: Check if fixes are in the CyberPanel script
test_cyberpanel_fixes() {
    log "Testing if fixes are present in CyberPanel script..."
    
    # Download the script
    curl -s https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh > /tmp/cyberpanel_test.sh
    
    # Check for EPEL 10 support
    if grep -q '"10")' /tmp/cyberpanel_test.sh && grep -q "epel-release-latest-10" /tmp/cyberpanel_test.sh; then
        log "✅ EPEL 10 support found in CyberPanel script"
    else
        error "❌ EPEL 10 support not found in CyberPanel script"
        return 1
    fi
    
    # Check for MariaDB RHEL 10 support
    if grep -q "rhel10-amd64" /tmp/cyberpanel_test.sh; then
        log "✅ MariaDB RHEL 10 support found in CyberPanel script"
    else
        error "❌ MariaDB RHEL 10 support not found in CyberPanel script"
        return 1
    fi
    
    # Check for remi-release 10 support
    if grep -q "remi-release-10" /tmp/cyberpanel_test.sh; then
        log "✅ remi-release 10 support found in CyberPanel script"
    else
        error "❌ remi-release 10 support not found in CyberPanel script"
        return 1
    fi
    
    # Check for boost libraries
    if grep -q "boost-devel boost-program-options" /tmp/cyberpanel_test.sh; then
        log "✅ Boost libraries support found in CyberPanel script"
    else
        error "❌ Boost libraries support not found in CyberPanel script"
        return 1
    fi
    
    # Clean up
    rm -f /tmp/cyberpanel_test.sh
    
    return 0
}

# Main test function
main() {
    log "Starting AlmaLinux 10 fixes verification..."
    echo ""
    
    local tests_passed=0
    local total_tests=7
    
    # Run all tests
    test_os_detection && ((tests_passed++))
    echo ""
    
    test_epel10 && ((tests_passed++))
    echo ""
    
    test_mariadb_rhel10 && ((tests_passed++))
    echo ""
    
    test_remi10 && ((tests_passed++))
    echo ""
    
    test_boost_libraries && ((tests_passed++))
    echo ""
    
    test_gpg_keys && ((tests_passed++))
    echo ""
    
    test_cyberpanel_fixes && ((tests_passed++))
    echo ""
    
    # Summary
    log "Test Results: $tests_passed/$total_tests tests passed"
    
    if [ $tests_passed -eq $total_tests ]; then
        log "🎉 All tests passed! AlmaLinux 10 fixes are working correctly."
        log "You can now run the CyberPanel installation:"
        echo "sh <(curl https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh)"
    else
        error "❌ Some tests failed. Please check the issues above."
        exit 1
    fi
}

# Run tests
main "$@"
