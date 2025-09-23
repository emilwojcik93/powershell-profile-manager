# PowerShell Profile Manager
# Main profile loader script

# Immediate SSH/SCP session detection (before any output)
$IsSSHSession = $false
$IsNonInteractiveSession = $false

# Check for SSH environment variables immediately
$sshEnvVars = @($env:SSH_CLIENT, $env:SSH_CONNECTION, $env:SSH_TTY, $env:SSH_AUTH_SOCK)
$hasSSHEnvVars = ($sshEnvVars | Where-Object { $_ -ne $null }).Count -gt 0

# Check for non-interactive indicators
$nonInteractiveEnvVars = @($env:CI, $env:BUILD_NUMBER, $env:GITHUB_ACTIONS, $env:AZURE_DEVOPS)
$hasNonInteractiveEnvVars = ($nonInteractiveEnvVars | Where-Object { $_ -ne $null }).Count -gt 0

# Check parent process for SSH indicators
try {
    $currentProcess = Get-Process -Id $PID -ErrorAction SilentlyContinue
    if ($currentProcess) {
        $parentProcess = Get-Process -Id $currentProcess.ParentId -ErrorAction SilentlyContinue
        if ($parentProcess -and $parentProcess.ProcessName -like '*ssh*') {
            $IsSSHSession = $true
        }
    }
} catch {
    # Ignore errors in process detection
}

# Set session flags
$IsSSHSession = $IsSSHSession -or $hasSSHEnvVars
$IsNonInteractiveSession = $IsNonInteractiveSession -or $hasNonInteractiveEnvVars

# Profile Manager Configuration
$ProfileManagerConfig = @{
    ModulesDirectory    = Join-Path $PSScriptRoot 'modules'
    LogLevel            = if ($IsSSHSession -or $IsNonInteractiveSession) { 'Error' } else { 'Info' }  # Debug, Info, Warning, Error
    AutoLoadModules     = $true
    EnableModuleLogging = -not ($IsSSHSession -or $IsNonInteractiveSession)
}

