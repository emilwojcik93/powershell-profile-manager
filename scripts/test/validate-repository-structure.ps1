#Requires -Version 5.1

<#
.SYNOPSIS
    Validates the repository structure for PowerShell Profile Manager

.DESCRIPTION
    This script validates that all required files and directories exist
    in the PowerShell Profile Manager repository.

.PARAMETER RepositoryRoot
    The root directory of the repository to validate

.EXAMPLE
    .\validate-repository-structure.ps1 -RepositoryRoot "C:\path\to\repo"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location)
)

$ErrorActionPreference = "Stop"

Write-Host "Validating repository structure..." -ForegroundColor Green

# Required files
$requiredFiles = @(
    "Microsoft.PowerShell_profile.ps1",
    "scripts\deploy\install.ps1",
    "scripts\deploy\uninstall.ps1",
    "scripts\deploy\release.ps1",
    "README.md",
    "CONTRIBUTING.md",
    "LICENSE",
    ".gitignore",
    ".cursorrules"
)

# Required directories
$requiredDirs = @(
    "modules",
    "docs",
    "scripts\build",
    "scripts\deploy",
    "scripts\test",
    "scripts\tools",
    "templates\html",
    "templates\markdown",
    ".github\workflows",
    ".cursor"
)

# Optional directories
$optionalDirs = @(
    ".vscode"
)

$structureValid = $true

# Check files
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $RepositoryRoot $file
    if (Test-Path $filePath) {
        Write-Host "SUCCESS: $file exists" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $file missing" -ForegroundColor Red
        $structureValid = $false
    }
}

# Check required directories
foreach ($dir in $requiredDirs) {
    $dirPath = Join-Path $RepositoryRoot $dir
    if (Test-Path $dirPath -PathType Container) {
        Write-Host "SUCCESS: $dir directory exists" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $dir directory missing" -ForegroundColor Red
        $structureValid = $false
    }
}

# Check optional directories
foreach ($dir in $optionalDirs) {
    $dirPath = Join-Path $RepositoryRoot $dir
    if (Test-Path $dirPath -PathType Container) {
        Write-Host "SUCCESS: $dir directory exists" -ForegroundColor Green
    } else {
        Write-Host "INFO: $dir directory not found (optional)" -ForegroundColor Yellow
    }
}

# Check module structure
$modules = @("VideoCompressor", "PowerShellMCP", "ExampleModule")
foreach ($module in $modules) {
    $modulePath = Join-Path $RepositoryRoot "modules\$module"
    if (Test-Path $modulePath -PathType Container) {
        Write-Host "SUCCESS: Module $module directory exists" -ForegroundColor Green
        
        $moduleFiles = @("$module.psm1", "$module.psd1", "README.md")
        foreach ($file in $moduleFiles) {
            $filePath = Join-Path $modulePath $file
            if (Test-Path $filePath) {
                Write-Host "SUCCESS: $file exists" -ForegroundColor Green
            } else {
                Write-Host "ERROR: $file missing" -ForegroundColor Red
                $structureValid = $false
            }
        }
    } else {
        Write-Host "ERROR: Module $module directory missing" -ForegroundColor Red
        $structureValid = $false
    }
}

if ($structureValid) {
    Write-Host "Repository structure validation passed" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Repository structure validation failed" -ForegroundColor Red
    exit 1
}
