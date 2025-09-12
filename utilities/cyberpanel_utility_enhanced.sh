#!/bin/bash
# Enhanced CyberPanel Utility Script with Full OS Compatibility
# Supports Ubuntu 20.04-24.04, AlmaLinux 8-10, RockyLinux 8-9, RHEL 8-9, CentOS 7-9, CloudLinux 7-8

export LC_CTYPE=en_US.UTF-8
SUDO_TEST=$(set)
BRANCH_NAME="stable"
GIT_URL="github.com/usmannasir/cyberpanel"
GIT_CONTENT_URL="raw.githubusercontent.com/usmannasir/cyberpanel"

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
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/cyberpanel_utility.log
}

# Enhanced OS detection with support for all CyberPanel-compatible systems
check_OS() {
    if [[ ! -f /etc/os-release ]]; then
        echo -e "${RED}Unable to detect the operating system...${NC}\n"
        exit 1
    fi
    
    source /etc/os-release
    DISTRO="$ID"
    VERSION_ID="$VERSION_ID"
    
    # Map distributions to CyberPanel OS types
    case "$DISTRO" in
        "centos")
            Server_OS="CentOS"
            ;;
        "almalinux")
            Server_OS="AlmaLinux"
            ;;
        "cloudlinux")
            Server_OS="CloudLinux"
            ;;
        "ubuntu")
            Server_OS="Ubuntu"
            ;;
        "rocky")
            Server_OS="RockyLinux"
            ;;
        "rhel")
            Server_OS="RHEL"
            ;;
        "openeuler")
            Server_OS="openEuler"
            ;;
        "debian")
            Server_OS="Debian"
            ;;
        *)
            echo -e "${RED}Unable to detect your system...${NC}"
            echo -e "\nCyberPanel is supported on x86_64 based:"
            echo -e "• Ubuntu 20.04, 22.04, 24.04"
            echo -e "• AlmaLinux 8, 9, 10"
            echo -e "• RockyLinux 8, 9"
            echo -e "• RHEL 8, 9"
            echo -e "• CentOS 7, 8, 9"
            echo -e "• CloudLinux 7, 8"
            echo -e "• openEuler 20.03, 22.03"
            echo -e "• Debian (community support)\n"
            exit 1
            ;;
    esac

    # Extract major version number
    Server_OS_Version=$(echo "$VERSION_ID" | cut -d. -f1)
    
    echo -e "${GREEN}System: $Server_OS $VERSION_ID detected...${NC}\n"
    log_message "Detected OS: $Server_OS $VERSION_ID"

    # Normalize RHEL-based systems for package management
    if [[ "$Server_OS" == "CloudLinux" ]] || [[ "$Server_OS" == "AlmaLinux" ]] || [[ "$Server_OS" == "RockyLinux" ]] || [[ "$Server_OS" == "RHEL" ]]; then
        Server_OS="CentOS"  # Use CentOS package management for all RHEL derivatives
    fi
}

# Enhanced package manager detection
detect_package_manager() {
    if command -v dnf >/dev/null 2>&1; then
        PKG_MANAGER="dnf"
        PKG_INSTALL="dnf install -y"
        PKG_UPDATE="dnf update -y"
        PKG_GROUP="dnf groupinstall -y"
    elif command -v yum >/dev/null 2>&1; then
        PKG_MANAGER="yum"
        PKG_INSTALL="yum install -y"
        PKG_UPDATE="yum update -y"
        PKG_GROUP="yum groupinstall -y"
    elif command -v apt >/dev/null 2>&1; then
        PKG_MANAGER="apt"
        PKG_INSTALL="DEBIAN_FRONTEND=noninteractive apt install -y"
        PKG_UPDATE="apt update && apt upgrade -y"
        PKG_GROUP="apt install -y"
    elif command -v apt-get >/dev/null 2>&1; then
        PKG_MANAGER="apt-get"
        PKG_INSTALL="DEBIAN_FRONTEND=noninteractive apt-get install -y"
        PKG_UPDATE="apt-get update && apt-get upgrade -y"
        PKG_GROUP="apt-get install -y"
    else
        echo -e "${RED}No supported package manager found${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Using package manager: $PKG_MANAGER${NC}"
    log_message "Using package manager: $PKG_MANAGER"
}

