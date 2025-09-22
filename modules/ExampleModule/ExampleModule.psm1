# ExampleModule - Template for PowerShell Profile Modules
# This module demonstrates best practices for creating profile modules

# Module configuration
$ExampleModuleConfig = @{
    DefaultValue = "Hello World"
    LogLevel = "Info"
    EnableFeatures = @{
        Feature1 = $true
        Feature2 = $false
    }
}

function Get-ExampleInfo {
    <#
    .SYNOPSIS
    Gets information about the ExampleModule
    
    .DESCRIPTION
    This function demonstrates how to create a simple informational function
    that returns details about the module and its configuration.
    
    .OUTPUTS
    [hashtable] Module information and configuration
    
    .EXAMPLE
    Get-ExampleInfo
    Returns module information and current configuration
    
    .EXAMPLE
    $info = Get-ExampleInfo
    $info.Configuration
    Gets just the configuration section
    #>
    
    [CmdletBinding()]
    param()
    
    $moduleInfo = @{
        Name = "ExampleModule"
        Version = "1.0.0"
        Description = "Example module template for PowerShell profile modules"
        Author = "PowerShell Profile Manager"
        Configuration = $ExampleModuleConfig
        Functions = @(
            "Get-ExampleInfo",
            "Set-ExampleConfig", 
            "Test-ExampleFunction"
        )
        LoadedAt = Get-Date
    }
    
    return $moduleInfo
}

function Set-ExampleConfig {
    <#
    .SYNOPSIS
    Sets configuration values for the ExampleModule
    
    .DESCRIPTION
    This function demonstrates how to create a configuration management function
    that allows users to modify module settings.
    
    .PARAMETER DefaultValue
    Sets the default value for the module
    
    .PARAMETER LogLevel
    Sets the logging level (Debug, Info, Warning, Error)
    
    .PARAMETER EnableFeature1
    Enables or disables Feature1
    
    .PARAMETER EnableFeature2
    Enables or disables Feature2
    
    .EXAMPLE
    Set-ExampleConfig -DefaultValue "New Value"
    Sets the default value to "New Value"
    
    .EXAMPLE
    Set-ExampleConfig -LogLevel "Debug" -EnableFeature1 $true
    Sets log level to Debug and enables Feature1
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$DefaultValue,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Debug", "Info", "Warning", "Error")]
        [string]$LogLevel,
        
        [Parameter(Mandatory = $false)]
        [bool]$EnableFeature1,
        
        [Parameter(Mandatory = $false)]
        [bool]$EnableFeature2
    )
    
    $changes = @()
    
    if ($PSBoundParameters.ContainsKey('DefaultValue')) {
        $ExampleModuleConfig.DefaultValue = $DefaultValue
        $changes += "DefaultValue set to: $DefaultValue"
    }
    
    if ($PSBoundParameters.ContainsKey('LogLevel')) {
        $ExampleModuleConfig.LogLevel = $LogLevel
        $changes += "LogLevel set to: $LogLevel"
    }
    
    if ($PSBoundParameters.ContainsKey('EnableFeature1')) {
        $ExampleModuleConfig.EnableFeatures.Feature1 = $EnableFeature1
        $changes += "Feature1 set to: $EnableFeature1"
    }
    
    if ($PSBoundParameters.ContainsKey('EnableFeature2')) {
        $ExampleModuleConfig.EnableFeatures.Feature2 = $EnableFeature2
        $changes += "Feature2 set to: $EnableFeature2"
    }
    
    if ($changes.Count -gt 0) {
        Write-Host "Configuration updated:" -ForegroundColor Green
        foreach ($change in $changes) {
            Write-Host "  - $change" -ForegroundColor Yellow
        }
    } else {
        Write-Host "No configuration changes made." -ForegroundColor Yellow
    }
    
    return $ExampleModuleConfig
}

