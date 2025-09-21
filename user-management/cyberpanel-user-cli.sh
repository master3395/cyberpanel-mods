#!/bin/bash

## Enhanced CyberPanel User-Friendly CLI Interface
## Integrated into CyberPanel Mods for unified user and admin functionality
## Original by Alfred Valderrama, Enhanced for CyberPanel Mods

## Regular Colors.

export BLUE='\e[1;94m'
export GREEN='\e[1;92m'
export RED='\e[1;91m'
export RESETCOLOR='\e[1;00m'
export BLACK='\e[0;30m'
export REGRED='\e[0;31m'
export REGGREEN='\e[0;32m'
export YELLOW='\e[0;33m'
export PURPLE='\e[0;35m'
export CYAN='\e[0;36m'
export WHITE='\e[0;37m'

## Bolder Colors

export BOLDBLACK='\e[1;30m'
export BOLDRED='\e[1;31m'
export BOLDGREEN='\e[1;32m'
export BOLDYELLOW='\e[1;33m'
export BOLDBLUE='\e[1;34m'
export BOLDPURPLE='\e[1;35m'
export BOLDCYAN='\e[1;36m'
export BOLDWHITE='\e[1;37m'

## Underlined Colors

export UNDERBLACK='\e[4;30m'
export UNDERRED='\e[4;31m'
export UNDERGREEN='\e[4;32m'
export UNDERYELLOW='\e[4;33m'
export UNDERBLUE='\e[4;34m'
export UNDERPURPLE='\e[4;35m'
export UNDERPURPLE='\e[4;36m'
export UNDERWHITE='\e[4;37m'

## Background colors

export BACKBLACK='\e[40m'
export BACKRED='\e[41m'
export BACKGREEN='\e[42m'
export BACKYELLOW='\e[43m'
export BACKBLUE='\e[44m'
export BACKPURPLE='\e[45m'
export BACKCYAN='\e[46m'
export BACKWHITE='\e[47m'
export TEXTRESET='\e[0m'

## Regex Variable Patterns

special_chars="(\:|\/|\?|\#|\@|\!|\\$|\&|\'|\(|\)|\*|\+|\,|\;|\=|\%|\[|\])"
username_special_chars="(\:|\/|\?|\#|\!|\\$|\&|\'|\(|\)|\*|\+|\,|\;|\=|\%|\[|\])"
email_pattern="\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b"
acl_pattern="admin\|reseller\|user\|Customer"
security_level="HIGH\|LOW"
package_pattern="Default\|admin_Standard\|admin_Professional\|admin_Enterprise"
dns_record_pattern="A\|AAAA\|CNAME\|MX\|TXT\|SPF\|NS\|SOA\|SRV\|CAA"
php_version_pattern="5\.3\|5\.4\|5\.5\|5\.6\|7\.0\|7\.1\|7\.2\|7\.3\|7\.4"
domain_pattern="(?*\.com|*\.ph|*\.org|*\.net|*\.edu|*\.gov|*\.www|www\.*)"
ipv4_pattern="\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"
only_numeric="[A-Za-z]"

# Logging function
log_message() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/cyberpanel_user_cli.log
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}ERROR: This script must be run as root${NC}"
        echo -e "${YELLOW}Please run: sudo su -${NC}"
        exit 1
    fi
}

# Check if CyberPanel is installed
check_cyberpanel() {
    if ! command -v cyberpanel >/dev/null 2>&1; then
        echo -e "${RED}ERROR: CyberPanel CLI not found${NC}"
        echo -e "${YELLOW}Please install CyberPanel first${NC}"
        exit 1
    fi
}

function Options()
{
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                      User Functions                                 *"
	echo "***********************************************************************"
	echo "1) Automatic Creation (Standard)"
	echo "2) Create User"
	echo "3) Delete User"
	echo "4) Suspend User"
	echo "5) Unsuspend User"
	echo "6) Edit User"
	echo "7) List Users"
	echo -e $GREEN
	echo "***********************************************************************"
	echo "*                      Website Functions                              *"
	echo "***********************************************************************"
	echo "8) Create Website"
	echo "9) Delete Website"
	echo "10) Create Child Domain"
	echo "11) Delete Child Domain"
	echo "12) List Websites"
	echo "13) Change PHP Version"
	echo "14) Change Package"
	echo -e $WHITE
	echo "***********************************************************************"
	echo "*                      DNS Functions                                  *"
	echo "***********************************************************************"
	echo "15) List DNS Zones"
	echo "16) List DNS Records"
	echo "17) Create DNS Zone"
	echo "18) Delete DNS Zone"
	echo "19) Create DNS Record"
	echo "20) Delete DNS Record"
	echo -e $BLUE
	echo "***********************************************************************"
	echo "*                      Backup Functions                               *"
	echo "***********************************************************************"
	echo "21) Create Backup"
	echo "22) Restore Backup"
	echo -e $WHITE
	echo "***********************************************************************"
	echo "*                      Package Functions                              *"
	echo "***********************************************************************"
	echo "23) Create Package"
	echo "24) Delete Package"
	echo "25) List Packages"
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                      Database Functions                             *"
	echo "***********************************************************************"
	echo "26) Create Database"
	echo "27) Delete Database"
	echo "28) List Databases"
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                      Email Functions                                *"
	echo "***********************************************************************"
	echo "29) Create Email"
	echo "30) Delete Email"
	echo "31) Change Email Password"
	echo "32) List Emails"
	echo -e $BLUE
	echo "***********************************************************************"
	echo "*                      FTP Functions                                  *"
	echo "***********************************************************************"
	echo "33) Create FTP Account"
	echo "34) Delete FTP Account"
	echo "35) Change FTP Password"
	echo "36) List FTP Accounts"
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                      SSL Functions                                  *"
	echo "***********************************************************************"
	echo "37) Issue SSL"
	echo "38) Hostname SSL"
	echo "39) Mail Server SSL"
	echo -e "\n\n"
	echo -e $TEXTRESET
}

# Source additional function files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/user-functions.sh"
source "$SCRIPT_DIR/website-functions.sh"

function Main()
{
	clear
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                 Welcome to Cyber Panel Helper Script                *"
	echo "***********************************************************************"
	echo -e $TEXTRESET
	Options
	read -p "Enter your choice: " choice
	if [[ $choice -gt 39 || $choice -lt 1 ]]; then
		echo "[!] Error! Index Out-Of-Range!!!"
		sleep 1
		Main
	fi
	case $choice in
		"1")
			createUser
			createWebsite
			issueSSL
		;;
		'2')
			createUser
		;;
		'3')
			deleteUser
		;;
		'4')
			suspendUser
		;;
		'5')
			unSuspendUser
		;;
		'6')
			editUser
		;;
		'7')
			listUsers
		;;
		'8')
			createWebsite
		;;
		'9')
			deleteWebsite
		;;
		'10')
			createChildDomain
		;;
		'11')
			deleteChildDomain
		;;
		'12')
			listWebsite
		;;
		'13')
			changePHP
		;;
		'14')
			changePackage
		;;
		*)
			echo "Function not implemented yet"
			sleep 2
			Main
		;;
	esac
}

# Check if CyberPanel CLI is available
is_cyberpanel=`which cyberpanel`
if [[ -e $is_cyberpanel ]]; then
	check_root
	check_cyberpanel
	log_message "CyberPanel User CLI started"
	Main
else
	echo "[*] Please install cyberpanel CLI first!"
	exit -1
fi
