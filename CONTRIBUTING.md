# Contributing to PowerShell Profile Manager

Thank you for your interest in contributing to the PowerShell Profile Manager! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Module Development](#module-development)
- [Documentation](#documentation)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Release Process](#release-process)

## Code of Conduct

This project follows a code of conduct that ensures a welcoming environment for all contributors. Please be respectful and constructive in all interactions.

## Getting Started

### Prerequisites

- Windows 10/11
- PowerShell 5.1 or later
- Git
- A GitHub account

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```powershell
   git clone https://github.com/yourusername/powershell-profile-manager.git
   cd powershell-profile-manager
   ```
3. Add the upstream repository:
   ```powershell
   git remote add upstream https://github.com/originalowner/powershell-profile-manager.git
   ```

### Development Setup

1. Create a development branch:
   ```powershell
   git checkout -b feature/your-feature-name
   ```

2. Test the current setup:
   ```powershell
   . .\Microsoft.PowerShell_profile.ps1
   Get-ProfileModules
   ```

## Development Workflow

### Branch Naming

Use descriptive branch names with prefixes:
- `feature/` - New features
- `bugfix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test improvements

### Commit Messages

Follow conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

Examples:
```
feat(VideoCompressor): add hardware acceleration support
fix(profile): resolve module loading error
docs(README): update installation instructions
```

## Module Development

### Creating a New Module

1. **Copy the ExampleModule template:**
   ```powershell
   Copy-Item "modules\ExampleModule" "modules\YourModule" -Recurse
   ```

2. **Update module files:**
   - Rename `.psm1` and `.psd1` files
   - Update module manifest with your module details
   - Replace example functions with your functionality

3. **Add to profile configuration:**
   ```powershell
   # In Microsoft.PowerShell_profile.ps1
   $ProfileModules += @{
       Name = "YourModule"
       Enabled = $true
       Description = "Your module description"
   }
   ```

### Module Structure Requirements

Each module must follow this structure:
```
YourModule/
├── YourModule.psm1      # Main module file
├── YourModule.psd1      # Module manifest
└── README.md            # Module documentation
```

### Module Manifest Requirements

The `.psd1` file must include:
- Unique GUID
- Proper version number
- Complete function exports
- Appropriate tags
- Project and license URIs

### Function Requirements

All exported functions must:
- Have comprehensive comment-based help
- Include parameter validation
- Handle errors gracefully
- Follow PowerShell naming conventions
- Include examples in help

Example:
```powershell
function Get-YourData {
    <#
    .SYNOPSIS
    Brief description of the function
    
    .DESCRIPTION
    Detailed description of what the function does
    
    .PARAMETER InputPath
    Path to the input file
    
    .OUTPUTS
    [hashtable] Description of return value
    
    .EXAMPLE
    Get-YourData -InputPath "C:\data.txt"
    Gets data from the specified file
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_})]
        [string]$InputPath
    )
    
    try {
        # Function implementation
        return $result
    }
    catch {
        Write-Error "Error processing data: $($_.Exception.Message)"
        return $null
    }
}
```

## Documentation

### Module Documentation

Each module must include a comprehensive README.md with:
- Module purpose and features
- Function documentation with examples
- Configuration options
- Requirements and dependencies
- Troubleshooting section

### Code Documentation

- Use comment-based help for all functions
- Include inline comments for complex logic
- Document configuration options
- Explain any external dependencies

### Documentation Standards

- Use clear, concise language
- Include practical examples
- Keep documentation up-to-date with code changes
- Use consistent formatting

## Testing

### Testing Requirements

All modules must include:
- Built-in testing functionality
- Test coverage for main functions
- Configuration testing
- Error condition testing

### Testing Framework

Use the testing framework from ExampleModule:
```powershell
function Test-YourModule {
    param(
        [ValidateSet("Basic", "Advanced", "All")]
        [string]$TestType = "Basic"
    )
    
    $results = @{
        Passed = 0
        Failed = 0
        Tests = @()
    }
    
    # Add your tests here
    
    return $results
}
```

### Manual Testing

Before submitting:
1. Test module loading/unloading
2. Test all functions with various inputs
3. Test error conditions
4. Test configuration changes
5. Verify documentation accuracy

## Submitting Changes

### Pull Request Process

1. **Ensure your changes are complete:**
   - All tests pass
   - Documentation is updated
   - Code follows style guidelines

2. **Create a pull request:**
   - Use a descriptive title
   - Include a detailed description
   - Reference any related issues
   - Include screenshots for UI changes

3. **Pull request template:**
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Refactoring
   
   ## Testing
   - [ ] All tests pass
   - [ ] Manual testing completed
   - [ ] Documentation updated
   
   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Comments added for complex code
   - [ ] No breaking changes (or documented)
   ```

### Review Process

- All pull requests require review
- Address review feedback promptly
- Keep pull requests focused and small
- Respond to comments constructively

## Release Process

### Version Numbering

Follow semantic versioning (MAJOR.MINOR.PATCH):
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation is current
- [ ] Version numbers updated
- [ ] Changelog updated
- [ ] Release notes prepared

## Style Guidelines

### PowerShell Style

- Use approved verbs for function names
- Follow PowerShell naming conventions
- Use proper indentation (4 spaces)
- Include parameter validation
- Handle errors appropriately

### Code Organization

- Group related functions together
- Use consistent parameter ordering
- Include module initialization
- Export only necessary functions

### Documentation Style

- Use clear, concise language
- Include practical examples
- Follow consistent formatting
- Keep documentation current

## Getting Help

- Check existing issues and discussions
- Ask questions in GitHub discussions
- Review the ExampleModule for patterns
- Consult PowerShell documentation

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- GitHub contributors page

Thank you for contributing to the PowerShell Profile Manager!