# Enhanced WatchDog management
set_watchdog() {
    echo -e "\n${CYAN}Please choose:${NC}"
    echo -e "\n1. Install/Update WatchDog."
    echo -e "\n2. Start or Check WatchDog."
    echo -e "\n3. Kill WatchDog."
    echo -e "\n4. Back to Main Menu."
    echo -e "\n"
    printf "%s" "Please enter number [1-4]: "
    read TMP_YN

    if [[ $TMP_YN == "1" ]]; then
        if [[ -f /etc/cyberpanel/watchdog.sh ]]; then
            bash /etc/cyberpanel/watchdog.sh kill
        fi
        rm -f /etc/cyberpanel/watchdog.sh
        rm -f /usr/local/bin/watchdog
        wget -O /etc/cyberpanel/watchdog.sh https://$GIT_CONTENT_URL/$BRANCH_NAME/CPScripts/watchdog.sh
        chmod 700 /etc/cyberpanel/watchdog.sh
        ln -s /etc/cyberpanel/watchdog.sh /usr/local/bin/watchdog
        echo -e "\n${GREEN}WatchDog has been installed/updated...${NC}"
        watchdog status
        set_watchdog
    elif [[ $TMP_YN == "2" ]]; then
        if [[ -f /etc/cyberpanel/watchdog.sh ]]; then
            watchdog status
            exit
        else
            echo -e "\n${YELLOW}You don't have WatchDog installed, please install it first...${NC}"
            set_watchdog
        fi
    elif [[ $TMP_YN == "3" ]]; then
        if [[ -f /etc/cyberpanel/watchdog.sh ]]; then
            echo -e "\n"
            watchdog kill
            exit
        else
            echo -e "\n${YELLOW}You don't have WatchDog installed, please install it first...${NC}"
            set_watchdog
        fi
    elif [[ $TMP_YN == "4" ]]; then
        main_page
    else
        echo -e "\n${RED}Please enter correct number...${NC}"
        exit
    fi
}

# Enhanced error checking
check_return() {
    if [[ $? -eq "0" ]]; then
        :
    else
        echo -e "\n${RED}Command failed, exiting...${NC}"
        log_message "Command failed, exiting"
        exit
    fi
}

# Enhanced self-update mechanism
self_check() {
    echo -e "\n${BLUE}Checking CyberPanel Utility update...${NC}"
    SUM=$(md5sum /usr/bin/cyberpanel_utility 2>/dev/null || echo "00000000000000000000000000000000")
    SUM1=${SUM:0:32}

    rm -f /usr/local/CyberPanel/cyberpanel_utility.sh
    wget -q -O /usr/local/CyberPanel/cyberpanel_utility.sh https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel_utility.sh 2>/dev/null || {
        echo -e "${YELLOW}Failed to check for updates, using local version${NC}"
        return
    }
    chmod 600 /usr/local/CyberPanel/cyberpanel_utility.sh

    SUM=$(md5sum /usr/local/CyberPanel/cyberpanel_utility.sh 2>/dev/null || echo "00000000000000000000000000000000")
    SUM2=${SUM:0:32}

    if [[ $SUM1 == $SUM2 ]]; then
        echo -e "\n${GREEN}CyberPanel Utility Script is up to date...${NC}\n"
    else
        local_string=$(head -2 /usr/bin/cyberpanel_utility 2>/dev/null || echo "")
        remote_string=$(head -2 /usr/local/CyberPanel/cyberpanel_utility.sh 2>/dev/null || echo "")
        
        if [[ $local_string == $remote_string ]]; then
            echo -e "\n${BLUE}Updating CyberPanel Utility Script...${NC}"
            rm -f /usr/bin/cyberpanel_utility
            mv /usr/local/CyberPanel/cyberpanel_utility.sh /usr/bin/cyberpanel_utility
            chmod 700 /usr/bin/cyberpanel_utility
            echo -e "\n${GREEN}CyberPanel Utility update completed...${NC}"
            echo -e "\n${YELLOW}Please execute it again...${NC}"
            exit
        else
            echo -e "\n${YELLOW}Failed to fetch server file...${NC}"
            echo -e "\n${YELLOW}Keep using local script...${NC}"
        fi
    fi

    rm -f /usr/local/CyberPanel/cyberpanel_utility.sh
}

