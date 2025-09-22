#Requires -Version 5.1
<#
.SYNOPSIS
    Cleans up test environment after testing
    
.DESCRIPTION
    This script removes all test installations and restores the profile from backup
    to ensure a clean state after testing.
    
.PARAMETER None
    This script takes no parameters
    
.EXAMPLE
    .\cleanup-test-environment.ps1
#>

Write-Host "=== CLEANING UP TEST ENVIRONMENT ===" -ForegroundColor Green

# Remove all test installations
$testPaths = @(
    "$env:USERPROFILE\PowerShell\ProfileManager-Test",
    "$env:USERPROFILE\PowerShell\ProfileManager-Remote",
    "$env:USERPROFILE\PowerShell\ProfileManager-Auto"
)

foreach ($path in $testPaths) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Cleaned up: $path" -ForegroundColor Gray
    }
}

# Restore profile if backup exists
$profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$backupPath = "$profilePath.backup"
if (Test-Path $backupPath) {
    Copy-Item -Path $backupPath -Destination $profilePath -Force
    Remove-Item -Path $backupPath -Force
    Write-Host "Restored profile from backup" -ForegroundColor Gray
}

Write-Host "Test environment cleanup completed" -ForegroundColor Green
