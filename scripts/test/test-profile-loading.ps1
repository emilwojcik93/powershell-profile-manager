#Requires -Version 5.1

<#
.SYNOPSIS
    Tests main profile loading and Cursor environment detection

.DESCRIPTION
    This script tests that the main profile script loads successfully
    and that all profile manager functions are available.

.PARAMETER RepositoryRoot
    The root directory of the repository to test

.EXAMPLE
    .\test-profile-loading.ps1 -RepositoryRoot "C:\path\to\repo"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = "Stop"

Write-Host "Testing Main Profile Loading..." -ForegroundColor Green

try {
    # Load the main profile script to test Cursor detection
    $profilePath = Join-Path $RepositoryRoot "Microsoft.PowerShell_profile.ps1"
    . $profilePath
    Write-Host "SUCCESS: Main profile script loads successfully" -ForegroundColor Green
    
    # Test if Cursor detection function exists
    if (Get-Command Test-CursorEnvironment -ErrorAction SilentlyContinue) {
        $isCursor = Test-CursorEnvironment
        Write-Host "SUCCESS: Cursor environment detection works (Result: $isCursor)" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Test-CursorEnvironment function not found" -ForegroundColor Red
        exit 1
    }
    
    # Test profile manager functions
    $profileFunctions = @(
        "Get-ProfileModules",
        "Get-ProfileModuleStatus", 
        "Get-ProfileManagerStatus",
        "Load-ProfileModule",
        "Unload-ProfileModule",
        "Reload-ProfileModule",
        "Unload-AllProfileModules",
        "Remove-ProfileManager",
        "Restore-DefaultProfile"
    )
    
    foreach ($func in $profileFunctions) {
        if (Get-Command $func -ErrorAction SilentlyContinue) {
            Write-Host "SUCCESS: $func function available" -ForegroundColor Green
        } else {
            Write-Host "ERROR: $func function not found" -ForegroundColor Red
            exit 1
        }
    }
    
} catch {
    Write-Host "ERROR: Main profile script failed to load: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nProfile loading test completed successfully!" -ForegroundColor Green
