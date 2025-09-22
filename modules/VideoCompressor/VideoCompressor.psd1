@{
    # Module manifest for VideoCompressor
    RootModule = 'VideoCompressor.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author = 'PowerShell Profile Manager'
    CompanyName = 'Community'
    Copyright = '(c) 2024. All rights reserved.'
    Description = 'Video compression module optimized for cloud storage platforms'
    PowerShellVersion = '5.1'
    
    # Functions to export from this module
    FunctionsToExport = @(
        'Compress-Video',
        'Test-FFmpegInstallation',
        'Get-VideoProperties',
        'Get-OptimalCompressionSettings',
        'Get-OutputDirectory'
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
            Tags = @('Video', 'Compression', 'FFmpeg', 'CloudStorage')
            ProjectUri = 'https://github.com/yourusername/powershell-profile-manager'
            LicenseUri = 'https://github.com/yourusername/powershell-profile-manager/blob/main/LICENSE'
            ReleaseNotes = @'
Initial release of VideoCompressor module
- Video compression with cloud storage optimization
- Automatic FFmpeg installation and configuration
- Hardware acceleration support
- Multiple compression modes (Fast, Balanced, Quality)
'@
        }
    }
}
