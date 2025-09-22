#Requires -Version 5.1

<#
.SYNOPSIS
    Notifies about background agent results

.DESCRIPTION
    This script provides notification about the background agent execution results.

.PARAMETER Status
    The status of the background agent execution

.EXAMPLE
    .\notify-results.ps1 -Status "success"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Status = "unknown"
)

$ErrorActionPreference = "Stop"

Write-Host "Background agent completed" -ForegroundColor Green
Write-Host "Status: $Status" -ForegroundColor $(if ($Status -eq "success") { "Green" } else { "Yellow" })

if ($Status -ne "success") {
    Write-Host "Check the workflow logs for details" -ForegroundColor Yellow
}
