# PowerShell Profile Manager Uninstallation Script
# This script removes the PowerShell Profile Manager and restores the default profile

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$InstallPath = "$env:USERPROFILE\PowerShell\ProfileManager",
    
    [Parameter(Mandatory = $false)]
    [switch]$Silent,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$KeepModules,
    
    [Parameter(Mandatory = $false)]
    [switch]$NonInteractive,
    
    [Parameter(Mandatory = $false)]
    [switch]$Unattended
)

# Set automation mode if any automation parameter is used
if ($NonInteractive -or $Unattended) {
    $Silent = $true
}

# Set error action preference
$ErrorActionPreference = if ($Silent -or $NonInteractive -or $Unattended) { "SilentlyContinue" } else { "Stop" }

function Write-UninstallLog {
    param(
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info"
    )
    
    if (-not $Silent) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $logMessage = "[$timestamp] $Message"
        
        switch ($Level) {
            "Info" { Write-Host $logMessage -ForegroundColor White }
            "Success" { Write-Host $logMessage -ForegroundColor Green }
            "Warning" { Write-Host $logMessage -ForegroundColor Yellow }
            "Error" { Write-Host $logMessage -ForegroundColor Red }
        }
    }
}

function Get-ProfilePath {
    # Determine the correct profile path based on PowerShell version
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        # PowerShell 7+
        return "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    } else {
        # Windows PowerShell 5.1
        return "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    }
}

function Test-ProfileManagerInstalled {
    $profilePath = Get-ProfilePath
    
    if (-not (Test-Path $profilePath)) {
        return $false
    }
    
    $profileContent = Get-Content $profilePath -Raw
    return $profileContent -like "*ProfileManager*"
}

