# Cursor/Agent Rules for Repository Structure

This document defines the comprehensive rules and guidelines for Cursor IDE and AI agents working with the PowerShell Profile Manager repository.

## Overview

These rules ensure consistent, maintainable, and scalable code organization while providing clear guidance for automated agents and developers.

## Repository Structure Rules

### **MANDATORY Directory Organization**

The repository follows a strict directory structure that must be maintained:

```
powershell-profile-manager/
├── .github/                          # GitHub-specific files
│   ├── workflows/                    # GitHub Actions workflows
│   │   ├── docs/                     # Workflow documentation
│   │   └── *.yml                     # Workflow files
│   ├── templates/                    # GitHub-specific templates
│   └── instructions/                 # GitHub-specific instructions
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
└── Microsoft.PowerShell_profile.ps1  # Main profile file
```

### **Script Organization Rules**

#### **Build Scripts** (`scripts/build/`)
- **Purpose**: Build, packaging, and release preparation
- **Examples**: `create-release-package.ps1`, `create-release-archive.ps1`
- **Naming**: Use descriptive names indicating build purpose

#### **Deploy Scripts** (`scripts/deploy/`)
- **Purpose**: Installation, deployment, and configuration
- **Examples**: `install.ps1`, `uninstall.ps1`, `release.ps1`
- **Requirements**: Must support automation parameters (`-NonInteractive`, `-Unattended`)

#### **Test Scripts** (`scripts/test/`)
- **Purpose**: Testing, validation, and quality assurance
- **Examples**: `validate-*.ps1`, `test-*.ps1`, `verify-*.ps1`
- **Requirements**: Must be non-interactive and return proper exit codes

#### **Tools Scripts** (`scripts/tools/`)
- **Purpose**: Utility scripts and helper functions
- **Examples**: `process-template.ps1`, `notify-results.ps1`, `auto-fix-issues.ps1`
- **Requirements**: Must be reusable and well-documented

### **Template Organization Rules**

#### **HTML Templates** (`templates/html/`)
- **Purpose**: Email notifications and HTML reports
- **Examples**: `critical-errors-email-template.html`, `pr-issues-email-template.html`
- **Requirements**: Must use placeholder syntax `{{variable}}`

#### **Markdown Templates** (`templates/markdown/`)
- **Purpose**: Documentation and PR comments
- **Examples**: `pr-comment-template.md`, `release-body.md`
- **Requirements**: Must use placeholder syntax `{{variable}}`

#### **PowerShell Templates** (`templates/powershell/`)
- **Purpose**: Script templates and module templates
- **Requirements**: Must include proper documentation and parameter validation

### **Module Organization Rules**

Each module must be in its own directory under `modules/`:
- **Required Files**: `.psm1`, `.psd1`, `README.md`
- **Naming**: Use PascalCase for module names
- **Documentation**: Must include comprehensive README with examples

## File Naming Standards

### **PowerShell Scripts**
- **Format**: `Verb-Noun.ps1`
- **Examples**: `Install-Profile.ps1`, `Test-ModuleLoading.ps1`
- **Requirements**: Must follow PowerShell naming conventions

### **Documentation Files**
- **Format**: `kebab-case.md`
- **Examples**: `installation-guide.md`, `repository-structure.md`
- **Requirements**: Must be descriptive and searchable

### **Template Files**
- **Format**: `template-name.type`
- **Examples**: `email-template.html`, `pr-comment-template.md`
- **Requirements**: Must indicate purpose and format

### **Module Files**
- **Format**: `ModuleName.psm1` and `ModuleName.psd1`
- **Requirements**: Must match directory name

## Path Reference Rules

### **Absolute Requirements**
- **ALWAYS use relative paths** from repository root
- **NO hardcoded absolute paths** in any files
- **NO environment-specific paths** (e.g., `C:\Users\...`)

### **Script Paths in Workflows**
- **Format**: `.\scripts\category\script-name.ps1`
- **Examples**: 
  - `.\scripts\deploy\install.ps1`
  - `.\scripts\test\validate-powershell-syntax.ps1`
  - `.\scripts\tools\process-template.ps1`

### **Template Paths**
- **Format**: `templates\type\template-name.type`
- **Examples**:
  - `templates\html\critical-errors-email-template.html`
  - `templates\markdown\pr-comment-template.md`

### **Module Paths**
- **Format**: `modules\ModuleName\ModuleName.psm1`
- **Examples**:
  - `modules\VideoCompressor\VideoCompressor.psm1`
  - `modules\PowerShellMCP\PowerShellMCP.psm1`

## Content Organization Rules

