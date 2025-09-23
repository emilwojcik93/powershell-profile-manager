#Requires -Version 5.1
<#
.SYNOPSIS
    Verifies initial clean state before testing install/uninstall cycle
    
.DESCRIPTION
    This script checks for existing ProfileManager installations and cleans them up
    to ensure a clean starting state for testing.
    
.PARAMETER None
    This script takes no parameters
    
.EXAMPLE
    .\verify-initial-clean-state.ps1
#>

Write-Host "=== VERIFYING INITIAL CLEAN STATE ===" -ForegroundColor Green

# Check for existing installations
$installPaths = @(
    "${env:USERPROFILE}\PowerShell\ProfileManager",
    "${env:USERPROFILE}\PowerShell\ProfileManager-Test",
    "${env:USERPROFILE}\PowerShell\ProfileManager-Auto"
)

$foundInstallations = @()
foreach ($path in $installPaths) {
    if (Test-Path $path) {
        $foundInstallations += $path
        Write-Host "WARNING: Found existing installation at: $path" -ForegroundColor Yellow
    }
}

if ($foundInstallations.Count -gt 0) {
    Write-Host "Cleaning up existing installations..." -ForegroundColor Yellow
    foreach ($path in $foundInstallations) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Removed: $path" -ForegroundColor Gray
        }
    }
}

# Check profile state
$profilePath = "${env:USERPROFILE}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path $profilePath) {
    $profileContent = Get-Content -Path $profilePath -Raw
    if ($profileContent -match "ProfileManager") {
        Write-Host "WARNING: Profile contains ProfileManager references" -ForegroundColor Yellow
        # Create backup and clean profile
        Copy-Item -Path $profilePath -Destination "$profilePath.backup" -Force
        $cleanProfile = $profileContent -replace "(?s)# ProfileManager.*?^# End ProfileManager.*?$", ""
        $cleanProfile | Set-Content -Path $profilePath -Encoding UTF8
        Write-Host "Cleaned profile and created backup" -ForegroundColor Gray
    }
}

Write-Host "Initial state verification completed" -ForegroundColor Green
