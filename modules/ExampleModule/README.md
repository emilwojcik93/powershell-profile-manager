# ExampleModule

A template module demonstrating best practices for creating PowerShell profile modules.

## Purpose

This module serves as a comprehensive example of how to structure and implement a PowerShell profile module. It demonstrates:

- Proper function structure and documentation
- Configuration management
- Error handling and testing
- Module initialization
- Best practices for PowerShell modules

## Functions

### Get-ExampleInfo

Returns information about the module and its current configuration.

```powershell
# Get module information
Get-ExampleInfo

# Access specific configuration
$info = Get-ExampleInfo
$info.Configuration
```

### Set-ExampleConfig

Manages module configuration settings.

```powershell
# Set default value
Set-ExampleConfig -DefaultValue "New Value"

# Set log level
Set-ExampleConfig -LogLevel "Debug"

# Enable/disable features
Set-ExampleConfig -EnableFeature1 $true -EnableFeature2 $false

# Multiple settings at once
Set-ExampleConfig -DefaultValue "Test" -LogLevel "Info" -EnableFeature1 $true
```

### Test-ExampleFunction

Tests the module's functionality and configuration.

```powershell
# Run basic tests
Test-ExampleFunction

# Test configuration management
Test-ExampleFunction -TestType Configuration

# Run all tests
Test-ExampleFunction -TestType All
```

## Configuration

The module uses a hashtable-based configuration system:

```powershell
$ExampleModuleConfig = @{
    DefaultValue = "Hello World"
    LogLevel = "Info"
    EnableFeatures = @{
        Feature1 = $true
        Feature2 = $false
    }
}
```

## Best Practices Demonstrated

### 1. Function Documentation
- Comprehensive comment-based help
- Parameter descriptions
- Example usage
- Output descriptions

### 2. Parameter Validation
- Mandatory parameters where appropriate
- Parameter sets for different use cases
- ValidateSet for enumerated values
- Type validation

### 3. Error Handling
- Try-catch blocks for critical operations
- Graceful degradation
- Informative error messages

### 4. Configuration Management
- Centralized configuration
- Runtime configuration updates
- Configuration validation

### 5. Testing
- Built-in testing functionality
- Multiple test types
- Clear test results
- Test result reporting

### 6. Module Structure
- Proper module manifest (.psd1)
- Clear function exports
- Module initialization
- User-friendly startup messages

## Creating Your Own Module

To create a new module based on this template:

1. **Copy the ExampleModule directory**
   ```powershell
   Copy-Item "modules\ExampleModule" "modules\YourModule" -Recurse
   ```

2. **Rename files**
   - `ExampleModule.psm1` → `YourModule.psm1`
   - `ExampleModule.psd1` → `YourModule.psd1`

3. **Update module manifest**
   - Change module name and GUID
   - Update function exports
   - Update description and metadata

4. **Update module content**
   - Replace example functions with your functionality
   - Update configuration as needed
   - Modify initialization messages

5. **Add to profile configuration**
   - Add your module to `$ProfileModules` in the main profile
   - Set `Enabled = $true`

6. **Test your module**
   - Use the testing framework
   - Verify all functions work correctly
   - Test configuration management

## Module Development Guidelines

### Function Structure
```powershell
function Your-Function {
    <#
    .SYNOPSIS
    Brief description of what the function does
    
    .DESCRIPTION
    Detailed description of the function's purpose and behavior
    
    .PARAMETER ParameterName
    Description of the parameter
    
    .OUTPUTS
    Description of what the function returns
    
    .EXAMPLE
    Your-Function -ParameterName "value"
    Description of what this example does
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ParameterName
    )
    
    try {
        # Function implementation
        return $result
    }
    catch {
        Write-Error "Error message: $($_.Exception.Message)"
        return $null
    }
}
```

### Configuration Management
```powershell
# Module-level configuration
$YourModuleConfig = @{
    Setting1 = "DefaultValue"
    Setting2 = $true
    NestedSettings = @{
        SubSetting1 = "Value"
        SubSetting2 = 42
    }
}

# Configuration function
function Set-YourModuleConfig {
    param(
        [string]$Setting1,
        [bool]$Setting2
    )
    
    if ($PSBoundParameters.ContainsKey('Setting1')) {
        $YourModuleConfig.Setting1 = $Setting1
    }
    
    if ($PSBoundParameters.ContainsKey('Setting2')) {
        $YourModuleConfig.Setting2 = $Setting2
    }
    
    return $YourModuleConfig
}
```

### Testing Framework
```powershell
function Test-YourModule {
    param(
        [ValidateSet("Basic", "Advanced", "All")]
        [string]$TestType = "Basic"
    )
    
    $results = @{
        Passed = 0
        Failed = 0
        Tests = @()
    }
    
    # Add your tests here
    # Use Add-TestResult helper function
    
    return $results
}
```

## License

This module is part of the PowerShell Profile Manager project and is licensed under the MIT License.
