# PowerShell Profile Manager Installation Script
# This script installs the PowerShell Profile Manager and its modules

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$InstallPath = "$env:USERPROFILE\PowerShell\ProfileManager",
    
    [Parameter(Mandatory = $false)]
    [string[]]$Modules = @("VideoCompressor"),
    
    [Parameter(Mandatory = $false)]
    [switch]$Silent,
    
    [Parameter(Mandatory = $false)]
    [string]$RepositoryUrl = "https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main",
    
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# Set error action preference
$ErrorActionPreference = if ($Silent) { "SilentlyContinue" } else { "Stop" }

function Write-InstallLog {
    param(
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info"
    )
    
    if (-not $Silent) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $logMessage = "[$timestamp] $Message"
        
        switch ($Level) {
            "Info" { Write-Host $logMessage -ForegroundColor White }
            "Success" { Write-Host $logMessage -ForegroundColor Green }
            "Warning" { Write-Host $logMessage -ForegroundColor Yellow }
            "Error" { Write-Host $logMessage -ForegroundColor Red }
        }
    }
}

function Test-InternetConnection {
    try {
        $response = Invoke-WebRequest -Uri "https://www.google.com" -TimeoutSec 5 -UseBasicParsing
        return $response.StatusCode -eq 200
    }
    catch {
        return $false
    }
}

function Test-CursorEnvironment {
    <#
    .SYNOPSIS
    Detects if PowerShell is running within Cursor IDE environment
    #>
    
    $cursorIndicators = @(
        $env:CURSOR_TRACE_ID,
        $env:VSCODE_GIT_ASKPASS_MAIN,
        $env:VSCODE_GIT_IPC_HANDLE,
        $env:VSCODE_GIT_ASKPASS_NODE,
        $env:VSCODE_INJECTION
    )
    
    return ($cursorIndicators | Where-Object { $_ -ne $null }).Count -gt 0
}

function Get-ProfilePath {
    # Determine the correct profile path based on PowerShell version
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        # PowerShell 7+
        return "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    } else {
        # Windows PowerShell 5.1
        return "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    }
}

