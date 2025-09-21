#!/bin/bash

# User Management Functions for CyberPanel
# Part of CyberPanel Mods - Enhanced Repository

## User Functions

function createUser()
{
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                   User Functions - Create User                      *"
	echo "***********************************************************************"
	echo -e $TEXTRESET
	read -p "Enter firstname (No Special Chars): " firstName
	echo $firstName | grep -P  $special_chars >> /dev/null || is_special="true"
	if [[ $is_special != "true" ]]; then
  		echo "[!] There is a special characters!"
  		echo "[*] Reverting...."
  		sleep 2 
  		clear
  		createUser
	fi

	unset is_special

	read -p "Enter lastname (No Special Chars): " lastName
	echo $lastName | grep -P  $special_chars >> /dev/null || is_special="true"
	if [[ $is_special != "true" ]]; then
  		echo "[!] There is a special characters!"
  		echo "[*] Reverting...."
  		sleep 2 
  		clear
  		createUser
	fi
	unset is_special

	read -p "Enter Email Address: " email
	echo $email | egrep $email_pattern >> /dev/null && is_email="true"
	if [[ $is_email != "true" ]]; then
  		echo "[!] Not a valid email address!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		createUser
	fi

	unset is_email

	read -p "Enter Username (No Special Chars Except Email Pattern): " userName
	echo $userName | grep -P $username_special_chars >> /dev/null || is_special="true"
	if [[ $is_special != "true" ]]; then
  		echo "[!] Not a valid username!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		createUser
	fi

	unset is_special

	read -s -p "Enter Secure Password: " SecurePassword
    echo -e '\n'
	read -s -p "Confirm Secure Password: " ConfirmSecurePassword
	echo -e "\n"
	if [[ $SecurePassword != $ConfirmSecurePassword ]]; then
  		echo "[!] Secure Password Did Not Match!!!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		createUser
	fi

	read -p "Websites Limit 0 - Unlimited (Not Recommended): " weblimit
	echo -e $weblimit | grep --invert-match "[0-9]" >> /dev/null || num_only="true"
	if [[ $num_only != "true" ]]; then
  		echo "[!] Web Limit Should not contain non-numeric characters!!!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		createUser
	fi

	unset num_only

	read -p "ACL Method (admin, reseller, user, Customer - Recommended) : " acl
	echo -e $acl | grep -w $acl_pattern >> /dev/null && right_acl="true"
	if [[ $right_acl != "true" ]]; then
  		echo "[!] Wrong ACL Choice!!!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		createUser
	fi

	unset right_acl

	read -p "Security Level (HIGH or LOW) : " sec_level
	echo -e $sec_level | grep -w $security_level >> /dev/null && sec_level_true="true"
	if [[ $sec_level_true != "true" ]]; then
  		echo "[!] Wrong Security Level Choice!!!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		createUser
	fi

	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                      	Details You Entered                         *"
	echo "***********************************************************************"
	echo "FirstName: $firstName"
	echo "LastName: $lastName"
	echo "Email: $email"
	echo "Username: $userName"
	echo "Password: $SecurePassword"
	echo "Web Limit: $weblimit"
	echo "ACL: $acl"
	echo "Security Level: $sec_level"
	read -p "Are you sure about this? [Y/N]: " choice
	choice=`echo $choice | tr [:lower:] [:upper:]`
	if [ $choice = "Y" ] ; then
		cyberpanel createUser --firstName $firstName --lastName $lastName --email $email --userName $userName --password $SecurePassword --websitesLimit $weblimit --selectedACL $acl --securityLevel $sec_level
		log_message "Created user: $userName with email: $email"
		unset firstName lastName email userName SecurePassword weblimit acl sec_level
		exit 0
	else
		echo -e "[*] Reverting..."
		unset firstName lastName email userName SecurePassword weblimit acl sec_level
		sleep 2
		clear
		createUser
	fi
}

function deleteUser()
{
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                   User Functions - Delete User                      *"
	echo "***********************************************************************"
	echo -e $TEXTRESET

	read -p "Enter Username (No Special Chars Except Email Pattern): " userName
	echo $userName | grep -P $username_special_chars >> /dev/null || is_special="true"
	if [[ $is_special != "true" ]]; then
  		echo "[!] Not a valid username!"
  		echo "[*] Reverting...."
  		sleep 2
  		clear
  		deleteUser
	fi

	unset is_special

	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                      	Details You Entered                         *"
	echo "***********************************************************************"
	echo "Username: $userName"
	read -p "Are you sure about this? [Y/N]: " choice
	choice=`echo $choice | tr [:lower:] [:upper:]`
	if [ $choice = "Y" ] ; then
		cyberpanel deleteUser --userName $userName || exit -1
		log_message "Deleted user: $userName"
		unset userName
		exit 0
	else
		echo -e "[*] Reverting..."
		sleep 2
		clear
		deleteUser
	fi
}

function listUsers()
{
	echo -e $YELLOW
	echo "***********************************************************************"
	echo "*                   User Functions - List Users                       *"
	echo "***********************************************************************"
	echo -e $TEXTRESET
	cyberpanel listUsers | sed -e 's/,/\n/g' | sed -e 's/\\//g' | sed -e 's/\"//g' | sed -e 's/{//g' | sed -e 's/}/\n/g'
}
