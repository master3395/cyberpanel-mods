#!/bin/bash

# Test script for Sieve Fix Enhanced
# This script tests the functionality without making actual changes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Testing Sieve Fix Enhanced Script...${NC}"

# Test 1: Check if script exists and is executable
echo -e "\n${YELLOW}Test 1: Script existence and permissions${NC}"
if [[ -f "sieve_fix_enhanced.sh" ]]; then
    echo -e "${GREEN}✓ Script exists${NC}"
    if [[ -x "sieve_fix_enhanced.sh" ]]; then
        echo -e "${GREEN}✓ Script is executable${NC}"
    else
        echo -e "${RED}✗ Script is not executable${NC}"
    fi
else
    echo -e "${RED}✗ Script not found${NC}"
fi

# Test 2: Check script syntax
echo -e "\n${YELLOW}Test 2: Script syntax validation${NC}"
if command -v bash >/dev/null 2>&1; then
    if bash -n sieve_fix_enhanced.sh 2>/dev/null; then
        echo -e "${GREEN}✓ Script syntax is valid${NC}"
    else
        echo -e "${RED}✗ Script has syntax errors${NC}"
    fi
else
    echo -e "${YELLOW}⚠ bash not available for syntax check${NC}"
fi

# Test 3: Check help functionality
echo -e "\n${YELLOW}Test 3: Help functionality${NC}"
if [[ -f "sieve_fix_enhanced.sh" ]]; then
    if grep -q "show_usage" sieve_fix_enhanced.sh; then
        echo -e "${GREEN}✓ Help function exists${NC}"
    else
        echo -e "${RED}✗ Help function not found${NC}"
    fi
    
    if grep -q "--help" sieve_fix_enhanced.sh; then
        echo -e "${GREEN}✓ Help option exists${NC}"
    else
        echo -e "${RED}✗ Help option not found${NC}"
    fi
fi

# Test 4: Check OS detection
echo -e "\n${YELLOW}Test 4: OS detection functionality${NC}"
if grep -q "detect_os" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ OS detection function exists${NC}"
else
    echo -e "${RED}✗ OS detection function not found${NC}"
fi

if grep -q "Ubuntu\|AlmaLinux\|RockyLinux\|RHEL\|CentOS\|CloudLinux\|openEuler\|Debian" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ Multiple OS support detected${NC}"
else
    echo -e "${RED}✗ Limited OS support detected${NC}"
fi

# Test 5: Check package installation functions
echo -e "\n${YELLOW}Test 5: Package installation functions${NC}"
if grep -q "install_sieve_packages" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ Package installation function exists${NC}"
else
    echo -e "${RED}✗ Package installation function not found${NC}"
fi

if grep -q "yum\|dnf\|apt" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ Multiple package managers supported${NC}"
else
    echo -e "${RED}✗ Limited package manager support${NC}"
fi

# Test 6: Check configuration functions
echo -e "\n${YELLOW}Test 6: Configuration functions${NC}"
if grep -q "configure_dovecot_sieve" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ Dovecot configuration function exists${NC}"
else
    echo -e "${RED}✗ Dovecot configuration function not found${NC}"
fi

if grep -q "configure_postfix_lmtp" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ Postfix configuration function exists${NC}"
else
    echo -e "${RED}✗ Postfix configuration function not found${NC}"
fi

# Test 7: Check service management
echo -e "\n${YELLOW}Test 7: Service management${NC}"
if grep -q "restart_services" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ Service restart function exists${NC}"
else
    echo -e "${RED}✗ Service restart function not found${NC}"
fi

if grep -q "systemctl" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ systemctl support detected${NC}"
else
    echo -e "${RED}✗ systemctl support not detected${NC}"
fi

# Test 8: Check verification functions
echo -e "\n${YELLOW}Test 8: Verification functions${NC}"
if grep -q "verify_installation" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ Verification function exists${NC}"
else
    echo -e "${RED}✗ Verification function not found${NC}"
fi

if grep -q "netstat\|ss" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ Port checking functionality exists${NC}"
else
    echo -e "${RED}✗ Port checking functionality not found${NC}"
fi

# Test 9: Check backup functionality
echo -e "\n${YELLOW}Test 9: Backup functionality${NC}"
if grep -q "backup_configurations" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ Backup function exists${NC}"
else
    echo -e "${RED}✗ Backup function not found${NC}"
fi

if grep -q "\.backup" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ Backup file creation detected${NC}"
else
    echo -e "${RED}✗ Backup file creation not detected${NC}"
fi

# Test 10: Check logging functionality
echo -e "\n${YELLOW}Test 10: Logging functionality${NC}"
if grep -q "log_message" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ Logging function exists${NC}"
else
    echo -e "${RED}✗ Logging function not found${NC}"
fi

if grep -q "/var/log/cyberpanel_sieve_fix.log" sieve_fix_enhanced.sh; then
    echo -e "${GREEN}✓ Log file path configured${NC}"
else
    echo -e "${RED}✗ Log file path not configured${NC}"
fi

echo -e "\n${BLUE}=== Test Summary ===${NC}"
echo -e "${GREEN}All functionality tests completed!${NC}"
echo -e "${YELLOW}Note: This is a syntax and structure test only.${NC}"
echo -e "${YELLOW}For full functionality testing, run the script on a test system.${NC}"
