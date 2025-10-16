#!/bin/bash

# تعريف ألوان ANSI
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
RESET='\e[0m'

# عنوان البرنامج
echo -e "${MAGENTA}==============================================${RESET}"
echo -e "${CYAN}  🔧 Default PHP Version Changer for CyberPanel${RESET}"
echo -e "${CYAN}  🛠️  For phpMyAdmin / Snappymail Management ${RESET}"
echo -e "${MAGENTA}==============================================${RESET}\n"

# إدخال المستخدم مع لون مميز
read -r -p $'\e[38;5;208mChoose PHP version [74-80-81-82-83-84-85-86]: \e[0m' Input_Number
echo ""

# وظيفة التثبيت مع مؤشر تقدم
install_php_version() {
  echo -e "${BLUE}🔄 Installing PHP $1 packages...${RESET}"
  if ! (yum -y install lsphp$1* 2> /dev/null || apt-get install -y lsphp$1* 2> /dev/null); then
    echo -e "${RED}❌ Failed to install PHP $1! Check repo configuration.${RESET}"
    exit 1
  fi
  echo -e "${GREEN}✅ PHP $1 packages installed successfully${RESET}"
}

# وظيفة الربط مع تأثيرات
link_php_version() {
  echo -e "${BLUE}🔗 Updating symbolic links...${RESET}"
  rm -f /usr/local/lscp/fcgi-bin/lsphp
  ln -s /usr/local/lsws/lsphp$1/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
  echo -e "${BLUE}🔄 Restarting LSCPD service...${RESET}"
  systemctl restart lscpd || service lscpd restart
  echo -e "${GREEN}🎉 Default PHP version changed to: PHP $Input_Number${RESET}"
}

# التحقق من الإصدار
change_php_version() {
  if [ -f /usr/local/lsws/lsphp$1/bin/lsphp ]; then
    echo -e "${YELLOW}🔍 Found existing PHP $2 installation${RESET}"
    link_php_version $1
  else
    echo -e "${YELLOW}⚠️ PHP $2 not found. Installing...${RESET}"
    install_php_version $1 && link_php_version $1
  fi
}

# معالجة الخيارات
case "$Input_Number" in
  74) change_php_version 74 "7.4" ;;
  80) change_php_version 80 "8.0" ;;
  81) change_php_version 81 "8.1" ;;
  82) change_php_version 82 "8.2" ;;
  83) change_php_version 83 "8.3" ;;
  84) change_php_version 84 "8.4" ;;
  85) change_php_version 85 "8.5" ;;
  86) change_php_version 86 "8.6" ;;
  *)
    echo -e "${RED}❌ Invalid input! Please choose from:${RESET}"
    echo -e "${CYAN}[74-80-81-82-83-84-85-86]${RESET}"
    exit 1
  ;;
esac

echo -e "${GREEN}✨ Operation completed successfully ✨${RESET}"