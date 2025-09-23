#Requires -Version 5.1

<#
.SYNOPSIS
    Attempts to auto-fix detected issues

.DESCRIPTION
    This script attempts to automatically fix common issues detected by the background agent.
    It can fix path references, syntax errors, and other common problems.

.PARAMETER RepositoryRoot
    The root directory of the repository

.PARAMETER MaxAttempts
    Maximum number of fix attempts before giving up

.EXAMPLE
    .\auto-fix-issues.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location),
    
    [Parameter(Mandatory = $false)]
    [int]$MaxAttempts = 3
)

$ErrorActionPreference = 'Continue'
$global:AutoFixLog = @()
$global:FixesApplied = 0

function Write-AutoFixLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Fix')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    $global:AutoFixLog += $logEntry
    
    $color = switch ($Level) {
        'Error' {
            'Red' 
        }
        'Warning' {
            'Yellow' 
        }
        'Success' {
            'Green' 
        }
        'Fix' {
            'Magenta' 
        }
        default {
            'White' 
        }
    }
    
    Write-Host $logEntry -ForegroundColor $color
}

function Test-ScriptSyntax {
    param([string]$ScriptPath)
    
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $ScriptPath -Raw), [ref]$null)
        return $true
    } catch {
        return $false
    }
}

function Fix-PathReferences {
    Write-AutoFixLog 'Checking for incorrect path references...' 'Info'
    
    $fixesApplied = 0
    
    # Common path fixes
    $pathFixes = @{
        'scripts\\install\.ps1'     = 'scripts\\deploy\\install\.ps1'
        'scripts\\uninstall\.ps1'   = 'scripts\\deploy\\uninstall\.ps1'
        'scripts\\release\.ps1'     = 'scripts\\deploy\\release\.ps1'
        '"scripts\\install\.ps1"'   = '"scripts\\deploy\\install\.ps1"'
        '"scripts\\uninstall\.ps1"' = '"scripts\\deploy\\uninstall\.ps1"'
        '"scripts\\release\.ps1"'   = '"scripts\\deploy\\release\.ps1"'
    }
    
    # Find all PowerShell files
    $psFiles = Get-ChildItem -Path $RepositoryRoot -Recurse -Include '*.ps1', '*.psm1', '*.psd1' | Where-Object { $_.FullName -notlike '*\.git\*' }
    
    foreach ($file in $psFiles) {
        $content = Get-Content $file.FullName -Raw
        $originalContent = $content
        
        foreach ($oldPath in $pathFixes.Keys) {
            $newPath = $pathFixes[$oldPath]
            if ($content -match $oldPath) {
                $content = $content -replace $oldPath, $newPath
                Write-AutoFixLog "Fixed path reference in $($file.Name): $oldPath -> $newPath" 'Fix'
                $fixesApplied++
            }
        }
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
            Write-AutoFixLog "Updated file: $($file.Name)" 'Success'
        }
    }
    
    return $fixesApplied
}

function Fix-SyntaxErrors {
    Write-AutoFixLog 'Checking for syntax errors...' 'Info'
    
    $fixesApplied = 0
    
    # Find all PowerShell files
    $psFiles = Get-ChildItem -Path $RepositoryRoot -Recurse -Include '*.ps1', '*.psm1' | Where-Object { $_.FullName -notlike '*\.git\*' }
    
    foreach ($file in $psFiles) {
        if (-not (Test-ScriptSyntax $file.FullName)) {
            Write-AutoFixLog "Syntax error detected in: $($file.Name)" 'Warning'
            
            # Try to fix common syntax issues
            $content = Get-Content $file.FullName -Raw
            $originalContent = $content
            
            # Fix common issues
            $content = $content -replace '\$\{([^}]+)\}', '$${$1}'  # Fix variable syntax
            $content = $content -replace '(\w+):\s*([^=])', '$$1: $2'  # Fix variable declarations
            
            if ($content -ne $originalContent) {
                Set-Content -Path $file.FullName -Value $content -Encoding UTF8
                Write-AutoFixLog "Applied syntax fixes to: $($file.Name)" 'Fix'
                $fixesApplied++
            }
        }
    }
    
    return $fixesApplied
}

function Fix-WorkflowIssues {
    Write-AutoFixLog 'Checking for workflow issues...' 'Info'
    
    $fixesApplied = 0
    
    # Find all workflow files
    $workflowFiles = Get-ChildItem -Path (Join-Path $RepositoryRoot '.github\workflows') -Include '*.yml', '*.yaml'
    
    foreach ($file in $workflowFiles) {
        $content = Get-Content $file.FullName -Raw
        $originalContent = $content
        
        # Fix common workflow issues
        $content = $content -replace 'workflows"', '.github\\workflows"'
        $content = $content -replace 'steps\.([^.]+)\.outputs\.([^.]+)', 'steps.$1.outputs.$2'
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
            Write-AutoFixLog "Fixed workflow issues in: $($file.Name)" 'Fix'
            $fixesApplied++
        }
    }
    
    return $fixesApplied
}

