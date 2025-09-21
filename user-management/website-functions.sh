#!/bin/bash

# Website Management Functions for CyberPanel
# Part of CyberPanel Mods - Enhanced Repository

## Website Functions

function createWebsite()
{
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                   Website Functions - Create Website                *"
	echo "***********************************************************************"
	echo -e $TEXTRESET
	read -p "Enter Package (Default | admin_Standard | admin_Professional | admin_Enterprise): " Package
	echo $Package | grep -w  $package_pattern >> /dev/null && is_package="true"
	if [[ $is_package != "true" ]]; then
  		echo "[!] Package Choice Cannot be found!"
  		echo "[*] Reverting...."
  		sleep 2 
  		clear
  		createWebsite
	fi
	unset is_package

	read -p "Enter Username of the Web Owner (No Special Chars Except Email Pattern): " userName
	echo $userName | grep -P $username_special_chars >> /dev/null || is_special="true"
	if [[ $is_special != "true" ]]; then
  		echo "[!] Not a valid username!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		createWebsite
	fi
	unset is_special

	read -p "Enter the website domain to be use: " Domain
	echo $Domain | egrep -e $domain_pattern >> /dev/null && is_domain="true"
	if [[ $is_domain != "true" ]]; then
  		echo "[!] Not a valid domain name!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		createWebsite
	fi
	unset is_domain

	read -p "Enter Email Address: " email
	echo $email | egrep $email_pattern >> /dev/null && is_email="true"
	if [[ $is_email != "true" ]]; then
  		echo "[!] Not a valid email address!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		createWebsite
	fi
	unset is_email

	echo -e "Available PHP Versions: 5.3 | 5.4 | 5.5 | 5.6 | 7.0 | 7.1 | 7.2 | 7.3 | 7.4 | 8.0 | 8.1 | 8.2 | 8.3"
	read -p "Enter PHP Version: " php_version
	echo $php_version | grep -w $php_version_pattern >> /dev/null && is_php="true"
	if [[ $is_php != "true" ]]; then
  		echo "[!] Not a valid PHP Version!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		createWebsite
	fi
	unset is_php

	read -p "Do you want to enable SSL (YES/NO)?: " Ssl
	Ssl=`echo $Ssl | tr [:lower:] [:upper:]`
	if [[ $Ssl = "YES" ]]; then
  		ssl_support=1
  	else
  		ssl_support=0
	fi

	read -p "Do you want to enable DKIM (YES/NO)?: " Dkim
	Dkim=`echo $Dkim | tr [:lower:] [:upper:]`
	if [[ $Dkim = "YES" ]]; then
  		dkim_support=1
  	else
  		dkim_support=0
	fi

	read -p "Do you want to enable openBasedir Protection (YES/NO)?: " Openbase
	Openbase=`echo $Openbase | tr [:lower:] [:upper:]`
	if [[ $Openbase = "YES" ]]; then
  		openbase_support=1
  	else
  		openbase_support=0
	fi

	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                      	Details You Entered                         *"
	echo "***********************************************************************"
	echo "Package: $Package"
	echo "Username (Owner): $userName"
	echo "Domain: $Domain"
	echo "Email: $email"
	echo "PHP Version: $php_version"
	echo "SSL Support: $Ssl"
	echo "DKIM Support: $Dkim"
	echo "Open Base Directory Protection Enable: $Openbase"
	read -p "Are you sure about this? [Y/N]: " choice
	choice=`echo $choice | tr [:lower:] [:upper:]`
	if [ $choice = "Y" ] ; then
		cyberpanel createWebsite --package $Package --owner $userName --domainName $Domain --email $email --php $php_version --ssl $ssl_support --dkim $dkim_support --openBasedir $openbase_support
		log_message "Created website: $Domain for user: $userName"
		unset Package userName Domain email php_version Ssl Dkim Openbase choice
		exit 0
	else
		echo -e "[*] Reverting..."
		unset Package userName Domain email php_version Ssl Dkim Openbase choice
		sleep 2
		clear
		createWebsite
	fi
}

function deleteWebsite()
{
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                   Website Functions - Delete Website                *"
	echo "***********************************************************************"
	echo -e $TEXTRESET
	echo "[*] Do not enter a child domain"
	read -p "Enter the website domain to be deleted: " Domain
	echo $Domain | egrep -e $domain_pattern >> /dev/null && is_domain="true"
	if [[ $is_domain != "true" ]]; then
  		echo "[!] Not a valid domain name!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		deleteWebsite
	fi
	unset is_domain

	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                      	Details You Entered                         *"
	echo "***********************************************************************"
	echo "Domain: $Domain"
	read -p "Are you sure about this? [Y/N]: " choice
	choice=`echo $choice | tr [:lower:] [:upper:]`
	if [ $choice = "Y" ] ; then
		cyberpanel deleteWebsite --domainName $Domain
		log_message "Deleted website: $Domain"
		unset Domain choice
		echo "Done..."
		exit 0
	else
		echo -e "[*] Reverting..."
		unset Domain choice
		deleteWebsite
	fi
}

function listWebsite()
{
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                   Website Functions - List Website                  *"
	echo "***********************************************************************"
	echo -e $TEXTRESET
	cyberpanel listWebsitesPretty
}

function changePHP()
{
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                Website Functions - Change PHP Version               *"
	echo "***********************************************************************"
	echo -e $TEXTRESET
	echo "[*] Do not enter a child domain"
	read -p "Enter the website master domain to be use: " Domain
	echo $Domain | egrep -e $domain_pattern >> /dev/null && is_domain="true"
	if [[ $is_domain != "true" ]]; then
  		echo "[!] Not a valid domain name!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		changePHP
	fi
	unset is_domain

	echo -e "Available PHP Versions: 5.3 | 5.4 | 5.5 | 5.6 | 7.0 | 7.1 | 7.2 | 7.3 | 7.4 | 8.0 | 8.1 | 8.2 | 8.3"
	read -p "Enter PHP Version: " php_version
	echo $php_version | grep -w $php_version_pattern >> /dev/null && is_php="true"
	if [[ $is_php != "true" ]]; then
  		echo "[!] Not a valid PHP Version!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		changePHP
	fi
	unset is_php
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                      	Details You Entered                         *"
	echo "***********************************************************************"
	echo "Domain: $Domain"
	echo "PHP Version: $php_version"
	read -p "Are you sure about this? [Y/N]: " choice
	choice=`echo $choice | tr [:lower:] [:upper:]`
	if [ $choice = "Y" ] ; then
		cyberpanel changePHP --domainName $Domain --php $php_version
		log_message "Changed PHP version for $Domain to $php_version"
		unset Domain php_version choice
		echo "Done..."
		exit 0
	else
		echo -e "[*] Reverting..."
		unset Domain php_version choice
		changePHP
	fi
}
