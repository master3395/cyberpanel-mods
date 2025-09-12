#!/bin/bash

# CyberPanel Mods OS Compatibility Checker
# This script checks if the current system is compatible with CyberPanel mods
# and provides recommendations for optimal performance

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
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/cyberpanel_mods_compatibility.log
}

# Function to detect OS and version
detect_os() {
    if [[ ! -f /etc/os-release ]]; then
        echo -e "${RED}ERROR: Unable to detect operating system${NC}"
        exit 1
    fi
    
    source /etc/os-release
    
    case "$ID" in
        "ubuntu")
            OS_NAME="Ubuntu"
            OS_VERSION="$VERSION_ID"
            OS_MAJOR_VERSION=$(echo "$VERSION_ID" | cut -d. -f1)
            ;;
        "almalinux")
            OS_NAME="AlmaLinux"
            OS_VERSION="$VERSION_ID"
            OS_MAJOR_VERSION=$(echo "$VERSION_ID" | cut -d. -f1)
            ;;
        "rocky")
            OS_NAME="RockyLinux"
            OS_VERSION="$VERSION_ID"
            OS_MAJOR_VERSION=$(echo "$VERSION_ID" | cut -d. -f1)
            ;;
        "rhel")
            OS_NAME="RHEL"
            OS_VERSION="$VERSION_ID"
            OS_MAJOR_VERSION=$(echo "$VERSION_ID" | cut -d. -f1)
            ;;
        "centos")
            OS_NAME="CentOS"
            OS_VERSION="$VERSION_ID"
            OS_MAJOR_VERSION=$(echo "$VERSION_ID" | cut -d. -f1)
            ;;
        "cloudlinux")
            OS_NAME="CloudLinux"
            OS_VERSION="$VERSION_ID"
            OS_MAJOR_VERSION=$(echo "$VERSION_ID" | cut -d. -f1)
            ;;
        "openeuler")
            OS_NAME="openEuler"
            OS_VERSION="$VERSION_ID"
            OS_MAJOR_VERSION=$(echo "$VERSION_ID" | cut -d. -f1)
            ;;
        "debian")
            OS_NAME="Debian"
            OS_VERSION="$VERSION_ID"
            OS_MAJOR_VERSION=$(echo "$VERSION_ID" | cut -d. -f1)
            ;;
        *)
            OS_NAME="Unknown"
            OS_VERSION="$VERSION_ID"
            OS_MAJOR_VERSION="Unknown"
            ;;
    esac
    
    echo -e "${BLUE}Detected OS: ${OS_NAME} ${OS_VERSION}${NC}"
}

