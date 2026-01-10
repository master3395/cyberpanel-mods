# ModSecurity LMDB Dependency Crash Fix

## Overview

This fix resolves the critical ModSecurity crash issue in CyberPanel that causes OpenLiteSpeed to crash with SIGSEGV (signal 11) when ModSecurity is enabled.

**Issue**: [GitHub Issue #1626](https://github.com/usmannasir/cyberpanel/issues/1626)

**Error**: `undefined symbol: mdb_env_create`

**Root Cause**: The `mod_security.so` binary installed via the `ols-modsecurity` package requires the LMDB (Lightning Memory-Mapped Database) library at runtime, but it's not available or properly linked.

## Solution

The fix ensures that a compatible ModSecurity binary (built without LMDB dependency or with LMDB statically linked) is always downloaded and used after installation, preventing the LMDB dependency crash.

## Compatibility

- **CyberPanel Versions**: 2.4.4, 2.5.5-dev
- **Operating Systems**:
  - Ubuntu 24.04, 22.04, 20.04
  - Debian 11, 12
  - AlmaLinux 8, 9, 10
  - RockyLinux 8, 9
  - RHEL 8, 9
  - CloudLinux 8, 9

## Quick Fix

### Automatic Fix (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix-modsecurity-lmdb-crash.sh | sudo bash
```

### Manual Fix

1. **Download and run the fix script**:
   ```bash
   wget https://raw.githubusercontent.com/master3395/cyberpanel-mods/main/security/fix-modsecurity-lmdb-crash.sh
   chmod +x fix-modsecurity-lmdb-crash.sh
   sudo ./fix-modsecurity-lmdb-crash.sh
   ```

2. **Restart OpenLiteSpeed** (if ModSecurity is already installed):
   ```bash
   sudo systemctl restart lsws
   ```

## What the Fix Does

1. **Updates `modSec.py`**: Modifies `/usr/local/CyberCP/plogical/modSec.py` to always download and use the compatible ModSecurity binary after package installation, regardless of whether custom OLS binaries are present.

2. **Downloads Compatible Binary**: Automatically detects the platform and downloads the appropriate compatible ModSecurity binary:
   - Ubuntu: `mod_security-compatible-ubuntu.so`
   - RHEL 8: `mod_security-compatible-rhel8.so`
   - RHEL 9/10: `mod_security-compatible-rhel.so`

3. **Verifies Checksums**: Validates the downloaded binary using SHA256 checksums to ensure integrity.

4. **Creates Backups**: Automatically backs up the original files before modification:
   - `/usr/local/lsws/modules/mod_security.so.backup-YYYYMMDD-HHMMSS`
   - `/usr/local/CyberCP/plogical/modSec.py.backup-YYYYMMDD-HHMMSS`

## Technical Details

### Code Changes

The fix modifies the `installModSec()` method in `plogical/modSec.py` to:

**Before**:
```python
# Check if custom OLS binary is installed - if so, replace with compatible ModSecurity
custom_ols_marker = "/usr/local/lsws/modules/cyberpanel_ols.so"
if os.path.exists(custom_ols_marker):
    # Download compatible binary
```

**After**:
```python
# Always download and install compatible ModSecurity binary to prevent LMDB dependency crashes
# This fixes the "undefined symbol: mdb_env_create" error that causes OpenLiteSpeed to crash
platform = modSec.detectPlatform()
if modSec.downloadCompatibleModSec(platform):
    # Success logging
else:
    # Warning logging with fallback
```

### Compatible Binaries

The compatible ModSecurity binaries are hosted at `https://cyberpanel.net/`:

| Platform | URL | SHA256 |
|----------|-----|--------|
| Ubuntu | `mod_security-compatible-ubuntu.so` | `ed02c813136720bd4b9de5925f6e41bdc8392e494d7740d035479aaca6d1e0cd` |
| RHEL 8 | `mod_security-compatible-rhel8.so` | `bbbf003bdc7979b98f09b640dffe2cbbe5f855427f41319e4c121403c05837b2` |
| RHEL 9/10 | `mod_security-compatible-rhel.so` | `19deb2ffbaf1334cf4ce4d46d53f747a75b29e835bf5a01f91ebcc0c78e98629` |

## Verification

After applying the fix, verify it's working:

1. **Check OpenLiteSpeed logs**:
   ```bash
   tail -f /usr/local/lsws/logs/error.log
   ```
   
   You should **NOT** see:
   - `undefined symbol: mdb_env_create`
   - `[AutoRestarter] child process received signal=11`
   - SIGSEGV crashes

2. **Check ModSecurity status**:
   ```bash
   ls -la /usr/local/lsws/modules/mod_security.so
   ```

3. **Test ModSecurity functionality**:
   - Enable ModSecurity in CyberPanel UI
   - Restart OpenLiteSpeed: `sudo systemctl restart lsws`
   - Check logs for successful startup
   - Test a website to verify ModSecurity is working

## Troubleshooting

### Fix Script Fails

If the fix script fails:

1. **Check logs**: Review the script output for specific errors
2. **Verify internet connection**: The script downloads binaries from `cyberpanel.net`
3. **Check file permissions**: Ensure you're running as root
4. **Manual application**: Follow the manual fix steps above

### ModSecurity Still Crashes

If ModSecurity still crashes after applying the fix:

1. **Verify the fix was applied**:
   ```bash
   grep -A 5 "Always download and install compatible ModSecurity binary" /usr/local/CyberCP/plogical/modSec.py
   ```

2. **Check if compatible binary is installed**:
   ```bash
   file /usr/local/lsws/modules/mod_security.so
   ```

3. **Reinstall ModSecurity**:
   - Disable ModSecurity in CyberPanel UI
   - Restart OpenLiteSpeed
   - Enable ModSecurity again (it will use the compatible binary automatically)

### Restore Original Files

If you need to restore the original files:

```bash
# Restore original modSec.py (replace YYYYMMDD-HHMMSS with actual timestamp)
sudo cp /usr/local/CyberCP/plogical/modSec.py.backup-YYYYMMDD-HHMMSS /usr/local/CyberCP/plogical/modSec.py

# Restore original ModSecurity binary (replace YYYYMMDD-HHMMSS with actual timestamp)
sudo cp /usr/local/lsws/modules/mod_security.so.backup-YYYYMMDD-HHMMSS /usr/local/lsws/modules/mod_security.so

# Restart OpenLiteSpeed
sudo systemctl restart lsws
```

## Prevention

To prevent this issue in future installations:

1. **Apply the fix before installing ModSecurity** (recommended)
2. **Update CyberPanel** to version 2.5.5-dev or later (includes the fix)
3. **Use the compatible binary** from the start during ModSecurity installation

## Related Issues

- [GitHub Issue #1626](https://github.com/usmannasir/cyberpanel/issues/1626) - Original issue report
- [CyberPanel-Mods Repository](https://github.com/master3395/cyberpanel-mods) - Complete fix and documentation

## Support

For issues or questions:
- **GitHub Issues**: [cyberpanel-mods/issues](https://github.com/master3395/cyberpanel-mods/issues)
- **CyberPanel Forums**: [community.cyberpanel.net](https://community.cyberpanel.net)

## Changelog

- **2026-01-10**: Initial fix release for CyberPanel 2.4.4 and 2.5.5-dev
- **2026-01-10**: Added automatic fix script with platform detection
- **2026-01-10**: Added comprehensive documentation and troubleshooting guide