function Test-ExampleFunction {
    <#
    .SYNOPSIS
    Tests the functionality of the ExampleModule
    
    .DESCRIPTION
    This function demonstrates how to create a testing function that validates
    the module's functionality and configuration.
    
    .PARAMETER TestType
    Type of test to run (Basic, Configuration, All)
    
    .OUTPUTS
    [hashtable] Test results
    
    .EXAMPLE
    Test-ExampleFunction
    Runs basic functionality tests
    
    .EXAMPLE
    Test-ExampleFunction -TestType Configuration
    Tests configuration management
    
    .EXAMPLE
    Test-ExampleFunction -TestType All
    Runs all available tests
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet("Basic", "Configuration", "All")]
        [string]$TestType = "Basic"
    )
    
    $testResults = @{
        TestType = $TestType
        Timestamp = Get-Date
        Results = @()
        Passed = 0
        Failed = 0
    }
    
    function Add-TestResult {
        param(
            [string]$TestName,
            [bool]$Passed,
            [string]$Message
        )
        
        $result = @{
            TestName = $TestName
            Passed = $Passed
            Message = $Message
        }
        
        $testResults.Results += $result
        
        if ($Passed) {
            $testResults.Passed++
            Write-Host " $TestName" -ForegroundColor Green
        } else {
            $testResults.Failed++
            Write-Host " $TestName - $Message" -ForegroundColor Red
        }
    }
    
    Write-Host "Running ExampleModule tests..." -ForegroundColor Cyan
    Write-Host "Test Type: $TestType" -ForegroundColor Yellow
    Write-Host ""
    
    # Basic functionality tests
    if ($TestType -in @("Basic", "All")) {
        try {
            $info = Get-ExampleInfo
            $passed = $info -ne $null -and $info.Name -eq "ExampleModule"
            Add-TestResult -TestName "Get-ExampleInfo Function" -Passed $passed -Message "Function returns expected data"
        }
        catch {
            Add-TestResult -TestName "Get-ExampleInfo Function" -Passed $false -Message $_.Exception.Message
        }
        
        try {
            $config = Set-ExampleConfig -DefaultValue "Test Value"
            $passed = $config.DefaultValue -eq "Test Value"
            Add-TestResult -TestName "Set-ExampleConfig Function" -Passed $passed -Message "Configuration update works"
        }
        catch {
            Add-TestResult -TestName "Set-ExampleConfig Function" -Passed $false -Message $_.Exception.Message
        }
    }
    
    # Configuration tests
    if ($TestType -in @("Configuration", "All")) {
        try {
            $originalValue = $ExampleModuleConfig.DefaultValue
            Set-ExampleConfig -DefaultValue "Test Config"
            $passed = $ExampleModuleConfig.DefaultValue -eq "Test Config"
            Set-ExampleConfig -DefaultValue $originalValue  # Restore original
            Add-TestResult -TestName "Configuration Management" -Passed $passed -Message "Configuration can be modified and restored"
        }
        catch {
            Add-TestResult -TestName "Configuration Management" -Passed $false -Message $_.Exception.Message
        }
        
        try {
            $originalLogLevel = $ExampleModuleConfig.LogLevel
            Set-ExampleConfig -LogLevel "Debug"
            $passed = $ExampleModuleConfig.LogLevel -eq "Debug"
            Set-ExampleConfig -LogLevel $originalLogLevel  # Restore original
            Add-TestResult -TestName "Log Level Configuration" -Passed $passed -Message "Log level can be changed"
        }
        catch {
            Add-TestResult -TestName "Log Level Configuration" -Passed $false -Message $_.Exception.Message
        }
    }
    
    # Summary
    Write-Host ""
    Write-Host "Test Summary:" -ForegroundColor Cyan
    Write-Host "  Passed: $($testResults.Passed)" -ForegroundColor Green
    Write-Host "  Failed: $($testResults.Failed)" -ForegroundColor Red
    Write-Host "  Total:  $($testResults.Results.Count)" -ForegroundColor White
    
    if ($testResults.Failed -eq 0) {
        Write-Host "All tests passed!" -ForegroundColor Green
    } else {
        Write-Host "Some tests failed. Check the results above." -ForegroundColor Yellow
    }
    
    return $testResults
}

# Module initialization
Write-Host "ExampleModule loaded successfully!" -ForegroundColor Green
Write-Host "Use Get-ExampleInfo to see module information" -ForegroundColor Yellow
Write-Host "Use Test-ExampleFunction to test module functionality" -ForegroundColor Yellow

# Functions are exported via the .psd1 manifest file


