#Requires -Version 5.1
<#
.SYNOPSIS
    Template processing script for GitHub Actions workflows

.DESCRIPTION
    This script processes template files by replacing placeholders with actual values.
    It supports both Markdown and HTML templates.

.PARAMETER TemplatePath
    Path to the template file

.PARAMETER OutputPath
    Path where the processed template should be saved

.PARAMETER Variables
    Hashtable containing variable names and values for replacement

.EXAMPLE
    .\process-template.ps1 -TemplatePath "templates\markdown\pr-comment-template.md" -OutputPath "processed-comment.md" -Variables @{statusIcon="✅"; totalCritical=0}
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TemplatePath,
    
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    
    [Parameter(Mandatory = $true)]
    [hashtable]$Variables
)

try {
    if (-not (Test-Path $TemplatePath)) {
        throw "Template file not found: $TemplatePath"
    }
    
    # Read the template content
    $templateContent = Get-Content -Path $TemplatePath -Raw -Encoding UTF8
    
    # Replace all variables in the template
    foreach ($variable in $Variables.GetEnumerator()) {
        $placeholder = "{{$($variable.Key)}}"
        $value = $variable.Value
        $templateContent = $templateContent -replace [regex]::Escape($placeholder), $value
    }
    
    # Ensure output directory exists
    $outputDir = Split-Path -Parent $OutputPath
    if ($outputDir -and -not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    
    # Write the processed template
    $templateContent | Out-File -FilePath $OutputPath -Encoding UTF8 -NoNewline
    
    Write-Host "Template processed successfully: $OutputPath" -ForegroundColor Green
    
} catch {
    Write-Error "Failed to process template: $($_.Exception.Message)"
    exit 1
}
