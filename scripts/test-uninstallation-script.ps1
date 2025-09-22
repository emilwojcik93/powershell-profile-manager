#Requires -Version 5.1

<#
.SYNOPSIS
    Tests uninstallation script functionality

.DESCRIPTION
    This script tests that the uninstallation script runs without errors.

.PARAMETER RepositoryRoot
    The root directory of the repository to test

.EXAMPLE
    .\test-uninstallation-script.ps1 -RepositoryRoot "C:\path\to\repo"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = "Stop"

Write-Host "Testing Uninstallation Script..." -ForegroundColor Green

try {
    $uninstallScriptPath = Join-Path $RepositoryRoot "scripts\uninstall.ps1"
    $result = & $uninstallScriptPath -Silent -Force 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Uninstallation script runs without errors" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Uninstallation script failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "Output: $result" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Uninstallation script exception: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nUninstallation script test completed successfully!" -ForegroundColor Green
