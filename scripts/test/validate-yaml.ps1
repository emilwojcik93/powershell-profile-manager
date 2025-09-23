#Requires -Version 5.1
<#
.SYNOPSIS
    Comprehensive YAML Validation Script for GitHub Actions Workflows and Configuration Files

.DESCRIPTION
    This script validates YAML files for syntax errors, GitHub Actions workflow compliance,
    and best practices. It provides detailed reporting and can fix common issues automatically.

.PARAMETER YamlPath
    Path to YAML file or directory containing YAML files to validate

.PARAMETER OutputFormat
    Output format for reports: JSON, HTML, XML, or Console (default: Console)

.PARAMETER ExportReport
    Path to export detailed validation report

.PARAMETER FixIssues
    Attempt to automatically fix common YAML issues

.PARAMETER MinimumSeverity
    Minimum severity level to report: Critical, High, Medium, Low, All (default: All)

.PARAMETER Quiet
    Suppress verbose output

.PARAMETER NoFailOnIssues
    Don't exit with error code when issues are found

.EXAMPLE
    .\validate-yaml.ps1 -YamlPath "workflows\test.yml"
    
.EXAMPLE
    .\validate-yaml.ps1 -YamlPath "." -OutputFormat JSON -ExportReport "yaml-validation-report.json"
    
.EXAMPLE
    .\validate-yaml.ps1 -YamlPath "workflows" -FixIssues -MinimumSeverity High

.NOTES
    Version: 1.0.0
    Requires: powershell-yaml module
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$YamlPath,
    
    [Parameter()]
    [ValidateSet("JSON", "HTML", "XML", "Console")]
    [string]$OutputFormat = "Console",
    
    [Parameter()]
    [string]$ExportReport,
    
    [Parameter()]
    [switch]$FixIssues,
    
    [Parameter()]
    [ValidateSet("Critical", "High", "Medium", "Low", "All")]
    [string]$MinimumSeverity = "All",
    
    [Parameter()]
    [switch]$Quiet,
    
    [Parameter()]
    [switch]$NoFailOnIssues
)

# Import required modules
try {
    Import-Module powershell-yaml -Force -ErrorAction Stop
    if (-not $Quiet) {
        Write-Host "powershell-yaml module loaded successfully" -ForegroundColor Green
    }
} catch {
    Write-Error "Failed to import powershell-yaml module. Please install it using: Install-Module -Name powershell-yaml -Force"
    exit 1
}

# Initialize validation results
$validationResults = @()
$totalFiles = 0
$totalIssues = 0
$criticalIssues = 0
$highIssues = 0
$mediumIssues = 0
$lowIssues = 0

# Define severity levels
$severityLevels = @{
    "Critical" = 4
    "High" = 3
    "Medium" = 2
    "Low" = 1
    "All" = 0
}

$minSeverityLevel = $severityLevels[$MinimumSeverity]

# Function to get severity level
function Get-SeverityLevel {
    param([string]$Severity)
    return $severityLevels[$Severity]
}

