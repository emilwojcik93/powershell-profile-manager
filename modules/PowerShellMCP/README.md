# PowerShellMCP Module

A PowerShell module that provides MCP (Model Context Protocol) server functionality for Cursor IDE integration, enabling secure PowerShell command execution through AI agents.

## Features

- **MCP Server Implementation**: Full MCP protocol support for Cursor IDE
- **Secure Command Execution**: Command validation and sandboxing
- **Real-time Output**: Streaming command results
- **Configurable Security**: Allow/block command patterns
- **Process Management**: Start/stop server with health monitoring
- **Cursor Integration**: Optimized for Cursor IDE agent sessions

## Functions

### Start-PowerShellMCPServer

Starts the PowerShell MCP Server for Cursor IDE integration.

```powershell
# Start with default settings
Start-PowerShellMCPServer

# Start with custom configuration
Start-PowerShellMCPServer -Port 3002 -WorkingDirectory "C:\Projects"
```

**Parameters:**
- `Port` (Optional): Server port (default: 3001)
- `Host` (Optional): Server host (default: localhost)
- `WorkingDirectory` (Optional): Working directory for commands

### Stop-PowerShellMCPServer

Stops the running MCP server.

```powershell
Stop-PowerShellMCPServer
```

### Get-PowerShellMCPStatus

Gets comprehensive status information about the MCP server.

```powershell
$status = Get-PowerShellMCPStatus
$status | Format-List
```

### Test-PowerShellMCPConnection

Tests connectivity to the MCP server.

```powershell
# Test default port
Test-PowerShellMCPConnection

# Test specific port
Test-PowerShellMCPConnection -Port 3002
```

### Invoke-PowerShellMCPCommand

Executes PowerShell commands via the MCP server.

```powershell
# Execute simple command
$result = Invoke-PowerShellMCPCommand -Command "Get-Date"

# Execute complex command
$result = Invoke-PowerShellMCPCommand -Command "Get-Process | Select-Object -First 5"
```

### Configuration Management

```powershell
# Get current configuration
Get-PowerShellMCPConfig

# Update configuration
Set-PowerShellMCPConfig -ServerPort 3002 -EnableLogging $true -LogLevel "Debug"
```

## Cursor IDE Integration

### Setup

1. **Install the module** (via Profile Manager)
2. **Start the MCP server**:
   ```powershell
   Start-PowerShellMCPServer
   ```

3. **Configure Cursor IDE**:
   - Open Cursor IDE
   - Go to Settings → Extensions → MCP
   - Add new MCP server configuration:
   ```json
   {
     "servers": {
       "powershell-mcp": {
         "command": "powershell.exe",
         "args": [
           "-NoProfile",
           "-ExecutionPolicy", "Bypass",
           "-Command", "Start-PowerShellMCPServer"
         ],
         "env": {}
       }
     }
   }
   ```

### Usage in Cursor

Once configured, you can use PowerShell commands in Cursor's AI agent:

```
# In Cursor chat
"Execute Get-Process to show running processes"
"Run Get-ChildItem to list files in current directory"
"Check system information with Get-ComputerInfo"
```

## Security Features

### Command Validation

The module includes built-in security measures:

**Allowed Commands:**
- `Get-*` - Information retrieval commands
- `Set-*` - Configuration commands
- `Test-*` - Testing and validation commands
- `Invoke-*` - Execution commands
- `Start-*`, `Stop-*` - Process management
- `New-*`, `Remove-*` - Object management
- `Copy-*`, `Move-*`, `Rename-*` - File operations

**Blocked Commands:**
- `Remove-Item -Path C:\*` - Dangerous file deletion
- `Format-Volume` - Disk formatting
- `Clear-EventLog` - System log clearing
- `Stop-Computer`, `Restart-Computer` - System shutdown
- `Shutdown` - System shutdown

### Execution Limits

