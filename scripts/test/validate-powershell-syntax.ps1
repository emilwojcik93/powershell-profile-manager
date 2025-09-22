#Requires -Version 5.1

<#
.SYNOPSIS
    Validates PowerShell syntax for all scripts and modules

.DESCRIPTION
    This script validates the PowerShell syntax for all scripts and modules
    in the PowerShell Profile Manager repository.

.PARAMETER RepositoryRoot
    The root directory of the repository to validate

.EXAMPLE
    .\validate-powershell-syntax.ps1 -RepositoryRoot "C:\path\to\repo"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = "Stop"

Write-Host "Validating PowerShell Scripts..." -ForegroundColor Green

# Test main profile script
Write-Host "`nTesting main profile script..." -ForegroundColor Cyan
try {
    $profilePath = Join-Path $RepositoryRoot "Microsoft.PowerShell_profile.ps1"
    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $profilePath -Raw), [ref]$null)
    Write-Host "SUCCESS: Main profile script syntax is valid" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Main profile script syntax error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test scripts
$scripts = @("install.ps1", "uninstall.ps1", "release.ps1")
foreach ($script in $scripts) {
    Write-Host "`nTesting $script script..." -ForegroundColor Cyan
    try {
        $scriptPath = Join-Path $RepositoryRoot "scripts\$script"
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $scriptPath -Raw), [ref]$null)
        Write-Host "SUCCESS: $script syntax is valid" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: $script syntax error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`nValidating PowerShell Modules..." -ForegroundColor Green

$modules = @("VideoCompressor", "PowerShellMCP", "ExampleModule")

foreach ($module in $modules) {
    Write-Host "`nTesting $module module..." -ForegroundColor Cyan
    
    $psm1Path = Join-Path $RepositoryRoot "modules\$module\$module.psm1"
    $psd1Path = Join-Path $RepositoryRoot "modules\$module\$module.psd1"
    
    # Test .psm1 file
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $psm1Path -Raw), [ref]$null)
        Write-Host "SUCCESS: $module.psm1 syntax is valid" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: $module.psm1 syntax error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    
    # Test .psd1 file
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $psd1Path -Raw), [ref]$null)
        Write-Host "SUCCESS: $module.psd1 syntax is valid" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: $module.psd1 syntax error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`nPowerShell syntax validation completed successfully!" -ForegroundColor Green