# Logging function
function Write-ProfileLog {
    param(
        [string]$Message,
        [ValidateSet('Debug', 'Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    # Skip all output if we're in an SSH/SCP session or non-interactive session
    if ($IsSSHSession -or $IsNonInteractiveSession) {
        return
    }
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        'Debug' {
            if ($ProfileManagerConfig.LogLevel -eq 'Debug') {
                Write-Host $logMessage -ForegroundColor Gray 
            } 
        }
        'Info' {
            if ($ProfileManagerConfig.LogLevel -in @('Debug', 'Info')) {
                Write-Host $logMessage -ForegroundColor White 
            } 
        }
        'Warning' {
            if ($ProfileManagerConfig.LogLevel -in @('Debug', 'Info', 'Warning')) {
                Write-Host $logMessage -ForegroundColor Yellow 
            } 
        }
        'Error' {
            Write-Host $logMessage -ForegroundColor Red 
        }
    }
}

# Environment Detection Functions
function Test-CursorEnvironment {
    <#
    .SYNOPSIS
    Detects if PowerShell is running within Cursor IDE environment
    
    .DESCRIPTION
    Checks for Cursor-specific environment variables to determine if the session
    is running within Cursor IDE, which can be used to optimize profile loading
    for agent sessions. Distinguishes between Cursor IDE and Windows Terminal.
    
    .OUTPUTS
    [bool] Returns $true if running in Cursor environment, $false otherwise
    #>
    
    # Check for Cursor-specific indicators
    $cursorIndicators = @(
        $env:CURSOR_TRACE_ID,
        $env:CURSOR_AGENT
    )
    
    # Check for VS Code indicators (Cursor is based on VS Code)
    $vscodeIndicators = @(
        $env:VSCODE_GIT_ASKPASS_MAIN,
        $env:VSCODE_GIT_IPC_HANDLE,
        $env:VSCODE_GIT_ASKPASS_NODE,
        $env:VSCODE_INJECTION
    )
    
    # Check if we're in Windows Terminal (which would be false positive)
    $isWindowsTerminal = $env:WT_SESSION -ne $null -and $env:CURSOR_TRACE_ID -eq $null
    
    # We're in Cursor if we have Cursor-specific indicators OR VS Code indicators
    # but NOT if we're in Windows Terminal without Cursor indicators
    $hasCursorIndicators = ($cursorIndicators | Where-Object { $_ -ne $null }).Count -gt 0
    $hasVscodeIndicators = ($vscodeIndicators | Where-Object { $_ -ne $null }).Count -gt 0
    
    return ($hasCursorIndicators -or $hasVscodeIndicators) -and -not $isWindowsTerminal
}

function Test-SSHSession {
    <#
    .SYNOPSIS
    Detects if PowerShell is running in an SSH/SCP session
    
    .DESCRIPTION
    Checks for SSH-specific environment variables and process indicators to determine if the session
    is running over SSH or SCP, which requires minimal output to avoid
    "Received message too long" errors.
    
    .OUTPUTS
    [bool] Returns $true if running in SSH session, $false otherwise
    #>
    
    # Check for SSH-specific environment variables
    $sshIndicators = @(
        $env:SSH_CLIENT,
        $env:SSH_CONNECTION,
        $env:SSH_TTY,
        $env:SSH_AUTH_SOCK
    )
    
    # Check if any SSH indicators are present
    $hasSSHIndicators = ($sshIndicators | Where-Object { $_ -ne $null }).Count -gt 0
    
    # Additional check: if TERM is set to xterm-256color and we have SSH vars
    $isSSHTerminal = $env:TERM -eq 'xterm-256color' -and $hasSSHIndicators
    
    # Check parent process for SSH indicators
    $isSSHParent = $false
    try {
        $currentProcess = Get-Process -Id $PID -ErrorAction SilentlyContinue
        if ($currentProcess) {
            $parentProcess = Get-Process -Id $currentProcess.ParentId -ErrorAction SilentlyContinue
            if ($parentProcess -and $parentProcess.ProcessName -like '*ssh*') {
                $isSSHParent = $true
            }
        }
    } catch {
        # Ignore errors in process detection
    }
    
    return $hasSSHIndicators -or $isSSHTerminal -or $isSSHParent
}

function Test-NonInteractiveSession {
    <#
    .SYNOPSIS
    Detects if PowerShell is running in a non-interactive session
    
    .DESCRIPTION
    Checks for indicators that suggest the session is non-interactive,
    such as SSH, SCP, or other automated contexts where output should be minimal.
    
    .OUTPUTS
    [bool] Returns $true if running in non-interactive session, $false otherwise
    #>
    
    # Check for non-interactive indicators
    $nonInteractiveIndicators = @(
        $env:SSH_CLIENT,
        $env:SSH_CONNECTION,
        $env:SSH_TTY,
        $env:CI,  # Continuous Integration
        $env:BUILD_NUMBER,  # Jenkins
        $env:GITHUB_ACTIONS,  # GitHub Actions
        $env:AZURE_DEVOPS  # Azure DevOps
    )
    
    # Check if any non-interactive indicators are present
    $hasNonInteractiveIndicators = ($nonInteractiveIndicators | Where-Object { $_ -ne $null }).Count -gt 0
    
    # Check if we're in a remote session (PowerShell remoting)
    $isRemoteSession = $env:COMPUTERNAME -ne $env:COMPUTERNAME -or $PSSenderInfo -ne $null
    
    return $hasNonInteractiveIndicators -or $isRemoteSession
}

# Detect Cursor environment and optimize accordingly
$IsCursorEnvironment = Test-CursorEnvironment

if ($IsCursorEnvironment) {
    if (-not ($IsSSHSession -or $IsNonInteractiveSession)) {
        Write-ProfileLog 'Cursor environment detected - optimizing for agent sessions' 'Info'
    }
    
    # Optimize for Cursor agent sessions
    $ProfileManagerConfig.LogLevel = 'Warning'  # Reduce logging verbosity
    $ProfileManagerConfig.EnableModuleLogging = $false  # Disable detailed logging
    $ProfileManagerConfig.AutoLoadModules = $true  # Still load modules but quietly
}

# Available modules configuration
$ProfileModules = @(
    @{
        Name        = 'VideoCompressor'
        Enabled     = $true
        Description = 'Video compression with cloud storage optimization'
    },
    @{
        Name        = 'PowerShellMCP'
        Enabled     = $IsCursorEnvironment  # Auto-enable in Cursor environment
        Description = 'MCP Server for Cursor IDE integration'
    },
    @{
        Name        = 'ExampleModule'
        Enabled     = $false  # Example module - disabled by default
        Description = 'Example module template'
    }
)

# Profile Manager Functions

function Test-ModulePath {
    param([string]$ModuleName)
    
    $modulePath = Join-Path $ProfileManagerConfig.ModulesDirectory $ModuleName
    $moduleFile = Join-Path $modulePath "$ModuleName.psm1"
    
    return (Test-Path $moduleFile)
}

function Load-ProfileModule {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        
        [switch]$Force
    )
    
    Write-ProfileLog "Loading module: $ModuleName" 'Info'
    
    # Check if module is already loaded
    if ((Get-Module -Name $ModuleName -ErrorAction SilentlyContinue) -and -not $Force) {
        Write-ProfileLog "Module $ModuleName is already loaded" 'Warning'
        return $true
    }
    
    # Check if module path exists
    if (-not (Test-ModulePath -ModuleName $ModuleName)) {
        Write-ProfileLog "Module $ModuleName not found in modules directory" 'Error'
        return $false
    }
    
    try {
        $modulePath = Join-Path $ProfileManagerConfig.ModulesDirectory $ModuleName
        $moduleFile = Join-Path $modulePath "$ModuleName.psm1"
        
        # Test module syntax before loading
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $moduleFile -Raw), [ref]$null)
        
        # Load the module with appropriate verbosity based on session type
        if ($IsSSHSession -or $IsNonInteractiveSession) {
            # Suppress all output for SSH/SCP sessions
            Import-Module $moduleFile -Force:$Force -ErrorAction Stop -WarningAction SilentlyContinue -Verbose:$false
        } else {
            # Normal loading for interactive sessions
            Import-Module $moduleFile -Force:$Force -ErrorAction Stop
        }
        
        Write-ProfileLog "Successfully loaded module: $ModuleName" 'Info'
        return $true
    } catch {
        Write-ProfileLog "Failed to load module $ModuleName`: $($_.Exception.Message)" 'Error'
        return $false
    }
}