function Install-ProfileManager {
    Write-InstallLog "Starting PowerShell Profile Manager installation..." "Info"
    
    # Check internet connection
    if (-not (Test-InternetConnection)) {
        Write-InstallLog "No internet connection available. Cannot download files." "Error"
        return $false
    }
    
    # Create installation directory
    Write-InstallLog "Creating installation directory: $InstallPath" "Info"
    try {
        if (Test-Path $InstallPath) {
            if ($Force) {
                Remove-Item -Path $InstallPath -Recurse -Force
                Write-InstallLog "Removed existing installation directory" "Warning"
            } else {
                Write-InstallLog "Installation directory already exists. Use -Force to overwrite." "Warning"
                return $false
            }
        }
        
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        New-Item -ItemType Directory -Path "$InstallPath\modules" -Force | Out-Null
        New-Item -ItemType Directory -Path "$InstallPath\docs" -Force | Out-Null
        Write-InstallLog "Created installation directories" "Success"
    }
    catch {
        Write-InstallLog "Failed to create installation directory: $($_.Exception.Message)" "Error"
        return $false
    }
    
    # Download main profile script
    Write-InstallLog "Downloading main profile script..." "Info"
    try {
        $profileScriptUrl = "$RepositoryUrl/Microsoft.PowerShell_profile.ps1"
        $profileScriptPath = Join-Path $InstallPath "Microsoft.PowerShell_profile.ps1"
        
        Invoke-WebRequest -Uri $profileScriptUrl -OutFile $profileScriptPath -UseBasicParsing
        Write-InstallLog "Downloaded main profile script" "Success"
    }
    catch {
        Write-InstallLog "Failed to download main profile script: $($_.Exception.Message)" "Error"
        return $false
    }
    
    # Download installation scripts
    Write-InstallLog "Downloading installation scripts..." "Info"
    try {
        $scriptsDir = Join-Path $InstallPath "scripts"
        New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
        
        $scriptFiles = @("install.ps1", "uninstall.ps1", "release.ps1")
        foreach ($scriptFile in $scriptFiles) {
            $scriptUrl = "$RepositoryUrl/scripts/$scriptFile"
            $scriptPath = Join-Path $scriptsDir $scriptFile
            
            try {
                Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath -UseBasicParsing
                Write-InstallLog "  Downloaded $scriptFile" "Success"
            }
            catch {
                Write-InstallLog "  Failed to download ${scriptFile}: $($_.Exception.Message)" "Warning"
            }
        }
    }
    catch {
        Write-InstallLog "Failed to download installation scripts: $($_.Exception.Message)" "Warning"
    }
    
    # Download modules
    foreach ($module in $Modules) {
        Write-InstallLog "Downloading module: $module" "Info"
        try {
            $modulePath = Join-Path $InstallPath "modules\$module"
            New-Item -ItemType Directory -Path $modulePath -Force | Out-Null
            
            # Download module files
            $moduleFiles = @("$module.psm1", "$module.psd1", "README.md")
            foreach ($file in $moduleFiles) {
                $fileUrl = "$RepositoryUrl/modules/$module/$file"
                $filePath = Join-Path $modulePath $file
                
                try {
                    Invoke-WebRequest -Uri $fileUrl -OutFile $filePath -UseBasicParsing
                    Write-InstallLog "  Downloaded $file" "Success"
                }
                catch {
                    Write-InstallLog "  Failed to download ${file}: $($_.Exception.Message)" "Warning"
                }
            }
        }
        catch {
            Write-InstallLog "Failed to download module $module`: $($_.Exception.Message)" "Error"
        }
    }
    
    # Download PowerShellMCP module if not in Modules list but Cursor environment detected
    if ($Modules -notcontains "PowerShellMCP" -and (Test-CursorEnvironment)) {
        Write-InstallLog "Cursor environment detected - downloading PowerShellMCP module..." "Info"
        try {
            $modulePath = Join-Path $InstallPath "modules\PowerShellMCP"
            New-Item -ItemType Directory -Path $modulePath -Force | Out-Null
            
            $moduleFiles = @("PowerShellMCP.psm1", "PowerShellMCP.psd1", "README.md")
            foreach ($file in $moduleFiles) {
                $fileUrl = "$RepositoryUrl/modules/PowerShellMCP/$file"
                $filePath = Join-Path $modulePath $file
                
                try {
                    Invoke-WebRequest -Uri $fileUrl -OutFile $filePath -UseBasicParsing
                    Write-InstallLog "  Downloaded $file" "Success"
                }
                catch {
                    Write-InstallLog "  Failed to download ${file}: $($_.Exception.Message)" "Warning"
                }
            }
        }
        catch {
            Write-InstallLog "Failed to download PowerShellMCP module: $($_.Exception.Message)" "Warning"
        }
    }
    
    # Download documentation
    Write-InstallLog "Downloading documentation..." "Info"
    try {
        $docFiles = @("installation.md", "module-development.md", "troubleshooting.md")
        foreach ($docFile in $docFiles) {
            $docUrl = "${RepositoryUrl}/docs/${docFile}"
            $docPath = Join-Path "${InstallPath}\docs" $docFile
            
            try {
                Invoke-WebRequest -Uri $docUrl -OutFile $docPath -UseBasicParsing
                Write-InstallLog "  Downloaded $docFile" "Success"
            }
            catch {
                Write-InstallLog "  Failed to download ${docFile}: $($_.Exception.Message)" "Warning"
            }
        }
    }
    catch {
        Write-InstallLog "Failed to download documentation: $($_.Exception.Message)" "Warning"
    }
    
    return $true
}

