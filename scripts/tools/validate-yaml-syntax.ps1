# YAML Syntax Validator
# Validates YAML syntax for all workflow files

param(
    [string]$Path = ".github/workflows",
    [switch]$Verbose
)

try {
    # Import required module
    Import-Module powershell-yaml -ErrorAction Stop
} catch {
    Write-Host "Installing powershell-yaml module..." -ForegroundColor Yellow
    Install-Module -Name powershell-yaml -Force -Scope CurrentUser
    Import-Module powershell-yaml
}

$yamlFiles = Get-ChildItem -Path $Path -Filter "*.yml" -Recurse
$validCount = 0
$invalidCount = 0

Write-Host "Validating YAML files in: $Path" -ForegroundColor Cyan
Write-Host "Found $($yamlFiles.Count) YAML files" -ForegroundColor Cyan
Write-Host ""

foreach ($file in $yamlFiles) {
    try {
        $content = Get-Content $file.FullName -Raw
        $yaml = ConvertFrom-Yaml $content
        
        if ($Verbose) {
            Write-Host "[OK] $($file.Name) - Valid YAML syntax" -ForegroundColor Green
            Write-Host "  - Keys: $($yaml.Keys -join ', ')" -ForegroundColor Gray
        } else {
            Write-Host "[OK] $($file.Name)" -ForegroundColor Green
        }
        $validCount++
    } catch {
        Write-Host "[ERROR] $($file.Name) - Invalid YAML syntax" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $invalidCount++
    }
}

Write-Host ""
Write-Host "Validation Summary:" -ForegroundColor Cyan
Write-Host "  Valid files: $validCount" -ForegroundColor Green
Write-Host "  Invalid files: $invalidCount" -ForegroundColor $(if ($invalidCount -gt 0) { 'Red' } else { 'Green' })

if ($invalidCount -gt 0) {
    exit 1
} else {
    Write-Host "All YAML files are valid!" -ForegroundColor Green
    exit 0
}
