# Configuration Guide

This guide explains how to configure and customize the PowerShell Profile Manager.

## Table of Contents

- [Profile Manager Configuration](#profile-manager-configuration)
- [Module Configuration](#module-configuration)
- [Environment Variables](#environment-variables)
- [Custom Settings](#custom-settings)
- [Advanced Configuration](#advanced-configuration)

## Profile Manager Configuration

### Main Configuration

The Profile Manager configuration is defined in `Microsoft.PowerShell_profile.ps1`:

```powershell
$ProfileManagerConfig = @{
    ModulesDirectory = Join-Path $PSScriptRoot "modules"
    LogLevel = "Info"  # Debug, Info, Warning, Error
    AutoLoadModules = $true
    EnableModuleLogging = $true
}
```

### Configuration Options

#### ModulesDirectory
- **Default**: `Join-Path $PSScriptRoot "modules"`
- **Description**: Path to the modules directory
- **Example**: `"C:\MyModules"`

#### LogLevel
- **Default**: `"Info"`
- **Options**: `Debug`, `Info`, `Warning`, `Error`
- **Description**: Controls logging verbosity

#### AutoLoadModules
- **Default**: `$true`
- **Description**: Automatically load enabled modules on startup

#### EnableModuleLogging
- **Default**: `$true`
- **Description**: Enable logging for module operations

### Module Configuration

Modules are configured in the `$ProfileModules` array:

```powershell
$ProfileModules = @(
    @{
        Name = "VideoCompressor"
        Enabled = $true
        Description = "Video compression with cloud storage optimization"
    },
    @{
        Name = "ExampleModule"
        Enabled = $false
        Description = "Example module template"
    }
)
```

### Module Configuration Options

#### Name
- **Required**: `$true`
- **Description**: Module name (must match directory name)

#### Enabled
- **Default**: `$true`
- **Description**: Whether to load the module automatically

#### Description
- **Default**: `""`
- **Description**: Human-readable description of the module

## Environment Variables

### Profile Manager Environment Variables

You can set these environment variables to customize behavior:

```powershell
# Custom installation path
$env:PROFILE_MANAGER_PATH = "C:\MyPowerShellModules"

# Custom log level
$env:PROFILE_MANAGER_LOG_LEVEL = "Debug"

# Disable auto-loading
$env:PROFILE_MANAGER_AUTO_LOAD = "false"
```

### Module-Specific Environment Variables

Some modules support environment variables for configuration:

```powershell
# VideoCompressor settings
$env:VIDEO_COMPRESSOR_OUTPUT_DIR = "C:\CompressedVideos"
$env:VIDEO_COMPRESSOR_DEFAULT_MODE = "Quality"

# ExampleModule settings
$env:EXAMPLE_MODULE_LOG_LEVEL = "Debug"
$env:EXAMPLE_MODULE_FEATURE1 = "true"
```

## Custom Settings

### Custom Module Configuration

You can add custom configuration to modules:

```powershell
# In your module's .psm1 file
$YourModuleConfig = @{
    CustomSetting1 = "Value1"
    CustomSetting2 = "Value2"
    AdvancedSettings = @{
        Timeout = 30
        RetryCount = 3
    }
}
```

### Custom Profile Configuration

Add custom settings to the main profile:

```powershell
# Add to Microsoft.PowerShell_profile.ps1
$CustomProfileSettings = @{
    WelcomeMessage = "Welcome to my PowerShell environment!"
    AutoUpdate = $true
    CustomAliases = @{
        "ll" = "Get-ChildItem -Force"
        "la" = "Get-ChildItem -Force -Hidden"
    }
}
```

## Advanced Configuration

### Custom Module Loading

Override the default module loading behavior:

```powershell
# Custom module loading function
function Load-CustomModule {
    param([string]$ModuleName)
    
    # Custom loading logic
    $modulePath = Join-Path $CustomModulesPath $ModuleName
    if (Test-Path $modulePath) {
        Import-Module $modulePath -Force
        Write-Host "Custom module loaded: $ModuleName" -ForegroundColor Green
    }
}
```

### Conditional Module Loading

Load modules based on conditions:

```powershell
# Load modules based on environment
if ($env:COMPUTERNAME -like "*DEV*") {
    Load-ProfileModule "DevelopmentModule"
}

if ($IsWindows) {
    Load-ProfileModule "WindowsModule"
}

if ($IsLinux) {
    Load-ProfileModule "LinuxModule"
}
```

### Dynamic Configuration

Load configuration from external sources:

```powershell
# Load configuration from JSON file
$configPath = "$env:APPDATA\PowerShell\ProfileManager\config.json"
if (Test-Path $configPath) {
    $externalConfig = Get-Content $configPath | ConvertFrom-Json
    $ProfileManagerConfig = $ProfileManagerConfig + $externalConfig
}

# Load configuration from environment
$envConfig = @{
    LogLevel = $env:PROFILE_MANAGER_LOG_LEVEL
    AutoLoadModules = $env:PROFILE_MANAGER_AUTO_LOAD -eq "true"
}
$ProfileManagerConfig = $ProfileManagerConfig + $envConfig
```

## Configuration Management

### Configuration Functions

Use built-in configuration management functions:

```powershell
# Get current configuration
Get-ProfileManagerStatus

# Update configuration
$ProfileManagerConfig.LogLevel = "Debug"

# Save configuration
Save-ProfileManagerConfig
```

### Module Configuration

Configure individual modules:

```powershell
# Configure VideoCompressor
Set-ExampleConfig -LogLevel "Debug" -EnableFeature1 $true

# Get module configuration
Get-ExampleInfo
```

### Configuration Validation

Validate configuration settings:

```powershell
# Validate ProfileManager configuration
function Test-ProfileManagerConfig {
    $errors = @()
    
    if (-not (Test-Path $ProfileManagerConfig.ModulesDirectory)) {
        $errors += "Modules directory not found"
    }
    
    if ($ProfileManagerConfig.LogLevel -notin @("Debug", "Info", "Warning", "Error")) {
        $errors += "Invalid log level"
    }
    
    return $errors
}
```

## Configuration Files

### Profile Configuration File

Create a dedicated configuration file:

```powershell
# config.ps1
$ProfileManagerConfig = @{
    ModulesDirectory = "C:\PowerShell\Modules"
    LogLevel = "Info"
    AutoLoadModules = $true
    EnableModuleLogging = $true
    CustomSettings = @{
        WelcomeMessage = "Welcome!"
        AutoUpdate = $true
    }
}

# Load in main profile
. "$PSScriptRoot\config.ps1"
```

### JSON Configuration

Use JSON for configuration:

```json
{
    "ProfileManager": {
        "ModulesDirectory": "C:\\PowerShell\\Modules",
        "LogLevel": "Info",
        "AutoLoadModules": true,
        "EnableModuleLogging": true
    },
    "Modules": {
        "VideoCompressor": {
            "Enabled": true,
            "DefaultMode": "Balanced"
        },
        "ExampleModule": {
            "Enabled": false,
            "LogLevel": "Debug"
        }
    }
}
```

Load JSON configuration:

```powershell
# Load JSON configuration
$configPath = "$PSScriptRoot\config.json"
if (Test-Path $configPath) {
    $jsonConfig = Get-Content $configPath | ConvertFrom-Json
    
    # Apply ProfileManager configuration
    $ProfileManagerConfig = $ProfileManagerConfig + $jsonConfig.ProfileManager
    
    # Apply module configuration
    foreach ($module in $jsonConfig.Modules.PSObject.Properties) {
        $moduleName = $module.Name
        $moduleConfig = $module.Value
        
        # Find and update module configuration
        $profileModule = $ProfileModules | Where-Object { $_.Name -eq $moduleName }
        if ($profileModule) {
            $profileModule.Enabled = $moduleConfig.Enabled
        }
    }
}
```

## Best Practices

### Configuration Organization

1. **Separate concerns**: Keep different types of configuration separate
2. **Use meaningful names**: Choose descriptive configuration names
3. **Document settings**: Comment configuration options
4. **Validate inputs**: Validate configuration values

### Configuration Security

1. **Avoid secrets**: Don't store passwords or API keys in configuration
2. **Use environment variables**: Store sensitive data in environment variables
3. **Restrict access**: Limit access to configuration files
4. **Encrypt sensitive data**: Encrypt sensitive configuration data

### Configuration Maintenance

1. **Version control**: Track configuration changes
2. **Backup configuration**: Regular backups of configuration
3. **Test changes**: Test configuration changes before deploying
4. **Document changes**: Document configuration modifications

## Examples

### Development Configuration

```powershell
# Development environment configuration
$ProfileManagerConfig = @{
    ModulesDirectory = "C:\Dev\PowerShell\Modules"
    LogLevel = "Debug"
    AutoLoadModules = $true
    EnableModuleLogging = $true
}

$ProfileModules = @(
    @{
        Name = "VideoCompressor"
        Enabled = $true
        Description = "Video compression module"
    },
    @{
        Name = "DevelopmentModule"
        Enabled = $true
        Description = "Development utilities"
    }
)
```

### Production Configuration

```powershell
# Production environment configuration
$ProfileManagerConfig = @{
    ModulesDirectory = "C:\PowerShell\Modules"
    LogLevel = "Warning"
    AutoLoadModules = $true
    EnableModuleLogging = $false
}

$ProfileModules = @(
    @{
        Name = "VideoCompressor"
        Enabled = $true
        Description = "Video compression module"
    }
)
```

### Minimal Configuration

```powershell
# Minimal configuration
$ProfileManagerConfig = @{
    ModulesDirectory = Join-Path $PSScriptRoot "modules"
    LogLevel = "Error"
    AutoLoadModules = $false
    EnableModuleLogging = $false
}

$ProfileModules = @()
```

This configuration guide provides comprehensive information about customizing the PowerShell Profile Manager to meet your specific needs.
