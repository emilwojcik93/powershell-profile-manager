#Requires -Version 5.1

<#
.SYNOPSIS
    Creates a ZIP archive for the release package

.DESCRIPTION
    This script creates a ZIP archive from the release package directory.

.PARAMETER Version
    The version number for the release

.PARAMETER RepositoryRoot
    The root directory of the repository

.EXAMPLE
    .\create-release-archive.ps1 -Version "1.0.0"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = "Stop"

$releaseDir = "release-v$Version"
$archiveName = "powershell-profile-manager-v$Version.zip"

# Create ZIP archive
Compress-Archive -Path "$releaseDir\*" -DestinationPath $archiveName -Force

Write-Host "Release archive created: $archiveName" -ForegroundColor Green
