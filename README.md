<div align="center">

<img src="https://community.cyberpanel.net/uploads/default/original/1X/416fdec0e96357d11f7b2756166c61b1aeca5939.png" alt="CyberPanel Logo" width="500"/>

# 🚀 CyberPanel Mods - Enhanced Repository

[![OS Support](https://img.shields.io/badge/OS-Ubuntu%2020.04--24.04%20%7C%20AlmaLinux%208--10%20%7C%20RockyLinux%208--9%20%7C%20RHEL%208--9%20%7C%20CentOS%207--9%20%7C%20CloudLinux%207--8-blue)](https://cyberpanel.net)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/master3395/cyberpanel-mods)

> **The most comprehensive collection of CyberPanel modifications, fixes, and utilities with full cross-platform compatibility**

📚 **[Complete Documentation](guides/)** | 🚀 **[Installation Guide](guides/installation-guide.md)** | 🔧 **[Troubleshooting](guides/troubleshooting-guide.md)** | 🛡️ **[Security Guide](guides/security-best-practices.md)**

## 🌟 Features

- 👥 **User & Website Management** - Complete user-facing operations for hosting management
- 🎯 **Master Menu Interface** - Interactive menu system for easy access to all mods
- ✅ **Full OS Compatibility** - Works on all CyberPanel-supported operating systems
- 🔧 **Enhanced Scripts** - Improved error handling, logging, and user experience
- 📚 **Comprehensive Documentation** - Detailed guides and examples
- 🛡️ **Security Focused** - All scripts follow security best practices
- 🔄 **Auto-Update Support** - Scripts can check and update themselves
- 📊 **Detailed Logging** - All operations are logged for troubleshooting
- 🖥️ **System Monitoring** - Built-in system status and information display
- 🎨 **Dual Interface** - Serves both end users and system administrators

## 🚀 Quick Start

### 🎯 Master Menu (Recommended)

The easiest way to use all CyberPanel mods is through our interactive master menu:

```bash
sh <(curl https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh || wget -O - https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh)
```

**Alternative (simpler):**
```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/cyberpanel-mods-menu.sh | bash
```

The master menu provides interactive access to all mods and utilities with a beautiful, user-friendly interface.

📖 **[See Full Installation Guide](guides/installation-guide.md)** for detailed setup instructions and all available commands.

### Quick Access Commands

```bash
# Check system compatibility
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/utilities/os_compatibility_checker.sh | bash

# Run core fixes
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/core-fixes/cyberpanel_core_fixes_enhanced.sh | bash

# Apply security hardening
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/cyberpanel_security_enhanced.sh | bash
```

📖 **For all commands and detailed usage, see the [Installation Guide](guides/installation-guide.md)**

## 📖 Documentation

### 📚 Comprehensive Guides

#### Getting Started

- 🚀 **[Installation Guide](guides/installation-guide.md)** - Complete setup instructions
- 🎯 **[Menu Demo](guides/menu-demo.md)** - Interactive menu walkthrough
- 🔍 **[OS-Specific Notes](guides/os-specific-notes.md)** - Platform-specific information

#### Problem Solving

- 🔧 **[Troubleshooting Guide](guides/troubleshooting-guide.md)** - Common issues and solutions
- 🛡️ **[Security Best Practices](guides/security-best-practices.md)** - Complete security guide
- 📊 **[OS Compatibility Analysis](guides/OS_COMPATIBILITY_ANALYSIS.md)** - System compatibility details

#### Advanced Topics

- 🐧 **[AlmaLinux 10 Installation](guides/ALMALINUX10_INSTALLATION_GUIDE.md)** - Latest release guide
- 🔧 **[Core Fix Summary](guides/CORE_FIX_SUMMARY.md)** - Technical fix documentation
- 📧 **[MailScanner Fix](guides/MAILSCANNER_ALMALINUX9_FIX.md)** - Email system fixes

📚 **[View All Documentation](guides/)** for complete guides and technical details.

## 📋 Requirements

- ✅ Root access to your server
- ✅ Internet connection for downloads
- ✅ CyberPanel installed and running
- ✅ Supported operating system ([see full list](guides/os-specific-notes.md))

## ⚠️ Important Notes

- **Always backup your data** before running any scripts
- **Test in a non-production environment** first
- **Read the documentation** before using any script
- **Check OS compatibility** with our compatibility checker

## 🤝 Contributing

We welcome contributions! To contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple OS versions
5. Submit a pull request

📖 **[Contributing Guide](CONTRIBUTING.md)** for detailed guidelines.

### 🐛 Reporting Issues

Found a bug? [Open an issue](https://github.com/master3395/cyberpanel-mods/issues) with:

- Operating system details
- Error messages
- Steps to reproduce
- Expected vs actual behavior

## 📞 Support

- 📚 **Documentation**: [guides/](guides/)
- 🐛 **Issues**: [GitHub Issues](https://github.com/master3395/cyberpanel-mods/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/master3395/cyberpanel-mods/discussions)
- 🌐 **CyberPanel Community**: [Official Forums](https://forums.cyberpanel.net)

## 🔒 Security

All scripts follow security best practices:

- No hardcoded passwords or secrets
- Secure file permissions
- Input validation and sanitization
- Comprehensive error handling
- Detailed logging for audit trails

📖 **[Security Best Practices](guides/security-best-practices.md)** for complete security guide.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **[CyberPanel Team](https://cyberpanel.net)** - For the amazing control panel
- **[Contributors](https://github.com/master3395/cyberpanel-mods/graphs/contributors)** - Who help improve this project
- **Community Members** - Who report issues and suggest improvements
- **Alfred Valderrama** - For cyberpanel-friendly-cli (user management base)

## 📚 Quick Guide Reference

### Essential Guides

| Guide                  | Description                                  | Link                                                                |
| ---------------------- | -------------------------------------------- | ------------------------------------------------------------------- |
| 🚀 Installation Guide  | Complete setup and installation instructions | [guides/installation-guide.md](guides/installation-guide.md)           |
| 🔧 Troubleshooting     | Common issues and solutions                  | [guides/troubleshooting-guide.md](guides/troubleshooting-guide.md)     |
| 🛡️ Security Guide    | Comprehensive security best practices        | [guides/security-best-practices.md](guides/security-best-practices.md) |
| 🖥️ OS-Specific Notes | Platform-specific information                | [guides/os-specific-notes.md](guides/os-specific-notes.md)             |
| 🎯 Menu Demo           | Interactive menu walkthrough                 | [guides/menu-demo.md](guides/menu-demo.md)                             |

### Technical Guides

| Guide                  | Description                         | Link                                                                              |
| ---------------------- | ----------------------------------- | --------------------------------------------------------------------------------- |
| 🐧 AlmaLinux 10        | Latest release installation guide   | [guides/ALMALINUX10_INSTALLATION_GUIDE.md](guides/ALMALINUX10_INSTALLATION_GUIDE.md) |
| 🔧 AlmaLinux 10 Fix    | Complete fix guide for AlmaLinux 10 | [guides/ALMALINUX10_COMPLETE_FIX_GUIDE.md](guides/ALMALINUX10_COMPLETE_FIX_GUIDE.md) |
| 📧 MailScanner Fix     | Email system fixes for AlmaLinux 9  | [guides/MAILSCANNER_ALMALINUX9_FIX.md](guides/MAILSCANNER_ALMALINUX9_FIX.md)         |
| 🔧 Core Fix Summary    | Technical fix documentation         | [guides/CORE_FIX_SUMMARY.md](guides/CORE_FIX_SUMMARY.md)                             |
| 📊 OS Compatibility    | System compatibility analysis       | [guides/OS_COMPATIBILITY_ANALYSIS.md](guides/OS_COMPATIBILITY_ANALYSIS.md)           |
| 🔧 Comprehensive Fixes | All OS fixes documentation          | [guides/COMPREHENSIVE_OS_FIXES.md](guides/COMPREHENSIVE_OS_FIXES.md)                 |
| 🎯 API Access Feature  | API access tab documentation        | [guides/API_ACCESS_TAB_FEATURE.md](guides/API_ACCESS_TAB_FEATURE.md)                 |

📚 **[Browse All Guides](guides/)** in the guides folder for complete documentation.

---

**Made with ❤️ for the CyberPanel Community**

</div>