# Function to add validation result
function Add-ValidationResult {
    param(
        [string]$File,
        [string]$Severity,
        [string]$Rule,
        [string]$Message,
        [string]$Line = "",
        [string]$Column = "",
        [string]$Suggestion = ""
    )
    
    if ((Get-SeverityLevel $Severity) -ge $minSeverityLevel) {
        $result = [PSCustomObject]@{
            File = $File
            Severity = $Severity
            Rule = $Rule
            Message = $Message
            Line = $Line
            Column = $Column
            Suggestion = $Suggestion
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        
        $script:validationResults += $result
        $script:totalIssues++
        
        switch ($Severity) {
            "Critical" { $script:criticalIssues++ }
            "High" { $script:highIssues++ }
            "Medium" { $script:mediumIssues++ }
            "Low" { $script:lowIssues++ }
        }
    }
}

# Function to validate YAML syntax
function Test-YamlSyntax {
    param(
        [string]$FilePath,
        [string]$Content
    )
    
    try {
        $yamlObject = ConvertFrom-Yaml -Yaml $Content -ErrorAction Stop
        return $true, $yamlObject
    } catch {
        Add-ValidationResult -File $FilePath -Severity "Critical" -Rule "YAML_SYNTAX_ERROR" -Message "YAML syntax error: $($_.Exception.Message)"
        return $false, $null
    }
}

# Function to validate GitHub Actions workflow
function Test-GitHubActionsWorkflow {
    param(
        [string]$FilePath,
        [object]$YamlObject
    )
    
    # Check if it's a GitHub Actions workflow
    if ($FilePath -match "\.github[\\\/]workflows[\\\/].*\.ya?ml$") {
        # Validate required fields
        if (-not $YamlObject.name) {
            Add-ValidationResult -File $FilePath -Severity "High" -Rule "MISSING_WORKFLOW_NAME" -Message "Workflow is missing required 'name' field"
        }
        
        if (-not $YamlObject.on) {
            Add-ValidationResult -File $FilePath -Severity "Critical" -Rule "MISSING_TRIGGER" -Message "Workflow is missing required 'on' trigger field"
        }
        
        if (-not $YamlObject.jobs) {
            Add-ValidationResult -File $FilePath -Severity "Critical" -Rule "MISSING_JOBS" -Message "Workflow is missing required 'jobs' field"
        }
        
        # Validate job structure
        if ($YamlObject.jobs) {
            # Handle both hashtable and PSCustomObject formats
            if ($YamlObject.jobs -is [System.Collections.IDictionary]) {
                $jobNames = $YamlObject.jobs.Keys
            } else {
                $jobNames = $YamlObject.jobs.PSObject.Properties.Name
            }
            
            foreach ($jobName in $jobNames) {
                if ($YamlObject.jobs -is [System.Collections.IDictionary]) {
                    $job = $YamlObject.jobs[$jobName]
                } else {
                    $job = $YamlObject.jobs.$jobName
                }
                
                if (-not $job."runs-on") {
                    Add-ValidationResult -File $FilePath -Severity "High" -Rule "MISSING_RUNS_ON" -Message "Job '$jobName' is missing required 'runs-on' field"
                }
                
                if (-not $job.steps) {
                    Add-ValidationResult -File $FilePath -Severity "High" -Rule "MISSING_STEPS" -Message "Job '$jobName' is missing required 'steps' field"
                } else {
                    # Validate steps
                    for ($i = 0; $i -lt $job.steps.Count; $i++) {
                        $step = $job.steps[$i]
                        
                        if (-not $step.name) {
                            Add-ValidationResult -File $FilePath -Severity "Medium" -Rule "MISSING_STEP_NAME" -Message "Step $($i + 1) in job '$jobName' is missing 'name' field"
                        }
                        
                        if (-not $step.uses -and -not $step.run) {
                            Add-ValidationResult -File $FilePath -Severity "High" -Rule "MISSING_STEP_ACTION" -Message "Step $($i + 1) in job '$jobName' must have either 'uses' or 'run' field"
                        }
                    }
                }
            }
        }
        
        # Check for common issues
        if ($YamlObject.on -and $YamlObject.on.PSObject.Properties.Name -contains "push") {
            $pushConfig = $YamlObject.on.push
            if ($pushConfig -and $pushConfig.branches -and $pushConfig.branches -contains "*") {
                Add-ValidationResult -File $FilePath -Severity "Medium" -Rule "WILDCARD_BRANCH" -Message "Using wildcard '*' for branches can trigger on all branches. Consider being more specific."
            }
        }
    }
}

# Function to validate YAML best practices
function Test-YamlBestPractices {
    param(
        [string]$FilePath,
        [string]$Content,
        [object]$YamlObject
    )
    
    # Check for common indentation issues
    $lines = $Content -split "`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1
        
        # Check for tabs instead of spaces
        if ($line -match "^\t") {
            Add-ValidationResult -File $FilePath -Severity "Medium" -Rule "TAB_INDENTATION" -Message "Line $lineNumber uses tabs instead of spaces for indentation" -Line $lineNumber -Suggestion "Use spaces instead of tabs for YAML indentation"
        }
        
        # Check for inconsistent indentation
        if ($line -match "^\s+") {
            $indent = $line -replace "^( *).*", '$1'
            if ($indent.Length % 2 -ne 0 -and $indent.Length -gt 0) {
                Add-ValidationResult -File $FilePath -Severity "Low" -Rule "ODD_INDENTATION" -Message "Line $lineNumber has odd number of spaces for indentation" -Line $lineNumber -Suggestion "Use even number of spaces for YAML indentation"
            }
        }
        
        # Check for trailing whitespace
        if ($line -match "\s+$") {
            Add-ValidationResult -File $FilePath -Severity "Low" -Rule "TRAILING_WHITESPACE" -Message "Line $lineNumber has trailing whitespace" -Line $lineNumber -Suggestion "Remove trailing whitespace"
        }
    }
    
    # Check for duplicate keys
    if ($YamlObject) {
        $duplicateKeys = @()
        $seenKeys = @{}
        
        function Test-DuplicateKeys {
            param([object]$Object, [string]$Path = "")
            
            if ($Object -is [System.Collections.IDictionary]) {
                foreach ($key in $Object.Keys) {
                    $fullPath = if ($Path) { "$Path.$key" } else { $key }
                    
                    if ($seenKeys.ContainsKey($key)) {
                        $duplicateKeys += $fullPath
                    } else {
                        $seenKeys[$key] = $true
                    }
                    
                    Test-DuplicateKeys -Object $Object[$key] -Path $fullPath
                }
            } elseif ($Object -is [System.Array]) {
                for ($i = 0; $i -lt $Object.Count; $i++) {
                    Test-DuplicateKeys -Object $Object[$i] -Path "$Path[$i]"
                }
            }
        }
        
        Test-DuplicateKeys -Object $YamlObject
        
        foreach ($duplicateKey in $duplicateKeys) {
            Add-ValidationResult -File $FilePath -Severity "High" -Rule "DUPLICATE_KEY" -Message "Duplicate key found: $duplicateKey" -Suggestion "Remove duplicate key or rename one of them"
        }
    }
}