function Unload-ProfileModule {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleName
    )
    
    Write-ProfileLog "Unloading module: $ModuleName" 'Info'
    
    try {
        Remove-Module -Name $ModuleName -Force -ErrorAction Stop
        Write-ProfileLog "Successfully unloaded module: $ModuleName" 'Info'
        return $true
    } catch {
        Write-ProfileLog "Failed to unload module $ModuleName`: $($_.Exception.Message)" 'Error'
        return $false
    }
}

function Reload-ProfileModule {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleName
    )
    
    Write-ProfileLog "Reloading module: $ModuleName" 'Info'
    
    Unload-ProfileModule -ModuleName $ModuleName
    return Load-ProfileModule -ModuleName $ModuleName -Force
}

function Get-ProfileModules {
    $enabledModules = $ProfileModules | Where-Object { $_.Enabled }
    
    if ($enabledModules.Count -eq 0) {
        Write-Host 'No modules are currently enabled.' -ForegroundColor Yellow
        return
    }
    
    # Create a simple table output
    Write-Host "`nProfile Manager Modules:" -ForegroundColor Green
    Write-Host '========================' -ForegroundColor Green
    
    foreach ($module in $enabledModules) {
        $isLoaded = (Get-Module -Name $module.Name -ErrorAction SilentlyContinue) -ne $null
        $isAvailable = Test-ModulePath -ModuleName $module.Name
        
        $loadedStatus = if ($isLoaded) {
            'Yes' 
        } else {
            'No' 
        }
        $availableStatus = if ($isAvailable) {
            'Yes' 
        } else {
            'No' 
        }
        
        Write-Host "`nModule: $($module.Name)" -ForegroundColor Cyan
        Write-Host "  Description: $($module.Description)" -ForegroundColor White
        Write-Host "  Loaded: $loadedStatus" -ForegroundColor $(if ($isLoaded) {
                'Green' 
            } else {
                'Red' 
            })
        Write-Host "  Available: $availableStatus" -ForegroundColor $(if ($isAvailable) {
                'Green' 
            } else {
                'Red' 
            })
    }
    
    Write-Host ''
}

