# CyberPanel AlmaLinux 9 Patch for installCyberPanel.py
# This patch fixes MariaDB command detection and service management issues

import os
import subprocess
import shlex

def find_mariadb_command():
    """
    Find the correct MariaDB client command for the current system
    Returns the command path or 'mysql' as fallback
    """
    # List of possible MariaDB client commands in order of preference
    mariadb_commands = ['mariadb', 'mysql', '/usr/bin/mariadb', '/usr/bin/mysql']
    
    for cmd in mariadb_commands:
        try:
            # Check if command exists and is executable
            result = subprocess.run(['which', cmd], capture_output=True, text=True)
            if result.returncode == 0 and os.path.exists(result.stdout.strip()):
                return result.stdout.strip()
        except:
            continue
    
    # If no command found, return 'mysql' as fallback
    return 'mysql'

def find_mariadb_service():
    """
    Find the correct MariaDB service name for the current system
    Returns the service name or 'mariadb' as fallback
    """
    # List of possible MariaDB service names in order of preference
    service_names = ['mariadb', 'mysqld', 'mysql']
    
    for service in service_names:
        try:
            # Check if service exists
            result = subprocess.run(['systemctl', 'list-unit-files', service + '.service'], 
                                  capture_output=True, text=True)
            if result.returncode == 0 and service + '.service' in result.stdout:
                return service
        except:
            continue
    
    # If no service found, return 'mariadb' as fallback
    return 'mariadb'

def patch_installCyberPanel():
    """
    Apply patches to installCyberPanel.py for AlmaLinux 9 compatibility
    """
    install_file = '/root/cyberpanel/install/installCyberPanel.py'
    
    if not os.path.exists(install_file):
        print(f"ERROR: {install_file} not found")
        return False
    
    # Read the original file
    with open(install_file, 'r') as f:
        content = f.read()
    
    # Patch 1: Fix MariaDB command detection in changeMYSQLRootPassword method
    old_change_mysql = '''            command = 'mariadb -u root -e "' + passwordCMD + '"'

            install_utils.call(command, self.distro, command, command, 0, 0, os.EX_OSERR)'''
    
    new_change_mysql = '''            # Find the correct MariaDB client command
            mariadb_cmd = find_mariadb_command()
            command = mariadb_cmd + ' -u root -e "' + passwordCMD + '"'

            install_utils.call(command, self.distro, command, command, 0, 0, os.EX_OSERR)'''
    
    if old_change_mysql in content:
        content = content.replace(old_change_mysql, new_change_mysql)
        print("Applied patch 1: Fixed MariaDB command detection in changeMYSQLRootPassword")
    else:
        print("WARNING: Could not find changeMYSQLRootPassword method to patch")
    
    # Patch 2: Fix MariaDB service detection in startMariaDB method
    old_start_mariadb = '''            ############## Start mariadb ######################
            self.manage_service('mariadb', 'start')'''
    
    new_start_mariadb = '''            ############## Start mariadb ######################
            # Find the correct MariaDB service name
            mariadb_service = find_mariadb_service()
            self.manage_service(mariadb_service, 'start')'''
    
    if old_start_mariadb in content:
        content = content.replace(old_start_mariadb, new_start_mariadb)
        print("Applied patch 2: Fixed MariaDB service detection in startMariaDB")
    else:
        print("WARNING: Could not find startMariaDB method to patch")
    
    # Patch 3: Fix MariaDB service enablement
    old_enable_mariadb = '''            self.manage_service('mariadb', 'enable')'''
    
    new_enable_mariadb = '''            self.manage_service(mariadb_service, 'enable')'''
    
    if old_enable_mariadb in content:
        content = content.replace(old_enable_mariadb, new_enable_mariadb)
        print("Applied patch 3: Fixed MariaDB service enablement")
    else:
        print("WARNING: Could not find MariaDB enable command to patch")
    
    # Add the helper functions at the top of the file
    helper_functions = '''
# Helper functions for AlmaLinux 9 compatibility
def find_mariadb_command():
    """
    Find the correct MariaDB client command for the current system
    Returns the command path or 'mysql' as fallback
    """
    import subprocess
    import os
    
    # List of possible MariaDB client commands in order of preference
    mariadb_commands = ['mariadb', 'mysql', '/usr/bin/mariadb', '/usr/bin/mysql']
    
    for cmd in mariadb_commands:
        try:
            # Check if command exists and is executable
            result = subprocess.run(['which', cmd], capture_output=True, text=True)
            if result.returncode == 0 and os.path.exists(result.stdout.strip()):
                return result.stdout.strip()
        except:
            continue
    
    # If no command found, return 'mysql' as fallback
    return 'mysql'

def find_mariadb_service():
    """
    Find the correct MariaDB service name for the current system
    Returns the service name or 'mariadb' as fallback
    """
    import subprocess
    
    # List of possible MariaDB service names in order of preference
    service_names = ['mariadb', 'mysqld', 'mysql']
    
    for service in service_names:
        try:
            # Check if service exists
            result = subprocess.run(['systemctl', 'list-unit-files', service + '.service'], 
                                  capture_output=True, text=True)
            if result.returncode == 0 and service + '.service' in result.stdout:
                return service
        except:
            continue
    
    # If no service found, return 'mariadb' as fallback
    return 'mariadb'

'''
    
    # Add helper functions after imports
    import_section_end = content.find('\nclass InstallCyberPanel:')
    if import_section_end != -1:
        content = content[:import_section_end] + helper_functions + content[import_section_end:]
        print("Applied patch 4: Added helper functions for MariaDB detection")
    else:
        print("WARNING: Could not find class definition to add helper functions")
    
    # Write the patched file
    with open(install_file, 'w') as f:
        f.write(content)
    
    print(f"Successfully patched {install_file}")
    return True

if __name__ == "__main__":
    print("Applying CyberPanel AlmaLinux 9 patches...")
    if patch_installCyberPanel():
        print("Patches applied successfully!")
    else:
        print("Failed to apply patches!")
