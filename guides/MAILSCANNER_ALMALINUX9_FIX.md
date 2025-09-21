# MailScanner AlmaLinux 9 Fix

## ✅ **Issue FIXED in Core**

**The MailScanner installation issue on AlmaLinux 9 has been FIXED in the CyberPanel core** as of version 2.5.5-dev.

### **Root Cause**
The MailScanner installer (`/usr/local/CyberCP/CPScripts/mailscannerinstaller.sh`) has a critical flaw:

1. ✅ **OS Detection Works**: Correctly detects AlmaLinux 9
2. ❌ **Missing Version 9 Support**: Only handles CentOS versions 7 and 8
3. ❌ **Fallthrough Problem**: AlmaLinux 9 falls through without installing required packages

### **Current Status**
- **CyberPanel Version**: 2.5.5-dev
- **Issue Status**: **FIXED** - Resolved in core
- **Affected OS**: AlmaLinux 9.x
- **Impact**: MailScanner installation now works correctly

## 🛠️ **Solution**

### **Core Fix Implemented**

The fix has been implemented directly in the CyberPanel core. No additional patches are needed for new installations.

### **For Existing Installations**

If you have an existing CyberPanel installation that was installed before this fix, you can update the MailScanner installer:

```bash
# Download and run the fix for existing installations
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/mailscanner_almalinux9_fix.sh | bash
```

### **Manual Fix Steps**

If the automated fix doesn't work, follow these manual steps:

#### **Step 1: Install Required Packages**

```bash
# Update system
dnf update -y

# Install EPEL repository
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

# Enable CRB repository
dnf config-manager --set-enabled crb

# Install MailScanner dependencies
dnf install -y perl dnf-utils perl-CPAN
dnf --enablerepo=crb install -y perl-IO-stringy
dnf install -y gcc cpp perl bzip2 zip make patch automake rpm-build \
    perl-Archive-Zip perl-Filesys-Df perl-OLE-Storage_Lite perl-Net-CIDR \
    perl-DBI perl-MIME-tools perl-DBD-SQLite binutils glibc-devel \
    perl-Filesys-Df zlib unzip zlib-devel wget mlocate clamav clamav-update \
    "perl(DBD::mysql)" unrar

# Install Perl modules
export PERL_MM_USE_DEFAULT=1
curl -L https://cpanmin.us | perl - App::cpanminus

perl -MCPAN -e 'install Encoding::FixLatin'
perl -MCPAN -e 'install Digest::SHA1'
perl -MCPAN -e 'install Geo::IP'
perl -MCPAN -e 'install Razor2::Client::Agent'
perl -MCPAN -e 'install Sys::Hostname::Long'
perl -MCPAN -e 'install Sys::SigAction'
perl -MCPAN -e 'install Net::Patricia'

# Update ClamAV
freshclam -v
```

#### **Step 2: Patch MailScanner Installer**

Add AlmaLinux 9 support to the MailScanner installer:

```bash
# Backup original installer
cp /usr/local/CyberCP/CPScripts/mailscannerinstaller.sh /usr/local/CyberCP/CPScripts/mailscannerinstaller.sh.backup

# Add AlmaLinux 9 section after CentOS 8 section
sed -i '/elif \[ "$CLNVERSION" = "ID=\\"cloudlinux\\"" \]; then/i\
elif [[ $Server_OS = "CentOS" ]] && [[ "$Server_OS_Version" = "9" ]] ; then\
\
  setenforce 0\
  dnf install -y perl dnf-utils perl-CPAN\
  dnf --enablerepo=crb install -y perl-IO-stringy\
  dnf install -y gcc cpp perl bzip2 zip make patch automake rpm-build perl-Archive-Zip perl-Filesys-Df perl-OLE-Storage_Lite perl-Net-CIDR perl-DBI perl-MIME-tools perl-DBD-SQLite binutils glibc-devel perl-Filesys-Df zlib unzip zlib-devel wget mlocate clamav clamav-update "perl(DBD::mysql)"\
\
  dnf install -y unrar\
\
  export PERL_MM_USE_DEFAULT=1\
  curl -L https://cpanmin.us | perl - App::cpanminus\
\
  perl -MCPAN -e '\''install Encoding::FixLatin'\''\
  perl -MCPAN -e '\''install Digest::SHA1'\''\
  perl -MCPAN -e '\''install Geo::IP'\''\
  perl -MCPAN -e '\''install Razor2::Client::Agent'\''\
  perl -MCPAN -e '\''install Sys::Hostname::Long'\''\
  perl -MCPAN -e '\''install Sys::SigAction'\''\
  perl -MCPAN -e '\''install Net::Patricia'\''\
\
  freshclam -v\
\
' /usr/local/CyberCP/CPScripts/mailscannerinstaller.sh
```

