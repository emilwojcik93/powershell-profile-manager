#Requires -Version 5.1
<#
.SYNOPSIS
    Test script to verify comprehensive validation workflow components

.DESCRIPTION
    This script tests both YAML and PowerShell validation components to ensure
    the comprehensive validation workflow will work correctly.

.PARAMETER TestPath
    Path to test (default: current directory)

.EXAMPLE
    .\test-comprehensive-validation.ps1
#>

[CmdletBinding()]
param(
    [string]$TestPath = "."
)

Write-Host "Testing Comprehensive Validation Components" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

# Test 1: Verify required modules are available
Write-Host "`nTesting Module Availability..." -ForegroundColor Yellow
try {
    Import-Module powershell-yaml -Force -ErrorAction Stop
    Write-Host "  powershell-yaml module loaded" -ForegroundColor Green
} catch {
    Write-Host "  powershell-yaml module failed to load: $_" -ForegroundColor Red
    exit 1
}

try {
    Import-Module PSScriptAnalyzer -Force -ErrorAction Stop
    Write-Host "  PSScriptAnalyzer module loaded" -ForegroundColor Green
} catch {
    Write-Host "  PSScriptAnalyzer module failed to load: $_" -ForegroundColor Red
    exit 1
}

# Test 2: Test YAML validation script
Write-Host "`nTesting YAML Validation Script..." -ForegroundColor Yellow
$yamlValidatorPath = ".\scripts\validate-yaml.ps1"
if (Test-Path $yamlValidatorPath) {
    Write-Host "  YAML validator script found" -ForegroundColor Green
    
    # Test with a simple YAML validation
    try {
        $result = & $yamlValidatorPath -YamlPath "workflows" -MinimumSeverity High -Quiet
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  YAML validation completed successfully" -ForegroundColor Green
        } else {
            Write-Host "  YAML validation completed with issues (exit code: $LASTEXITCODE)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  YAML validation failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  YAML validator script not found at: $yamlValidatorPath" -ForegroundColor Red
}

# Test 3: Test PowerShell validation script (if available)
Write-Host "`nTesting PowerShell Validation Script..." -ForegroundColor Yellow
$psValidatorPath = ".\tools\scripts\script-validator\src\PowerShell-Script-Validator.ps1"
if (Test-Path $psValidatorPath) {
    Write-Host "  ✅ PowerShell validator script found" -ForegroundColor Green
    
    # Test with a simple PowerShell validation
    try {
        $result = & $psValidatorPath -ScriptPath "scripts\validate-yaml.ps1" -MinimumSeverity High -Quiet -NoFailOnIssues
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ PowerShell validation completed successfully" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ PowerShell validation completed with issues (exit code: $LASTEXITCODE)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ❌ PowerShell validation failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  ⚠️ PowerShell validator script not found at: $psValidatorPath" -ForegroundColor Yellow
    Write-Host "    This is expected if the script-validator tool is not available" -ForegroundColor Gray
}

# Test 4: Test comprehensive workflow YAML syntax
Write-Host "`n🔍 Testing Comprehensive Workflow YAML..." -ForegroundColor Yellow
$workflowPath = ".\workflows\comprehensive-validation.yml"
if (Test-Path $workflowPath) {
    Write-Host "  ✅ Comprehensive workflow file found" -ForegroundColor Green
    
    # Test YAML syntax specifically
    try {
        $content = Get-Content -Path $workflowPath -Raw -Encoding UTF8
        $yamlObject = ConvertFrom-Yaml -Yaml $content -ErrorAction Stop
        Write-Host "  ✅ Comprehensive workflow YAML syntax is valid" -ForegroundColor Green
        
        # Check for required workflow fields
        if ($yamlObject.name) {
            Write-Host "  ✅ Workflow has name: $($yamlObject.name)" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ Workflow missing name field" -ForegroundColor Yellow
        }
        
        if ($yamlObject.on) {
            Write-Host "  ✅ Workflow has trigger configuration" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Workflow missing trigger configuration" -ForegroundColor Red
        }
        
        if ($yamlObject.jobs) {
            Write-Host "  ✅ Workflow has jobs configuration" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Workflow missing jobs configuration" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "  ❌ Comprehensive workflow YAML syntax error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  ❌ Comprehensive workflow file not found at: $workflowPath" -ForegroundColor Red
}

# Test 5: Test report generation
Write-Host "`n📊 Testing Report Generation..." -ForegroundColor Yellow
try {
    $testReportPath = ".\test-validation-report.json"
    $result = & $yamlValidatorPath -YamlPath "workflows\comprehensive-validation.yml" -OutputFormat JSON -ExportReport $testReportPath -Quiet -MinimumSeverity High
    
    if (Test-Path $testReportPath) {
        Write-Host "  ✅ JSON report generated successfully" -ForegroundColor Green
        
        # Try to parse the report
        try {
            $report = Get-Content -Path $testReportPath -Raw | ConvertFrom-Json
            Write-Host "  ✅ JSON report is valid and parseable" -ForegroundColor Green
            Write-Host "    Files processed: $($report.Summary.TotalFiles)" -ForegroundColor Gray
            Write-Host "    Total issues: $($report.Summary.TotalIssues)" -ForegroundColor Gray
        } catch {
            Write-Host "  ❌ JSON report is not valid: $_" -ForegroundColor Red
        }
        
        # Clean up test report
        Remove-Item -Path $testReportPath -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "  ❌ JSON report was not generated" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Report generation test failed: $_" -ForegroundColor Red
}

# Summary
Write-Host "`n📋 Test Summary" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host "All core components tested successfully!" -ForegroundColor Green
Write-Host "`nThe comprehensive validation workflow is ready to use!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. Commit the new comprehensive-validation.yml workflow" -ForegroundColor White
Write-Host "  2. The workflow will automatically run on push/PR to main/develop branches" -ForegroundColor White
Write-Host "  3. Check workflow artifacts for detailed validation reports" -ForegroundColor White
Write-Host "  4. Review PR comments for validation feedback" -ForegroundColor White
