#Requires -Version 5.1
<#
.SYNOPSIS
    Verifies the installation state and checks logs
    
.DESCRIPTION
    This script verifies that the installation was successful by checking files,
    directories, and profile modifications. It also verifies the install log.
    
.PARAMETER None
    This script takes no parameters
    
.EXAMPLE
    .\verify-installation-state.ps1
#>

Write-Host "=== VERIFYING INSTALLATION STATE ===" -ForegroundColor Green

$testPath = "$env:USERPROFILE\PowerShell\ProfileManager-Test"

# Count files and directories
$fileCount = (Get-ChildItem -Path $testPath -Recurse -File).Count
$dirCount = (Get-ChildItem -Path $testPath -Recurse -Directory).Count

Write-Host "Installation directory: $testPath" -ForegroundColor Cyan
Write-Host "Files created: $fileCount" -ForegroundColor Cyan
Write-Host "Directories created: $dirCount" -ForegroundColor Cyan

# Verify specific files
$requiredFiles = @(
    "Microsoft.PowerShell_profile.ps1",
    "modules\VideoCompressor\VideoCompressor.psm1",
    "modules\VideoCompressor\VideoCompressor.psd1"
)

foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $testPath $file
    if (Test-Path $fullPath) {
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Error "Missing required file: $file"
        exit 1
    }
}

# Check profile modification
$profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path $profilePath) {
    $profileContent = Get-Content -Path $profilePath -Raw
    if ($profileContent -match "ProfileManager") {
        Write-Host "  [OK] Profile modified correctly" -ForegroundColor Green
    } else {
        Write-Error "Profile not modified correctly"
        exit 1
    }
}

Write-Host "Installation state verification completed" -ForegroundColor Green

# Verify install log was created and contains expected information
$installLogPath = Join-Path $env:TEMP "Install-Test-$(Get-Date -Format 'yyyyMMdd')*.log"
$installLogs = Get-ChildItem -Path $installLogPath -ErrorAction SilentlyContinue
if ($installLogs) {
    $latestInstallLog = $installLogs | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Write-Host "Install log created successfully: $($latestInstallLog.FullName)" -ForegroundColor Green
    $logContent = Get-Content -Path $latestInstallLog.FullName -Raw
    if ($logContent -match "Installation completed successfully") {
        Write-Host "  [OK] Install log contains success message" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] Install log missing success message" -ForegroundColor Yellow
    }
    if ($logContent -match "Log file saved to") {
        Write-Host "  [OK] Install log contains log file reference" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] Install log missing log file reference" -ForegroundColor Yellow
    }
} else {
    Write-Host "WARNING: Install log not found" -ForegroundColor Yellow
}
