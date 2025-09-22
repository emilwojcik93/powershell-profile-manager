@{
    # Module manifest for PowerShellMCP
    RootModule = 'PowerShellMCP.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'c3d4e5f6-a7b8-9012-cdef-345678901234'
    Author = 'PowerShell Profile Manager'
    CompanyName = 'Community'
    Copyright = '(c) 2024. All rights reserved.'
    Description = 'PowerShell MCP Server for Cursor IDE integration'
    PowerShellVersion = '5.1'
    
    # Functions to export from this module
    FunctionsToExport = @(
        'Start-PowerShellMCPServer',
        'Stop-PowerShellMCPServer',
        'Get-PowerShellMCPStatus',
        'Test-PowerShellMCPConnection',
        'Invoke-PowerShellMCPCommand',
        'Get-PowerShellMCPConfig',
        'Set-PowerShellMCPConfig'
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
            Tags = @('MCP', 'Cursor', 'IDE', 'PowerShell', 'Server')
        ProjectUri = 'https://github.com/emilwojcik93/powershell-profile-manager'
        LicenseUri = 'https://github.com/emilwojcik93/powershell-profile-manager/blob/main/LICENSE'
            ReleaseNotes = @'
Initial release of PowerShellMCP module
- MCP Server for Cursor IDE integration
- PowerShell command execution via MCP protocol
- Secure command execution with validation
- Real-time output streaming
'@
        }
    }
}