# Enhanced CyberPanel upgrade with better error handling
cyberpanel_upgrade() {
    SERVER_COUNTRY="unknown"
    SERVER_COUNTRY=$(curl --silent --max-time 5 https://cyberpanel.sh/?country 2>/dev/null || echo "unknown")
    
    if [[ ${#SERVER_COUNTRY} == "2" ]] || [[ ${#SERVER_COUNTRY} == "6" ]]; then
        echo -e "\n${BLUE}Checking server...${NC}"
    else
        echo -e "\n${BLUE}Checking server...${NC}"
        SERVER_COUNTRY="unknown"
    fi

    if [[ $SERVER_COUNTRY == "CN" ]]; then
        GIT_URL="gitee.com/qtwrk/cyberpanel"
        GIT_CONTENT_URL="gitee.com/qtwrk/cyberpanel/raw"
    fi

    echo -e "${BLUE}CyberPanel upgrading...${NC}"
    rm -f /usr/local/cyberpanel_upgrade.sh
    wget -O /usr/local/cyberpanel_upgrade.sh -q https://$GIT_CONTENT_URL/${BRANCH_NAME}/cyberpanel_upgrade.sh || {
        echo -e "${RED}Failed to download upgrade script${NC}"
        exit 1
    }
    chmod 700 /usr/local/cyberpanel_upgrade.sh
    /usr/local/cyberpanel_upgrade.sh
    rm -f /usr/local/cyberpanel_upgrade.sh
    exit
}

# Enhanced help system
show_help() {
    echo -e "\n${BLUE}Fetching information...${NC}\n"
    curl --silent https://cyberpanel.sh/misc/faq.sh | sudo -u nobody bash | less -r || {
        echo -e "${YELLOW}Failed to fetch FAQ, showing local help${NC}"
        show_local_help
    }
    exit
}

# Local help fallback
show_local_help() {
    echo -e "${CYAN}CyberPanel Utility Help${NC}"
    echo -e "\n${BLUE}Available Commands:${NC}"
    echo -e "• upgrade - Upgrade CyberPanel"
    echo -e "• addons - Install additional components"
    echo -e "• watchdog - Manage WatchDog service"
    echo -e "• help - Show this help"
    echo -e "\n${BLUE}Supported Operating Systems:${NC}"
    echo -e "• Ubuntu 20.04, 22.04, 24.04"
    echo -e "• AlmaLinux 8, 9, 10"
    echo -e "• RockyLinux 8, 9"
    echo -e "• RHEL 8, 9"
    echo -e "• CentOS 7, 8, 9"
    echo -e "• CloudLinux 7, 8"
}

# Enhanced addons with better OS compatibility
addons() {
    echo -e "\n${CYAN}Please choose:${NC}"
    echo -e "\n1. Install Memcached extension for PHP."
    echo -e "\n2. Install Memcached server."
    echo -e "\n3. Install Redis extension for PHP."
    echo -e "\n4. Install Redis server."
    echo -e "\n5. Raise phpMyAdmin upload limits."
    echo -e "\n6. Install additional PHP versions."
    echo -e "\n7. Back to Main Menu.\n"
    printf "%s" "Please enter number [1-7]: "
    read TMP_YN

    case $TMP_YN in
        1) install_php_memcached ;;
        2) install_memcached ;;
        3) install_php_redis ;;
        4) install_redis ;;
        5) phpmyadmin_limits ;;
        6) install_php_versions ;;
        7) main_page ;;
        *) echo -e "${RED}Please enter the right number [1-7]${NC}\n"; exit ;;
    esac
}

# Enhanced phpMyAdmin limits with OS-specific paths
phpmyadmin_limits() {
    echo -e "${BLUE}This will change following parameters for PHP 7.3:${NC}"
    echo -e "• Post Max Size from default 8M to 500M"
    echo -e "• Upload Max Filesize from default 2M to 500M"
    echo -e "• Memory Limit from default 128M to 768M"
    echo -e "• Max Execution Time from default 30 to 600"
    echo -e "\n${YELLOW}Please note this will also apply to all sites using PHP 7.3${NC}"
    printf "%s" "Please confirm to proceed: [Y/n]: "
    read TMP_YN
    
    if [[ $TMP_YN == "Y" ]] || [[ $TMP_YN == "y" ]]; then
        # OS-specific PHP configuration paths
        if [[ "$Server_OS" == "CentOS" ]] || [[ "$Server_OS" == "openEuler" ]]; then
            php_ini_path="/usr/local/lsws/lsphp73/etc/php.ini"
        elif [[ "$Server_OS" == "Ubuntu" ]]; then
            php_ini_path="/usr/local/lsws/lsphp73/etc/php/7.3/litespeed/php.ini"
        else
            # Try to find the correct path
            php_ini_path=$(find /usr/local/lsws -name "php.ini" -path "*/lsphp73/*" 2>/dev/null | head -1)
            if [[ -z "$php_ini_path" ]]; then
                echo -e "${RED}Could not find PHP 7.3 configuration file${NC}"
                exit 1
            fi
        fi
        
        if [[ -f "$php_ini_path" ]]; then
            sed -i 's|post_max_size = 8M|post_max_size = 500M|g' "$php_ini_path"
            sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 500M|g' "$php_ini_path"
            sed -i 's|memory_limit = 128M|memory_limit = 768M|g' "$php_ini_path"
            sed -i 's|max_execution_time = 30|max_execution_time = 600|g' "$php_ini_path"
            systemctl restart lscpd || service lscpd restart
            echo -e "${GREEN}Changes applied successfully${NC}"
        else
            echo -e "${RED}PHP configuration file not found: $php_ini_path${NC}"
        fi
    else
        echo -e "${YELLOW}Operation cancelled${NC}"
        exit
    fi
}

