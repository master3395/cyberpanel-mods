#!/bin/bash

# Function to fix a symbolic link
fix_symlink() {
    local target=$1
    local link=$2
    if [ -L "$link" ]; then
        sudo rm "$link"
        sudo ln -s "$target" "$link"
        echo "Fixed symbolic link: $link -> $target"
    fi
}

# Fix Python interpreter link
fix_symlink /usr/bin/python3 /usr/local/CyberCP/bin/python

# Fix other known symbolic links
fix_symlink /usr/local/lsws/bin/lswsctrl /usr/bin/lswsctrl

# Restart services
sudo /usr/local/lsws/bin/lswsctrl restart
sudo systemctl restart lscpd

echo "Symbolic link issues fixed and services restarted."