### **Workflow Rules**
- **NO inline script blocks** - All scripts must be external
- **NO hardcoded content** - Load all content from dedicated files
- **NO duplicate workflows** - Consolidate similar functionality
- **External Script Loading**: All workflow steps must call external scripts

### **Template Processing**
- **Use**: `scripts/tools/process-template.ps1` for dynamic content
- **Placeholder Syntax**: Use `{{variable}}` for template variables
- **Output Management**: Save processed templates to appropriate locations

### **Documentation Requirements**
- **README.md**: Must reflect current directory structure
- **Module READMEs**: Required for each module with examples
- **API Documentation**: Required for all public functions
- **Usage Examples**: Required for all major features
- **Migration Guides**: Required for structural changes

## Automation and Agent Rules

### **Script Requirements for Automation**
- **MUST support**: `-NonInteractive` and `-Unattended` parameters
- **MUST be**: Non-interactive when automation parameters are used
- **MUST return**: Proper exit codes (0 for success, non-zero for failure)
- **MUST log**: All operations to files when `-LogPath` is specified

### **Error Handling Standards**
- **Use**: `-ErrorAction Stop` for critical operations
- **Implement**: try-catch blocks for all major operations
- **Provide**: Meaningful error messages with context
- **Log**: All errors to appropriate log files

### **Output Standards**
- **Use**: `Write-Host` with explicit `-ForegroundColor` for visibility
- **NO Unicode**: Use ASCII characters only (e.g., `[OK]` instead of `✓`)
- **Consistent**: Use same output format across all scripts
- **Structured**: Use consistent logging format with timestamps

### **Variable Naming Rules**
- **NEVER use**: System/read-only variable names (`$host`, `$error`, `$input`, etc.)
- **Use**: Descriptive variable names that don't conflict with PowerShell built-ins
- **Special Characters**: Use `${var}:` instead of `$var:` for special characters
- **Examples**: `${env:TEMP}`, `${var}.exe`, `${var}%`

## Workflow Integration Rules

### **GitHub Actions Requirements**
- **Shell**: Use `shell: pwsh` for PowerShell commands
- **Checkout**: Use `uses: actions/checkout@v4`
- **Error Handling**: Use proper error handling with `exit 1` for failures
- **Output**: Use `Write-Host` with colors for better visibility

### **External Content Loading**
- **Scripts**: All workflow steps must call external scripts
- **Templates**: Use template processing for dynamic content
- **Documentation**: Load documentation from dedicated files
- **Configuration**: Use environment variables for configuration

### **Path Consistency**
- **All workflows**: Must use new directory structure
- **All references**: Must use relative paths from repository root
- **All scripts**: Must be in appropriate category directories
- **All templates**: Must be in dedicated template directories

## Quality Assurance Rules

### **Testing Requirements**
- **All scripts**: Must be tested with different parameter combinations
- **Error conditions**: Must be tested and handled properly
- **Syntax validation**: Must be performed before committing
- **Integration testing**: Must be performed for all workflows

### **Documentation Standards**
- **Comprehensive**: Include all required sections
- **Examples**: Provide practical usage examples
- **Up-to-date**: Keep documentation synchronized with code
- **Searchable**: Use consistent naming and structure

### **Code Quality**
- **Standards**: Follow PowerShell best practices
- **Validation**: Use proper parameter validation
- **Error handling**: Implement comprehensive error handling
- **Logging**: Include proper logging and output formatting

## Enforcement and Monitoring

### **Automated Validation**
- **Repository structure**: Validated by `validate-repository-structure.ps1`
- **Script syntax**: Validated by `validate-powershell-syntax.ps1`
- **Workflow integrity**: Validated by comprehensive validation workflows
- **Documentation**: Validated by documentation review processes

### **Agent Monitoring**
- **Background agent**: Monitors repository health continuously
- **Workflow monitoring**: Tracks all workflow executions
- **Error detection**: Automatically detects and reports issues
- **Auto-fix**: Attempts to fix issues automatically when possible

### **Compliance Checking**
- **Structure compliance**: Ensures directory structure is maintained
- **Naming compliance**: Ensures naming standards are followed
- **Path compliance**: Ensures all paths use correct references
- **Content compliance**: Ensures content organization rules are followed

## Best Practices Summary

1. **Always use the established directory structure**
2. **Never create duplicate directories or files**
3. **Always use external scripts in workflows**
4. **Always use relative paths from repository root**
5. **Always support automation parameters in scripts**
6. **Always use ASCII characters only**
7. **Always include proper error handling and logging**
8. **Always maintain up-to-date documentation**
9. **Always test all changes thoroughly**
10. **Always follow PowerShell best practices**

These rules ensure the repository remains maintainable, scalable, and consistent while providing clear guidance for both human developers and automated agents.
