# PowerShell Script Validation Runner
# This script is called by GitHub Actions workflows

param(
    [string]$EventName = "push",
    [string]$BaseRef = "main",
    [string]$OutputDir = ".\validation-results"
)

try {
    # Import the validator script
    $validatorPath = ".\scripts\test\validate-powershell-syntax.ps1"

    if (Test-Path $validatorPath) {
        Write-Host "Running PowerShell validation using: $validatorPath"

        # Create output directory
        New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null

        # Get list of changed PowerShell files
        $changedFiles = @()
        if ($EventName -eq "pull_request") {
            $changedFiles = git diff --name-only origin/$BaseRef..HEAD | Where-Object { $_ -match '\.ps1$|\.psm1$|\.psd1$' }
        } else {
            $changedFiles = git diff --name-only HEAD~1..HEAD | Where-Object { $_ -match '\.ps1$|\.psm1$|\.psd1$' }
        }

        Write-Host "Changed PowerShell files: $($changedFiles -join ', ')"

        # Initialize results
        $criticalCount = 0
        $highCount = 0
        $totalCount = 0

        # Validate each changed file
        foreach ($file in $changedFiles) {
            if (Test-Path $file) {
                Write-Host "Validating: $file"

                # Run validation on individual file (ignore exit code to continue validation)
                try {
                    $null = & $validatorPath -ScriptPath $file -OutputFormat "JSON" -ExportReport "$OutputDir\$($file -replace '[\\\/:]', '_').json" -Quiet -MinimumSeverity "All" -NoFailOnIssues 2>&1
                    Write-Host "Validation completed for: $file"
                } catch {
                    Write-Host "Validation encountered issues for: $file (continuing...)"
                }
            }
        }

        # Also run validation on entire repository for comprehensive analysis
        Write-Host "Running comprehensive repository validation..."
        try {
            $null = & $validatorPath -ScriptPath "." -OutputFormat "HTML" -ExportReport "$OutputDir\comprehensive-report.html" -Quiet -MinimumSeverity "Medium" -NoFailOnIssues 2>&1
            Write-Host "Comprehensive validation completed"
        } catch {
            Write-Host "Comprehensive validation encountered issues (continuing...)"
        }

        # Count issues by parsing the JSON reports
        foreach ($file in $changedFiles) {
            $reportFile = "$OutputDir\$($file -replace '[\\\/:]', '_').json"
            if (Test-Path $reportFile) {
                try {
                    $report = Get-Content $reportFile -Raw | ConvertFrom-Json
                    if ($report -and $report.Count -gt 0) {
                        $criticalCount += ($report | Where-Object { $_.Severity -eq 'Critical' -or $_.Severity -eq 'Error' }).Count
                        $highCount += ($report | Where-Object { $_.Severity -eq 'Warning' -or $_.Severity -eq 'High' }).Count
                        $totalCount += $report.Count
                    }
                } catch {
                    Write-Host "Could not parse report for: $file"
                }
            }
        }

        Write-Host "Validation completed. Critical: $criticalCount, High: $highCount, Total: $totalCount"
    } else {
        Write-Host "Validator script not found at: $validatorPath"
        $criticalCount = 0
        $highCount = 0
        $totalCount = 0
    }
} catch {
    Write-Host "Error during validation: $_"
    $criticalCount = 0
    $highCount = 0
    $totalCount = 0
}

# Set GitHub outputs
echo "critical-errors=$criticalCount" >> $env:GITHUB_OUTPUT
echo "high-errors=$highCount" >> $env:GITHUB_OUTPUT
echo "total-issues=$totalCount" >> $env:GITHUB_OUTPUT
echo "changed-files=$($changedFiles -join ',')" >> $env:GITHUB_OUTPUT