# Function to check CyberPanel compatibility
check_cyberpanel_compatibility() {
    echo -e "\n${CYAN}=== CyberPanel Compatibility Check ===${NC}"
    
    # Check if CyberPanel is installed
    if [[ -f /etc/cyberpanel/machineIP ]]; then
        echo -e "${GREEN}✓ CyberPanel is installed${NC}"
        CYBERPANEL_INSTALLED=true
    else
        echo -e "${YELLOW}⚠ CyberPanel not detected${NC}"
        CYBERPANEL_INSTALLED=false
    fi
    
    # Check supported OS versions
    case "$OS_NAME" in
        "Ubuntu")
            case "$OS_MAJOR_VERSION" in
                "20"|"22"|"24")
                    echo -e "${GREEN}✓ Ubuntu ${OS_VERSION} is fully supported${NC}"
                    COMPATIBILITY_LEVEL="FULL"
                    ;;
                "18")
                    echo -e "${YELLOW}⚠ Ubuntu ${OS_VERSION} is supported but may have limited features${NC}"
                    COMPATIBILITY_LEVEL="LIMITED"
                    ;;
                *)
                    echo -e "${RED}✗ Ubuntu ${OS_VERSION} is not officially supported${NC}"
                    COMPATIBILITY_LEVEL="UNSUPPORTED"
                    ;;
            esac
            ;;
        "AlmaLinux"|"RockyLinux"|"RHEL")
            case "$OS_MAJOR_VERSION" in
                "8"|"9"|"10")
                    echo -e "${GREEN}✓ ${OS_NAME} ${OS_VERSION} is fully supported${NC}"
                    COMPATIBILITY_LEVEL="FULL"
                    ;;
                "7")
                    echo -e "${YELLOW}⚠ ${OS_NAME} ${OS_VERSION} is supported but may have limited features${NC}"
                    COMPATIBILITY_LEVEL="LIMITED"
                    ;;
                *)
                    echo -e "${RED}✗ ${OS_NAME} ${OS_VERSION} is not officially supported${NC}"
                    COMPATIBILITY_LEVEL="UNSUPPORTED"
                    ;;
            esac
            ;;
        "CentOS")
            case "$OS_MAJOR_VERSION" in
                "7"|"8"|"9")
                    echo -e "${GREEN}✓ CentOS ${OS_VERSION} is fully supported${NC}"
                    COMPATIBILITY_LEVEL="FULL"
                    ;;
                *)
                    echo -e "${RED}✗ CentOS ${OS_VERSION} is not officially supported${NC}"
                    COMPATIBILITY_LEVEL="UNSUPPORTED"
                    ;;
            esac
            ;;
        "CloudLinux")
            case "$OS_MAJOR_VERSION" in
                "7"|"8")
                    echo -e "${GREEN}✓ CloudLinux ${OS_VERSION} is fully supported${NC}"
                    COMPATIBILITY_LEVEL="FULL"
                    ;;
                *)
                    echo -e "${RED}✗ CloudLinux ${OS_VERSION} is not officially supported${NC}"
                    COMPATIBILITY_LEVEL="UNSUPPORTED"
                    ;;
            esac
            ;;
        "openEuler")
            echo -e "${YELLOW}⚠ openEuler ${OS_VERSION} has community support${NC}"
            COMPATIBILITY_LEVEL="COMMUNITY"
            ;;
        "Debian")
            echo -e "${YELLOW}⚠ Debian ${OS_VERSION} has community support${NC}"
            COMPATIBILITY_LEVEL="COMMUNITY"
            ;;
        *)
            echo -e "${RED}✗ ${OS_NAME} ${OS_VERSION} is not supported${NC}"
            COMPATIBILITY_LEVEL="UNSUPPORTED"
            ;;
    esac
}

# Function to check package manager
check_package_manager() {
    echo -e "\n${CYAN}=== Package Manager Check ===${NC}"
    
    if command -v dnf >/dev/null 2>&1; then
        echo -e "${GREEN}✓ DNF package manager detected${NC}"
        PACKAGE_MANAGER="dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo -e "${GREEN}✓ YUM package manager detected${NC}"
        PACKAGE_MANAGER="yum"
    elif command -v apt >/dev/null 2>&1; then
        echo -e "${GREEN}✓ APT package manager detected${NC}"
        PACKAGE_MANAGER="apt"
    elif command -v apt-get >/dev/null 2>&1; then
        echo -e "${GREEN}✓ APT-GET package manager detected${NC}"
        PACKAGE_MANAGER="apt-get"
    else
        echo -e "${RED}✗ No supported package manager found${NC}"
        PACKAGE_MANAGER="none"
    fi
}

# Function to check system requirements
check_system_requirements() {
    echo -e "\n${CYAN}=== System Requirements Check ===${NC}"
    
    # Check available memory
    if command -v free >/dev/null 2>&1; then
        MEMORY_GB=$(free -g | awk 'NR==2{print $2}')
        if [[ $MEMORY_GB -ge 2 ]]; then
            echo -e "${GREEN}✓ Memory: ${MEMORY_GB}GB (Recommended: 2GB+)${NC}"
        else
            echo -e "${YELLOW}⚠ Memory: ${MEMORY_GB}GB (Recommended: 2GB+)${NC}"
        fi
    fi
    
    # Check disk space
    if command -v df >/dev/null 2>&1; then
        DISK_SPACE=$(df -h / | awk 'NR==2{print $4}' | sed 's/G//')
        if [[ $DISK_SPACE -ge 20 ]]; then
            echo -e "${GREEN}✓ Disk Space: ${DISK_SPACE}GB available (Recommended: 20GB+)${NC}"
        else
            echo -e "${YELLOW}⚠ Disk Space: ${DISK_SPACE}GB available (Recommended: 20GB+)${NC}"
        fi
    fi
    
    # Check CPU architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        echo -e "${GREEN}✓ Architecture: ${ARCH} (Supported)${NC}"
    else
        echo -e "${RED}✗ Architecture: ${ARCH} (Not supported)${NC}"
    fi
}

