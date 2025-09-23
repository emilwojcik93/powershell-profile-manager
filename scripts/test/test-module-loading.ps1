#Requires -Version 5.1

<#
.SYNOPSIS
    Tests module loading for all PowerShell modules

.DESCRIPTION
    This script tests that all PowerShell modules can be loaded successfully
    and export their expected functions.

.PARAMETER RepositoryRoot
    The root directory of the repository to test

.EXAMPLE
    .\test-module-loading.ps1 -RepositoryRoot "C:\path\to\repo"
#>

[CmdletBinding()]
param(
    # Standard automation parameters
    [Parameter(Mandatory = $false)]
    [switch]$Silent,
    
    [Parameter(Mandatory = $false)]
    [switch]$NonInteractive,
    
    [Parameter(Mandatory = $false)]
    [switch]$Unattended,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$VerboseLogging,
    
    # Standard path parameters
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = "Stop"

Write-Host "Testing Module Loading..." -ForegroundColor Green

$modules = @("VideoCompressor", "PowerShellMCP", "ExampleModule")

foreach ($module in $modules) {
    Write-Host "`nTesting $module module loading..." -ForegroundColor Cyan
    
    $modulePath = Join-Path $RepositoryRoot "modules\$module"
    
    try {
        Import-Module $modulePath -Force -ErrorAction Stop
        Write-Host "SUCCESS: $module module loads successfully" -ForegroundColor Green
        
        # Test module functions
        $moduleInfo = Get-Module $module
        if ($moduleInfo.ExportedFunctions.Count -gt 0) {
            Write-Host "SUCCESS: $module exports $($moduleInfo.ExportedFunctions.Count) functions" -ForegroundColor Green
            
            # List exported functions
            foreach ($func in $moduleInfo.ExportedFunctions.Keys) {
                Write-Host "  - $func" -ForegroundColor White
            }
        } else {
            Write-Host "WARNING: $module exports no functions" -ForegroundColor Yellow
        }
        
        Remove-Module $module -Force
    } catch {
        Write-Host "ERROR: $module module failed to load: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`nModule loading test completed successfully!" -ForegroundColor Green
