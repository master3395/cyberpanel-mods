# CyberPanel AlmaLinux 10 Complete Fix Guide

## 🚨 **Problem Summary**

The original error you encountered was caused by several compatibility issues between CyberPanel and AlmaLinux 10:

1. **Repository Conflicts**: Installer was trying to use CentOS 9 repositories on AlmaLinux 10
2. **Missing EPEL 10 Support**: The `setup_epel_repo()` function didn't handle version 10
3. **Wrong MariaDB Repository**: Using RHEL 9 instead of RHEL 10 repository
4. **Missing Boost Libraries**: `libboost_program_options.so.1.75.0` required for galera-4
5. **Wrong Remi Release**: Installing remi-release-9 instead of remi-release-10
6. **GPG Key Import Issues**: LiteSpeed GPG key import failures

## ✅ **Complete Fix Applied**

I've fixed all these issues in the main CyberPanel installation script (`cyberpanel/cyberpanel.sh`):

### **1. Fixed EPEL Repository Setup**
```bash
# Added support for version 10 in setup_epel_repo() function
"10")
    # AlmaLinux 10 EPEL support
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
    Check_Return "yum repo" "no_exit"
    ;;
```

### **2. Fixed MariaDB Repository**
```bash
# Updated MariaDB repository to use RHEL 10
elif [[ "$Server_OS_Version" = "10" ]] && uname -m | grep -q 'x86_64'; then
    cat <<EOF >/etc/yum.repos.d/MariaDB.repo
# MariaDB 10.11 RHEL10 repository list - AlmaLinux 10 compatible
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.11/rhel10-amd64/
module_hotfixes=1
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
enabled=1
gpgcheck=1
EOF
```

### **3. Fixed Remi Release Installation**
```bash
# Added version-specific remi-release installation
if [[ "$Server_OS_Version" = "9" ]]; then
  yum install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm
elif [[ "$Server_OS_Version" = "10" ]]; then
  yum install -y https://rpms.remirepo.net/enterprise/remi-release-10.rpm
fi
```

### **4. Added Boost Libraries Support**
```bash
# Enhanced package installation for AlmaLinux 9/10
dnf install -y libnsl zip wget strace net-tools curl which bc telnet htop libevent-devel gcc libattr-devel xz-devel MariaDB-server MariaDB-client MariaDB-devel curl-devel git platform-python-devel tar socat python3 zip unzip bind-utils gpgme-devel openssl-devel boost-devel boost-program-options

# Fix boost library compatibility for galera-4 on AlmaLinux 10
if [[ "$Server_OS_Version" = "10" ]]; then
  if [ ! -f /usr/lib64/libboost_program_options.so.1.75.0 ]; then
    BOOST_VERSION=$(find /usr/lib64 -name "libboost_program_options.so.*" | head -1 | sed 's/.*libboost_program_options\.so\.//')
    if [ -n "$BOOST_VERSION" ]; then
      ln -sf /usr/lib64/libboost_program_options.so.$BOOST_VERSION /usr/lib64/libboost_program_options.so.1.75.0
      log_info "Created boost library symlink for galera-4 compatibility"
    fi
  fi
fi
```

### **5. Fixed GPG Key Import**
```bash
# Added fallback for GPG key import
rpm --import https://cyberpanel.sh/rpms.litespeedtech.com/centos/RPM-GPG-KEY-litespeed || {
  log_warning "Primary GPG key import failed, trying alternative source"
  rpm --import https://rpms.litespeedtech.com/centos/RPM-GPG-KEY-litespeed || {
    log_error "Failed to import LiteSpeed GPG key from all sources"
    return 1
  }
}
```

## 🚀 **How to Use the Fix**

### **Option 1: Use the Fixed CyberPanel Script (Recommended)**

The main CyberPanel installation script has been updated with all fixes. Simply run:

```bash
sh <(curl https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh || wget -O - https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh)
```

### **Option 2: Manual Fix Before Installation**

If you want to fix your system before running the installer:

```bash
# 1. Fix repositories
dnf update -y
dnf remove -y epel-release remi-release 2>/dev/null || true
rm -f /etc/yum.repos.d/epel.repo /etc/yum.repos.d/remi.repo /etc/yum.repos.d/MariaDB.repo

# 2. Install correct repositories
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-10.rpm
dnf config-manager --set-enabled epel crb

# 3. Create MariaDB repository
cat <<EOF >/etc/yum.repos.d/MariaDB.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.11/rhel10-amd64/
module_hotfixes=1
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
enabled=1
gpgcheck=1
EOF

# 4. Import GPG keys
rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
rpm --import https://cyberpanel.sh/rpms.litespeedtech.com/centos/RPM-GPG-KEY-litespeed

# 5. Install boost libraries
dnf install -y boost-devel boost-program-options

# 6. Create boost symlink for galera-4
BOOST_VERSION=$(find /usr/lib64 -name "libboost_program_options.so.*" | head -1 | sed 's/.*libboost_program_options\.so\.//')
ln -sf /usr/lib64/libboost_program_options.so.$BOOST_VERSION /usr/lib64/libboost_program_options.so.1.75.0

# 7. Clean and refresh
dnf clean all
dnf makecache

# 8. Now run CyberPanel installer
sh <(curl https://raw.githubusercontent.com/usmannasir/cyberpanel/refs/heads/v2.5.5-dev/install.sh)
```

## 🔍 **What Was Fixed**

| Issue | Root Cause | Fix Applied |
|-------|------------|-------------|
| **Repository Conflicts** | Installer used CentOS 9 repos on AlmaLinux 10 | Added version 10 support to all repository functions |
| **EPEL Missing** | `setup_epel_repo()` didn't handle version 10 | Added case for "10" with correct EPEL 10 URL |
| **MariaDB Wrong Repo** | Used RHEL 9 instead of RHEL 10 | Updated baseurl to `rhel10-amd64/` |
| **Remi Release Wrong** | Hardcoded to version 9 | Added conditional logic for version 9 vs 10 |
| **Boost Libraries Missing** | Not included in package installation | Added `boost-devel boost-program-options` |
| **GPG Key Failures** | No fallback for key import | Added fallback to alternative source |
| **Galera Dependencies** | Missing `libboost_program_options.so.1.75.0` | Created symlink from available version |

## ✅ **Verification**

After installation, verify everything is working:

```bash
# Check services
systemctl status lscpd
systemctl status mariadb

# Check CyberPanel access
curl -k https://localhost:8090

# Check boost library
ls -la /usr/lib64/libboost_program_options.so.1.75.0
```

## 🎯 **Expected Results**

With these fixes, your AlmaLinux 10 installation should:

1. ✅ **Detect AlmaLinux 10 correctly** (not CentOS 10)
2. ✅ **Install EPEL 10** instead of trying EPEL 9
3. ✅ **Use RHEL 10 MariaDB repository** instead of RHEL 9
4. ✅ **Install remi-release-10** instead of remi-release-9
5. ✅ **Include boost libraries** for galera-4 compatibility
6. ✅ **Successfully import GPG keys** with fallback support
7. ✅ **Complete MariaDB installation** without dependency errors

## 📝 **Technical Details**

The fixes ensure that:
- **Repository URLs** are correct for AlmaLinux 10
- **Package dependencies** are properly resolved
- **GPG key validation** works with fallback options
- **Boost library compatibility** is maintained for galera-4
- **All version checks** properly handle AlmaLinux 10

This should resolve all the errors you encountered in your original installation attempt.