function Configure-Profile {
    Write-InstallLog "Configuring PowerShell profile..." "Info"
    
    try {
        $profilePath = Get-ProfilePath
        $profileDir = Split-Path $profilePath -Parent
        
        # Create profile directory if it doesn't exist
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
            Write-InstallLog "Created profile directory: $profileDir" "Success"
        }
        
        # Check if profile manager is already configured
        $profileContent = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { "" }
        
        if ($profileContent -like "*ProfileManager*") {
            if ($Force) {
                Write-InstallLog "Removing existing ProfileManager configuration..." "Warning"
                $profileContent = $profileContent -replace "(?s)# PowerShell Profile Manager.*?\. '$InstallPath.*?\n", ""
                $profileContent = $profileContent -replace "(?s)\. '$InstallPath.*?\n", ""
            } else {
                Write-InstallLog "ProfileManager is already configured. Use -Force to reconfigure." "Warning"
                return $true
            }
        }
        
        # Add profile manager configuration
        $profileManagerConfig = @"

# PowerShell Profile Manager
. '$InstallPath\Microsoft.PowerShell_profile.ps1'
"@
        
        $newProfileContent = $profileContent + $profileManagerConfig
        Set-Content -Path $profilePath -Value $newProfileContent -Encoding UTF8
        
        Write-InstallLog "Configured PowerShell profile: $profilePath" "Success"
        return $true
    }
    catch {
        Write-InstallLog "Failed to configure PowerShell profile: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Test-Installation {
    Write-InstallLog "Testing installation..." "Info"
    
    try {
        # Test profile loading
        $profilePath = Get-ProfilePath
        if (-not (Test-Path $profilePath)) {
            Write-InstallLog "Profile file not found: $profilePath" "Error"
            return $false
        }
        
        # Test module loading
        $profileScriptPath = Join-Path $InstallPath "Microsoft.PowerShell_profile.ps1"
        if (-not (Test-Path $profileScriptPath)) {
            Write-InstallLog "Profile script not found: $profileScriptPath" "Error"
            return $false
        }
        
        # Test module files
        foreach ($module in $Modules) {
            $modulePath = Join-Path $InstallPath "modules\$module"
            $moduleFile = Join-Path $modulePath "$module.psm1"
            
            if (-not (Test-Path $moduleFile)) {
                Write-InstallLog "Module file not found: $moduleFile" "Error"
                return $false
            }
        }
        
        Write-InstallLog "Installation test passed" "Success"
        return $true
    }
    catch {
        Write-InstallLog "Installation test failed: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Show-InstallationSummary {
    Write-InstallLog "Installation Summary:" "Info"
    Write-InstallLog "  Installation Path: $InstallPath" "Info"
    Write-InstallLog "  Profile Path: $(Get-ProfilePath)" "Info"
    Write-InstallLog "  Installed Modules: $($Modules -join ', ')" "Info"
    Write-InstallLog "  Repository URL: $RepositoryUrl" "Info"
    
    Write-InstallLog "`nNext Steps:" "Info"
    Write-InstallLog "  1. Restart PowerShell or run: . `$PROFILE" "Info"
    Write-InstallLog "  2. Test installation: Get-ProfileModules" "Info"
    Write-InstallLog "  3. Check module status: Get-ProfileModuleStatus VideoCompressor" "Info"
    
    if (-not $Silent) {
        $restart = Read-Host "`nRestart PowerShell now? (y/n)"
        if ($restart -eq 'y' -or $restart -eq 'Y') {
            Write-InstallLog "Restarting PowerShell..." "Info"
            Start-Process PowerShell -ArgumentList "-NoExit", "-Command", ". `$PROFILE; Get-ProfileModules"
        }
    }
}

# Main installation process
try {
    Write-InstallLog "PowerShell Profile Manager Installer" "Info"
    Write-InstallLog "=====================================" "Info"
    
    # Install profile manager
    if (-not (Install-ProfileManager)) {
        Write-InstallLog "Installation failed" "Error"
        exit 1
    }
    
    # Configure profile
    if (-not (Configure-Profile)) {
        Write-InstallLog "Profile configuration failed" "Error"
        exit 1
    }
    
    # Test installation
    if (-not (Test-Installation)) {
        Write-InstallLog "Installation test failed" "Error"
        exit 1
    }
    
    # Show summary
    Show-InstallationSummary
    
    Write-InstallLog "Installation completed successfully!" "Success"
}
catch {
    Write-InstallLog "Installation failed with error: $($_.Exception.Message)" "Error"
    exit 1
}
