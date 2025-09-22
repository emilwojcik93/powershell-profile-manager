# PowerShell Development Instructions

## PowerShell 5.x Compatibility Standards

### Variable Syntax with Special Characters
Always use bracket notation when variables are near special characters to avoid syntax errors:

```powershell
# CORRECT - Use brackets for special characters
$path = "${env:TEMP}\file.txt"
$url = "https://${host}:${port}/api"
$command = "${exe} --config=${config}"
$output = "${var}%"

# INCORRECT - Can cause syntax errors
$path = "$env:TEMP\file.txt"  # Backslash issue
$url = "https://$host:$port/api"  # Colon issue
$command = "$exe --config=$config"  # Space issue
$output = "$var%"  # Percent issue
```

### Path Handling
Use proper path construction with brackets:

```powershell
# CORRECT
$installPath = "${env:ProgramFiles}\MyApp"
$configFile = "${installPath}\config.json"
$logFile = "${env:TEMP}\install.log"

# INCORRECT
$installPath = "$env:ProgramFiles\MyApp"  # Backslash issue
$configFile = "$installPath\config.json"  # Backslash issue
```

### Error Handling Patterns
Implement comprehensive error handling:

```powershell
function Install-Something {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InstallPath
    )
    
    try {
        # Validate input
        if (-not (Test-Path $InstallPath -PathType Container)) {
            New-Item -ItemType Directory -Path $InstallPath -Force -ErrorAction Stop
        }
        
        # Main operation
        Write-Host "Installing to: ${InstallPath}" -ForegroundColor Green
        
        # Critical operations with error handling
        $result = Some-CriticalOperation -Path "${InstallPath}" -ErrorAction Stop
        
        Write-Host "Installation completed successfully" -ForegroundColor Green
        return $result
        
    } catch {
        Write-Error "Installation failed: $($_.Exception.Message)"
        return $false
    }
}
```

### Cursor Environment Detection
Always include Cursor environment detection and optimization:

```powershell
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

# Use in main profile
if (Test-CursorEnvironment) {
    # Optimize for agent sessions
    $LogLevel = "Warning"
    $EnableModuleLogging = $false
    $AutoLoadModules = $true
}
```

### Module Development Standards
Follow proper module structure:

```powershell
# Module manifest (.psd1)
@{
    RootModule = 'MyModule.psm1'
    ModuleVersion = '1.0.0'
    Author = 'Your Name'
    Description = 'Module description'
    FunctionsToExport = @('Get-Something', 'Set-Something')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
}

# Module script (.psm1)
function Get-Something {
    <#
    .SYNOPSIS
    Gets something important
    
    .DESCRIPTION
    Detailed description of what this function does
    
    .PARAMETER Name
    The name of the thing to get
    
    .EXAMPLE
    Get-Something -Name "Test"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    
    try {
        # Implementation here
        Write-Host "Getting: ${Name}" -ForegroundColor Green
        return $result
    } catch {
        Write-Error "Failed to get ${Name}: $($_.Exception.Message)"
    }
}

# Export functions
Export-ModuleMember -Function Get-Something
```

### GitHub Actions PowerShell Scripts
Use proper syntax for GitHub Actions:

```powershell
# CORRECT - Use brackets and proper error handling
Write-Host "Starting installation..." -ForegroundColor Green

try {
    $installPath = "${env:RUNNER_TEMP}\install"
    New-Item -ItemType Directory -Path $installPath -Force -ErrorAction Stop
    
    $result = & ".\scripts\install.ps1" -InstallPath $installPath -Silent -Force 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Installation successful" -ForegroundColor Green
    } else {
        Write-Host "Installation failed: $result" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Exception: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

### Self-Elevation Pattern
Implement WinUtil-style self-elevation:

```powershell
function Test-Administrator {
    <#
    .SYNOPSIS
    Tests if the current session is running as Administrator
    #>
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Start-ElevatedProcess {
    <#
    .SYNOPSIS
    Starts the current script with elevated privileges
    #>
    param(
        [string]$Arguments = ""
    )
    
    if (-not (Test-Administrator)) {
        Write-Host "Elevating privileges..." -ForegroundColor Yellow
        Start-Process PowerShell -ArgumentList "-ExecutionPolicy Bypass -File `"${PSCommandPath}`" ${Arguments}" -Verb RunAs
        exit
    }
}
```

### Output and Logging Standards
Use consistent output formatting:

```powershell
function Write-InstallLog {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "Error" { "Red" }
        "Warning" { "Yellow" }
        "Success" { "Green" }
        default { "White" }
    }
    
    Write-Host "[${timestamp}] ${Message}" -ForegroundColor $color
}

# Usage
Write-InstallLog "Starting installation" "Info"
Write-InstallLog "Installation completed" "Success"
Write-InstallLog "Installation failed" "Error"
```

### Parameter Validation
Always include proper parameter validation:

```powershell
function Install-Module {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("CurrentUser", "AllUsers")]
        [string]$Scope = "CurrentUser",
        
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    
    # Parameter validation
    if ($ModuleName -match '[<>:"|?*]') {
        throw "Invalid module name: ${ModuleName}. Contains invalid characters."
    }
    
    # Implementation
}
```

### UTF-8/ASCII Compliance
Never use Unicode characters in source files:

```powershell
# CORRECT - ASCII only
Write-Host "Starting installation..." -ForegroundColor Green
Write-Host "Installation completed successfully" -ForegroundColor Green
Write-Host "Warning: This may take several minutes" -ForegroundColor Yellow

# INCORRECT - Unicode characters
Write-Host "🚀 Starting installation..." -ForegroundColor Green
Write-Host "✅ Installation completed successfully" -ForegroundColor Green
Write-Host "⚠️ Warning: This may take several minutes" -ForegroundColor Yellow
```

### Background Agent Integration
Include agent-friendly patterns:

```powershell
function Write-AgentLog {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $emoji = switch ($Level) {
        "Error" { "ERROR" }
        "Warning" { "WARN" }
        "Success" { "SUCCESS" }
        "Fix" { "FIX" }
        default { "INFO" }
    }
    
    Write-Host "[${timestamp}] ${emoji} ${Message}" -ForegroundColor $(
        switch ($Level) {
            "Error" { "Red" }
            "Warning" { "Yellow" }
            "Success" { "Green" }
            "Fix" { "Magenta" }
            default { "White" }
        }
    )
}
```

## Best Practices Summary

1. **Always use `${variable}` bracket notation for variables near special characters**
2. **Include comprehensive error handling with try-catch blocks**
3. **Use proper parameter validation and help documentation**
4. **Test for Cursor environment and optimize accordingly**
5. **Use UTF-8/ASCII characters only - no Unicode or emojis**
6. **Implement self-elevation for admin operations**
7. **Use consistent logging and output formatting**
8. **Follow Infrastructure as Code principles**
9. **Include proper module structure and exports**
10. **Test scripts in both interactive and silent modes**
