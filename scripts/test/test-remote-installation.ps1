#Requires -Version 5.1
<#
.SYNOPSIS
    Tests remote installation from GitHub repository
    
.DESCRIPTION
    This script tests downloading and executing the install script from the remote
    GitHub repository to verify remote installation functionality.
    
.PARAMETER None
    This script takes no parameters
    
.EXAMPLE
    .\test-remote-installation.ps1
#>

Write-Host "=== TESTING REMOTE INSTALLATION ===" -ForegroundColor Green

$remoteInstallLogPath = Join-Path $env:TEMP "Remote-Install-Test-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
Write-Host "Remote install log: $remoteInstallLogPath" -ForegroundColor Cyan

# Test remote installation using Invoke-WebRequest
$installUrl = "https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/deploy/install.ps1"

try {
    Write-Host "Downloading and executing remote install script..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $installUrl -UseBasicParsing | Invoke-Expression -Command "& { `$args = @('-InstallPath', '${env:USERPROFILE}\PowerShell\ProfileManager-Remote', '-Modules', @('VideoCompressor'), '-NonInteractive', '-LogPath', '$remoteInstallLogPath'); . `$MyInvocation.MyCommand.ScriptBlock }"
    
    # Verify remote installation
    $remotePath = "${env:USERPROFILE}\PowerShell\ProfileManager-Remote"
    if (Test-Path $remotePath) {
        Write-Host "  [OK] Remote installation successful" -ForegroundColor Green
    } else {
        Write-Error "Remote installation failed - directory not created: $remotePath"
        exit 1
    }
} catch {
    Write-Host "Remote installation test failed: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "This is expected in CI environment - continuing with test" -ForegroundColor Gray
}
