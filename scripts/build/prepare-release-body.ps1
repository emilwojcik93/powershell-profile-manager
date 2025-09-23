#Requires -Version 5.1

<#
.SYNOPSIS
    Prepares release body file for GitHub release

.DESCRIPTION
    This script generates the release body from template and saves it to a file
    for use in GitHub release creation.

.PARAMETER Version
    The version number for the release

.PARAMETER OutputPath
    Path where to save the release body file

.PARAMETER RepositoryRoot
    The root directory of the repository

.EXAMPLE
    .\prepare-release-body.ps1 -Version "1.0.0" -OutputPath "release-body.md"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = 'release-body.md',
    
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = 'Stop'

Write-Host "Generating release body for version $Version..." -ForegroundColor Green

$releaseBody = & (Join-Path $RepositoryRoot 'scripts\build\generate-release-body.ps1') -Version $Version

$releaseBody | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Host "Release body saved to: $OutputPath" -ForegroundColor Green
