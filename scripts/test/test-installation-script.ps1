#Requires -Version 5.1
<#
.SYNOPSIS
    Tests the installation script with automation parameters
    
.DESCRIPTION
    This script tests the installation script with automation parameters and logging,
    then verifies the installation was successful.
    
.PARAMETER None
    This script takes no parameters
    
.EXAMPLE
    .\test-installation-script.ps1
#>

Write-Host '=== TESTING INSTALLATION SCRIPT ===' -ForegroundColor Green

$installLogPath = Join-Path $env:TEMP "Install-Test-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
Write-Host "Install log: $installLogPath" -ForegroundColor Cyan

# Test with automation parameters
.\scripts\deploy\install.ps1 -InstallPath "${env:USERPROFILE}\PowerShell\ProfileManager-Test" -Modules @('VideoCompressor') -NonInteractive -LogPath $installLogPath -Force

# Verify installation
$testPath = "${env:USERPROFILE}\PowerShell\ProfileManager-Test"
if (-not (Test-Path $testPath)) {
    Write-Error "Installation failed - directory not created: $testPath"
    exit 1
}

$modulePath = Join-Path $testPath 'modules\VideoCompressor'
if (-not (Test-Path $modulePath)) {
    Write-Error "Installation failed - module directory not created: $modulePath"
    exit 1
}

Write-Host 'Installation verification completed successfully' -ForegroundColor Green
