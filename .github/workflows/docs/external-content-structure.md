# External Content Structure for GitHub Workflows

This document describes the structure and purpose of external content files used by GitHub workflows instead of inline script blocks.

## Directory Structure

```
.github/workflows/
├── scripts/           # PowerShell scripts for workflow steps
├── docs/             # Documentation files
├── templates/        # Template files (HTML, Markdown, etc.)
└── *.yml            # Workflow files (now load external content)
```

## Scripts Directory

The `scripts/` directory contains individual PowerShell scripts for each workflow step:

### Test Install/Uninstall Cycle Scripts

- **`verify-initial-clean-state.ps1`** - Verifies and cleans initial state
- **`test-installation-script.ps1`** - Tests installation with automation parameters
- **`verify-installation-state.ps1`** - Verifies installation and checks logs
- **`test-uninstallation-script.ps1`** - Tests uninstallation with automation parameters
- **`verify-clean-uninstall-state.ps1`** - Verifies clean uninstall and no leftovers
- **`test-remote-installation.ps1`** - Tests remote installation from GitHub
- **`cleanup-test-environment.ps1`** - Cleans up test environment
- **`generate-test-report.ps1`** - Generates comprehensive test report

## Benefits of External Content

1. **Maintainability** - Scripts can be edited independently of workflows
2. **Reusability** - Scripts can be used across multiple workflows
3. **Version Control** - Better tracking of changes to individual components
4. **Testing** - Scripts can be tested independently
5. **Readability** - Workflows are cleaner and easier to understand
6. **Modularity** - Each script has a single responsibility

## Usage in Workflows

Instead of inline script blocks, workflows now use:

```yaml
- name: Step Name
  shell: pwsh
  run: .\.github\workflows\scripts\script-name.ps1
```

## Script Requirements

All scripts in this directory must:

- Include proper PowerShell documentation (SYNOPSIS, DESCRIPTION, PARAMETER, EXAMPLE)
- Use `#Requires -Version 5.1` for compatibility
- Follow consistent error handling patterns
- Use ASCII characters only (no Unicode)
- Include proper logging and output formatting
- Be self-contained and executable independently

## Template Files

The `templates/` directory contains:

- **HTML templates** for email notifications
- **Markdown templates** for PR comments
- **Documentation templates** for various outputs

## Documentation Files

The `docs/` directory contains:

- **Structure documentation** (this file)
- **Usage guides** for different workflow types
- **Troubleshooting guides** for common issues