# Function to check required services
check_services() {
    echo -e "\n${CYAN}=== Required Services Check ===${NC}"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        echo -e "${GREEN}✓ Running as root${NC}"
    else
        echo -e "${RED}✗ Not running as root (Required)${NC}"
    fi
    
    # Check systemd
    if command -v systemctl >/dev/null 2>&1; then
        echo -e "${GREEN}✓ systemd is available${NC}"
    else
        echo -e "${RED}✗ systemd not available (Required)${NC}"
    fi
    
    # Check curl/wget
    if command -v curl >/dev/null 2>&1; then
        echo -e "${GREEN}✓ curl is available${NC}"
    else
        echo -e "${YELLOW}⚠ curl not available (Recommended)${NC}"
    fi
    
    if command -v wget >/dev/null 2>&1; then
        echo -e "${GREEN}✓ wget is available${NC}"
    else
        echo -e "${YELLOW}⚠ wget not available (Recommended)${NC}"
    fi
}

# Function to provide recommendations
provide_recommendations() {
    echo -e "\n${CYAN}=== Recommendations ===${NC}"
    
    case "$COMPATIBILITY_LEVEL" in
        "FULL")
            echo -e "${GREEN}✓ Your system is fully compatible with CyberPanel mods${NC}"
            echo -e "${BLUE}  You can safely use all mods without restrictions${NC}"
            ;;
        "LIMITED")
            echo -e "${YELLOW}⚠ Your system has limited compatibility${NC}"
            echo -e "${BLUE}  Some mods may not work as expected${NC}"
            echo -e "${BLUE}  Consider upgrading to a fully supported version${NC}"
            ;;
        "COMMUNITY")
            echo -e "${YELLOW}⚠ Your system has community support only${NC}"
            echo -e "${BLUE}  Use mods with caution and test thoroughly${NC}"
            echo -e "${BLUE}  Report any issues to the community${NC}"
            ;;
        "UNSUPPORTED")
            echo -e "${RED}✗ Your system is not officially supported${NC}"
            echo -e "${BLUE}  Mods may not work or could cause system instability${NC}"
            echo -e "${BLUE}  Consider using a supported operating system${NC}"
            ;;
    esac
    
    # OS-specific recommendations
    case "$OS_NAME" in
        "Ubuntu")
            if [[ "$OS_MAJOR_VERSION" == "24" ]]; then
                echo -e "${BLUE}  Ubuntu 24.04 is the newest supported version${NC}"
                echo -e "${BLUE}  All mods should work optimally${NC}"
            fi
            ;;
        "AlmaLinux"|"RockyLinux")
            if [[ "$OS_MAJOR_VERSION" == "10" ]]; then
                echo -e "${BLUE}  ${OS_NAME} 10 is the newest supported version${NC}"
                echo -e "${BLUE}  All mods should work optimally${NC}"
            fi
            ;;
    esac
}

# Function to generate compatibility report
generate_report() {
    echo -e "\n${CYAN}=== Compatibility Report ===${NC}"
    
    REPORT_FILE="/tmp/cyberpanel_mods_compatibility_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "CyberPanel Mods Compatibility Report"
        echo "Generated: $(date)"
        echo "OS: $OS_NAME $OS_VERSION"
        echo "Architecture: $(uname -m)"
        echo "Package Manager: $PACKAGE_MANAGER"
        echo "Compatibility Level: $COMPATIBILITY_LEVEL"
        echo "CyberPanel Installed: $CYBERPANEL_INSTALLED"
        echo ""
        echo "Recommendations:"
        case "$COMPATIBILITY_LEVEL" in
            "FULL") echo "- System is fully compatible" ;;
            "LIMITED") echo "- System has limited compatibility" ;;
            "COMMUNITY") echo "- System has community support only" ;;
            "UNSUPPORTED") echo "- System is not officially supported" ;;
        esac
    } > "$REPORT_FILE"
    
    echo -e "${GREEN}Report saved to: $REPORT_FILE${NC}"
}

# Main function
main() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}  CyberPanel Mods Compatibility Checker${NC}"
    echo -e "${PURPLE}========================================${NC}"
    
    log_message "Starting compatibility check for $OS_NAME $OS_VERSION"
    
    detect_os
    check_cyberpanel_compatibility
    check_package_manager
    check_system_requirements
    check_services
    provide_recommendations
    generate_report
    
    echo -e "\n${GREEN}Compatibility check completed!${NC}"
    log_message "Compatibility check completed"
}

# Run main function
main "$@"
