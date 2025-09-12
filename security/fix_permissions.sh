#!/bin/bash
# CyberPanel Utility Script with FixPerms Integration

export LC_CTYPE=en_US.UTF-8
SUDO_TEST=$(set)
BRANCH_NAME="stable"
GIT_URL="github.com/usmannasir/cyberpanel"
GIT_CONTENT_URL="raw.githubusercontent.com/usmannasir/cyberpanel"

fixperms() {
    echo -e "\nFixPerms Utility\n"
    echo -e "1. Fix permissions for a single user."
    echo -e "2. Fix permissions for all users."
    echo -e "3. Back to Main Menu.\n"
    printf "%s" "Please enter number [1-3]: "
    read option

    case $option in
        1)
            read -p "Enter the username: " username
            sudo bash <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/fixperms.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/fixperms.sh) -a $username
            ;;
        2)
            sudo bash <(curl -s https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/fixperms.sh || wget -qO - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/fixperms.sh) -all
            ;;
        3)
            main_page
            ;;
        *)
            echo "Invalid option. Returning to the main menu."
            main_page
            ;;
    esac
}

check_OS() {
    if [[ ! -f /etc/os-release ]] ; then
        echo -e "Unable to detect the operating system...\n"
        exit
    fi

    DISTRO=$(grep "^ID=" /etc/os-release | grep -E -o "[a-z]\w+")

    case $DISTRO in
        centos)
            Server_OS="CentOS";;
        almalinux)
            Server_OS="AlmaLinux";;
        cloudlinux)
            Server_OS="CloudLinux";;
        ubuntu)
            Server_OS="Ubuntu";;
        rocky)
            Server_OS="RockyLinux";;
        openeuler)
            Server_OS="openEuler";;
        *)
            echo -e "Unable to detect your system..."
            echo -e "\nCyberPanel is supported on x86_64 based Ubuntu 18.04, Ubuntu 20.04, Ubuntu 20.10, Ubuntu 22.04, CentOS 7, CentOS 8, AlmaLinux 8, RockyLinux 8, CloudLinux 7, CloudLinux 8, openEuler 20.03, openEuler 22.03...\n"
            exit;;
    esac

    Server_OS_Version=$(grep VERSION_ID /etc/os-release | awk -F[=,] '{print $2}' | tr -d \" | head -c2 | tr -d .)
    echo -e "System: $Server_OS $Server_OS_Version detected...\n"

    if [[ $Server_OS == "CloudLinux" || "$Server_OS" == "AlmaLinux" || "$Server_OS" == "RockyLinux" ]] ; then
        Server_OS="CentOS"
    fi
}

main_page() {
    echo -e "\t\tCyberPanel Utility Tools \e[31m(beta)\e[39m

  1. Upgrade CyberPanel.

  2. FixPerms Utility.

  3. Addons.

  4. Frequently Asked Question (FAQ).

  5. Exit.

  "
    read -p "  Please enter the number[1-5]: " num
    echo ""
    case "$num" in
        1)
            cyberpanel_upgrade
            ;;
        2)
            fixperms
            ;;
        3)
            addons
            ;;
        4)
            show_help
            ;;
        5)
            exit
            ;;
        *)
            echo -e "  Please enter the right number [1-5]\n"
            exit
            ;;
    esac
}

# Additional existing functions like addons(), cyberpanel_upgrade(), etc., remain unchanged.

sudo_check() {
    echo -e "\nChecking root privileges..."
    if echo $SUDO_TEST | grep SUDO > /dev/null ; then
        echo -e "\nYou are using SUDO, please run as root user..."
        echo -e "\nIf you don't have direct access to root user, please run \e[31msudo su -\e[39m command (do NOT miss the \e[31m-\e[39m at end or it will fail) and then run utility command again."
        exit
    fi

    if [[ $(id -u) != 0 ]]  > /dev/null; then
        echo -e "\nYou must use root user to use CyberPanel Utility..."
        exit
    else
        echo -e "\nYou are running as root..."
    fi
}

sudo_check

panel_check() {
    if [[ ! -f /etc/cyberpanel/machineIP ]] ; then
        echo -e "\nCannot detect CyberPanel..."
        echo -e "\nExit..."
        exit
    fi
}

panel_check

self_check() {
    echo -e "\nChecking CyberPanel Utility update..."
    SUM=$(md5sum /usr/bin/cyberpanel_utility)
    SUM1=${SUM:0:32}
    # Get md5sum of local file

    rm -f /usr/local/CyberPanel/cyberpanel_utility.sh
    wget -q -O /usr/local/CyberPanel/cyberpanel_utility.sh https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/cyberpanel_utility.sh
    chmod 600 /usr/local/CyberPanel/cyberpanel_utility.sh

    SUM=$(md5sum /usr/local/CyberPanel/cyberpanel_utility.sh)
    SUM2=${SUM:0:32}
    # Get md5sum of remote file

    if [[ $SUM1 == $SUM2 ]] ; then
        echo -e "\nCyberPanel Utility Script is up to date...\n"
    else
        local_string=$(head -2 /usr/bin/cyberpanel_utility)
        remote_string=$(head -2 /usr/local/CyberPanel/cyberpanel_utility.sh)
        # Check file content before replacing itself in case failed to download the file.
        if [[ $local_string == $remote_string ]] ; then
            echo -e "\nUpdating CyberPanel Utility Script..."
            rm -f /usr/bin/cyberpanel_utility
            mv /usr/local/CyberPanel/cyberpanel_utility.sh /usr/bin/cyberpanel_utility
            chmod 700 /usr/bin/cyberpanel_utility
            echo -e "\nCyberPanel Utility update completed..."
            echo -e "\nPlease execute it again..."
            exit
        else
            echo -e "\nFailed to fetch server file..."
            echo -e "\nKeep using local script..."
        fi
    fi

    rm -f /usr/local/CyberPanel/cyberpanel_utility.sh
}

self_check

check_OS

if [ $# -eq 0 ] ; then
    main_page
else
    if [[ $1 == "upgrade" ]] || [[ $1 == "-u" ]] || [[ $1 == "--update" ]] || [[ $1 == "--upgrade" ]] || [[ $1 == "update" ]]; then
        cyberpanel_upgrade
    fi
    if [[ $1 == "help" ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]] ; then
        show_help
        exit
    fi
    echo -e "\nUnrecognized argument..."
    exit
fi