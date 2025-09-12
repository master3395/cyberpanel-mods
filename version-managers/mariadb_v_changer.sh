#!/bin/bash
set -e

# Prompt for the desired MariaDB version
read -p "Enter the MariaDB version you want to install (e.g., 10.6): " mariadb_version

# Define constants
repo_url="https://downloads.mariadb.com/MariaDB/mariadb_repo_setup"
config_file="/etc/my.cnf"
backup_dir="/tmp/mariadb_backup_$(date +%Y%m%d%H%M%S)"
current_version=$(mysql --version 2>/dev/null || echo "None")

# Display current MariaDB version
echo "Current MariaDB version: $current_version"

# Confirm the operation
read -p "Do you want to proceed with installing MariaDB version $mariadb_version? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Backup existing MariaDB configuration and data
echo "Backing up existing configuration and data to $backup_dir..."
mkdir -p "$backup_dir"
cp -r /var/lib/mysql "$backup_dir/" || echo "No data directory to backup."
cp "$config_file" "$backup_dir/my.cnf.bak" || echo "No configuration file to backup."

# Stop MariaDB service
echo "Stopping MariaDB service..."
systemctl stop mariadb || systemctl stop mysql || echo "Service not running."

# Remove current MariaDB installation
echo "Removing existing MariaDB installation..."
yum remove -y mariadb* || apt-get remove -y mariadb* || echo "No existing MariaDB installation found."

# Add MariaDB repository and install the specified version
echo "Setting up MariaDB repository for version $mariadb_version..."
curl -sS "$repo_url" | bash -s -- --mariadb-server-version="$mariadb_version"

echo "Installing MariaDB version $mariadb_version..."
yum install -y mariadb-server || apt-get install -y mariadb-server || {
    echo "Failed to install MariaDB version $mariadb_version."
    exit 1
}

# Start MariaDB service
echo "Starting MariaDB service..."
systemctl start mariadb || systemctl start mysql || {
    echo "Failed to start MariaDB service."
    exit 1
}

# Display new MariaDB version
echo "MariaDB has been successfully updated to version:"
mysql --version

echo ""
echo "MariaDB version $mariadb_version has been installed successfully."
echo "Backup of the previous configuration and data is located at $backup_dir."