# Function to fix common YAML issues
function Repair-YamlIssues {
    param(
        [string]$FilePath,
        [string]$Content
    )
    
    $fixedContent = $Content
    
    # Fix tab indentation
    $fixedContent = $fixedContent -replace "`t", "  "
    
    # Remove trailing whitespace
    $lines = $fixedContent -split "`n"
    $fixedLines = $lines | ForEach-Object { $_ -replace "\s+$", "" }
    $fixedContent = $fixedLines -join "`n"
    
    # Ensure file ends with newline
    if (-not $fixedContent.EndsWith("`n")) {
        $fixedContent += "`n"
    }
    
    return $fixedContent
}

# Main validation logic
try {
    if (-not $Quiet) {
        Write-Host "Starting YAML validation..." -ForegroundColor Cyan
        Write-Host "Target: $YamlPath" -ForegroundColor Cyan
        Write-Host "Minimum Severity: $MinimumSeverity" -ForegroundColor Cyan
        if ($FixIssues) {
            Write-Host "Auto-fix enabled" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    # Get YAML files to validate
    $yamlFiles = @()
    
    if (Test-Path $YamlPath -PathType Leaf) {
        if ($YamlPath -match "\.ya?ml$") {
            $yamlFiles += $YamlPath
        }
    } elseif (Test-Path $YamlPath -PathType Container) {
        $yamlFiles += Get-ChildItem -Path $YamlPath -Recurse -Include "*.yml", "*.yaml" | Select-Object -ExpandProperty FullName
    } else {
        Write-Error "Path not found: $YamlPath"
        exit 1
    }
    
    $totalFiles = $yamlFiles.Count
    
    if ($totalFiles -eq 0) {
        if (-not $Quiet) {
            Write-Host "No YAML files found in: $YamlPath" -ForegroundColor Yellow
        }
        exit 0
    }
    
    if (-not $Quiet) {
        Write-Host "Found $totalFiles YAML file(s) to validate" -ForegroundColor Green
        Write-Host ""
    }
    
    # Validate each YAML file
    foreach ($yamlFile in $yamlFiles) {
        $relativePath = $yamlFile -replace [regex]::Escape((Get-Location).Path + "\"), ""
        
        if (-not $Quiet) {
            Write-Host "Validating: $relativePath" -ForegroundColor Cyan
        }
        
        try {
            $content = Get-Content -Path $yamlFile -Raw -Encoding UTF8
            $isValid, $yamlObject = Test-YamlSyntax -FilePath $relativePath -Content $content
            
            if ($isValid) {
                # Validate GitHub Actions workflow if applicable
                Test-GitHubActionsWorkflow -FilePath $relativePath -YamlObject $yamlObject
                
                # Validate best practices
                Test-YamlBestPractices -FilePath $relativePath -Content $content -YamlObject $yamlObject
                
                if (-not $Quiet) {
                    Write-Host "  Syntax valid" -ForegroundColor Green
                }
            }
            
            # Auto-fix issues if requested
            if ($FixIssues -and $isValid) {
                $fixedContent = Repair-YamlIssues -FilePath $relativePath -Content $content
                if ($fixedContent -ne $content) {
                    Set-Content -Path $yamlFile -Value $fixedContent -Encoding UTF8 -NoNewline
                    if (-not $Quiet) {
                        Write-Host "  Auto-fixed common issues" -ForegroundColor Yellow
                    }
                }
            }
            
        } catch {
            Add-ValidationResult -File $relativePath -Severity "Critical" -Rule "FILE_READ_ERROR" -Message "Failed to read file: $($_.Exception.Message)"
        }
    }
    
    # Generate summary
    if (-not $Quiet) {
        Write-Host ""
        Write-Host "Validation Summary:" -ForegroundColor Cyan
        Write-Host "  Files processed: $totalFiles" -ForegroundColor White
        Write-Host "  Critical issues: $criticalIssues" -ForegroundColor $(if ($criticalIssues -gt 0) { 'Red' } else { 'Green' })
        Write-Host "  High issues: $highIssues" -ForegroundColor $(if ($highIssues -gt 0) { 'Yellow' } else { 'Green' })
        Write-Host "  Medium issues: $mediumIssues" -ForegroundColor $(if ($mediumIssues -gt 0) { 'Yellow' } else { 'Green' })
        Write-Host "  Low issues: $lowIssues" -ForegroundColor $(if ($lowIssues -gt 0) { 'Yellow' } else { 'Green' })
        Write-Host "  Total issues: $totalIssues" -ForegroundColor $(if ($totalIssues -gt 0) { 'Yellow' } else { 'Green' })
    }
    
    # Export report if requested
    if ($ExportReport) {
        $reportData = @{
            Summary = @{
                TotalFiles = $totalFiles
                TotalIssues = $totalIssues
                CriticalIssues = $criticalIssues
                HighIssues = $highIssues
                MediumIssues = $mediumIssues
                LowIssues = $lowIssues
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Issues = $validationResults
        }
        
        switch ($OutputFormat) {
            "JSON" {
                $reportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $ExportReport -Encoding UTF8
            }
            "XML" {
                $reportData | Export-Clixml -Path $ExportReport
            }
            "HTML" {
                $htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>YAML Validation Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #007acc; color: white; padding: 15px; border-radius: 5px; }
        .summary { background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .issue { margin: 10px 0; padding: 10px; border-left: 4px solid #ccc; }
        .critical { border-left-color: #dc3545; }
        .high { border-left-color: #fd7e14; }
        .medium { border-left-color: #ffc107; }
        .low { border-left-color: #28a745; }
        .file { font-weight: bold; color: #007acc; }
        .rule { font-family: monospace; background-color: #e9ecef; padding: 2px 4px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>YAML Validation Report</h1>
        <p>Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
    </div>
    
    <div class="summary">
        <h2>Summary</h2>
        <p><strong>Files processed:</strong> $totalFiles</p>
        <p><strong>Total issues:</strong> $totalIssues</p>
        <p><strong>Critical:</strong> $criticalIssues | <strong>High:</strong> $highIssues | <strong>Medium:</strong> $mediumIssues | <strong>Low:</strong> $lowIssues</p>
    </div>
    
    <h2>Issues</h2>
"@
                
                foreach ($issue in $validationResults) {
                    $severityClass = $issue.Severity.ToLower()
                    $htmlReport += @"
    <div class="issue $severityClass">
        <div class="file">$($issue.File)</div>
        <div><span class="rule">$($issue.Rule)</span> - $($issue.Message)</div>
        $(if ($issue.Line) { "<div>Line: $($issue.Line)</div>" })
        $(if ($issue.Suggestion) { "<div><strong>Suggestion:</strong> $($issue.Suggestion)</div>" })
    </div>
"@
                }
                
                $htmlReport += @"
</body>
</html>
"@
                $htmlReport | Out-File -FilePath $ExportReport -Encoding UTF8
            }
        }
        
        if (-not $Quiet) {
            Write-Host "Report exported to: $ExportReport" -ForegroundColor Green
        }
    }
    
    # Display issues in console if not quiet
    if (-not $Quiet -and $validationResults.Count -gt 0) {
        Write-Host ""
        Write-Host "Issues Found:" -ForegroundColor Cyan
        
        foreach ($issue in $validationResults) {
            $color = switch ($issue.Severity) {
                "Critical" { "Red" }
                "High" { "Yellow" }
                "Medium" { "Yellow" }
                "Low" { "Green" }
                default { "White" }
            }
            
            Write-Host "  [$($issue.Severity)] $($issue.File): $($issue.Message)" -ForegroundColor $color
            if ($issue.Suggestion) {
                Write-Host "    Suggestion: $($issue.Suggestion)" -ForegroundColor Gray
            }
        }
    }
    
    # Exit with appropriate code
    if ($totalIssues -gt 0 -and -not $NoFailOnIssues) {
        if (-not $Quiet) {
            Write-Host ""
            Write-Host "Validation completed with issues found" -ForegroundColor Red
        }
        exit 1
    } else {
        if (-not $Quiet) {
            Write-Host ""
            Write-Host "All YAML files validated successfully" -ForegroundColor Green
        }
        exit 0
    }
    
} catch {
    Write-Error "Validation failed: $($_.Exception.Message)"
    exit 1
}