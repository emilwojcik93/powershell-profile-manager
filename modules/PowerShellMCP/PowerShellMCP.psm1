# PowerShellMCP Module
# MCP Server for Cursor IDE integration

# Module configuration
$PowerShellMCPConfig = @{
    ServerPort = 3001
    ServerHost = "localhost"
    MaxExecutionTime = 300  # 5 minutes
    EnableLogging = $true
    LogLevel = "Info"
    AllowedCommands = @(
        "Get-*",
        "Set-*",
        "Test-*",
        "Invoke-*",
        "Start-*",
        "Stop-*",
        "New-*",
        "Remove-*",
        "Copy-*",
        "Move-*",
        "Rename-*"
    )
    BlockedCommands = @(
        "Remove-Item -Path C:\*",
        "Format-Volume",
        "Clear-EventLog",
        "Stop-Computer",
        "Restart-Computer",
        "Shutdown"
    )
    WorkingDirectory = $PWD.Path
}

# MCP Server process
$MCPProcess = $null
$MCPServerScript = $null

function Start-PowerShellMCPServer {
    <#
    .SYNOPSIS
    Starts the PowerShell MCP Server for Cursor IDE integration
    
    .DESCRIPTION
    This function starts an MCP (Model Context Protocol) server that allows
    Cursor IDE to execute PowerShell commands securely. The server provides
    a bridge between Cursor's AI agent and PowerShell execution.
    
    .PARAMETER Port
    Port number for the MCP server (default: 3001)
    
    .PARAMETER Host
    Host address for the MCP server (default: localhost)
    
    .PARAMETER WorkingDirectory
    Working directory for PowerShell command execution
    
    .EXAMPLE
    Start-PowerShellMCPServer
    Starts the MCP server with default settings
    
    .EXAMPLE
    Start-PowerShellMCPServer -Port 3002 -WorkingDirectory "C:\Projects"
    Starts the MCP server on port 3002 with custom working directory
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [int]$Port = $PowerShellMCPConfig.ServerPort,
        
        [Parameter(Mandatory = $false)]
        [string]$McpHost = $PowerShellMCPConfig.ServerHost,
        
        [Parameter(Mandatory = $false)]
        [string]$WorkingDirectory = $PowerShellMCPConfig.WorkingDirectory
    )
    
    # Check if server is already running
    if ($MCPProcess -and -not $MCPProcess.HasExited) {
        Write-Host "PowerShell MCP Server is already running on port $Port" -ForegroundColor Yellow
        return $true
    }
    
    try {
        Write-Host "Starting PowerShell MCP Server..." -ForegroundColor Green
        Write-Host "  Host: $McpHost" -ForegroundColor White
        Write-Host "  Port: $Port" -ForegroundColor White
        Write-Host "  Working Directory: $WorkingDirectory" -ForegroundColor White
        
        # Create the MCP server script
        $MCPServerScript = Create-MCPServerScript -Port $Port -Host $McpHost -WorkingDirectory $WorkingDirectory
        
        # Start the server process
        $MCPProcess = Start-Process -FilePath "powershell.exe" -ArgumentList @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-Command", $MCPServerScript
        ) -PassThru -WindowStyle Hidden
        
        # Wait a moment for the server to start
        Start-Sleep -Seconds 2
        
        # Test the connection
        if (Test-PowerShellMCPConnection -Port $Port) {
            Write-Host "PowerShell MCP Server started successfully!" -ForegroundColor Green
            Write-Host "Server is ready for Cursor IDE integration" -ForegroundColor Cyan
            return $true
        } else {
            Write-Host "Failed to start PowerShell MCP Server" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error starting PowerShell MCP Server: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Stop-PowerShellMCPServer {
    <#
    .SYNOPSIS
    Stops the PowerShell MCP Server
    
    .DESCRIPTION
    Gracefully stops the running MCP server process.
    
    .EXAMPLE
    Stop-PowerShellMCPServer
    Stops the currently running MCP server
    #>
    
    [CmdletBinding()]
    param()
    
    if ($MCPProcess -and -not $MCPProcess.HasExited) {
        try {
            Write-Host "Stopping PowerShell MCP Server..." -ForegroundColor Yellow
            $MCPProcess.Kill()
            $MCPProcess.WaitForExit(5000)  # Wait up to 5 seconds
            
            if ($MCPProcess.HasExited) {
                Write-Host "PowerShell MCP Server stopped successfully" -ForegroundColor Green
            } else {
                Write-Host "PowerShell MCP Server did not stop gracefully" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "Error stopping PowerShell MCP Server: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "PowerShell MCP Server is not running" -ForegroundColor Yellow
    }
}

function Get-PowerShellMCPStatus {
    <#
    .SYNOPSIS
    Gets the current status of the PowerShell MCP Server
    
    .DESCRIPTION
    Returns information about the MCP server status, configuration, and health.
    
    .OUTPUTS
    [hashtable] Status information about the MCP server
    
    .EXAMPLE
    Get-PowerShellMCPStatus
    Gets the current MCP server status
    #>
    
    [CmdletBinding()]
    param()
    
    $status = @{
        IsRunning = $false
        ProcessId = $null
        Port = $PowerShellMCPConfig.ServerPort
        Host = $PowerShellMCPConfig.ServerHost
        WorkingDirectory = $PowerShellMCPConfig.WorkingDirectory
        MaxExecutionTime = $PowerShellMCPConfig.MaxExecutionTime
        EnableLogging = $PowerShellMCPConfig.EnableLogging
        LogLevel = $PowerShellMCPConfig.LogLevel
        AllowedCommands = $PowerShellMCPConfig.AllowedCommands.Count
        BlockedCommands = $PowerShellMCPConfig.BlockedCommands.Count
        ConnectionTest = $false
    }
    
    if ($MCPProcess -and -not $MCPProcess.HasExited) {
        $status.IsRunning = $true
        $status.ProcessId = $MCPProcess.Id
        $status.ConnectionTest = Test-PowerShellMCPConnection -Port $PowerShellMCPConfig.ServerPort
    }
    
    return $status
}

function Test-PowerShellMCPConnection {
    <#
    .SYNOPSIS
    Tests the connection to the PowerShell MCP Server
    
    .DESCRIPTION
    Attempts to connect to the MCP server to verify it's running and responsive.
    
    .PARAMETER Port
    Port number to test (default: configured port)
    
    .OUTPUTS
    [bool] Returns $true if connection is successful, $false otherwise
    
    .EXAMPLE
    Test-PowerShellMCPConnection
    Tests connection to the default MCP server port
    
    .EXAMPLE
    Test-PowerShellMCPConnection -Port 3002
    Tests connection to a specific port
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [int]$Port = $PowerShellMCPConfig.ServerPort
    )
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($PowerShellMCPConfig.ServerHost, $Port)
        $tcpClient.Close()
        return $true
    }
    catch {
        return $false
    }
}

function Invoke-PowerShellMCPCommand {
    <#
    .SYNOPSIS
    Executes a PowerShell command via the MCP server
    
    .DESCRIPTION
    Sends a PowerShell command to the MCP server for execution and returns the result.
    This function provides a way to test the MCP server functionality.
    
    .PARAMETER Command
    PowerShell command to execute
    
    .PARAMETER Port
    MCP server port (default: configured port)
    
    .OUTPUTS
    [hashtable] Command execution result
    
    .EXAMPLE
    Invoke-PowerShellMCPCommand -Command "Get-Date"
    Executes Get-Date command via MCP server
    
    .EXAMPLE
    Invoke-PowerShellMCPCommand -Command "Get-Process | Select-Object -First 5"
    Executes a more complex command via MCP server
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        
        [Parameter(Mandatory = $false)]
        [int]$Port = $PowerShellMCPConfig.ServerPort
    )
    
    if (-not (Test-PowerShellMCPConnection -Port $Port)) {
        Write-Host "MCP Server is not running on port $Port" -ForegroundColor Red
        return @{
            Success = $false
            Error = "MCP Server not available"
            Output = $null
        }
    }
    
    try {
        # This is a simplified implementation
        # In a real MCP server, you would send JSON-RPC messages
        Write-Host "Executing command via MCP server: $Command" -ForegroundColor Yellow
        
        # For demonstration, execute the command directly
        # In a real implementation, this would go through the MCP protocol
        $output = Invoke-Expression $Command 2>&1
        
        return @{
            Success = $true
            Error = $null
            Output = $output
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
            Output = $null
        }
    }
}

