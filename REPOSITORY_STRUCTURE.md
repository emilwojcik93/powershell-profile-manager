# PowerShell Profile Manager - Repository Structure

This document defines the standard repository structure following best practices for PowerShell projects.

## Directory Structure

```
powershell-profile-manager/
├── .github/                          # GitHub-specific files
│   ├── workflows/                    # GitHub Actions workflows
│   │   ├── scripts/                  # Workflow-specific scripts
│   │   ├── templates/                # Workflow templates
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

## Standards and Best Practices

### 1. Directory Naming
- Use lowercase with hyphens for multi-word directories
- Use descriptive names that clearly indicate purpose
- Avoid abbreviations unless they're widely understood

### 2. File Naming
- PowerShell scripts: `Verb-Noun.ps1` (e.g., `Install-Profile.ps1`)
- Documentation: `kebab-case.md` (e.g., `installation-guide.md`)
- Templates: `template-name.type` (e.g., `email-template.html`)

### 3. Script Organization
- **Build scripts**: Compilation, packaging, and build processes
- **Deploy scripts**: Installation, deployment, and configuration
- **Test scripts**: Testing, validation, and quality assurance
- **Tools scripts**: Utilities, helpers, and maintenance tasks

### 4. Module Organization
- Each module in its own directory
- Module directory contains: `.psm1`, `.psd1`, `README.md`
- Follow PowerShell module manifest standards

### 5. Documentation Organization
- **API docs**: Technical reference for functions and cmdlets
- **Examples**: Practical usage examples and samples
- **Guides**: Step-by-step instructions and tutorials
- **Main docs**: Overview, installation, and getting started

### 6. Template Organization
- **HTML templates**: Email notifications, reports
- **Markdown templates**: Documentation, README files
- **PowerShell templates**: Script templates, module templates

### 7. GitHub Integration
- **Workflows**: CI/CD pipelines and automation
- **Templates**: Issue templates, PR templates
- **Instructions**: Copilot instructions, contribution guidelines

## Migration Plan

1. **Phase 1**: Create new directory structure
2. **Phase 2**: Move files to appropriate locations
3. **Phase 3**: Update all references and paths
4. **Phase 4**: Clean up duplicate files
5. **Phase 5**: Update documentation
6. **Phase 6**: Test all functionality

## Benefits

- **Clarity**: Clear separation of concerns
- **Maintainability**: Easy to find and modify files
- **Scalability**: Structure supports growth
- **Standards**: Follows PowerShell and GitHub best practices
- **Consistency**: Uniform organization across all components