# Enhanced Redis installation with better OS support
install_php_redis() {
    echo -e "${BLUE}Installing Redis extension for PHP...${NC}"
    
    if [[ $Server_OS == "CentOS" ]]; then
        $PKG_INSTALL lsphp74-redis lsphp73-redis lsphp72-redis lsphp71-redis lsphp70-redis lsphp56-redis lsphp55-redis lsphp54-redis
    elif [[ $Server_OS == "Ubuntu" ]]; then
        $PKG_INSTALL lsphp74-redis lsphp73-redis lsphp72-redis lsphp71-redis lsphp70-redis
    elif [[ $Server_OS == "openEuler" ]]; then
        $PKG_INSTALL lsphp74-redis lsphp73-redis lsphp72-redis lsphp71-redis
    else
        echo -e "${YELLOW}Unsupported OS for automatic Redis extension installation${NC}"
        echo -e "${BLUE}Please install Redis extensions manually for your PHP versions${NC}"
    fi
    
    echo -e "\n${GREEN}Redis extension for PHP has been installed...${NC}"
    exit
}

# Enhanced Redis server installation
install_redis() {
    if [[ -f /usr/bin/redis-cli ]]; then
        echo -e "\n${GREEN}Redis is already installed...${NC}"
        return
    fi
    
    echo -e "${BLUE}Installing Redis server...${NC}"
    
    if [[ $Server_OS == "CentOS" ]]; then
        $PKG_INSTALL redis
    elif [[ $Server_OS == "Ubuntu" ]]; then
        $PKG_INSTALL redis-server
    elif [[ $Server_OS == "openEuler" ]]; then
        $PKG_INSTALL redis6
    else
        echo -e "${YELLOW}Unsupported OS for automatic Redis installation${NC}"
        exit 1
    fi
    
    # Configure Redis for IPv4 only if IPv6 is not available
    if ! ifconfig -a | grep inet6 >/dev/null 2>&1; then
        echo -e "\n${BLUE}No IPv6 detected, configuring Redis for IPv4 only...${NC}"
        if [[ $Server_OS == "Ubuntu" ]]; then
            sed -i 's|bind 127.0.0.1 ::1|bind 127.0.0.1|g' /etc/redis/redis.conf
        fi
    fi

    # Start and enable Redis service
    if systemctl is-active --quiet redis; then
        systemctl status redis
    else
        systemctl enable redis
        systemctl start redis
        systemctl status redis
    fi
    
    echo -e "\n${GREEN}Redis server installation completed${NC}"
}

# Enhanced Memcached installation
install_memcached() {
    echo -e "\n${CYAN}Would you like to install Memcached or LiteSpeed Memcached?${NC}"
    echo -e "\n1. LiteSpeed Memcached"
    echo -e "\n2. Memcached"
    echo -e "\n3. Back to Main Menu\n"
    printf "%s" "Please enter number [1-3]: "
    read TMP_YN

    case $TMP_YN in
        1) install_litespeed_memcached ;;
        2) install_standard_memcached ;;
        3) main_page ;;
        *) echo -e "${RED}Please enter the right number [1-3]${NC}\n"; exit ;;
    esac
}