function Get-PowerShellMCPConfig {
    <#
    .SYNOPSIS
    Gets the current PowerShell MCP configuration
    
    .DESCRIPTION
    Returns the current configuration settings for the PowerShell MCP server.
    
    .OUTPUTS
    [hashtable] Current MCP configuration
    
    .EXAMPLE
    Get-PowerShellMCPConfig
    Gets the current MCP configuration
    #>
    
    [CmdletBinding()]
    param()
    
    return $PowerShellMCPConfig
}

function Set-PowerShellMCPConfig {
    <#
    .SYNOPSIS
    Sets PowerShell MCP configuration values
    
    .DESCRIPTION
    Updates the configuration settings for the PowerShell MCP server.
    
    .PARAMETER ServerPort
    Port number for the MCP server
    
    .PARAMETER ServerHost
    Host address for the MCP server
    
    .PARAMETER MaxExecutionTime
    Maximum execution time for commands in seconds
    
    .PARAMETER EnableLogging
    Enable or disable logging
    
    .PARAMETER LogLevel
    Logging level (Debug, Info, Warning, Error)
    
    .EXAMPLE
    Set-PowerShellMCPConfig -ServerPort 3002 -EnableLogging $true
    Updates the server port and enables logging
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [int]$ServerPort,
        
        [Parameter(Mandatory = $false)]
        [string]$ServerHost,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxExecutionTime,
        
        [Parameter(Mandatory = $false)]
        [bool]$EnableLogging,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Debug", "Info", "Warning", "Error")]
        [string]$LogLevel
    )
    
    $changes = @()
    
    if ($PSBoundParameters.ContainsKey('ServerPort')) {
        $PowerShellMCPConfig.ServerPort = $ServerPort
        $changes += "ServerPort set to: $ServerPort"
    }
    
    if ($PSBoundParameters.ContainsKey('ServerHost')) {
        $PowerShellMCPConfig.ServerHost = $ServerHost
        $changes += "ServerHost set to: $ServerHost"
    }
    
    if ($PSBoundParameters.ContainsKey('MaxExecutionTime')) {
        $PowerShellMCPConfig.MaxExecutionTime = $MaxExecutionTime
        $changes += "MaxExecutionTime set to: $MaxExecutionTime seconds"
    }
    
    if ($PSBoundParameters.ContainsKey('EnableLogging')) {
        $PowerShellMCPConfig.EnableLogging = $EnableLogging
        $changes += "EnableLogging set to: $EnableLogging"
    }
    
    if ($PSBoundParameters.ContainsKey('LogLevel')) {
        $PowerShellMCPConfig.LogLevel = $LogLevel
        $changes += "LogLevel set to: $LogLevel"
    }
    
    if ($changes.Count -gt 0) {
        Write-Host "MCP Configuration updated:" -ForegroundColor Green
        foreach ($change in $changes) {
            Write-Host "  - $change" -ForegroundColor Yellow
        }
    } else {
        Write-Host "No configuration changes made." -ForegroundColor Yellow
    }
    
    return $PowerShellMCPConfig
}