function Get-ProfileModuleStatus {
    param([string]$ModuleName)
    
    $module = $ProfileModules | Where-Object { $_.Name -eq $ModuleName }
    if (-not $module) {
        return 'Module not configured'
    }
    
    $isLoaded = (Get-Module -Name $ModuleName -ErrorAction SilentlyContinue) -ne $null
    $isAvailable = Test-ModulePath -ModuleName $ModuleName
    
    return @{
        Name      = $ModuleName
        Enabled   = $module.Enabled
        Loaded    = $isLoaded
        Available = $isAvailable
        Status    = if ($isAvailable -and $isLoaded) {
            'Active' 
        } elseif ($isAvailable -and -not $isLoaded) {
            'Available' 
        } elseif (-not $isAvailable) {
            'Missing' 
        } else {
            'Unknown' 
        }
    }
}

function Unload-AllProfileModules {
    Write-ProfileLog 'Unloading all profile modules' 'Info'
    
    $loadedModules = Get-Module | Where-Object { $_.Name -in ($ProfileModules | Where-Object { $_.Enabled }).Name }
    
    foreach ($module in $loadedModules) {
        Unload-ProfileModule -ModuleName $module.Name
    }
}

function Remove-ProfileManager {
    <#
    .SYNOPSIS
    Completely removes the PowerShell Profile Manager and restores default profile
    
    .DESCRIPTION
    This function provides a complete cleanup of the PowerShell Profile Manager,
    including removing all modules, configuration, and restoring the default profile.
    
    .PARAMETER KeepModules
    Keep the module files but remove profile configuration
    
    .PARAMETER Force
    Skip confirmation prompts
    
    .EXAMPLE
    Remove-ProfileManager
    Removes ProfileManager with confirmation prompts
    
    .EXAMPLE
    Remove-ProfileManager -Force
    Removes ProfileManager without confirmation prompts
    
    .EXAMPLE
    Remove-ProfileManager -KeepModules
    Removes ProfileManager configuration but keeps module files
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$KeepModules,
        
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    
    if (-not $Force) {
        Write-Host 'This will completely remove the PowerShell Profile Manager.' -ForegroundColor Yellow
        Write-Host 'What will be removed:' -ForegroundColor Cyan
        Write-Host '  • All loaded profile modules' -ForegroundColor White
        Write-Host '  • ProfileManager configuration from PowerShell profile' -ForegroundColor White
        
        if (-not $KeepModules) {
            Write-Host '  • All module files and directories' -ForegroundColor White
        } else {
            Write-Host '  • Module files will be kept' -ForegroundColor Green
        }
        
        Write-Host ''
        $confirm = Read-Host 'Are you sure you want to continue? (y/n)'
        if ($confirm -ne 'y' -and $confirm -ne 'Y') {
            Write-Host 'ProfileManager removal cancelled.' -ForegroundColor Yellow
            return
        }
    }
    
    Write-ProfileLog 'Starting ProfileManager removal...' 'Info'
    
    # Step 1: Unload all modules
    Write-ProfileLog 'Unloading all profile modules...' 'Info'
    Unload-AllProfileModules
    
    # Step 2: Remove profile configuration
    Write-ProfileLog 'Removing profile configuration...' 'Info'
    try {
        $profilePath = $PROFILE
        if (Test-Path $profilePath) {
            $profileContent = Get-Content $profilePath -Raw
            
            if ($profileContent -like '*ProfileManager*') {
                # Remove ProfileManager configuration lines
                $lines = $profileContent -split "`n"
                $newLines = @()
                $skipNext = $false
                
                foreach ($line in $lines) {
                    if ($line -like '*# PowerShell Profile Manager*') {
                        $skipNext = $true
                        continue
                    } elseif ($skipNext -and $line -like '*ProfileManager*') {
                        $skipNext = $false
                        continue
                    } elseif ($line -like '*ProfileManager*') {
                        continue
                    } else {
                        $newLines += $line
                    }
                }
                
                $newContent = $newLines -join "`n"
                $newContent = $newContent.TrimEnd()
                
                if ($newContent -eq '') {
                    Remove-Item -Path $profilePath -Force
                    Write-ProfileLog 'Removed empty profile file' 'Success'
                } else {
                    Set-Content -Path $profilePath -Value $newContent -Encoding UTF8
                    Write-ProfileLog 'Updated profile file' 'Success'
                }
            } else {
                Write-ProfileLog 'ProfileManager configuration not found in profile' 'Warning'
            }
        } else {
            Write-ProfileLog "Profile file not found: $profilePath" 'Warning'
        }
    } catch {
        Write-ProfileLog "Failed to remove profile configuration: $($_.Exception.Message)" 'Error'
    }
    
    # Step 3: Remove module files (if not keeping them)
    if (-not $KeepModules) {
        Write-ProfileLog 'Removing module files...' 'Info'
        try {
            $modulesPath = Join-Path $PSScriptRoot 'modules'
            if (Test-Path $modulesPath) {
                Remove-Item -Path $modulesPath -Recurse -Force
                Write-ProfileLog 'Removed modules directory' 'Success'
            } else {
                Write-ProfileLog 'Modules directory not found' 'Warning'
            }
        } catch {
            Write-ProfileLog "Failed to remove module files: $($_.Exception.Message)" 'Error'
        }
    } else {
        Write-ProfileLog 'Keeping module files as requested' 'Info'
    }
    
    # Step 4: Remove installation directory (if not keeping modules)
    if (-not $KeepModules) {
        Write-ProfileLog 'Removing installation directory...' 'Info'
        try {
            if (Test-Path $PSScriptRoot) {
                # Only remove if this is the ProfileManager directory
                $parentDir = Split-Path $PSScriptRoot -Parent
                if ($PSScriptRoot -like '*ProfileManager*') {
                    Remove-Item -Path $PSScriptRoot -Recurse -Force
                    Write-ProfileLog 'Removed installation directory' 'Success'
                } else {
                    Write-ProfileLog 'Skipping installation directory removal (not ProfileManager directory)' 'Warning'
                }
            }
        } catch {
            Write-ProfileLog "Failed to remove installation directory: $($_.Exception.Message)" 'Error'
        }
    }
    
    Write-ProfileLog 'ProfileManager removal completed' 'Success'
    Write-Host 'PowerShell Profile Manager has been removed.' -ForegroundColor Green
    Write-Host 'Restart PowerShell to ensure clean state.' -ForegroundColor Yellow
}

