#!/bin/bash
mysql_password=$(cat /etc/cyberpanel/mysqlPassword)
success=0

# Try both table names in case one is wrong (different CyberPanel versions/configurations)
# First try: loginSystem_administrator (standard table name)
mysql -u root -p"$mysql_password" cyberpanel -e "UPDATE loginSystem_administrator SET twoFA = 0, secretKey = 'None' WHERE loginSystem_administrator.id = 1;" 2>/dev/null && success=1

# If first attempt failed, try alternative table name: cyberpanel.admin
if [[ $success -eq 0 ]]; then
	mysql -u root -p"$mysql_password" cyberpanel -e "UPDATE cyberpanel.admin SET twoFA = 0, secretKey = 'None' WHERE id = 1;" 2>/dev/null && success=1
fi

if [[ $success -eq 1 ]]; then
	echo ""
	echo "Two-factor authentication successfully removed for admin user."
	echo "Please try to login now."
	exit 0
else
	echo ""
	echo "ERROR: Could not disable 2FA. Please check database connection and table names."
	exit 1
fi
