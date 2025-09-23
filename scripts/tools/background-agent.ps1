#Requires -Version 5.1

<#
.SYNOPSIS
    Background agent for continuous testing and fixing

.DESCRIPTION
    This script runs comprehensive tests on the PowerShell Profile Manager
    and attempts to fix any issues found.

.PARAMETER RepositoryRoot
    The root directory of the repository to test

.PARAMETER Mode
    The agent mode: full, syntax-only, workflows-only, modules-only

.EXAMPLE
    .\background-agent.ps1 -RepositoryRoot "C:\path\to\repo" -Mode "full"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location),
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("full", "syntax-only", "workflows-only", "modules-only")]
    [string]$Mode = "full"
)

$ErrorActionPreference = "Continue"
$global:AgentErrors = @()
$global:AgentFixes = @()

# Create agent log function
function Write-AgentLog {
    param([string]$Message, [string]$Level = "Info")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $emoji = switch ($Level) {
        "Error" { "ERROR" }
        "Warning" { "WARN" }
        "Success" { "SUCCESS" }
        "Fix" { "FIX" }
        default { "INFO" }
    }
    Write-Host "[$timestamp] $emoji $Message" -ForegroundColor $(
        switch ($Level) {
            "Error" { "Red" }
            "Warning" { "Yellow" }
            "Success" { "Green" }
            "Fix" { "Magenta" }
            default { "White" }
        }
    )
}

Write-AgentLog "Initializing Background Agent..." "Info"
Write-AgentLog "PowerShell Version: $($PSVersionTable.PSVersion)" "Info"
Write-AgentLog "Agent Mode: $Mode" "Info"
Write-AgentLog "Repository Root: $RepositoryRoot" "Info"

# Run validation scripts based on mode
$scriptsToRun = @()

switch ($Mode) {
    "full" {
        $scriptsToRun = @(
            "validate-repository-structure.ps1",
            "validate-powershell-syntax.ps1",
            "test-module-loading.ps1",
            "test-profile-loading.ps1",
            "test-powershellmcp-module.ps1",
            "test-videocompressor-module.ps1",
            "test-installation-script.ps1",
            "test-uninstallation-script.ps1",
            "test-release-script.ps1"
        )
    }
    "syntax-only" {
        $scriptsToRun = @(
            "validate-powershell-syntax.ps1"
        )
    }
    "workflows-only" {
        $scriptsToRun = @(
            "validate-repository-structure.ps1",
            "validate-powershell-syntax.ps1"
        )
    }
    "modules-only" {
        $scriptsToRun = @(
            "test-module-loading.ps1",
            "test-powershellmcp-module.ps1",
            "test-videocompressor-module.ps1"
        )
    }
}

$scriptsPath = Join-Path $RepositoryRoot "scripts\test"
$allTestsPassed = $true

foreach ($script in $scriptsToRun) {
    $scriptPath = Join-Path $scriptsPath $script
    Write-AgentLog "Running $script..." "Info"
    
    try {
        $result = & $scriptPath -RepositoryRoot $RepositoryRoot 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-AgentLog "$script completed successfully" "Success"
        } else {
            Write-AgentLog "$script failed with exit code: $LASTEXITCODE" "Error"
            $global:AgentErrors += "$script failed"
            $allTestsPassed = $false
        }
    } catch {
        Write-AgentLog "$script exception: $($_.Exception.Message)" "Error"
        $global:AgentErrors += "$script exception"
        $allTestsPassed = $false
    }
}

# Generate final report
Write-Host "`n" -NoNewline
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "                    BACKGROUND AGENT REPORT                     " -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

Write-Host "`nAgent Information:" -ForegroundColor Yellow
Write-Host "  PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor White
Write-Host "  Agent Mode: $Mode" -ForegroundColor White
Write-Host "  Repository Root: $RepositoryRoot" -ForegroundColor White
Write-Host "  Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')" -ForegroundColor White

if ($allTestsPassed) {
    Write-Host "`nOverall Status: ✅ ALL TESTS PASSED" -ForegroundColor Green
    Write-Host "Repository is functioning correctly!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nOverall Status: ❌ ISSUES FOUND" -ForegroundColor Red
    Write-Host "Errors encountered:" -ForegroundColor Red
    foreach ($error in $global:AgentErrors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
    exit 1
}
