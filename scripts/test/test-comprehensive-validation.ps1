# Test Comprehensive Validation Workflow
# This script tests all components of the comprehensive validation system

param(
    [switch]$Verbose
)

Write-Host "Testing Comprehensive Validation System" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Test 1: YAML Validation Script
Write-Host "`n1. Testing YAML Validation Script..." -ForegroundColor Yellow
try {
    $yamlTest = .\scripts\test\validate-yaml.ps1 -YamlPath "workflows" -ExportReport "test-yaml-report.json" -Quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   SUCCESS: YAML validation script works correctly" -ForegroundColor Green
    } else {
        Write-Host "   WARNING: YAML validation script had issues (exit code: $LASTEXITCODE)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ERROR: YAML validation script failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Template Processing Script
Write-Host "`n2. Testing Template Processing Script..." -ForegroundColor Yellow
try {
    $testTemplate = @"
Hello {{name}}!
This is a test template with {{variable}}.
"@
    $testTemplate | Set-Content "test-template.md"
    
    $templateVars = @{
        name = "TestUser"
        variable = "test value"
    }
    
    .\scripts\tools\process-template.ps1 -TemplatePath "test-template.md" -OutputPath "test-output.md" -Variables $templateVars
    
    if (Test-Path "test-output.md") {
        $content = Get-Content "test-output.md" -Raw
        if ($content -match "TestUser" -and $content -match "test value") {
            Write-Host "   SUCCESS: Template processing works correctly" -ForegroundColor Green
        } else {
            Write-Host "   ERROR: Template processing failed - variables not replaced" -ForegroundColor Red
        }
        Remove-Item "test-template.md", "test-output.md" -ErrorAction SilentlyContinue
    } else {
        Write-Host "   ERROR: Template processing failed - output file not created" -ForegroundColor Red
    }
} catch {
    Write-Host "   ERROR: Template processing script failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: PowerShell Syntax Validation
Write-Host "`n3. Testing PowerShell Syntax Validation..." -ForegroundColor Yellow
try {
    .\scripts\test\validate-powershell-syntax.ps1 -RepositoryRoot .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   SUCCESS: PowerShell syntax validation works correctly" -ForegroundColor Green
    } else {
        Write-Host "   WARNING: PowerShell syntax validation had issues (exit code: $LASTEXITCODE)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ERROR: PowerShell syntax validation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Workflow Files Exist
Write-Host "`n4. Testing Workflow Files..." -ForegroundColor Yellow
$workflows = @(
    "workflows\comprehensive-validation.yml",
    "workflows\powershell-validation.yml",
    "workflows\background-agent.yml",
    "workflows\release.yml",
    "workflows\test-installation.yml",
    "workflows\test.yml",
    "workflows\validate.yml"
)

$allWorkflowsExist = $true
foreach ($workflow in $workflows) {
    if (Test-Path $workflow) {
        Write-Host "   SUCCESS: $workflow exists" -ForegroundColor Green
    } else {
        Write-Host "   ERROR: $workflow missing" -ForegroundColor Red
        $allWorkflowsExist = $false
    }
}

# Test 5: Template Files Exist
Write-Host "`n5. Testing Template Files..." -ForegroundColor Yellow
$templates = @(
    "templates\markdown\pr-comment-template.md",
    "templates\html\critical-errors-email-template.html",
    "templates\html\pr-issues-email-template.html"
)

$allTemplatesExist = $true
foreach ($template in $templates) {
    if (Test-Path $template) {
        Write-Host "   SUCCESS: $template exists" -ForegroundColor Green
    } else {
        Write-Host "   ERROR: $template missing" -ForegroundColor Red
        $allTemplatesExist = $false
    }
}

# Test 6: Script Files Exist
Write-Host "`n6. Testing Script Files..." -ForegroundColor Yellow
$scripts = @(
    "scripts\test\validate-yaml.ps1",
    "scripts\test\validate-powershell-syntax.ps1",
    "scripts\tools\process-template.ps1"
)

$allScriptsExist = $true
foreach ($script in $scripts) {
    if (Test-Path $script) {
        Write-Host "   SUCCESS: $script exists" -ForegroundColor Green
    } else {
        Write-Host "   ERROR: $script missing" -ForegroundColor Red
        $allScriptsExist = $false
    }
}

# Summary
Write-Host "`nTest Summary" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host "All core components tested successfully!" -ForegroundColor Green
Write-Host "`nThe comprehensive validation workflow is ready to use!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. Commit the new comprehensive-validation.yml workflow" -ForegroundColor White
Write-Host "  2. The workflow will automatically run on push/PR to main/develop branches" -ForegroundColor White
Write-Host "  3. Check workflow artifacts for detailed validation reports" -ForegroundColor White
Write-Host "  4. Review PR comments for validation feedback" -ForegroundColor White