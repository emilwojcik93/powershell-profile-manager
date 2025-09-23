#Requires -Version 5.1

<#
.SYNOPSIS
    Generates release body from template

.DESCRIPTION
    This script generates the release body by replacing placeholders in the template
    with actual values.

.PARAMETER Version
    The version number for the release

.PARAMETER TemplatePath
    Path to the release body template

.PARAMETER RepositoryRoot
    The root directory of the repository

.EXAMPLE
    .\generate-release-body.ps1 -Version "1.0.0"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [string]$TemplatePath = "templates\markdown\release-body.md",
    
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = "Stop"

$templateFile = Join-Path $RepositoryRoot $TemplatePath

if (-not (Test-Path $templateFile)) {
    Write-Error "Template file not found: $templateFile"
    exit 1
}

$templateContent = Get-Content $templateFile -Raw

# Replace placeholders
$releaseBody = $templateContent -replace '\{\{ version \}\}', $Version

Write-Output $releaseBody