# Install LiteSpeed Memcached
install_litespeed_memcached() {
    if systemctl is-active --quiet memcached; then
        echo -e "\n${YELLOW}It seems Memcached server is already running...${NC}"
        systemctl status memcached
        exit
    fi
    
    if [[ -f /usr/local/lsmcd/bin/lsmcd ]]; then
        echo -e "\n${GREEN}LiteSpeed Memcached is already installed...${NC}"
    else
        echo -e "${BLUE}Installing LiteSpeed Memcached...${NC}"
        
        # Install dependencies
        if [[ $Server_OS == "CentOS" ]] || [[ $Server_OS == "openEuler" ]]; then
            $PKG_GROUP "Development Tools"
            $PKG_INSTALL autoconf automake zlib-devel openssl-devel expat-devel pcre-devel libmemcached-devel cyrus-sasl*
        elif [[ $Server_OS == "Ubuntu" ]]; then
            $PKG_INSTALL build-essential zlib1g-dev libexpat1-dev openssl libssl-dev libsasl2-dev libpcre3-dev git
        fi
        
        # Download and compile LiteSpeed Memcached
        wget https://cdn.cyberpanel.sh/litespeed/lsmcd.tar.gz
        tar xzvf lsmcd.tar.gz
        DIR=$(pwd)
        cd "$DIR/lsmcd"
        ./fixtimestamp.sh
        ./configure CFLAGS=" -O3" CXXFLAGS=" -O3"
        make
        make install
        cd "$DIR"
        rm -rf lsmcd lsmcd.tar.gz
    fi
    
    # Start LiteSpeed Memcached
    if systemctl is-active --quiet lsmcd; then
        systemctl status lsmcd
    else
        systemctl enable lsmcd
        systemctl start lsmcd
        systemctl status lsmcd
    fi
    
    echo -e "\n${GREEN}LiteSpeed Memcached installation completed${NC}"
}

# Install standard Memcached
install_standard_memcached() {
    if systemctl is-active --quiet lsmcd; then
        echo -e "\n${YELLOW}It seems LiteSpeed Memcached server is already running...${NC}"
        systemctl status lsmcd
        exit
    fi
    
    if [[ -f /usr/bin/memcached ]]; then
        echo -e "\n${GREEN}Memcached is already installed...${NC}"
    else
        echo -e "${BLUE}Installing standard Memcached...${NC}"
        
        if [[ $Server_OS == "CentOS" ]]; then
            $PKG_INSTALL memcached
            sed -i 's|OPTIONS=""|OPTIONS="-l 127.0.0.1 -U 0"|g' /etc/sysconfig/memcached
        elif [[ $Server_OS == "Ubuntu" ]]; then
            $PKG_INSTALL memcached
        elif [[ $Server_OS == "openEuler" ]]; then
            $PKG_INSTALL memcached
            sed -i 's|OPTIONS=""|OPTIONS="-l 127.0.0.1 -U 0"|g' /etc/sysconfig/memcached
        fi
    fi
    
    # Start Memcached
    if systemctl is-active --quiet memcached; then
        systemctl status memcached
    else
        systemctl enable memcached
        systemctl start memcached
        systemctl status memcached
    fi
    
    echo -e "\n${GREEN}Standard Memcached installation completed${NC}"
}

# Enhanced PHP Memcached extension installation
install_php_memcached() {
    echo -e "${BLUE}Installing Memcached extension for PHP...${NC}"
    
    if [[ $Server_OS == "CentOS" ]]; then
        $PKG_INSTALL lsphp74-memcached lsphp73-memcached lsphp72-memcached lsphp71-memcached lsphp70-memcached lsphp56-pecl-memcached lsphp55-pecl-memcached lsphp54-pecl-memcached
    elif [[ $Server_OS == "Ubuntu" ]]; then
        $PKG_INSTALL lsphp74-memcached lsphp73-memcached lsphp72-memcached lsphp71-memcached lsphp70-memcached
    elif [[ $Server_OS == "openEuler" ]]; then
        $PKG_INSTALL lsphp74-memcached lsphp73-memcached lsphp72-memcached lsphp71-memcached
    else
        echo -e "${YELLOW}Unsupported OS for automatic Memcached extension installation${NC}"
        echo -e "${BLUE}Please install Memcached extensions manually for your PHP versions${NC}"
    fi
    
    echo -e "\n${GREEN}Memcached extension for PHP has been installed...${NC}"
    exit
}

