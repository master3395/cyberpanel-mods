#!/usr/bin/env bash
# Author: Michael Ramsey (Modified by Assistant)
# Objective: Fix permissions issues for Linux users using CyberPanel, cPanel, or Plesk

# Detect the Control Panel
if [ -f /usr/local/cpanel/cpanel ]; then
    ControlPanel="cpanel"
elif [ -f /usr/bin/cyberpanel ]; then
    ControlPanel="cyberpanel"
elif [ -f /usr/local/psa/core.version ]; then
    ControlPanel="plesk"
else
    echo "Unsupported Control Panel. Exiting."
    exit 1
fi

echo "============================================================="
echo "$ControlPanel Control Panel Detected"
echo "============================================================="

# Detect the OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo "Unable to detect the operating system. Exiting."
    exit 1
fi

# Function: Print Help Text
helptext() {
    echo "Fix Perms Script Help:"
    echo "Sets file/directory permissions to match suPHP and FastCGI schemes"
    echo "USAGE: Select an option from the menu"
    echo "-------"
    echo "Options:"
    echo "1) Fix permissions for all accounts"
    echo "2) Fix permissions for a specific account"
    echo "3) Display help"
    echo "4) Exit"
    exit 0
}

# Fix Permissions for CyberPanel Users
fixperms_cyberpanel() {
    local account=$1

    if [ -z "$account" ]; then
        echo "Error: Account name is required."
        return
    fi

    local user_homedir=$(grep -E "^${account}:" /etc/passwd | cut -d: -f6)

    if [ -z "$user_homedir" ]; then
        echo "Error: User $account does not exist."
        return
    fi

    echo "Fixing permissions for CyberPanel user: $account"

    chown -R $account:$account "$user_homedir"/public_html
    chmod -R 755 "$user_homedir"/public_html
    find "$user_homedir"/public_html -type f -exec chmod 644 {} \;

    chown -R vmail:vmail /home/vmail
    chmod 755 /home/vmail
    find /home/vmail -type d -exec chmod 755 {} \;
    find /home/vmail -type f -exec chmod 640 {} \;

    echo "Finished fixing permissions for CyberPanel user: $account"
}

# Fix Permissions for cPanel Users
fixperms_cpanel() {
    local account=$1

    if [ -z "$account" ]; then
        echo "Error: Account name is required."
        return
    fi

    local user_homedir=$(grep -E "^${account}:" /etc/passwd | cut -d: -f6)

    if [ -z "$user_homedir" ]; then
        echo "Error: User $account does not exist."
        return
    fi

    echo "Fixing permissions for cPanel user: $account"

    chown -R $account:$account "$user_homedir"/public_html
    chmod -R 755 "$user_homedir"/public_html
    find "$user_homedir"/public_html -type f -exec chmod 644 {} \;

    echo "Finished fixing permissions for cPanel user: $account"
}

# Fix Permissions for Plesk Users
fixperms_plesk() {
    local account=$1

    if [ -z "$account" ]; then
        echo "Error: Account name is required."
        return
    fi

    local user_homedir=$(grep -E "^${account}:" /etc/passwd | cut -d: -f6)

    if [ -z "$user_homedir" ]; then
        echo "Error: User $account does not exist."
        return
    fi

    echo "Fixing permissions for Plesk user: $account"

    chown -R $account:psacln "$user_homedir"/httpdocs
    chmod -R 755 "$user_homedir"/httpdocs
    find "$user_homedir"/httpdocs -type f -exec chmod 644 {} \;

    echo "Finished fixing permissions for Plesk user: $account"
}

# Main Menu Function
display_menu() {
    while true; do
        echo "============================================"
        echo "Fix Permissions Script"
        echo "============================================"
        echo "1) Fix permissions for all accounts"
        echo "2) Fix permissions for a specific account"
        echo "3) Display help"
        echo "4) Exit"
        read -rp "Enter your choice: " choice

        case $choice in
            1)
                if [ "$ControlPanel" == "cyberpanel" ]; then
                    for user in $(getent passwd | awk -F: '1000<$3 && $3<60000 {print $1}'); do
                        fixperms_cyberpanel "$user"
                    done
                else
                    echo "Fixing all accounts is only supported for CyberPanel."
                fi
                ;;
            2)
                read -rp "Enter the account name: " account
                case "$ControlPanel" in
                    cpanel)
                        fixperms_cpanel "$account"
                        ;;
                    cyberpanel)
                        fixperms_cyberpanel "$account"
                        ;;
                    plesk)
                        fixperms_plesk "$account"
                        ;;
                    *)
                        echo "Unsupported Control Panel."
                        ;;
                esac
                ;;
            3)
                helptext
                ;;
            4)
                echo "Exiting."
                break
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}

display_menu

exit 0