- **Timeout Protection**: Commands timeout after 5 minutes (configurable)
- **Working Directory**: Commands execute in a controlled directory
- **Process Isolation**: Commands run in separate PowerShell processes

## Configuration

### Default Configuration

```powershell
$PowerShellMCPConfig = @{
    ServerPort = 3001
    ServerHost = "localhost"
    MaxExecutionTime = 300  # 5 minutes
    EnableLogging = $true
    LogLevel = "Info"
    WorkingDirectory = $PWD.Path
    AllowedCommands = @("Get-*", "Set-*", "Test-*", ...)
    BlockedCommands = @("Remove-Item -Path C:\*", ...)
}
```

### Customization

```powershell
# Update configuration
Set-PowerShellMCPConfig -ServerPort 3002 -MaxExecutionTime 600 -LogLevel "Debug"

# Add custom allowed commands
$config = Get-PowerShellMCPConfig
$config.AllowedCommands += "Custom-*"

# Add custom blocked commands
$config.BlockedCommands += "Dangerous-Command"
```

## Troubleshooting

### Common Issues

#### Server Won't Start
```powershell
# Check if port is in use
Test-NetConnection -ComputerName localhost -Port 3001

# Try different port
Start-PowerShellMCPServer -Port 3002
```

#### Connection Failed
```powershell
# Test connection
Test-PowerShellMCPConnection

# Check server status
Get-PowerShellMCPStatus
```

#### Command Execution Failed
```powershell
# Check if command is allowed
$config = Get-PowerShellMCPConfig
$config.AllowedCommands

# Test with simple command
Invoke-PowerShellMCPCommand -Command "Get-Date"
```

### Debug Mode

Enable debug logging for troubleshooting:

```powershell
Set-PowerShellMCPConfig -EnableLogging $true -LogLevel "Debug"
Start-PowerShellMCPServer
```

## Examples

### Basic Usage

```powershell
# Start server
Start-PowerShellMCPServer

# Check status
$status = Get-PowerShellMCPStatus
Write-Host "Server running: $($status.IsRunning)"
Write-Host "Port: $($status.Port)"

# Execute commands
$result = Invoke-PowerShellMCPCommand -Command "Get-Process | Select-Object -First 3"
$result.Output

# Stop server
Stop-PowerShellMCPServer
```

### Advanced Configuration

```powershell
# Custom configuration
Set-PowerShellMCPConfig -ServerPort 3002 -MaxExecutionTime 600 -LogLevel "Debug"

# Start with custom working directory
Start-PowerShellMCPServer -Port 3002 -WorkingDirectory "C:\Projects\MyProject"

# Test connection
if (Test-PowerShellMCPConnection -Port 3002) {
    Write-Host "MCP Server is ready!" -ForegroundColor Green
}
```

### Integration with Profile Manager

```powershell
# Auto-start MCP server in Cursor environment
if (Test-CursorEnvironment) {
    Start-PowerShellMCPServer
}
```

## Requirements

- **PowerShell**: 5.1 or later
- **Cursor IDE**: Latest version with MCP support
- **Windows**: Windows 10/11 (PowerShell Core support coming soon)

## Security Considerations

⚠️ **Important Security Notes:**

1. **Command Validation**: Only whitelisted commands are allowed
2. **Timeout Protection**: Commands are limited to 5 minutes execution time
3. **Process Isolation**: Commands run in separate PowerShell processes
4. **Working Directory**: Commands execute in controlled directories
5. **Logging**: All command execution is logged for audit purposes

## License

This module is part of the PowerShell Profile Manager project and is licensed under the MIT License.

## Related Resources

- [Cursor IDE Documentation](https://cursor.com/docs/agent/terminal)
- [MCP Protocol Specification](https://cursor.com/docs/context/mcp)
- [PowerShell Profile Manager](../README.md)
- [Cursor MCP Integration Guide](https://forum.cursor.com/t/how-to-use-mcp-server/50064)
