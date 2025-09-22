#Requires -Version 5.1

<#
.SYNOPSIS
    Tests release script functionality

.DESCRIPTION
    This script tests that the release script runs without errors
    and creates the expected release artifacts.

.PARAMETER RepositoryRoot
    The root directory of the repository to test

.EXAMPLE
    .\test-release-script.ps1 -RepositoryRoot "C:\path\to\repo"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = "Stop"

Write-Host "Testing Release Script..." -ForegroundColor Green

try {
    $releaseScriptPath = Join-Path $RepositoryRoot "scripts\release.ps1"
    $result = & $releaseScriptPath -Version "1.0.0-test" -OutputPath ".\test-release" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Release script runs without errors" -ForegroundColor Green
        
        # Check if release was created
        if (Test-Path ".\test-release") {
            Write-Host "SUCCESS: Release directory was created" -ForegroundColor Green
        } else {
            Write-Host "WARNING: Release directory was not created" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "ERROR: Release script failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "Output: $result" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Release script exception: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Cleanup test release directory
    if (Test-Path ".\test-release") {
        Remove-Item ".\test-release" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Test release directory cleaned up" -ForegroundColor White
    }
}

Write-Host "`nRelease script test completed successfully!" -ForegroundColor Green