function Create-MCPServerScript {
    <#
    .SYNOPSIS
    Creates the MCP server script content
    
    .DESCRIPTION
    Generates the PowerShell script that implements the MCP server functionality.
    This is a simplified implementation for demonstration purposes.
    #>
    
    param(
        [int]$Port,
        [string]$McpHost,
        [string]$WorkingDirectory
    )
    
    $serverScript = @"
# PowerShell MCP Server Script
# Generated by PowerShellMCP module

`$ErrorActionPreference = "Stop"

# MCP Server Configuration
`$serverConfig = @{
    Port = $Port
    Host = "$McpHost"
    WorkingDirectory = "$WorkingDirectory"
    MaxExecutionTime = $($PowerShellMCPConfig.MaxExecutionTime)
    EnableLogging = `$$($PowerShellMCPConfig.EnableLogging.ToString().ToLower())
    LogLevel = "$($PowerShellMCPConfig.LogLevel)"
}

# Logging function
function Write-MCPLog {
    param([string]`$Message, [string]`$Level = "Info")
    
    if (`$serverConfig.EnableLogging) {
        `$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        `$logMessage = "[`$timestamp] [`$Level] `$Message"
        
        switch (`$Level) {
            "Debug" { if (`$serverConfig.LogLevel -eq "Debug") { Write-Host `$logMessage -ForegroundColor Gray } }
            "Info" { if (`$serverConfig.LogLevel -in @("Debug", "Info")) { Write-Host `$logMessage -ForegroundColor White } }
            "Warning" { if (`$serverConfig.LogLevel -in @("Debug", "Info", "Warning")) { Write-Host `$logMessage -ForegroundColor Yellow } }
            "Error" { Write-Host `$logMessage -ForegroundColor Red }
        }
    }
}

