# Repository Structure Guide

This guide explains the organization and structure of the PowerShell Profile Manager repository.

## Overview

The repository follows a standardized structure that separates concerns and makes the codebase maintainable and scalable.

## Directory Structure

```
powershell-profile-manager/
├── .github/                          # GitHub-specific files
│   ├── workflows/                    # GitHub Actions workflows
│   │   ├── docs/                     # Workflow documentation
│   │   └── *.yml                     # Workflow files
│   ├── templates/                    # GitHub-specific templates
│   │   ├── html/                     # HTML email templates
│   │   └── markdown/                 # Markdown templates
│   └── instructions/                 # GitHub-specific instructions
├── .vscode/                          # VS Code configuration
├── docs/                             # Documentation
│   ├── api/                          # API documentation
│   ├── examples/                     # Usage examples
│   ├── guides/                       # User guides
│   └── *.md                          # Main documentation files
├── modules/                          # PowerShell modules
│   ├── ExampleModule/                # Example module
│   ├── PowerShellMCP/                # MCP module
│   └── VideoCompressor/              # Video compression module
├── scripts/                          # PowerShell scripts
│   ├── build/                        # Build scripts
│   ├── deploy/                       # Deployment scripts
│   ├── test/                         # Test scripts
│   ├── tools/                        # Utility scripts
│   └── *.ps1                         # Main scripts
├── templates/                        # Template files
│   ├── html/                         # HTML templates
│   ├── markdown/                     # Markdown templates
│   └── powershell/                   # PowerShell templates
├── tests/                            # Test files
│   ├── unit/                         # Unit tests
│   ├── integration/                  # Integration tests
│   └── fixtures/                     # Test data
├── .cursorrules                      # Cursor IDE rules
├── .gitignore                        # Git ignore rules
├── LICENSE                           # License file
├── README.md                         # Main README
└── Microsoft.PowerShell_profile.ps1  # Main profile file
```

## Script Organization

### Build Scripts (`scripts/build/`)
Scripts responsible for building, packaging, and preparing releases:
- `create-release-package.ps1` - Creates release packages
- `create-release-archive.ps1` - Creates release archives
- `generate-release-body.ps1` - Generates release documentation
- `prepare-release-body.ps1` - Prepares release body content

### Deploy Scripts (`scripts/deploy/`)
Scripts responsible for installation, deployment, and configuration:
- `install.ps1` - Main installation script
- `uninstall.ps1` - Uninstallation script
- `release.ps1` - Release management script

### Test Scripts (`scripts/test/`)
Scripts responsible for testing, validation, and quality assurance:
- `validate-*.ps1` - Validation scripts
- `test-*.ps1` - Test scripts
- `verify-*.ps1` - Verification scripts
- `cleanup-*.ps1` - Cleanup scripts

### Tools Scripts (`scripts/tools/`)
Utility scripts for maintenance, automation, and helper functions:
- `process-template.ps1` - Template processing
- `notify-results.ps1` - Notification utilities
- `auto-fix-issues.ps1` - Automatic issue fixing
- `background-agent.ps1` - Background agent
- `generate-test-report.ps1` - Test report generation

## Module Organization

Each module is contained in its own directory under `modules/`:
- **ExampleModule**: Example module demonstrating best practices
- **PowerShellMCP**: MCP (Model Context Protocol) integration module
- **VideoCompressor**: Video compression functionality module

Each module directory contains:
- `ModuleName.psm1` - Module implementation
- `ModuleName.psd1` - Module manifest
- `README.md` - Module documentation

## Template Organization

### HTML Templates (`templates/html/`)
- `critical-errors-email-template.html` - Critical error notifications
- `pr-issues-email-template.html` - PR issue notifications

### Markdown Templates (`templates/markdown/`)
- `pr-comment-template.md` - PR comment templates
- `release-body.md` - Release documentation templates

### PowerShell Templates (`templates/powershell/`)
- Script templates for common PowerShell patterns
- Module templates for new module creation

## Documentation Organization

### API Documentation (`docs/api/`)
Technical reference documentation for:
- Function signatures
- Parameter descriptions
- Return values
- Examples

### Examples (`docs/examples/`)
Practical usage examples:
- `basic-usage.ps1` - Basic usage examples
- `advanced-usage.ps1` - Advanced usage examples

### Guides (`docs/guides/`)
Step-by-step instructions:
- `repository-structure.md` - This guide
- Installation guides
- Configuration guides
- Troubleshooting guides

## GitHub Integration

### Workflows (`.github/workflows/`)
CI/CD pipelines and automation:
- `comprehensive-validation.yml` - Comprehensive validation
- `powershell-validation.yml` - PowerShell-specific validation
- `release.yml` - Release management
- `test-installation.yml` - Installation testing
- `test-install-uninstall-cycle.yml` - Full cycle testing
- `background-agent.yml` - Background automation

### Templates (`.github/templates/`)
GitHub-specific templates for:
- Issue templates
- PR templates
- Release templates

## Best Practices

### File Naming
- PowerShell scripts: `Verb-Noun.ps1` (e.g., `Install-Profile.ps1`)
- Documentation: `kebab-case.md` (e.g., `installation-guide.md`)
- Templates: `template-name.type` (e.g., `email-template.html`)

### Script Standards
- Include proper PowerShell documentation
- Use `#Requires -Version 5.1` for compatibility
- Follow consistent error handling patterns
- Use ASCII characters only (no Unicode)
- Include proper logging and output formatting
- **MUST support automation parameters** (`-NonInteractive`, `-Unattended`)

### Module Standards
- Each module in its own directory
- Include `.psm1`, `.psd1`, and `README.md`
- Follow PowerShell module manifest standards
- Use descriptive function names

### Cursor/Agent Rules
For comprehensive rules and guidelines for Cursor IDE and AI agents, see:
- **[Cursor/Agent Rules](cursor-agent-rules.md)** - Complete rules and guidelines
- **[.cursorrules](../.cursorrules)** - Cursor IDE configuration file

### Path Reference Standards
- **ALWAYS use relative paths** from repository root
- **Script paths**: `.\scripts\category\script-name.ps1`
- **Template paths**: `templates\type\template-name.type`
- **Module paths**: `modules\ModuleName\ModuleName.psm1`

## Migration Notes

This structure was implemented to:
- Separate concerns clearly
- Improve maintainability
- Support scalability
- Follow PowerShell and GitHub best practices
- Ensure consistency across all components

All workflows and scripts have been updated to use the new paths, ensuring backward compatibility while providing a cleaner, more organized structure.
