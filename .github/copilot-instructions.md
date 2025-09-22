# GitHub Copilot Instructions for PowerShell Profile Manager

## Repository Overview
This is a PowerShell Profile Manager repository that provides a structured, modular approach to managing PowerShell profiles with Cursor IDE integration and MCP server support.

## Core Principles

### Infrastructure as Code (IaC) Approach
- All scripts must be self-contained and executable without manual intervention
- Use proper PowerShell 5.x compatible syntax with `${var}` bracket notation
- Implement WinUtil-style self-elevation for admin operations
- No static assets - everything must be dynamically generated or configurable
- UTF-8/ASCII only - no Unicode characters in source files

### PowerShell Syntax Standards
- **Variable Syntax**: Use `${var}:` instead of `$var:` for special characters
- **Path Handling**: Use `"${var}.exe"` instead of `"$var.exe"`
- **Special Characters**: Use `${var}%` instead of `$var%`
- **Bracket Notation**: Always use `${variable}` when variable is near special characters
- **Error Handling**: Use `-ErrorAction Stop` for critical operations
- **Output Management**: Use `Write-Host` with explicit `-ForegroundColor` for better visibility

### Module Development
- Each module must have `.psm1` (script module) and `.psd1` (manifest) files
- Use `[CmdletBinding()]` for advanced function features
- Include comprehensive help documentation with `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`
- Use `Export-ModuleMember` to explicitly export functions
- Include proper parameter validation with `[Parameter()]` attributes

### Cursor IDE Integration
- Detect Cursor environment using `Test-CursorEnvironment` function
- Optimize profile loading for agent sessions (disable heavy prompts)
- Use MCP server for secure command execution
- Implement proper terminal behavior to avoid hanging issues

## Code Generation Guidelines

### When generating PowerShell scripts:
1. **Always use bracket notation for variables near special characters**
2. **Include proper error handling with try-catch blocks**
3. **Use explicit parameter types and validation**
4. **Include comprehensive help documentation**
5. **Test for Cursor environment and optimize accordingly**
6. **Use UTF-8/ASCII characters only - no emojis or Unicode**

### When generating GitHub Actions workflows:
1. **Use correct action references (actions/setup-powershell@v1)**
2. **Include proper error handling and logging**
3. **Use ASCII characters only in workflow files**
4. **Implement proper timeout and resource management**
5. **Include comprehensive testing and validation steps**

### When generating documentation:
1. **Use clear, professional language**
2. **Include practical examples and use cases**
3. **Provide troubleshooting sections**
4. **Keep documentation synchronized with code changes**
5. **Use proper markdown formatting**

## Repository Structure
```
/
├── Microsoft.PowerShell_profile.ps1    # Main profile script
├── scripts/                            # Installation and utility scripts
│   ├── install.ps1
│   ├── uninstall.ps1
│   └── release.ps1
├── modules/                            # PowerShell modules
│   ├── VideoCompressor/
│   ├── PowerShellMCP/
│   └── ExampleModule/
├── docs/                              # Documentation
├── .github/workflows/                 # GitHub Actions
├── .cursor/                           # Cursor configuration
└── .vscode/                           # VS Code settings
```

## Testing and Validation
- All scripts must be testable on GitHub Actions runners
- Include comprehensive syntax validation
- Test module loading and function availability
- Validate installation and uninstallation processes
- Test Cursor environment detection and optimization

## Security Considerations
- Never hardcode sensitive information
- Use environment variables for configuration
- Validate all user inputs
- Use secure defaults for all parameters
- Implement proper command validation in MCP server

## Performance Optimization
- Use `-Silent` parameter for operations that don't need verbose output
- Implement proper timeout handling
- Use efficient string operations
- Avoid unnecessary file I/O operations
- Optimize for agent sessions when in Cursor environment

## Background Agent Integration
- Agent continuously monitors repository health
- Auto-fixes common issues when possible
- Provides detailed logging and reporting
- Runs comprehensive tests on all components
- Maintains repository quality automatically

## Best Practices
1. **Always test scripts in both interactive and silent modes**
2. **Use proper PowerShell 5.x compatible syntax**
3. **Include comprehensive error handling**
4. **Document all functions and parameters**
5. **Maintain UTF-8/ASCII character compliance**
6. **Use bracket notation for variables near special characters**
7. **Implement proper Cursor IDE integration**
8. **Follow Infrastructure as Code principles**
