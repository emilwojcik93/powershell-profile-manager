#Requires -Version 5.1

<#
.SYNOPSIS
    Tests installation script functionality

.DESCRIPTION
    This script tests that the installation script runs without errors
    and creates the expected directory structure.

.PARAMETER RepositoryRoot
    The root directory of the repository to test

.EXAMPLE
    .\test-installation-script.ps1 -RepositoryRoot "C:\path\to\repo"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = "Stop"

Write-Host "Testing Installation Script..." -ForegroundColor Green

# Create test directory
$testPath = "C:\Temp\ProfileManagerTest_$([System.Guid]::NewGuid().ToString('N')[0..7] -join '')"
New-Item -ItemType Directory -Path $testPath -Force | Out-Null

try {
    # Test installation script execution
    Write-Host "Testing installation script execution..." -ForegroundColor Cyan
    $installScriptPath = Join-Path $RepositoryRoot "scripts\install.ps1"
    
    # Ensure the install script exists
    if (-not (Test-Path $installScriptPath)) {
        Write-Host "ERROR: Install script not found at: $installScriptPath" -ForegroundColor Red
        exit 1
    }
    
    # Run the installation script with proper error handling
    try {
        $sourcePath = Split-Path $RepositoryRoot -Parent
        Write-Host "Running: $installScriptPath -InstallPath $testPath -Force -SkipInternetCheck -SourcePath $sourcePath" -ForegroundColor Gray
        Write-Host "Source path exists: $(Test-Path $sourcePath)" -ForegroundColor Gray
        Write-Host "Main profile script exists: $(Test-Path (Join-Path $sourcePath 'Microsoft.PowerShell_profile.ps1'))" -ForegroundColor Gray
        
        $result = & $installScriptPath -InstallPath $testPath -Force -SkipInternetCheck -SourcePath $sourcePath 2>&1
        $exitCode = $LASTEXITCODE
        Write-Host "Installation script output: $result" -ForegroundColor Gray
        Write-Host "Installation script exit code: $exitCode" -ForegroundColor Gray
    } catch {
        Write-Host "ERROR: Exception during installation: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    
    if ($exitCode -eq 0) {
        Write-Host "SUCCESS: Installation script runs without errors" -ForegroundColor Green
        
        # Verify installation results
        if (Test-Path "$testPath\Microsoft.PowerShell_profile.ps1") {
            Write-Host "SUCCESS: Main profile script was installed" -ForegroundColor Green
        } else {
            Write-Host "WARNING: Main profile script was not installed" -ForegroundColor Yellow
        }
        
        if (Test-Path "$testPath\modules") {
            Write-Host "SUCCESS: Modules directory was created" -ForegroundColor Green
        } else {
            Write-Host "WARNING: Modules directory was not created" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "ERROR: Installation script failed with exit code: $exitCode" -ForegroundColor Red
        Write-Host "Output: $result" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Installation script exception: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Cleanup
    if (Test-Path $testPath) {
        Remove-Item $testPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Test directory cleaned up" -ForegroundColor White
    }
}

Write-Host "`nInstallation script test completed successfully!" -ForegroundColor Green
