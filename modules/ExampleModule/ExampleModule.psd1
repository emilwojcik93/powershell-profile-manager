@{
    # Module manifest for ExampleModule
    RootModule = 'ExampleModule.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b2c3d4e5-a6b7-8901-bcde-f23456789012'
    Author = 'PowerShell Profile Manager'
    CompanyName = 'Community'
    Copyright = '(c) 2024. All rights reserved.'
    Description = 'Example module template showing best practices for PowerShell profile modules'
    PowerShellVersion = '5.1'
    
    # Functions to export from this module
    FunctionsToExport = @(
        'Get-ExampleInfo',
        'Set-ExampleConfig',
        'Test-ExampleFunction'
    )
    
    # Cmdlets to export from this module
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = @()
    
    # Aliases to export from this module
    AliasesToExport = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            Tags = @('Example', 'Template', 'Profile', 'Module')
            ProjectUri = 'https://github.com/yourusername/powershell-profile-manager'
            LicenseUri = 'https://github.com/yourusername/powershell-profile-manager/blob/main/LICENSE'
            ReleaseNotes = @'
Example module template
- Demonstrates best practices for PowerShell profile modules
- Shows proper function structure and documentation
- Includes configuration management
- Provides testing capabilities
'@
        }
    }
}
