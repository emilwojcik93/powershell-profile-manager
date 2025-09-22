# Migration Guide

This guide helps you migrate from the original VideoCompressor gist to the new PowerShell Profile Manager repository.

## What Changed

### From Gist to Repository Structure

**Before (Gist)**:
```
VideoCompressor.ps1          # Single script file
QUICK_START.md              # Basic documentation
```

**After (Repository)**:
```
├── Microsoft.PowerShell_profile.ps1  # Main profile loader
├── install.ps1                       # Installation script
├── uninstall.ps1                     # Uninstallation script
├── release.ps1                       # Release preparation script
├── modules/                          # Module directory
│   ├── VideoCompressor/              # VideoCompressor module
│   │   ├── VideoCompressor.psm1      # Module implementation
│   │   ├── VideoCompressor.psd1      # Module manifest
│   │   └── README.md                 # Module documentation
│   └── ExampleModule/                # Example module template
│       ├── ExampleModule.psm1
│       ├── ExampleModule.psd1
│       └── README.md
├── docs/                             # Documentation
│   ├── installation.md
│   ├── module-development.md
│   ├── troubleshooting.md
│   ├── configuration.md
│   └── examples/
└── .github/workflows/                # CI/CD workflows
    ├── release.yml
    └── test.yml
```

## Migration Steps

### Option 1: Clean Installation (Recommended)

1. **Remove old installation**:
   ```powershell
   # If you have the old gist installed, remove it first
   # Check your PowerShell profile for old references
   Get-Content $PROFILE
   ```

2. **Install new Profile Manager**:
   ```powershell
   # Install the new Profile Manager
   iwr -useb https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/install.ps1 | iex
   ```

3. **Verify installation**:
   ```powershell
   # Check that everything is working
   Get-ProfileModules
   Compress-Video "test.mp4"  # Test VideoCompressor
   ```

### Option 2: Manual Migration

1. **Backup current setup**:
   ```powershell
   # Backup your current profile
   Copy-Item $PROFILE "$PROFILE.backup.$(Get-Date -Format 'yyyyMMdd')"
   ```

2. **Download new structure**:
   ```powershell
   # Clone or download the repository
   git clone https://github.com/yourusername/powershell-profile-manager.git
   cd powershell-profile-manager
   ```

3. **Install manually**:
   ```powershell
   # Run the installation script
   .\install.ps1
   ```

## Key Differences

### Function Access

**Before**:
```powershell
# Functions were available directly
Compress-Video "video.mp4"
```

**After**:
```powershell
# Functions are available through module system
Compress-Video "video.mp4"  # Still works the same way
Get-ProfileModules          # New: Check loaded modules
```

### Configuration

**Before**:
- No configuration management
- Hardcoded settings

**After**:
```powershell
# Rich configuration management
Get-ProfileManagerStatus    # Check system status
Get-ProfileModules          # List available modules
Load-ProfileModule VideoCompressor  # Load specific modules
Unload-ProfileModule VideoCompressor  # Unload modules
```

### Installation

**Before**:
```powershell
# Manual installation
iwr 'https://gist.githubusercontent.com/...' -OutFile 'VideoCompressor.ps1'
Add-Content $PROFILE '. .\VideoCompressor.ps1'
```

**After**:
```powershell
# Automated installation
iwr -useb https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/install.ps1 | iex
```

### Uninstallation

**Before**:
- Manual removal required
- No cleanup tools

**After**:
```powershell
# Automated uninstallation
Remove-ProfileManager -Force
# Or use the uninstall script
iwr -useb https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/uninstall.ps1 | iex
```

## New Features

### Module Management
```powershell
# List all modules
Get-ProfileModules

# Check module status
Get-ProfileModuleStatus VideoCompressor

# Load/unload modules dynamically
Load-ProfileModule VideoCompressor
Unload-ProfileModule VideoCompressor
```

### System Status
```powershell
# Get comprehensive status
Get-ProfileManagerStatus

# Check what's loaded
Get-Module | Where-Object { $_.Name -like "*Video*" }
```

### Cleanup and Maintenance
```powershell
# Complete removal
Remove-ProfileManager

# Restore default profile
Restore-DefaultProfile

# Unload all modules
Unload-AllProfileModules
```

### Testing and Validation
```powershell
# Test module functionality
Test-ExampleFunction -TestType All

# Check system health
Get-ProfileManagerStatus
```

## Backward Compatibility

### VideoCompressor Functions

All VideoCompressor functions work exactly the same:

```powershell
# These all work the same as before
Compress-Video "video.mp4"
Compress-Video "video.mp4" -CompressionMode "Fast"
Compress-Video "video.mp4" -OutputDirectory "C:\Compressed"
```

### Profile Integration

The new system integrates seamlessly with your existing PowerShell profile:

```powershell
# Your profile now loads the Profile Manager
# Which then loads the configured modules
# VideoCompressor is loaded automatically (if enabled)
```

## Troubleshooting Migration

### Common Issues

#### "Module not found" errors
```powershell
# Check if modules are available
Get-ProfileModules

# Reload modules
Reload-ProfileModule VideoCompressor
```

#### Profile conflicts
```powershell
# Check profile content
Get-Content $PROFILE

# Clean installation
Remove-ProfileManager -Force
iwr -useb https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/install.ps1 | iex
```

#### Function not available
```powershell
# Check if module is loaded
Get-Module VideoCompressor

# Load module manually
Load-ProfileModule VideoCompressor
```

### Getting Help

1. **Check status**:
   ```powershell
   Get-ProfileManagerStatus
   ```

2. **Review documentation**:
   - `docs/installation.md`
   - `docs/troubleshooting.md`
   - `docs/configuration.md`

3. **Test functionality**:
   ```powershell
   Test-ExampleFunction -TestType All
   ```

## Benefits of Migration

### Improved Organization
- Modular structure
- Better separation of concerns
- Easier maintenance

### Enhanced Functionality
- Module management
- Configuration options
- Testing framework
- Error handling

### Better Documentation
- Comprehensive guides
- Examples and tutorials
- Troubleshooting help

### Development Support
- CI/CD workflows
- Automated testing
- Release management
- Contribution guidelines

## Support

If you encounter issues during migration:

1. **Check the troubleshooting guide**: `docs/troubleshooting.md`
2. **Review installation guide**: `docs/installation.md`
3. **Create a GitHub issue** with diagnostic information
4. **Use diagnostic commands**:
   ```powershell
   Get-ProfileManagerStatus
   Get-ProfileModules
   $Error | Select-Object -Last 10
   ```

The new PowerShell Profile Manager provides a much more robust and maintainable foundation for your PowerShell customizations while maintaining full backward compatibility with your existing VideoCompressor usage.
