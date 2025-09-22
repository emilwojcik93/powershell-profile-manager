#Requires -Version 5.1

<#
.SYNOPSIS
    Tests VideoCompressor module functionality

.DESCRIPTION
    This script tests that the VideoCompressor module loads successfully
    and that all video compression functions are available.

.PARAMETER RepositoryRoot
    The root directory of the repository to test

.EXAMPLE
    .\test-videocompressor-module.ps1 -RepositoryRoot "C:\path\to\repo"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = "Stop"

Write-Host "Testing VideoCompressor Module..." -ForegroundColor Green

try {
    $modulePath = Join-Path $RepositoryRoot "modules\VideoCompressor"
    Import-Module $modulePath -Force
    Write-Host "SUCCESS: VideoCompressor module loads successfully" -ForegroundColor Green
    
    # Test VideoCompressor functions
    $vcFunctions = @(
        "Install-FFmpeg",
        "Get-VideoProperties",
        "Get-OptimalCompressionSettings",
        "Get-OutputDirectory",
        "Compress-Video"
    )
    
    foreach ($func in $vcFunctions) {
        if (Get-Command $func -ErrorAction SilentlyContinue) {
            Write-Host "SUCCESS: $func function available" -ForegroundColor Green
        } else {
            Write-Host "ERROR: $func function not found" -ForegroundColor Red
            exit 1
        }
    }
    
    Remove-Module VideoCompressor -Force
} catch {
    Write-Host "ERROR: VideoCompressor module test failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nVideoCompressor module test completed successfully!" -ForegroundColor Green