# New function to install additional PHP versions
install_php_versions() {
    echo -e "\n${CYAN}Available PHP versions for installation:${NC}"
    echo -e "1. PHP 7.1"
    echo -e "2. PHP 7.2"
    echo -e "3. PHP 7.3"
    echo -e "4. PHP 7.4"
    echo -e "5. PHP 8.0"
    echo -e "6. PHP 8.1"
    echo -e "7. PHP 8.2"
    echo -e "8. PHP 8.3"
    echo -e "9. PHP 8.4"
    echo -e "0. Back to Main Menu"
    echo -e "\n"
    printf "%s" "Please enter number [0-9]: "
    read PHP_VERSION

    case $PHP_VERSION in
        1) install_specific_php "71" "7.1" ;;
        2) install_specific_php "72" "7.2" ;;
        3) install_specific_php "73" "7.3" ;;
        4) install_specific_php "74" "7.4" ;;
        5) install_specific_php "80" "8.0" ;;
        6) install_specific_php "81" "8.1" ;;
        7) install_specific_php "82" "8.2" ;;
        8) install_specific_php "83" "8.3" ;;
        9) install_specific_php "84" "8.4" ;;
        0) main_page ;;
        *) echo -e "${RED}Please enter the right number [0-9]${NC}\n"; install_php_versions ;;
    esac
}

# Install specific PHP version
install_specific_php() {
    local php_version="$1"
    local php_display="$2"
    
    echo -e "${BLUE}Installing PHP $php_display...${NC}"
    
    if [[ $Server_OS == "CentOS" ]]; then
        $PKG_INSTALL lsphp$php_version* || {
            echo -e "${RED}Failed to install PHP $php_display${NC}"
            return 1
        }
    elif [[ $Server_OS == "Ubuntu" ]]; then
        $PKG_INSTALL lsphp$php_version* || {
            echo -e "${RED}Failed to install PHP $php_display${NC}"
            return 1
        }
    else
        echo -e "${YELLOW}Unsupported OS for automatic PHP installation${NC}"
        return 1
    fi
    
    echo -e "${GREEN}PHP $php_display has been installed successfully${NC}"
    install_php_versions
}

# Enhanced main page with better formatting
main_page() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}    CyberPanel Utility Tools (Enhanced)${NC}"
    echo -e "${PURPLE}========================================${NC}"
    echo -e ""
    echo -e "${CYAN}1. Upgrade CyberPanel.${NC}"
    echo -e ""
    echo -e "${CYAN}2. Addons.${NC}"
    echo -e ""
    echo -e "${CYAN}3. WatchDog (beta)${NC}"
    echo -e ""
    echo -e "${CYAN}4. Frequently Asked Questions (FAQ)${NC}"
    echo -e ""
    echo -e "${CYAN}5. Exit.${NC}"
    echo -e ""
    read -p "  Please enter the number [1-5]: " num
    echo ""
    
    case "$num" in
        1) cyberpanel_upgrade ;;
        2) addons ;;
        3) set_watchdog ;;
        4) show_help ;;
        5) exit ;;
        *) echo -e "${RED}Please enter the right number [1-5]${NC}\n"; main_page ;;
    esac
}

# Enhanced panel check
panel_check() {
    if [[ ! -f /etc/cyberpanel/machineIP ]]; then
        echo -e "\n${YELLOW}Can not detect CyberPanel...${NC}"
        echo -e "\n${YELLOW}Exit...${NC}"
        exit
    fi
}

# Enhanced sudo check
sudo_check() {
    echo -e "\n${BLUE}Checking root privileges...${NC}"
    if echo $SUDO_TEST | grep SUDO > /dev/null; then
        echo -e "\n${RED}You are using SUDO, please run as root user...${NC}"
        echo -e "\nIf you don't have direct access to root user, please run ${YELLOW}sudo su -${NC} command (do NOT miss the ${YELLOW}-${NC} at end or it will fail) and then run utility command again."
        exit
    fi

    if [[ $(id -u) != 0 ]] > /dev/null; then
        echo -e "\n${RED}You must use root user to use CyberPanel Utility...${NC}"
        exit
    else
        echo -e "\n${GREEN}You are running as root...${NC}"
    fi
}

# Main execution
sudo_check
panel_check
self_check
check_OS
detect_package_manager

if [ $# -eq 0 ]; then
    main_page
else
    case "$1" in
        "upgrade"|"-u"|"--update"|"--upgrade"|"update")
            cyberpanel_upgrade
            ;;
        "help"|"-h"|"--help")
            show_help
            exit
            ;;
        *)
            echo -e "\n${RED}Unrecognized argument...${NC}"
            exit
            ;;
    esac
fi
