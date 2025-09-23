#Requires -Version 5.1
<#
.SYNOPSIS
    Verifies clean uninstall state and checks for leftover files
    
.DESCRIPTION
    This script verifies that the uninstallation was complete by checking that
    installation directories are gone, profiles are restored, and no leftover files exist.
    
.PARAMETER None
    This script takes no parameters
    
.EXAMPLE
    .\verify-clean-uninstall-state.ps1
#>

Write-Host "=== VERIFYING CLEAN UNINSTALL STATE ===" -ForegroundColor Green

# Check that installation directory is gone
$testPath = "${env:USERPROFILE}\PowerShell\ProfileManager-Test"
if (Test-Path $testPath) {
    Write-Error "Uninstallation incomplete - directory still exists: $testPath"
    exit 1
}

# Check profile restoration
$profilePath = "${env:USERPROFILE}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path $profilePath) {
    $profileContent = Get-Content -Path $profilePath -Raw
    if ($profileContent -match "ProfileManager") {
        Write-Error "Uninstallation incomplete - profile still contains ProfileManager references"
        exit 1
    } else {
        Write-Host "  [OK] Profile restored correctly" -ForegroundColor Green
    }
}

# Check for any leftover files
$leftoverPaths = @(
    "${env:USERPROFILE}\PowerShell\ProfileManager",
    "${env:USERPROFILE}\PowerShell\ProfileManager-Test",
    "${env:USERPROFILE}\PowerShell\ProfileManager-Auto"
)

$leftovers = @()
foreach ($path in $leftoverPaths) {
    if (Test-Path $path) {
        $leftovers += $path
    }
}

if ($leftovers.Count -gt 0) {
    Write-Host "WARNING: Found leftover files:" -ForegroundColor Yellow
    foreach ($leftover in $leftovers) {
        Write-Host "  - $leftover" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [OK] No leftover files found" -ForegroundColor Green
}

Write-Host "Clean uninstall state verification completed" -ForegroundColor Green
