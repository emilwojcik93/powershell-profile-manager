# Troubleshooting Guide

This guide helps you resolve common issues with the PowerShell Profile Manager.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Module Loading Issues](#module-loading-issues)
- [Profile Configuration Issues](#profile-configuration-issues)
- [Performance Issues](#performance-issues)
- [Error Messages](#error-messages)
- [Diagnostic Commands](#diagnostic-commands)

## Installation Issues

### Execution Policy Error

**Problem**: `Execution of scripts is disabled on this system`

**Solution**:
```powershell
# Check current execution policy
Get-ExecutionPolicy

# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for single execution
PowerShell -ExecutionPolicy Bypass -File install.ps1
```

### Internet Connection Issues

**Problem**: Installation fails due to network connectivity

**Solution**:
1. Check internet connection
2. Verify firewall settings
3. Try manual installation:
   ```powershell
   # Download files manually
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/yourusername/powershell-profile-manager/main/install.ps1" -OutFile "install.ps1"
   ```

### Permission Denied

**Problem**: Access denied when creating directories or files

**Solution**:
```powershell
# Run PowerShell as Administrator
Start-Process PowerShell -Verb RunAs

# Or install to user directory
.\install.ps1 -InstallPath "$env:USERPROFILE\PowerShell\ProfileManager"
```

## Module Loading Issues

### Module Not Found

**Problem**: `Module not found in modules directory`

**Diagnosis**:
```powershell
# Check module status
Get-ProfileModuleStatus VideoCompressor

# Check if module files exist
Test-Path "modules\VideoCompressor\VideoCompressor.psm1"
```

**Solution**:
1. Verify module is in the correct directory
2. Check module file permissions
3. Reinstall the module:
   ```powershell
   # Reload specific module
   Reload-ProfileModule VideoCompressor
   ```

### Module Syntax Errors

**Problem**: `Syntax validation failed`

**Diagnosis**:
```powershell
# Test module syntax
$modulePath = "modules\VideoCompressor\VideoCompressor.psm1"
[System.Management.Automation.PSParser]::Tokenize((Get-Content $modulePath -Raw), [ref]$null)
```

**Solution**:
1. Check for syntax errors in the module file
2. Validate PowerShell syntax
3. Test module in isolation

### Module Dependencies Missing

**Problem**: Module fails to load due to missing dependencies

**Solution**:
1. Check module requirements
2. Install missing dependencies
3. Update module configuration

## Profile Configuration Issues

### Profile Not Loading

**Problem**: PowerShell profile doesn't load on startup

**Diagnosis**:
```powershell
# Check profile path
$PROFILE

# Test profile loading
Test-Path $PROFILE
. $PROFILE

# Check for errors
$Error
```

**Solution**:
1. Verify profile file exists
2. Check profile syntax
3. Test profile loading manually
4. Check execution policy

### Profile Conflicts

**Problem**: Multiple profile configurations conflict

**Solution**:
```powershell
# Check current profile content
Get-Content $PROFILE

# Clean profile configuration
Remove-ProfileManager -Force

# Reinstall cleanly
.\install.ps1 -Force
```

### Profile Corruption

**Problem**: Profile file is corrupted or malformed

**Solution**:
```powershell
# Restore default profile
Restore-DefaultProfile -Backup

# Or remove and recreate
Remove-Item $PROFILE -Force
.\install.ps1
```

## Performance Issues

### Slow Startup

**Problem**: PowerShell takes too long to start

**Diagnosis**:
```powershell
# Check loaded modules
Get-Module

# Check profile loading time
Measure-Command { . $PROFILE }
```

**Solution**:
1. Disable unnecessary modules
2. Optimize module loading
3. Use lazy loading for heavy modules

### Memory Usage

**Problem**: High memory consumption

**Solution**:
```powershell
# Check memory usage
Get-Process PowerShell | Select-Object ProcessName, WorkingSet

# Unload unused modules
Unload-AllProfileModules
```

## Error Messages

### Common Error Messages

#### "FFmpeg is not recognized as an internal or external command"

**Cause**: FFmpeg is not installed or not in PATH

**Solution**:
```powershell
# Let VideoCompressor install FFmpeg
Compress-Video "test.mp4"

# Or install manually
winget install Gyan.FFmpeg
```

#### "Module loading failed"

**Cause**: Module file is corrupted or has syntax errors

**Solution**:
```powershell
# Check module status
Get-ProfileModuleStatus ModuleName

# Reload module
Reload-ProfileModule ModuleName
```

#### "Access denied"

**Cause**: Insufficient permissions

**Solution**:
```powershell
# Run as Administrator
Start-Process PowerShell -Verb RunAs

# Or change installation location
.\install.ps1 -InstallPath "$env:USERPROFILE\PowerShell\ProfileManager"
```

## Diagnostic Commands

### System Information

```powershell
# Get system information
Get-ProfileManagerStatus

# Check PowerShell version
$PSVersionTable

# Check execution policy
Get-ExecutionPolicy -List
```

### Module Diagnostics

```powershell
# List all modules
Get-ProfileModules

# Check specific module
Get-ProfileModuleStatus VideoCompressor

# Test module functionality
Test-ExampleFunction -TestType All
```

### Profile Diagnostics

```powershell
# Check profile path
$PROFILE

# Check profile content
Get-Content $PROFILE

# Test profile loading
. $PROFILE
```

### Network Diagnostics

```powershell
# Test internet connectivity
Test-NetConnection -ComputerName "www.google.com" -Port 80

# Test GitHub connectivity
Test-NetConnection -ComputerName "raw.githubusercontent.com" -Port 443
```

## Advanced Troubleshooting

### Debug Mode

Enable debug logging for detailed information:

```powershell
# Set debug log level
$ProfileManagerConfig.LogLevel = "Debug"

# Reload profile
. $PROFILE
```

### Manual Module Loading

Load modules manually for testing:

```powershell
# Load specific module
Load-ProfileModule VideoCompressor

# Test module functions
Get-Command -Module VideoCompressor
```

### Clean Installation

Perform a completely clean installation:

```powershell
# Remove everything
Remove-ProfileManager -Force

# Clean profile
Restore-DefaultProfile -Force

# Fresh install
.\install.ps1 -Force
```

## Getting Help

### Self-Help Resources

1. **Check this troubleshooting guide**
2. **Review module documentation**
3. **Use diagnostic commands**
4. **Check GitHub issues**

### Community Support

- **GitHub Issues**: Create an issue with diagnostic information
- **GitHub Discussions**: Ask questions and share solutions
- **Documentation**: Review comprehensive guides

### Reporting Issues

When reporting issues, include:

1. **System information**:
   ```powershell
   Get-ProfileManagerStatus
   ```

2. **Error messages**: Copy the complete error message

3. **Steps to reproduce**: Detailed steps that cause the issue

4. **Expected behavior**: What should happen

5. **Actual behavior**: What actually happens

### Diagnostic Information

Include this information when reporting issues:

```powershell
# System information
$PSVersionTable
Get-ProfileManagerStatus

# Module status
Get-ProfileModules

# Error history
$Error | Select-Object -Last 10

# Profile content
Get-Content $PROFILE
```

## Prevention

### Best Practices

1. **Regular backups**: Backup your profile regularly
2. **Test changes**: Test module changes before deploying
3. **Version control**: Use version control for custom modules
4. **Documentation**: Document custom configurations

### Maintenance

```powershell
# Regular maintenance tasks
Get-ProfileManagerStatus
Get-ProfileModules
Test-ExampleFunction -TestType All
```

This troubleshooting guide should help you resolve most issues with the PowerShell Profile Manager. If you encounter issues not covered here, please create a GitHub issue with detailed diagnostic information.