function Fix-SpecificErrors {
    param([array]$Errors)
    
    Write-AutoFixLog 'Analyzing specific errors for targeted fixes...' 'Info'
    $fixesApplied = 0
    
    foreach ($errorLog in $Errors) {
        Write-AutoFixLog "Analyzing error: $errorLog" 'Info'
        
        # Fix path-related errors
        if ($errorLog -match 'scripts\\install\.ps1|scripts\\uninstall\.ps1|scripts\\release\.ps1') {
            Write-AutoFixLog 'Detected path reference error, applying path fixes...' 'Fix'
            $fixesApplied += Fix-PathReferences
        }
        
        # Fix syntax errors
        if ($errorLog -match 'syntax|parse|token') {
            Write-AutoFixLog 'Detected syntax error, applying syntax fixes...' 'Fix'
            $fixesApplied += Fix-SyntaxErrors
        }
        
        # Fix workflow errors
        if ($errorLog -match 'workflow|yaml|yml') {
            Write-AutoFixLog 'Detected workflow error, applying workflow fixes...' 'Fix'
            $fixesApplied += Fix-WorkflowIssues
        }
    }
    
    return $fixesApplied
}

function Test-Fixes {
    Write-AutoFixLog 'Testing fixes by running validation scripts...' 'Info'
    
    $testScripts = @(
        'validate-repository-structure.ps1',
        'validate-powershell-syntax.ps1'
    )
    
    $allPassed = $true
    
    foreach ($script in $testScripts) {
        $scriptPath = Join-Path (Join-Path $RepositoryRoot 'scripts\test') $script
        if (Test-Path $scriptPath) {
            try {
                $result = & $scriptPath -RepositoryRoot $RepositoryRoot 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-AutoFixLog "$script passed" 'Success'
                } else {
                    Write-AutoFixLog "$script failed with exit code: $LASTEXITCODE" 'Warning'
                    $allPassed = $false
                }
            } catch {
                Write-AutoFixLog "$script exception: $($_.Exception.Message)" 'Error'
                $allPassed = $false
            }
        }
    }
    
    return $allPassed
}

# Load error information from background agent
$errorFile = Join-Path $RepositoryRoot 'agent-errors.json'
$agentErrors = @()

if (Test-Path $errorFile) {
    try {
        $errorInfo = Get-Content $errorFile -Raw | ConvertFrom-Json
        $agentErrors = $errorInfo.Errors
        Write-AutoFixLog "Loaded $($agentErrors.Count) errors from background agent" 'Info'
        Write-AutoFixLog "Agent mode: $($errorInfo.AgentMode)" 'Info'
        Write-AutoFixLog "Error timestamp: $($errorInfo.Timestamp)" 'Info'
    } catch {
        Write-AutoFixLog "Failed to load error information: $($_.Exception.Message)" 'Warning'
    }
} else {
    Write-AutoFixLog 'No error file found, will scan for common issues' 'Info'
}

# Main auto-fix process
Write-AutoFixLog 'Starting auto-fix process...' 'Info'
Write-AutoFixLog "Repository Root: $RepositoryRoot" 'Info'
Write-AutoFixLog "Max Attempts: $MaxAttempts" 'Info'

$attempt = 1
$totalFixes = 0

do {
    Write-AutoFixLog "=== Auto-Fix Attempt $attempt ===" 'Info'
    
    $fixesThisRound = 0
    
    # Apply targeted fixes based on specific errors
    if ($agentErrors.Count -gt 0) {
        $fixesThisRound += Fix-SpecificErrors -Errors $agentErrors
    } else {
        # Apply general fixes if no specific errors available
        $fixesThisRound += Fix-PathReferences
        $fixesThisRound += Fix-SyntaxErrors
        $fixesThisRound += Fix-WorkflowIssues
    }
    
    $totalFixes += $fixesThisRound
    
    if ($fixesThisRound -gt 0) {
        Write-AutoFixLog "Applied $fixesThisRound fixes in attempt $attempt" 'Success'
        
        # Test if fixes resolved issues
        if (Test-Fixes) {
            Write-AutoFixLog 'All tests now pass! Auto-fix successful.' 'Success'
            break
        } else {
            Write-AutoFixLog 'Some tests still fail, will retry...' 'Warning'
        }
    } else {
        Write-AutoFixLog "No fixes applied in attempt $attempt" 'Info'
        break
    }
    
    $attempt++
} while ($attempt -le $MaxAttempts)

# Final summary
Write-AutoFixLog '=== Auto-Fix Summary ===' 'Info'
Write-AutoFixLog "Total fixes applied: $totalFixes" 'Info'
Write-AutoFixLog "Attempts made: $($attempt - 1)" 'Info'

if ($totalFixes -gt 0) {
    Write-AutoFixLog 'Auto-fix process completed successfully!' 'Success'
    exit 0
} else {
    Write-AutoFixLog 'No auto-fixable issues found or manual intervention required' 'Warning'
    exit 1
}
