#Requires -Version 5.1

<#
.SYNOPSIS
    Creates a release package for the PowerShell Profile Manager

.DESCRIPTION
    This script creates a release package by copying all necessary files
    and creating an installer script.

.PARAMETER Version
    The version number for the release

.PARAMETER IncludeExamples
    Whether to include example modules in the release

.PARAMETER RepositoryRoot
    The root directory of the repository

.EXAMPLE
    .\create-release-package.ps1 -Version "1.0.0" -IncludeExamples $false
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [bool]$IncludeExamples = $false,
    
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = "Stop"

Write-Host "Creating release package..." -ForegroundColor Green

$releaseDir = "release-v$Version"

# Create release directory
New-Item -ItemType Directory -Path $releaseDir -Force | Out-Null

# Copy main files
Copy-Item "Microsoft.PowerShell_profile.ps1" $releaseDir -Force
Copy-Item "README.md" $releaseDir -Force
Copy-Item "CONTRIBUTING.md" $releaseDir -Force
Copy-Item "LICENSE" $releaseDir -Force
Copy-Item "MIGRATION_GUIDE.md" $releaseDir -Force

# Copy scripts directory
Copy-Item "scripts" $releaseDir -Recurse -Force

# Copy docs directory
Copy-Item "docs" $releaseDir -Recurse -Force

# Copy modules (filter out examples if not requested)
New-Item -ItemType Directory -Path "$releaseDir\modules" -Force | Out-Null

$modules = Get-ChildItem "modules" -Directory
foreach ($module in $modules) {
    if ($module.Name -eq "ExampleModule" -and -not $IncludeExamples) {
        Write-Host "Skipping example module: $($module.Name)" -ForegroundColor Yellow
        continue
    }
    Copy-Item $module.FullName "$releaseDir\modules" -Recurse -Force
    Write-Host "Included module: $($module.Name)" -ForegroundColor Green
}

# Create installer script
$installerContent = @"
# PowerShell Profile Manager Installer
# Version: $Version
# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Write-Host "Installing PowerShell Profile Manager v$Version..." -ForegroundColor Green

# Download and execute installation script
try {
    `$installScript = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/install.ps1" -UseBasicParsing
    Invoke-Expression `$installScript.Content
} catch {
    Write-Host "Failed to download installation script: `$(`$_.Exception.Message)" -ForegroundColor Red
    exit 1
}
"@

$installerContent | Out-File -FilePath "$releaseDir\install.ps1" -Encoding UTF8

Write-Host "Release package created: $releaseDir" -ForegroundColor Green
