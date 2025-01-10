
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
    echo "Usage: fixperms [options] -a account_name"
    echo "Options:"
    echo "  -h or --help       Show this help message"
    echo "  -v                 Enable verbose output"
    echo "  -all               Run on all accounts"
    echo "  -a <account_name>  Specify a CyberPanel/cPanel/Plesk account"
    exit 0
}

# Fix Permissions for CyberPanel Users
fixperms_cyberpanel() {
    local account=$1

    if [ -z "$account" ]; then
        echo "Error: Account name is required."
        helptext
    fi

    local user_homedir=$(grep -E "^${account}:" /etc/passwd | cut -d: -f6)

    if [ -z "$user_homedir" ]; then
        echo "Error: User $account does not exist."
        exit 1
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
        helptext
    fi

    local user_homedir=$(grep -E "^${account}:" /etc/passwd | cut -d: -f6)

    if [ -z "$user_homedir" ]; then
        echo "Error: User $account does not exist."
        exit 1
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
        helptext
    fi

    local user_homedir=$(grep -E "^${account}:" /etc/passwd | cut -d: -f6)

    if [ -z "$user_homedir" ]; then
        echo "Error: User $account does not exist."
        exit 1
    fi

    echo "Fixing permissions for Plesk user: $account"

    chown -R $account:psacln "$user_homedir"/httpdocs
    chmod -R 755 "$user_homedir"/httpdocs
    find "$user_homedir"/httpdocs -type f -exec chmod 644 {} \;

    echo "Finished fixing permissions for Plesk user: $account"
}

# Main Function
fixperms() {
    local account=$1

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
            echo "Error: Unsupported Control Panel."
            exit 1
            ;;
    esac
}

# Handle Arguments
case "$1" in
    -h|--help)
        helptext
        ;;
    -v)
        verbose="-v"
        ;;
    -all)
        if [ "$ControlPanel" == "cyberpanel" ]; then
            for user in $(getent passwd | awk -F: '1000<$3 && $3<60000 {print $1}'); do
                fixperms "$user"
            done
        else
            echo "-all option is only supported for CyberPanel."
            exit 1
        fi
        ;;
    -a)
        fixperms "$2"
        ;;
    *)
        echo "Error: Invalid option."
        helptext
        ;;
esac

exit 0
