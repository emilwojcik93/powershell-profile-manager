# Comprehensive Script and YAML Validation Runner
# This script is called by GitHub Actions workflows

param(
    [string]$EventName = "push",
    [string]$BaseRef = "main",
    [string]$OutputDir = ".\validation-results"
)

# PowerShell Validation
try {
    $validatorPath = ".\scripts\test\validate-powershell-syntax.ps1"
    $psCriticalCount = 0
    $psHighCount = 0
    $psTotalCount = 0
    $changedPsFiles = @()

    if (Test-Path $validatorPath) {
        Write-Host "Running PowerShell validation using: $validatorPath"
        New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null

        # Get list of changed PowerShell files
        if ($EventName -eq "pull_request") {
            $changedPsFiles = git diff --name-only origin/$BaseRef..HEAD | Where-Object { $_ -match '\.ps1$|\.psm1$|\.psd1$' }
        } else {
            $changedPsFiles = git diff --name-only HEAD~1..HEAD | Where-Object { $_ -match '\.ps1$|\.psm1$|\.psd1$' }
        }

        Write-Host "Changed PowerShell files: $($changedPsFiles -join ', ')"

        # Validate each changed PowerShell file
        foreach ($file in $changedPsFiles) {
            if (Test-Path $file) {
                Write-Host "Validating PowerShell: $file"
                try {
                    $null = & $validatorPath -ScriptPath $file -OutputFormat "JSON" -ExportReport "$OutputDir\ps_$($file -replace '[\\\/:]', '_').json" -Quiet -MinimumSeverity "All" -NoFailOnIssues 2>&1
                    Write-Host "PowerShell validation completed for: $file"
                } catch {
                    Write-Host "PowerShell validation encountered issues for: $file (continuing...)"
                }
            }
        }

        # Run comprehensive PowerShell validation
        Write-Host "Running comprehensive PowerShell repository validation..."
        try {
            $null = & $validatorPath -ScriptPath "." -OutputFormat "HTML" -ExportReport "$OutputDir\ps-comprehensive-report.html" -Quiet -MinimumSeverity "Medium" -NoFailOnIssues 2>&1
            Write-Host "Comprehensive PowerShell validation completed"
        } catch {
            Write-Host "Comprehensive PowerShell validation encountered issues (continuing...)"
        }

        # Count PowerShell issues
        foreach ($file in $changedPsFiles) {
            $reportFile = "$OutputDir\ps_$($file -replace '[\\\/:]', '_').json"
            if (Test-Path $reportFile) {
                try {
                    $report = Get-Content $reportFile -Raw | ConvertFrom-Json
                    if ($report -and $report.Count -gt 0) {
                        $psCriticalCount += ($report | Where-Object { $_.Severity -eq 'Critical' -or $_.Severity -eq 'Error' }).Count
                        $psHighCount += ($report | Where-Object { $_.Severity -eq 'Warning' -or $_.Severity -eq 'High' }).Count
                        $psTotalCount += $report.Count
                    }
                } catch {
                    Write-Host "Could not parse PowerShell report for: $file"
                }
            }
        }

        Write-Host "PowerShell validation completed. Critical: $psCriticalCount, High: $psHighCount, Total: $psTotalCount"
    } else {
        Write-Host "PowerShell validator script not found at: $validatorPath"
    }
} catch {
    Write-Host "Error during PowerShell validation: $_"
}

# YAML Validation
try {
    $yamlValidatorPath = ".\scripts\test\validate-yaml.ps1"
    $yamlCriticalCount = 0
    $yamlHighCount = 0
    $yamlTotalCount = 0
    $changedYamlFiles = @()

    if (Test-Path $yamlValidatorPath) {
        Write-Host "Running YAML validation using: $yamlValidatorPath"

        # Get list of changed YAML files
        if ($EventName -eq "pull_request") {
            $changedYamlFiles = git diff --name-only origin/$BaseRef..HEAD | Where-Object { $_ -match '\.ya?ml$' }
        } else {
            $changedYamlFiles = git diff --name-only HEAD~1..HEAD | Where-Object { $_ -match '\.ya?ml$' }
        }

        Write-Host "Changed YAML files: $($changedYamlFiles -join ', ')"

        # Validate each changed YAML file
        foreach ($file in $changedYamlFiles) {
            if (Test-Path $file) {
                Write-Host "Validating YAML: $file"
                try {
                    $null = & $yamlValidatorPath -YamlPath $file -OutputFormat "JSON" -ExportReport "$OutputDir\yaml_$($file -replace '[\\\/:]', '_').json" -Quiet -MinimumSeverity "All" -NoFailOnIssues 2>&1
                    Write-Host "YAML validation completed for: $file"
                } catch {
                    Write-Host "YAML validation encountered issues for: $file (continuing...)"
                }
            }
        }

        # Run comprehensive YAML validation
        Write-Host "Running comprehensive YAML repository validation..."
        try {
            $null = & $yamlValidatorPath -YamlPath ".github\workflows" -OutputFormat "HTML" -ExportReport "$OutputDir\yaml-comprehensive-report.html" -Quiet -MinimumSeverity "Medium" -NoFailOnIssues 2>&1
            Write-Host "Comprehensive YAML validation completed"
        } catch {
            Write-Host "Comprehensive YAML validation encountered issues (continuing...)"
        }

        # Count YAML issues
        foreach ($file in $changedYamlFiles) {
            $reportFile = "$OutputDir\yaml_$($file -replace '[\\\/:]', '_').json"
            if (Test-Path $reportFile) {
                try {
                    $report = Get-Content $reportFile -Raw | ConvertFrom-Json
                    if ($report -and $report.Issues -and $report.Issues.Count -gt 0) {
                        $yamlCriticalCount += ($report.Issues | Where-Object { $_.Severity -eq 'Critical' }).Count
                        $yamlHighCount += ($report.Issues | Where-Object { $_.Severity -eq 'High' }).Count
                        $yamlTotalCount += $report.Issues.Count
                    }
                } catch {
                    Write-Host "Could not parse YAML report for: $file"
                }
            }
        }

        Write-Host "YAML validation completed. Critical: $yamlCriticalCount, High: $yamlHighCount, Total: $yamlTotalCount"
    } else {
        Write-Host "YAML validator script not found at: $yamlValidatorPath"
    }
} catch {
    Write-Host "Error during YAML validation: $_"
}

# Set GitHub outputs
echo "ps-critical-errors=$psCriticalCount" >> $env:GITHUB_OUTPUT
echo "ps-high-errors=$psHighCount" >> $env:GITHUB_OUTPUT
echo "ps-total-issues=$psTotalCount" >> $env:GITHUB_OUTPUT
echo "ps-changed-files=$($changedPsFiles -join ',')" >> $env:GITHUB_OUTPUT
echo "yaml-critical-errors=$yamlCriticalCount" >> $env:GITHUB_OUTPUT
echo "yaml-high-errors=$yamlHighCount" >> $env:GITHUB_OUTPUT
echo "yaml-total-issues=$yamlTotalCount" >> $env:GITHUB_OUTPUT
echo "yaml-changed-files=$($changedYamlFiles -join ',')" >> $env:GITHUB_OUTPUT