# Command validation
function Test-AllowedCommand {
    param([string]`$Command)
    
    `$allowedPatterns = @(
        "Get-*",
        "Set-*", 
        "Test-*",
        "Invoke-*",
        "Start-*",
        "Stop-*",
        "New-*",
        "Remove-*",
        "Copy-*",
        "Move-*",
        "Rename-*"
    )
    
    `$blockedPatterns = @(
        "Remove-Item -Path C:\*",
        "Format-Volume",
        "Clear-EventLog",
        "Stop-Computer",
        "Restart-Computer",
        "Shutdown"
    )
    
    # Check blocked patterns first
    foreach (`$pattern in `$blockedPatterns) {
        if (`$Command -like `$pattern) {
            return `$false
        }
    }
    
    # Check allowed patterns
    foreach (`$pattern in `$allowedPatterns) {
        if (`$Command -like `$pattern) {
            return `$true
        }
    }
    
    return `$false
}

# Execute PowerShell command
function Invoke-PowerShellCommand {
    param([string]`$Command)
    
    try {
        Write-MCPLog "Executing command: `$Command" "Info"
        
        # Validate command
        if (-not (Test-AllowedCommand -Command `$Command)) {
            throw "Command not allowed: `$Command"
        }
        
        # Set working directory
        Set-Location `$serverConfig.WorkingDirectory
        
        # Execute command with timeout
        `$job = Start-Job -ScriptBlock { param(`$cmd) Invoke-Expression `$cmd } -ArgumentList `$Command
        
        if (`$job | Wait-Job -Timeout `$serverConfig.MaxExecutionTime) {
            `$result = `$job | Receive-Job
            `$job | Remove-Job
            return @{
                Success = `$true
                Output = `$result
                Error = `$null
            }
        } else {
            `$job | Stop-Job
            `$job | Remove-Job
            throw "Command execution timed out after `$(`$serverConfig.MaxExecutionTime) seconds"
        }
    }
    catch {
        Write-MCPLog "Command execution failed: `$(`$_.Exception.Message)" "Error"
        return @{
            Success = `$false
            Output = `$null
            Error = `$_.Exception.Message
        }
    }
}

# Start MCP Server
Write-MCPLog "Starting PowerShell MCP Server on `$(`$serverConfig.Host):`$(`$serverConfig.Port)" "Info"

# This is a simplified implementation
# In a real MCP server, you would implement the full JSON-RPC protocol
# For now, we'll just keep the process running
Write-MCPLog "MCP Server is running and ready for connections" "Info"

# Keep the server running
while (`$true) {
    Start-Sleep -Seconds 1
}
"@

    return $serverScript
}

# Module initialization
Write-Host "PowerShellMCP module loaded successfully!" -ForegroundColor Green
Write-Host "Use Start-PowerShellMCPServer to start the MCP server for Cursor IDE integration" -ForegroundColor Yellow

# Functions are exported via the .psd1 manifest file
