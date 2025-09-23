# Script to update all PowerShell scripts with standardized parameters
# This script adds the standard parameter set to scripts that don't have it

param(
    [Parameter(Mandatory = $false)]
    [string]$ScriptPath = "scripts",
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

# Standard parameter block to add
$StandardParams = @"
    # Standard automation parameters
    [Parameter(Mandatory = `$false)]
    [switch]`$Silent,
    
    [Parameter(Mandatory = `$false)]
    [switch]`$NonInteractive,
    
    [Parameter(Mandatory = `$false)]
    [switch]`$Unattended,
    
    [Parameter(Mandatory = `$false)]
    [switch]`$Force,
    
    [Parameter(Mandatory = `$false)]
    [switch]`$VerboseLogging,
    
    # Standard path parameters
    [Parameter(Mandatory = `$false)]
    [string]`$RepositoryRoot = (Get-Location)
"@

# Get all PowerShell scripts
$scripts = Get-ChildItem -Path $ScriptPath -Filter "*.ps1" -Recurse

$updatedCount = 0
$skippedCount = 0

foreach ($script in $scripts) {
    try {
        $content = Get-Content $script.FullName -Raw
        
        # Skip if already has VerboseLogging parameter
        if ($content -match 'switch\$\$VerboseLogging') {
            Write-Host "SKIPPED: $($script.Name) - Already has standardized parameters" -ForegroundColor Yellow
            $skippedCount++
            continue
        }
        
        # Skip if no param block found
        if ($content -notmatch 'param\s*\(') {
            Write-Host "SKIPPED: $($script.Name) - No param block found" -ForegroundColor Yellow
            $skippedCount++
            continue
        }
        
        # Find the param block and replace it
        $paramPattern = 'param\s*\([^)]*\)'
        $paramMatch = [regex]::Match($content, $paramPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        
        if ($paramMatch.Success) {
            $existingParams = $paramMatch.Value
            
            # Check if it already has some standard parameters
            if ($existingParams -match 'switch\$\$Silent' -or $existingParams -match 'switch\$\$NonInteractive') {
                Write-Host "SKIPPED: $($script.Name) - Already has some standard parameters" -ForegroundColor Yellow
                $skippedCount++
                continue
            }
            
            # Create new param block
            $newParamBlock = "param(`n$StandardParams`n)"
            
            # Replace the param block
            $newContent = [regex]::Replace($content, $paramPattern, $newParamBlock, [System.Text.RegularExpressions.RegexOptions]::Singleline)
            
            if ($WhatIf) {
                Write-Host "WOULD UPDATE: $($script.Name)" -ForegroundColor Cyan
            } else {
                Set-Content -Path $script.FullName -Value $newContent -Encoding UTF8
                Write-Host "UPDATED: $($script.Name)" -ForegroundColor Green
            }
            
            $updatedCount++
        } else {
            Write-Host "SKIPPED: $($script.Name) - Could not parse param block" -ForegroundColor Yellow
            $skippedCount++
        }
    } catch {
        Write-Host "ERROR: $($script.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  Updated: $updatedCount" -ForegroundColor Green
Write-Host "  Skipped: $skippedCount" -ForegroundColor Yellow
Write-Host "  Total: $($scripts.Count)" -ForegroundColor White
