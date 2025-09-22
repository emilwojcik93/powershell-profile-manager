#Requires -Version 5.1
<#
.SYNOPSIS
    Tests the uninstallation script with automation parameters
    
.DESCRIPTION
    This script tests the uninstallation script with automation parameters and logging,
    then verifies the uninstallation was successful.
    
.PARAMETER None
    This script takes no parameters
    
.EXAMPLE
    .\test-uninstallation-script.ps1
#>

Write-Host "=== TESTING UNINSTALLATION SCRIPT ===" -ForegroundColor Green

$uninstallLogPath = Join-Path $env:TEMP "Uninstall-Test-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
Write-Host "Uninstall log: $uninstallLogPath" -ForegroundColor Cyan

# Test with automation parameters and logging
.\scripts\deploy\uninstall.ps1 -InstallPath "$env:USERPROFILE\PowerShell\ProfileManager-Test" -Unattended -LogPath $uninstallLogPath

# Verify uninstallation
$testPath = "$env:USERPROFILE\PowerShell\ProfileManager-Test"
if (Test-Path $testPath) {
    Write-Error "Uninstallation failed - directory still exists: $testPath"
    exit 1
}

Write-Host "Uninstallation verification completed successfully" -ForegroundColor Green

# Verify uninstall log was created and contains expected information
$uninstallLogPath = Join-Path $env:TEMP "Uninstall-Test-$(Get-Date -Format 'yyyyMMdd')*.log"
$uninstallLogs = Get-ChildItem -Path $uninstallLogPath -ErrorAction SilentlyContinue
if ($uninstallLogs) {
    $latestUninstallLog = $uninstallLogs | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Write-Host "Uninstall log created successfully: $($latestUninstallLog.FullName)" -ForegroundColor Green
    $logContent = Get-Content -Path $latestUninstallLog.FullName -Raw
    if ($logContent -match "Uninstallation completed successfully") {
        Write-Host "  [OK] Uninstall log contains success message" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] Uninstall log missing success message" -ForegroundColor Yellow
    }
    if ($logContent -match "Log file saved to") {
        Write-Host "  [OK] Uninstall log contains log file reference" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] Uninstall log missing log file reference" -ForegroundColor Yellow
    }
} else {
    Write-Host "WARNING: Uninstall log not found" -ForegroundColor Yellow
}
