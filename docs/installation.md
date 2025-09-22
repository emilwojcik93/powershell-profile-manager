# Installation Guide

This guide covers various installation methods for the PowerShell Profile Manager.

## Table of Contents

- [Quick Installation](#quick-installation)
- [Manual Installation](#manual-installation)
- [Development Installation](#development-installation)
- [Uninstallation](#uninstallation)
- [Troubleshooting](#troubleshooting)

## Quick Installation

### One-Line Installation

```powershell
iwr -useb https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/install.ps1 | iex
```

This command will:
1. Download the installation script
2. Create the necessary directories
3. Download all modules
4. Configure your PowerShell profile
5. Load the profile manager

### Installation with Custom Options

```powershell
# Install to custom directory
iwr -useb https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/install.ps1 | iex -InstallPath "C:\MyPowerShellModules"

# Install with specific modules
iwr -useb https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/install.ps1 | iex -Modules @("VideoCompressor")
```

## Manual Installation

### Step 1: Create Directory Structure

```powershell
# Create the main directory
$installPath = "$env:USERPROFILE\PowerShell\ProfileManager"
New-Item -ItemType Directory -Path $installPath -Force

# Create subdirectories
New-Item -ItemType Directory -Path "$installPath\modules" -Force
New-Item -ItemType Directory -Path "$installPath\docs" -Force
```

### Step 2: Download Files

```powershell
# Download main profile script
$profileUrl = "https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/Microsoft.PowerShell_profile.ps1"
Invoke-WebRequest -Uri $profileUrl -OutFile "$installPath\Microsoft.PowerShell_profile.ps1"

# Download scripts
$scriptsDir = "$installPath\scripts"
New-Item -ItemType Directory -Path $scriptsDir -Force

$scriptFiles = @("install.ps1", "uninstall.ps1", "release.ps1")
foreach ($scriptFile in $scriptFiles) {
    $scriptUrl = "https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/$scriptFile"
    Invoke-WebRequest -Uri $scriptUrl -OutFile "$scriptsDir\$scriptFile"
}

# Download modules
$modules = @("VideoCompressor", "PowerShellMCP", "ExampleModule")
foreach ($module in $modules) {
    $modulePath = "$installPath\modules\$module"
    New-Item -ItemType Directory -Path $modulePath -Force
    
    # Download module files
    $psm1Url = "https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/modules/$module/$module.psm1"
    $psd1Url = "https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/modules/$module/$module.psd1"
    $readmeUrl = "https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/modules/$module/README.md"
    
    Invoke-WebRequest -Uri $psm1Url -OutFile "$modulePath\$module.psm1"
    Invoke-WebRequest -Uri $psd1Url -OutFile "$modulePath\$module.psd1"
    Invoke-WebRequest -Uri $readmeUrl -OutFile "$modulePath\README.md"
}
```

### Step 3: Configure Profile

```powershell
# Get profile path
$profilePath = $PROFILE

# Create profile directory if it doesn't exist
$profileDir = Split-Path $profilePath -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force
}

# Add profile manager to profile
$profileContent = @"
# PowerShell Profile Manager
. '$installPath\Microsoft.PowerShell_profile.ps1'
"@

Add-Content -Path $profilePath -Value $profileContent
```

### Step 4: Load Profile

```powershell
# Reload profile
. $PROFILE

# Verify installation
Get-ProfileModules
```

## Development Installation

### Clone Repository

```powershell
# Clone the repository
git clone https://github.com/yourusername/powershell-profile-manager.git
cd powershell-profile-manager

# Create symbolic link to profile
$profilePath = $PROFILE
$profileDir = Split-Path $profilePath -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force
}

# Create symbolic link (requires admin privileges)
New-Item -ItemType SymbolicLink -Path $profilePath -Target "$PWD\Microsoft.PowerShell_profile.ps1" -Force
```

### Development Setup

```powershell
# Load the profile
. $PROFILE

# Test installation
Get-ProfileModules
Test-ExampleFunction -TestType All
```

## Uninstallation

### Complete Removal

```powershell
# Run uninstall script
iwr -useb https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/uninstall.ps1 | iex
```

### Manual Uninstallation

```powershell
# Remove from profile
$profileContent = Get-Content $PROFILE
$newContent = $profileContent | Where-Object { $_ -notlike "*ProfileManager*" }
$newContent | Set-Content $PROFILE

# Remove installation directory
$installPath = "$env:USERPROFILE\PowerShell\ProfileManager"
if (Test-Path $installPath) {
    Remove-Item -Path $installPath -Recurse -Force
}

# Unload modules
Get-Module | Where-Object { $_.Name -in @("VideoCompressor", "ExampleModule") } | Remove-Module -Force
```

## Installation Options

### Custom Installation Path

```powershell
# Install to custom location
$customPath = "C:\MyPowerShellModules"
iwr -useb https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/install.ps1 | iex -InstallPath $customPath
```

### Selective Module Installation

```powershell
# Install only specific modules
$modules = @("VideoCompressor")
iwr -useb https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/install.ps1 | iex -Modules $modules
```

### Silent Installation

```powershell
# Install without prompts
iwr -useb https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/install.ps1 | iex -Silent
```

## Profile Configuration

### Multiple Profile Support

The profile manager supports different PowerShell profiles:

- **PowerShell 5.1**: `Microsoft.PowerShell_profile.ps1`
- **PowerShell 7+**: `Microsoft.PowerShell_profile.ps1`
- **Windows PowerShell**: `Microsoft.PowerShell_profile.ps1`

### Profile Locations

Default profile locations:
- `$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
- `$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

### Custom Profile Integration

To integrate with existing profiles:

```powershell
# Add to existing profile
Add-Content -Path $PROFILE -Value @"

# PowerShell Profile Manager
. '$env:USERPROFILE\PowerShell\ProfileManager\Microsoft.PowerShell_profile.ps1'
"@
```

## Troubleshooting

### Common Issues

#### Execution Policy Error

```powershell
# Check execution policy
Get-ExecutionPolicy

# Set execution policy (requires admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Profile Not Loading

```powershell
# Check profile path
$PROFILE

# Test profile loading
Test-Path $PROFILE
. $PROFILE

# Check for errors
$Error
```

#### Module Loading Issues

```powershell
# Check module status
Get-ProfileModuleStatus VideoCompressor

# Reload specific module
Reload-ProfileModule VideoCompressor

# Check module path
Test-Path "modules\VideoCompressor\VideoCompressor.psm1"
```

#### Permission Issues

```powershell
# Run as administrator if needed
Start-Process PowerShell -Verb RunAs

# Check file permissions
Get-Acl $PROFILE
```

### Diagnostic Commands

```powershell
# Check installation status
Get-ProfileModules

# Test all modules
Test-ExampleFunction -TestType All

# Check profile configuration
Get-Content $PROFILE

# Verify module paths
Get-ChildItem "modules" -Recurse
```

### Getting Help

If you encounter issues:

1. Check the [troubleshooting guide](troubleshooting.md)
2. Review module-specific documentation
3. Create an issue on GitHub
4. Check existing issues and discussions

## Advanced Configuration

### Environment Variables

```powershell
# Set custom installation path
$env:PROFILE_MANAGER_PATH = "C:\MyModules"

# Set log level
$env:PROFILE_MANAGER_LOG_LEVEL = "Debug"
```

### Module Configuration

```powershell
# Configure specific modules
Set-ExampleConfig -LogLevel "Debug" -EnableFeature1 $true

# Check module configuration
Get-ExampleInfo
```

### Custom Module Loading

```powershell
# Load modules manually
Load-ProfileModule VideoCompressor

# Unload modules
Unload-ProfileModule ExampleModule

# Reload modules
Reload-ProfileModule VideoCompressor
```