#### **Step 3: Install MailScanner**

Now try installing MailScanner through the CyberPanel interface, or run manually:

```bash
# Manual installation
cd /tmp
wget https://github.com/MailScanner/v5/releases/download/5.4.4-1/MailScanner-5.4.4-1.rhel.noarch.rpm
rpm -Uvh MailScanner-5.4.4-1.rhel.noarch.rpm

# Create required directories
mkdir -p /var/spool/MailScanner/spamassassin
mkdir -p /var/run/MailScanner
mkdir -p /var/lock/subsys/MailScanner

# Set proper ownership
chown postfix.mtagroup /var/spool/MailScanner/spamassassin
chown root.mtagroup /var/spool/MailScanner/incoming/
chown postfix.mtagroup /var/spool/MailScanner/milterin
chown postfix.mtagroup /var/spool/MailScanner/milterout
chown postfix.mtagroup /var/spool/postfix/hold
chown postfix.mtagroup /var/spool/postfix/incoming
usermod -a -G mtagroup nobody

# Set proper permissions
chmod g+rx /var/spool/postfix/incoming
chmod g+rx /var/spool/postfix/hold
chmod -R 0775 /var/spool/postfix/incoming
chmod -R 0775 /var/spool/postfix/hold

# Configure MailScanner
sed -i 's/^Run As User =.*/& postfix/' /etc/MailScanner/MailScanner.conf

# Start MailScanner service
systemctl enable mailscanner
systemctl start mailscanner
```

## 🔍 **Verification**

After applying the fix, verify the installation:

```bash
# Check if MailScanner is installed
rpm -q MailScanner

# Check if service is running
systemctl status mailscanner

# Check MailScanner configuration
/usr/sbin/MailScanner --version

# Check logs
tail -f /var/log/maillog
```

## 📋 **Supported Operating Systems**

### **Current Status**
| OS | Version | MailScanner Support | Status |
|----|---------|-------------------|--------|
| Ubuntu | 18.04, 20.04, 22.04, 24.04 | ✅ Working | ✅ |
| AlmaLinux | 8 | ✅ Working | ✅ |
| AlmaLinux | 9 | ✅ Working | ✅ **Fixed in core** |
| AlmaLinux | 10 | ✅ Working | ✅ |
| RockyLinux | 8, 9 | ✅ Working | ✅ |
| CentOS | 7, 8 | ✅ Working | ✅ |
| CloudLinux | 7, 8 | ✅ Working | ✅ |

## 🐛 **Known Issues**

1. **Original Issue**: MailScanner installer doesn't handle AlmaLinux 9 ✅ **FIXED**
2. **Workaround**: Use the provided fix script for existing installations
3. **Future Fix**: ✅ **IMPLEMENTED** in the main CyberPanel repository

## 📞 **Support**

If you encounter issues with this fix:

1. Check the log file: `/var/log/cyberpanel_mailscanner_fix.log`
2. Verify AlmaLinux 9 detection: `cat /etc/os-release`
3. Test package installation: `dnf list installed | grep clamav`
4. Check Perl modules: `perl -MEncoding::FixLatin -e "print 'OK\n'"`

## 🔄 **Reverting Changes**

To revert the changes:

```bash
# Restore original installer
cp /usr/local/CyberCP/CPScripts/mailscannerinstaller.sh.backup /usr/local/CyberCP/CPScripts/mailscannerinstaller.sh

# Remove MailScanner
systemctl stop mailscanner
systemctl disable mailscanner
rpm -e MailScanner
```

## 📝 **Changelog**

- **v1.0** (2025-01-27): Initial fix for AlmaLinux 9 MailScanner installation
- Added comprehensive package installation for AlmaLinux 9
- Patched MailScanner installer to handle version 9
- Created automated fix script
- Added manual installation instructions
- **v1.1** (2025-01-27): **CORE FIX IMPLEMENTED**
- ✅ Implemented AlmaLinux 9 support directly in CyberPanel core
- ✅ Updated MailScanner installer (`/usr/local/CyberCP/CPScripts/mailscannerinstaller.sh`)
- ✅ Updated MailScanner uninstaller (`/usr/local/CyberCP/CPScripts/mailscanneruninstaller.sh`)
- ✅ Updated error messages to include AlmaLinux 9
- ✅ Added comprehensive test suite
- ✅ Updated documentation to reflect core fix
