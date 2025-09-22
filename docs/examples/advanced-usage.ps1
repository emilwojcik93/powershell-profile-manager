# PowerShell Profile Manager - Advanced Usage Examples
# This file demonstrates advanced usage patterns and customization

# Example 1: Custom Module Configuration
Write-Host "=== Custom Module Configuration ===" -ForegroundColor Cyan

# Configure VideoCompressor with custom settings
if (Get-Command Set-ExampleConfig -ErrorAction SilentlyContinue) {
    Write-Host "Configuring ExampleModule..." -ForegroundColor Yellow
    
    # Set custom configuration
    Set-ExampleConfig -LogLevel "Debug" -EnableFeature1 $true -EnableFeature2 $false
    
    # Get updated configuration
    $config = Get-ExampleInfo
    Write-Host "Updated configuration:" -ForegroundColor Green
    $config.Configuration | Format-List
}

# Example 2: Dynamic Module Loading
Write-Host "`n=== Dynamic Module Loading ===" -ForegroundColor Cyan

# Load modules based on conditions
$currentUser = $env:USERNAME
$computerName = $env:COMPUTERNAME

Write-Host "Current user: $currentUser" -ForegroundColor White
Write-Host "Computer name: $computerName" -ForegroundColor White

# Load modules based on user
if ($currentUser -like "*admin*" -or $currentUser -like "*dev*") {
    Write-Host "Loading development modules for user: $currentUser" -ForegroundColor Yellow
    # Load-ProfileModule "DevelopmentModule"
}

# Load modules based on computer
if ($computerName -like "*DEV*" -or $computerName -like "*TEST*") {
    Write-Host "Loading test modules for computer: $computerName" -ForegroundColor Yellow
    # Load-ProfileModule "TestModule"
}

# Example 3: Module Health Monitoring
Write-Host "`n=== Module Health Monitoring ===" -ForegroundColor Cyan

function Test-ModuleHealth {
    param([string]$ModuleName)
    
    $health = @{
        ModuleName = $ModuleName
        IsLoaded = $false
        HasErrors = $false
        FunctionCount = 0
        LastError = $null
    }
    
    try {
        $module = Get-Module -Name $ModuleName -ErrorAction Stop
        if ($module) {
            $health.IsLoaded = $true
            $health.FunctionCount = $module.ExportedFunctions.Count
            
            # Check for errors
            if ($module.ExportedFunctions.Count -eq 0) {
                $health.HasErrors = $true
                $health.LastError = "No exported functions"
            }
        }
    }
    catch {
        $health.HasErrors = $true
        $health.LastError = $_.Exception.Message
    }
    
    return $health
}

# Test health of all modules
$modules = Get-ProfileModules | Where-Object { $_.Available -eq $true }
foreach ($module in $modules) {
    $health = Test-ModuleHealth -ModuleName $module.Name
    Write-Host "Module: $($health.ModuleName)" -ForegroundColor White
    Write-Host "  Loaded: $($health.IsLoaded)" -ForegroundColor $(if ($health.IsLoaded) { "Green" } else { "Red" })
    Write-Host "  Functions: $($health.FunctionCount)" -ForegroundColor White
    Write-Host "  Errors: $($health.HasErrors)" -ForegroundColor $(if ($health.HasErrors) { "Red" } else { "Green" })
    if ($health.LastError) {
        Write-Host "  Last Error: $($health.LastError)" -ForegroundColor Red
    }
}

# Example 4: Performance Monitoring
Write-Host "`n=== Performance Monitoring ===" -ForegroundColor Cyan