function Unload-ProfileModules {
    Write-UninstallLog "Unloading profile modules..." "Info"
    
    try {
        # Get list of modules that might be loaded
        $profileModules = @("VideoCompressor", "ExampleModule")
        $loadedModules = Get-Module | Where-Object { $_.Name -in $profileModules }
        
        foreach ($module in $loadedModules) {
            try {
                Remove-Module -Name $module.Name -Force -ErrorAction SilentlyContinue
                Write-UninstallLog "  Unloaded module: $($module.Name)" "Success"
            }
            catch {
                Write-UninstallLog "  Failed to unload module $($module.Name): $($_.Exception.Message)" "Warning"
            }
        }
        
        return $true
    }
    catch {
        Write-UninstallLog "Failed to unload modules: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Remove-ProfileConfiguration {
    Write-UninstallLog "Removing profile configuration..." "Info"
    
    try {
        $profilePath = Get-ProfilePath
        
        if (-not (Test-Path $profilePath)) {
            Write-UninstallLog "Profile file not found: $profilePath" "Warning"
            return $true
        }
        
        $profileContent = Get-Content $profilePath -Raw
        
        if ($profileContent -notlike "*ProfileManager*") {
            Write-UninstallLog "ProfileManager configuration not found in profile" "Warning"
            return $true
        }
        
        # Remove ProfileManager configuration lines
        $lines = $profileContent -split "`n"
        $newLines = @()
        $skipNext = $false
        
        foreach ($line in $lines) {
            if ($line -like "*# PowerShell Profile Manager*") {
                $skipNext = $true
                continue
            }
            elseif ($skipNext -and $line -like "*ProfileManager*") {
                $skipNext = $false
                continue
            }
            elseif ($line -like "*ProfileManager*") {
                continue
            }
            else {
                $newLines += $line
            }
        }
        
        $newContent = $newLines -join "`n"
        
        # Remove trailing empty lines
        $newContent = $newContent.TrimEnd()
        
        if ($newContent -eq "") {
            # If profile is empty, remove it
            Remove-Item -Path $profilePath -Force
            Write-UninstallLog "Removed empty profile file" "Success"
        } else {
            # Save updated profile
            Set-Content -Path $profilePath -Value $newContent -Encoding UTF8
            Write-UninstallLog "Updated profile file" "Success"
        }
        
        return $true
    }
    catch {
        Write-UninstallLog "Failed to remove profile configuration: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Remove-InstallationFiles {
    Write-UninstallLog "Removing installation files..." "Info"
    
    try {
        if (-not (Test-Path $InstallPath)) {
            Write-UninstallLog "Installation directory not found: $InstallPath" "Warning"
            return $true
        }
        
        if ($KeepModules) {
            Write-UninstallLog "Keeping modules as requested" "Info"
            return $true
        }
        
        # Get confirmation if not silent and not forced
        if (-not $Silent -and -not $Force) {
            $confirm = Read-Host "Remove all installation files from $InstallPath? (y/n)"
            if ($confirm -ne 'y' -and $confirm -ne 'Y') {
                Write-UninstallLog "Installation files removal cancelled" "Warning"
                return $true
            }
        }
        
        Remove-Item -Path $InstallPath -Recurse -Force
        Write-UninstallLog "Removed installation directory: $InstallPath" "Success"
        
        return $true
    }
    catch {
        Write-UninstallLog "Failed to remove installation files: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Test-Uninstallation {
    Write-UninstallLog "Testing uninstallation..." "Info"
    
    try {
        # Test profile configuration removal
        $profilePath = Get-ProfilePath
        if (Test-Path $profilePath) {
            $profileContent = Get-Content $profilePath -Raw
            if ($profileContent -like "*ProfileManager*") {
                Write-UninstallLog "ProfileManager configuration still found in profile" "Error"
                return $false
            }
        }
        
        # Test module unloading
        $profileModules = @("VideoCompressor", "ExampleModule")
        $loadedModules = Get-Module | Where-Object { $_.Name -in $profileModules }
        
        if ($loadedModules.Count -gt 0) {
            Write-UninstallLog "Some profile modules are still loaded" "Warning"
        }
        
        # Test installation directory removal
        if (-not $KeepModules -and (Test-Path $InstallPath)) {
            Write-UninstallLog "Installation directory still exists" "Warning"
        }
        
        Write-UninstallLog "Uninstallation test completed" "Success"
        return $true
    }
    catch {
        Write-UninstallLog "Uninstallation test failed: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Show-UninstallationSummary {
    Write-UninstallLog 'Uninstallation Summary:' 'Info'
    Write-UninstallLog "  Installation Path: $InstallPath" 'Info'
    Write-UninstallLog "  Profile Path: $(Get-ProfilePath)" 'Info'
    Write-UninstallLog "  Keep Modules: $KeepModules" 'Info'
    Write-UninstallLog "  Force Mode: $Force" 'Info'
    
    Write-UninstallLog "`nWhat was removed:" 'Info'
    Write-UninstallLog '  [OK] ProfileManager configuration from PowerShell profile' 'Success'
    Write-UninstallLog '  [OK] Loaded profile modules' 'Success'
    
    if (-not $KeepModules) {
        Write-UninstallLog '  [OK] Installation files and directories' 'Success'
    } else {
        Write-UninstallLog '  [SKIP] Installation files (kept as requested)' 'Warning'
    }
    
    Write-UninstallLog "`nNext Steps:" 'Info'
    Write-UninstallLog '  1. Restart PowerShell to ensure clean state' 'Info'
    Write-UninstallLog '  2. Your PowerShell profile is now restored to default' 'Info'
    
    if ($KeepModules) {
        Write-UninstallLog "  3. Modules are still available at: $InstallPath" 'Info'
    }
    
    if (-not $Silent) {
        $restart = Read-Host "`nRestart PowerShell now? (y/n)"
        if ($restart -eq 'y' -or $restart -eq 'Y') {
            Write-UninstallLog 'Restarting PowerShell...' 'Info'
            Start-Process PowerShell
        }
    }
}

function Show-Confirmation {
    if ($Silent) {
        return $true
    }
    
    Write-UninstallLog "PowerShell Profile Manager Uninstaller" "Info"
    Write-UninstallLog "======================================" "Info"
    Write-UninstallLog ""
    Write-UninstallLog "This will remove the PowerShell Profile Manager and restore your default profile." "Warning"
    Write-UninstallLog ""
    Write-UninstallLog "What will be removed:" "Info"
    Write-UninstallLog "  - ProfileManager configuration from PowerShell profile" "Info"
    Write-UninstallLog "  - All loaded profile modules" "Info"
    
    if (-not $KeepModules) {
        Write-UninstallLog "  - All installation files and directories" "Info"
    } else {
        Write-UninstallLog "  - Installation files will be kept" "Info"
    }
    
    Write-UninstallLog ""
    Write-UninstallLog "Installation Path: $InstallPath" "Info"
    Write-UninstallLog "Profile Path: $(Get-ProfilePath)" "Info"
    Write-UninstallLog ""
    
    if ($Silent -or $Force) {
        return $true
    } else {
        $confirm = Read-Host "Are you sure you want to continue? (y/n)"
        return ($confirm -eq 'y' -or $confirm -eq 'Y')
    }
}

# Main uninstallation process
try {
    # Check if ProfileManager is installed
    if (-not (Test-ProfileManagerInstalled)) {
        Write-UninstallLog "PowerShell Profile Manager is not installed or not configured." "Warning"
        Write-UninstallLog "Nothing to uninstall." "Info"
        exit 0
    }
    
    # Show confirmation
    if (-not (Show-Confirmation)) {
        Write-UninstallLog "Uninstallation cancelled by user." "Info"
        exit 0
    }
    
    # Unload modules
    if (-not (Unload-ProfileModules)) {
        Write-UninstallLog "Failed to unload modules" "Error"
        exit 1
    }
    
    # Remove profile configuration
    if (-not (Remove-ProfileConfiguration)) {
        Write-UninstallLog "Failed to remove profile configuration" "Error"
        exit 1
    }
    
    # Remove installation files
    if (-not (Remove-InstallationFiles)) {
        Write-UninstallLog "Failed to remove installation files" "Error"
        exit 1
    }
    
    # Test uninstallation
    if (-not (Test-Uninstallation)) {
        Write-UninstallLog "Uninstallation test failed" "Error"
        exit 1
    }
    
    # Show summary
    Show-UninstallationSummary
    
    Write-UninstallLog 'Uninstallation completed successfully!' 'Success'
}
catch {
    Write-UninstallLog "Uninstallation failed with error: $($_.Exception.Message)" 'Error'
    exit 1
}
