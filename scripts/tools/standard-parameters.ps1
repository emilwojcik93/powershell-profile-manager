# Standard Parameter Definitions for PowerShell Profile Manager Scripts
# This file defines common parameter patterns used across all scripts

# Common parameter sets for different script types

# Standard automation parameters
$StandardAutomationParams = @{
    Silent = @{
        Type = 'switch'
        Description = 'Suppress verbose output'
        Default = $false
    }
    NonInteractive = @{
        Type = 'switch'
        Description = 'Run in non-interactive mode (no prompts)'
        Default = $false
    }
    Unattended = @{
        Type = 'switch'
        Description = 'Run in unattended mode (automation-friendly)'
        Default = $false
    }
    Force = @{
        Type = 'switch'
        Description = 'Force operation without confirmation'
        Default = $false
    }
    VerboseLogging = @{
        Type = 'switch'
        Description = 'Enable verbose logging output'
        Default = $false
    }
}

# Standard path parameters
$StandardPathParams = @{
    InstallPath = @{
        Type = 'string'
        Description = 'Installation directory path'
        Default = '${env:USERPROFILE}\PowerShell\ProfileManager'
    }
    OutputPath = @{
        Type = 'string'
        Description = 'Output file or directory path'
        Default = '.\output'
    }
    LogPath = @{
        Type = 'string'
        Description = 'Log file path'
        Default = $null
    }
    RepositoryRoot = @{
        Type = 'string'
        Description = 'Repository root directory'
        Default = '(Get-Location)'
    }
}

# Standard validation parameters
$StandardValidationParams = @{
    EventName = @{
        Type = 'string'
        Description = 'GitHub event name (push, pull_request, etc.)'
        Default = 'push'
    }
    BaseRef = @{
        Type = 'string'
        Description = 'Base reference for comparison'
        Default = 'main'
    }
    OutputDir = @{
        Type = 'string'
        Description = 'Output directory for validation results'
        Default = '.\validation-results'
    }
    MinimumSeverity = @{
        Type = 'string'
        Description = 'Minimum severity level to report'
        ValidateSet = @('Critical', 'High', 'Medium', 'Low', 'All')
        Default = 'All'
    }
}

# Standard module parameters
$StandardModuleParams = @{
    Modules = @{
        Type = 'string[]'
        Description = 'List of modules to process'
        Default = '@()'
    }
    RepositoryUrl = @{
        Type = 'string'
        Description = 'Repository URL for downloads'
        Default = 'https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main'
    }
}

# Function to apply standard parameter behavior
function Set-StandardParameterBehavior {
    param(
        [hashtable]$Params
    )
    
    # Set error action preference based on automation parameters
    if ($Params.Silent -or $Params.NonInteractive -or $Params.Unattended) {
        $ErrorActionPreference = 'SilentlyContinue'
        $VerbosePreference = 'SilentlyContinue'
    } else {
        $ErrorActionPreference = 'Stop'
    }
    
    # Set silent mode if any automation parameter is used
    if ($Params.NonInteractive -or $Params.Unattended) {
        $Params.Silent = $true
    }
    
    # Set up logging if VerboseLogging is enabled
    if ($Params.VerboseLogging) {
        $VerbosePreference = 'Continue'
    }
}

# Function to create standard parameter block
function New-StandardParameterBlock {
    param(
        [string[]]$ParameterSets = @('Automation', 'Path'),
        [hashtable]$CustomParams = @{}
    )
    
    $paramBlock = @()
    $paramBlock += "param("
    
    # Add automation parameters
    if ($ParameterSets -contains 'Automation') {
        foreach ($param in $StandardAutomationParams.GetEnumerator()) {
            $paramBlock += "    [Parameter(Mandatory = `$false)]"
            $paramBlock += "    [switch]`$$($param.Key),"
            $paramBlock += ""
        }
    }
    
    # Add path parameters
    if ($ParameterSets -contains 'Path') {
        foreach ($param in $StandardPathParams.GetEnumerator()) {
            $paramBlock += "    [Parameter(Mandatory = `$false)]"
            $paramBlock += "    [string]`$$($param.Key) = `"$($param.Value.Default)`","
            $paramBlock += ""
        }
    }
    
    # Add validation parameters
    if ($ParameterSets -contains 'Validation') {
        foreach ($param in $StandardValidationParams.GetEnumerator()) {
            $paramBlock += "    [Parameter(Mandatory = `$false)]"
            if ($param.Value.ValidateSet) {
                $paramBlock += "    [ValidateSet(`"$($param.Value.ValidateSet -join '", "')`")]"
            }
            $paramBlock += "    [string]`$$($param.Key) = `"$($param.Value.Default)`","
            $paramBlock += ""
        }
    }
    
    # Add module parameters
    if ($ParameterSets -contains 'Module') {
        foreach ($param in $StandardModuleParams.GetEnumerator()) {
            $paramBlock += "    [Parameter(Mandatory = `$false)]"
            $paramBlock += "    [$($param.Value.Type)]`$$($param.Key) = $($param.Value.Default),"
            $paramBlock += ""
        }
    }
    
    # Add custom parameters
    foreach ($param in $CustomParams.GetEnumerator()) {
        $paramBlock += "    [Parameter(Mandatory = `$false)]"
        $paramBlock += "    [$($param.Value.Type)]`$$($param.Key) = `"$($param.Value.Default)`","
        $paramBlock += ""
    }
    
    # Remove trailing comma from last parameter
    if ($paramBlock.Count -gt 1) {
        $paramBlock[-2] = $paramBlock[-2] -replace ',$', ''
    }
    
    $paramBlock += ")"
    
    return $paramBlock -join "`n"
}

# Export functions for use in other scripts
Export-ModuleMember -Function Set-StandardParameterBehavior, New-StandardParameterBlock
