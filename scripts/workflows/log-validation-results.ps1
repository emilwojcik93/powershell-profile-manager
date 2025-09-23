# Log Validation Results
# This script logs validation results to console

param(
    [string]$EventType = "commit",
    [int]$CriticalErrors = 0,
    [int]$HighErrors = 0,
    [int]$TotalIssues = 0,
    [string]$WorkflowRunUrl = "",
    [string]$CommitUrl = "",
    [string]$PrUrl = ""
)

if ($EventType -eq "commit" -and $CriticalErrors -gt 0) {
    Write-Host "Critical errors detected in commit:" -ForegroundColor Red
    Write-Host "  - PowerShell Critical Errors: $CriticalErrors" -ForegroundColor Red
    Write-Host "  - Workflow Run: $WorkflowRunUrl" -ForegroundColor Cyan
    Write-Host "  - Commit: $CommitUrl" -ForegroundColor Cyan
    Write-Host "Note: GitHub will automatically send workflow failure notifications via email" -ForegroundColor Yellow
}
elseif ($EventType -eq "pr" -and $HighErrors -gt 0) {
    Write-Host "High priority issues detected in PR:" -ForegroundColor Yellow
    Write-Host "  - PowerShell High Errors: $HighErrors" -ForegroundColor Yellow
    Write-Host "  - PR: $PrUrl" -ForegroundColor Cyan
    Write-Host "  - Workflow Run: $WorkflowRunUrl" -ForegroundColor Cyan
    Write-Host "Note: GitHub will automatically send workflow notifications via email" -ForegroundColor Yellow
}
else {
    Write-Host "No critical issues detected." -ForegroundColor Green
}
