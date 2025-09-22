#Requires -Version 5.1

<#
.SYNOPSIS
    Tests PowerShellMCP module functionality

.DESCRIPTION
    This script tests that the PowerShellMCP module loads successfully
    and that all MCP functions are available and working.

.PARAMETER RepositoryRoot
    The root directory of the repository to test

.EXAMPLE
    .\test-powershellmcp-module.ps1 -RepositoryRoot "C:\path\to\repo"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = "Stop"

Write-Host "Testing PowerShellMCP Module..." -ForegroundColor Green

try {
    $modulePath = Join-Path $RepositoryRoot "modules\PowerShellMCP"
    Import-Module $modulePath -Force
    Write-Host "SUCCESS: PowerShellMCP module loads successfully" -ForegroundColor Green
    
    # Test MCP functions
    $mcpFunctions = @(
        "Start-PowerShellMCPServer",
        "Stop-PowerShellMCPServer",
        "Get-PowerShellMCPStatus",
        "Test-PowerShellMCPConnection",
        "Invoke-PowerShellMCPCommand",
        "Get-PowerShellMCPConfig",
        "Set-PowerShellMCPConfig"
    )
    
    foreach ($func in $mcpFunctions) {
        if (Get-Command $func -ErrorAction SilentlyContinue) {
            Write-Host "SUCCESS: $func function available" -ForegroundColor Green
        } else {
            Write-Host "ERROR: $func function not found" -ForegroundColor Red
            exit 1
        }
    }
    
    # Test MCP configuration
    $config = Get-PowerShellMCPConfig
    if ($config -and $config.ServerPort -and $config.ServerHost) {
        Write-Host "SUCCESS: MCP configuration is valid" -ForegroundColor Green
        Write-Host "  Port: $($config.ServerPort)" -ForegroundColor White
        Write-Host "  Host: $($config.ServerHost)" -ForegroundColor White
        Write-Host "  Max Execution Time: $($config.MaxExecutionTime) seconds" -ForegroundColor White
    } else {
        Write-Host "ERROR: MCP configuration is invalid" -ForegroundColor Red
        exit 1
    }
    
    Remove-Module PowerShellMCP -Force
} catch {
    Write-Host "ERROR: PowerShellMCP module test failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nPowerShellMCP module test completed successfully!" -ForegroundColor Green