function Restore-DefaultProfile {
    <#
    .SYNOPSIS
    Restores the PowerShell profile to its default state
    
    .DESCRIPTION
    This function removes all customizations from the PowerShell profile
    and restores it to a clean default state.
    
    .PARAMETER Backup
    Create a backup of the current profile before restoring
    
    .PARAMETER Force
    Skip confirmation prompts
    
    .EXAMPLE
    Restore-DefaultProfile
    Restores profile with confirmation and backup
    
    .EXAMPLE
    Restore-DefaultProfile -Force
    Restores profile without confirmation prompts
    
    .EXAMPLE
    Restore-DefaultProfile -Backup:$false
    Restores profile without creating backup
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Backup = $true,
        
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    
    if (-not $Force) {
        Write-Host 'This will restore your PowerShell profile to its default state.' -ForegroundColor Yellow
        Write-Host 'All customizations will be removed.' -ForegroundColor Red
        
        if ($Backup) {
            Write-Host 'A backup will be created before restoration.' -ForegroundColor Green
        }
        
        Write-Host ''
        $confirm = Read-Host 'Are you sure you want to continue? (y/n)'
        if ($confirm -ne 'y' -and $confirm -ne 'Y') {
            Write-Host 'Profile restoration cancelled.' -ForegroundColor Yellow
            return
        }
    }
    
    Write-ProfileLog 'Starting profile restoration...' 'Info'
    
    try {
        $profilePath = $PROFILE
        
        if (Test-Path $profilePath) {
            # Create backup if requested
            if ($Backup) {
                $backupPath = "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                Copy-Item -Path $profilePath -Destination $backupPath
                Write-ProfileLog "Created profile backup: $backupPath" 'Success'
            }
            
            # Remove the profile file
            Remove-Item -Path $profilePath -Force
            Write-ProfileLog 'Removed profile file' 'Success'
        } else {
            Write-ProfileLog "Profile file not found: $profilePath" 'Warning'
        }
        
        Write-ProfileLog 'Profile restoration completed' 'Success'
        Write-Host 'PowerShell profile has been restored to default state.' -ForegroundColor Green
        Write-Host 'Restart PowerShell to apply changes.' -ForegroundColor Yellow
        
        if ($Backup -and (Test-Path $backupPath)) {
            Write-Host "Backup created at: $backupPath" -ForegroundColor Cyan
        }
    } catch {
        Write-ProfileLog "Failed to restore profile: $($_.Exception.Message)" 'Error'
        Write-Host "Profile restoration failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-ProfileManagerStatus {
    <#
    .SYNOPSIS
    Gets the current status of the PowerShell Profile Manager
    
    .DESCRIPTION
    This function provides comprehensive information about the current state
    of the PowerShell Profile Manager, including loaded modules, configuration,
    and system information.
    
    .OUTPUTS
    [hashtable] Status information about the ProfileManager
    
    .EXAMPLE
    Get-ProfileManagerStatus
    Gets complete status information
    #>
    
    [CmdletBinding()]
    param()
    
    $status = @{
        ProfileManagerVersion  = '1.0.0'
        PowerShellVersion      = $PSVersionTable.PSVersion.ToString()
        ProfilePath            = $PROFILE
        ProfileExists          = Test-Path $PROFILE
        ModulesDirectory       = $ProfileManagerConfig.ModulesDirectory
        ModulesDirectoryExists = Test-Path $ProfileManagerConfig.ModulesDirectory
        AutoLoadModules        = $ProfileManagerConfig.AutoLoadModules
        LogLevel               = $ProfileManagerConfig.LogLevel
        IsCursorEnvironment    = $IsCursorEnvironment
        IsSSHSession          = $IsSSHSession
        IsNonInteractiveSession = $IsNonInteractiveSession
        ShouldSuppressOutput  = $IsSSHSession -or $IsNonInteractiveSession
        ConfiguredModules      = @()
        LoadedModules          = @()
        AvailableModules       = @()
        MissingModules         = @()
        ErrorModules           = @()
    }
    
    # Check configured modules
    foreach ($module in $ProfileModules) {
        $moduleStatus = @{
            Name        = $module.Name
            Enabled     = $module.Enabled
            Description = $module.Description
            Available   = Test-ModulePath -ModuleName $module.Name
            Loaded      = (Get-Module -Name $module.Name -ErrorAction SilentlyContinue) -ne $null
        }
        
        $status.ConfiguredModules += $moduleStatus
        
        if ($moduleStatus.Available) {
            $status.AvailableModules += $module.Name
        } else {
            $status.MissingModules += $module.Name
        }
        
        if ($moduleStatus.Loaded) {
            $status.LoadedModules += $module.Name
        }
    }
    
    # Check for modules with errors
    $loadedModules = Get-Module | Where-Object { $_.Name -in $status.LoadedModules }
    foreach ($module in $loadedModules) {
        if ($module.ExportedFunctions.Count -eq 0) {
            $status.ErrorModules += $module.Name
        }
    }
    
    return $status
}

function Test-EnvironmentDetection {
    <#
    .SYNOPSIS
    Tests the environment detection functions to help debug session types
    
    .DESCRIPTION
    This function tests all environment detection functions and displays
    the results to help understand what type of session PowerShell is running in.
    
    .EXAMPLE
    Test-EnvironmentDetection
    Tests all environment detection functions
    #>
    
    [CmdletBinding()]
    param()
    
    Write-Host "=== Environment Detection Test ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Test Cursor environment
    $cursorResult = Test-CursorEnvironment
    Write-Host "Cursor Environment: " -NoNewline -ForegroundColor White
    Write-Host $(if ($cursorResult) { "YES" } else { "NO" }) -ForegroundColor $(if ($cursorResult) { "Green" } else { "Red" })
    
    # Test SSH session
    $sshResult = Test-SSHSession
    Write-Host "SSH Session: " -NoNewline -ForegroundColor White
    Write-Host $(if ($sshResult) { "YES" } else { "NO" }) -ForegroundColor $(if ($sshResult) { "Green" } else { "Red" })
    
    # Test non-interactive session
    $nonInteractiveResult = Test-NonInteractiveSession
    Write-Host "Non-Interactive Session: " -NoNewline -ForegroundColor White
    Write-Host $(if ($nonInteractiveResult) { "YES" } else { "NO" }) -ForegroundColor $(if ($nonInteractiveResult) { "Green" } else { "Red" })
    
    # Show output suppression status
    $shouldSuppress = $IsSSHSession -or $IsNonInteractiveSession
    Write-Host "Output Suppression: " -NoNewline -ForegroundColor White
    Write-Host $(if ($shouldSuppress) { "YES" } else { "NO" }) -ForegroundColor $(if ($shouldSuppress) { "Yellow" } else { "Green" })
    
    Write-Host ""
    Write-Host "=== Environment Variables ===" -ForegroundColor Cyan
    
    # Show relevant environment variables
    $envVars = @(
        'SSH_CLIENT',
        'SSH_CONNECTION', 
        'SSH_TTY',
        'SSH_AUTH_SOCK',
        'TERM',
        'CURSOR_TRACE_ID',
        'CURSOR_AGENT',
        'VSCODE_GIT_ASKPASS_MAIN',
        'VSCODE_GIT_IPC_HANDLE',
        'WT_SESSION'
    )
    
    foreach ($var in $envVars) {
        $value = [Environment]::GetEnvironmentVariable($var)
        if ($value) {
            Write-Host "$var = $value" -ForegroundColor Green
        } else {
            Write-Host "$var = (not set)" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "=== Profile Configuration ===" -ForegroundColor Cyan
    Write-Host "Log Level: $($ProfileManagerConfig.LogLevel)" -ForegroundColor White
    Write-Host "Enable Module Logging: $($ProfileManagerConfig.EnableModuleLogging)" -ForegroundColor White
    Write-Host "Auto Load Modules: $($ProfileManagerConfig.AutoLoadModules)" -ForegroundColor White
}

function Initialize-ProfileManager {
    Write-ProfileLog 'Initializing PowerShell Profile Manager' 'Info'
    Write-ProfileLog "Modules directory: $($ProfileManagerConfig.ModulesDirectory)" 'Debug'
    
    # Check if modules directory exists
    if (-not (Test-Path $ProfileManagerConfig.ModulesDirectory)) {
        Write-ProfileLog "Modules directory not found: $($ProfileManagerConfig.ModulesDirectory)" 'Error'
        return
    }
    
    # Load enabled modules
    if ($ProfileManagerConfig.AutoLoadModules) {
        $enabledModules = $ProfileModules | Where-Object { $_.Enabled }
        
        foreach ($module in $enabledModules) {
            $success = Load-ProfileModule -ModuleName $module.Name
            if (-not $success) {
                Write-ProfileLog "Skipping module $($module.Name) due to load failure" 'Warning'
            }
        }
    }
    
    Write-ProfileLog 'Profile Manager initialization complete' 'Info'
}

# Initialize the profile manager
Initialize-ProfileManager

# Profile manager functions are now available in the global scope