function Measure-ModuleLoadTime {
    param([string]$ModuleName)
    
    $startTime = Get-Date
    try {
        Load-ProfileModule -ModuleName $ModuleName -Force
        $endTime = Get-Date
        $loadTime = ($endTime - $startTime).TotalMilliseconds
        
        return @{
            ModuleName = $ModuleName
            LoadTime = $loadTime
            Success = $true
        }
    }
    catch {
        $endTime = Get-Date
        $loadTime = ($endTime - $startTime).TotalMilliseconds
        
        return @{
            ModuleName = $ModuleName
            LoadTime = $loadTime
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# Measure load times for all modules
Write-Host "Measuring module load times..." -ForegroundColor Yellow
$modules = Get-ProfileModules | Where-Object { $_.Available -eq $true }
foreach ($module in $modules) {
    $result = Measure-ModuleLoadTime -ModuleName $module.Name
    $status = if ($result.Success) { "✓" } else { "✗" }
    $color = if ($result.Success) { "Green" } else { "Red" }
    
    Write-Host "  $status $($result.ModuleName): $([math]::Round($result.LoadTime, 2))ms" -ForegroundColor $color
    if (-not $result.Success) {
        Write-Host "    Error: $($result.Error)" -ForegroundColor Red
    }
}

# Example 5: Custom Module Creation
Write-Host "`n=== Custom Module Creation ===" -ForegroundColor Cyan

# Example of creating a custom module programmatically
function New-CustomModule {
    param(
        [string]$ModuleName,
        [string]$Description,
        [string[]]$Functions
    )
    
    $modulePath = Join-Path $ProfileManagerConfig.ModulesDirectory $ModuleName
    $psm1Path = Join-Path $modulePath "$ModuleName.psm1"
    $psd1Path = Join-Path $modulePath "$ModuleName.psd1"
    
    # Create module directory
    if (-not (Test-Path $modulePath)) {
        New-Item -ItemType Directory -Path $modulePath -Force | Out-Null
    }
    
    # Create .psm1 file
    $psm1Content = @"
# $ModuleName Module
# $Description

function Get-$ModuleName`Info {
    <#
    .SYNOPSIS
    Gets information about the $ModuleName module
    #>
    
    return @{
        Name = "$ModuleName"
        Description = "$Description"
        Version = "1.0.0"
        Functions = @($($Functions -join ', '))
    }
}

# Export module members
Export-ModuleMember -Function @(
    'Get-$ModuleName`Info'
)
"@
    
    Set-Content -Path $psm1Path -Value $psm1Content -Encoding UTF8
    
    # Create .psd1 file
    $psd1Content = @"
@{
    RootModule = '$ModuleName.psm1'
    ModuleVersion = '1.0.0'
    GUID = '$(New-Guid)'
    Author = 'PowerShell Profile Manager'
    Description = '$Description'
    PowerShellVersion = '5.1'
    
    FunctionsToExport = @(
        'Get-$ModuleName`Info'
    )
}
"@
    
    Set-Content -Path $psd1Path -Value $psd1Content -Encoding UTF8
    
    Write-Host "Created custom module: $ModuleName" -ForegroundColor Green
    Write-Host "  Path: $modulePath" -ForegroundColor White
    Write-Host "  Functions: $($Functions -join ', ')" -ForegroundColor White
    
    return $modulePath
}

# Example: Create a custom module
Write-Host "Creating custom module example..." -ForegroundColor Yellow
$customModulePath = New-CustomModule -ModuleName "CustomExample" -Description "Custom example module" -Functions @("Get-CustomExampleInfo")

# Example 6: Module Dependency Management
Write-Host "`n=== Module Dependency Management ===" -ForegroundColor Cyan

function Get-ModuleDependencies {
    param([string]$ModuleName)
    
    $dependencies = @()
    
    # Check for required modules in manifest
    $manifestPath = Join-Path $ProfileManagerConfig.ModulesDirectory "$ModuleName\$ModuleName.psd1"
    if (Test-Path $manifestPath) {
        try {
            $manifest = Import-PowerShellDataFile $manifestPath
            if ($manifest.RequiredModules) {
                $dependencies += $manifest.RequiredModules
            }
        }
        catch {
            Write-Warning "Could not read manifest for $ModuleName"
        }
    }
    
    return $dependencies
}

# Check dependencies for all modules
$modules = Get-ProfileModules | Where-Object { $_.Available -eq $true }
foreach ($module in $modules) {
    $dependencies = Get-ModuleDependencies -ModuleName $module.Name
    if ($dependencies.Count -gt 0) {
        Write-Host "Module $($module.Name) dependencies:" -ForegroundColor White
        foreach ($dep in $dependencies) {
            Write-Host "  - $dep" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Module $($module.Name) has no dependencies" -ForegroundColor Green
    }
}

# Example 7: Configuration Backup and Restore
Write-Host "`n=== Configuration Backup and Restore ===" -ForegroundColor Cyan

function Backup-ProfileManagerConfig {
    param([string]$BackupPath = "$env:TEMP\ProfileManagerBackup")
    
    $backupDir = "$BackupPath\$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    
    # Backup main profile
    if (Test-Path $PROFILE) {
        Copy-Item -Path $PROFILE -Destination "$backupDir\profile.ps1"
    }
    
    # Backup modules
    $modulesBackupPath = Join-Path $backupDir "modules"
    if (Test-Path $ProfileManagerConfig.ModulesDirectory) {
        Copy-Item -Path $ProfileManagerConfig.ModulesDirectory -Destination $modulesBackupPath -Recurse
    }
    
    # Backup configuration
    $config = @{
        ProfileManagerConfig = $ProfileManagerConfig
        ProfileModules = $ProfileModules
        BackupDate = Get-Date
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
    }
    
    $config | ConvertTo-Json -Depth 10 | Set-Content -Path "$backupDir\config.json" -Encoding UTF8
    
    Write-Host "Configuration backed up to: $backupDir" -ForegroundColor Green
    return $backupDir
}

# Create backup
Write-Host "Creating configuration backup..." -ForegroundColor Yellow
$backupPath = Backup-ProfileManagerConfig

# Example 8: Module Auto-Update
Write-Host "`n=== Module Auto-Update ===" -ForegroundColor Cyan

function Update-ProfileManagerModules {
    param([switch]$Force)
    
    $updatedModules = @()
    $failedModules = @()
    
    $modules = Get-ProfileModules | Where-Object { $_.Available -eq $true }
    
    foreach ($module in $modules) {
        Write-Host "Checking for updates: $($module.Name)" -ForegroundColor Yellow
        
        try {
            # Check if module has update function
            $updateFunction = "Update-$($module.Name)"
            if (Get-Command $updateFunction -ErrorAction SilentlyContinue) {
                & $updateFunction -Force:$Force
                $updatedModules += $module.Name
                Write-Host "  ✓ Updated $($module.Name)" -ForegroundColor Green
            } else {
                Write-Host "  ⊘ No update function for $($module.Name)" -ForegroundColor Yellow
            }
        }
        catch {
            $failedModules += $module.Name
            Write-Host "  ✗ Failed to update $($module.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    return @{
        Updated = $updatedModules
        Failed = $failedModules
    }
}

# Check for updates
Write-Host "Checking for module updates..." -ForegroundColor Yellow
$updateResults = Update-ProfileManagerModules

if ($updateResults.Updated.Count -gt 0) {
    Write-Host "Updated modules: $($updateResults.Updated -join ', ')" -ForegroundColor Green
}

if ($updateResults.Failed.Count -gt 0) {
    Write-Host "Failed updates: $($updateResults.Failed -join ', ')" -ForegroundColor Red
}

# Example 9: Advanced Error Handling
Write-Host "`n=== Advanced Error Handling ===" -ForegroundColor Cyan

function Invoke-SafeModuleOperation {
    param(
        [string]$ModuleName,
        [string]$Operation,
        [scriptblock]$ScriptBlock
    )
    
    $result = @{
        ModuleName = $ModuleName
        Operation = $Operation
        Success = $false
        Error = $null
        Duration = 0
    }
    
    $startTime = Get-Date
    
    try {
        Write-Host "Executing $Operation on $ModuleName..." -ForegroundColor Yellow
        
        $scriptResult = & $ScriptBlock
        $result.Success = $true
        $result.Result = $scriptResult
        
        Write-Host "  ✓ $Operation completed successfully" -ForegroundColor Green
    }
    catch {
        $result.Error = $_.Exception.Message
        Write-Host "  ✗ $Operation failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        $endTime = Get-Date
        $result.Duration = ($endTime - $startTime).TotalMilliseconds
    }
    
    return $result
}

# Example usage of safe operations
$modules = Get-ProfileModules | Where-Object { $_.Available -eq $true }
foreach ($module in $modules) {
    $result = Invoke-SafeModuleOperation -ModuleName $module.Name -Operation "Load" {
        Load-ProfileModule -ModuleName $module.Name -Force
    }
    
    Write-Host "Operation result for $($module.Name):" -ForegroundColor White
    Write-Host "  Success: $($result.Success)" -ForegroundColor $(if ($result.Success) { "Green" } else { "Red" })
    Write-Host "  Duration: $([math]::Round($result.Duration, 2))ms" -ForegroundColor White
    if ($result.Error) {
        Write-Host "  Error: $($result.Error)" -ForegroundColor Red
    }
}

# Example 10: Integration with External Tools
Write-Host "`n=== Integration with External Tools ===" -ForegroundColor Cyan

# Example: Integration with Git
function Get-ProfileManagerGitStatus {
    $gitStatus = @{
        HasGit = $false
        IsRepository = $false
        Branch = $null
        Status = $null
    }
    
    try {
        $gitVersion = git --version 2>$null
        if ($gitVersion) {
            $gitStatus.HasGit = $true
            
            $gitDir = git rev-parse --git-dir 2>$null
            if ($gitDir) {
                $gitStatus.IsRepository = $true
                $gitStatus.Branch = git branch --show-current 2>$null
                $gitStatus.Status = git status --porcelain 2>$null
            }
        }
    }
    catch {
        # Git not available or not a repository
    }
    
    return $gitStatus
}

# Check Git status
$gitStatus = Get-ProfileManagerGitStatus
Write-Host "Git Integration Status:" -ForegroundColor White
Write-Host "  Has Git: $($gitStatus.HasGit)" -ForegroundColor $(if ($gitStatus.HasGit) { "Green" } else { "Red" })
Write-Host "  Is Repository: $($gitStatus.IsRepository)" -ForegroundColor $(if ($gitStatus.IsRepository) { "Green" } else { "Red" })
if ($gitStatus.Branch) {
    Write-Host "  Branch: $($gitStatus.Branch)" -ForegroundColor White
}

Write-Host "`n=== Advanced Examples Complete ===" -ForegroundColor Green
Write-Host "These examples demonstrate advanced usage patterns and customization options." -ForegroundColor White
Write-Host "For more information, see the documentation in the docs/ directory." -ForegroundColor White
