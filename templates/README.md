# Template System for GitHub Actions Workflows

This directory contains template files used by the GitHub Actions workflows for generating dynamic content such as PR comments and email notifications.

## Directory Structure

```
templates/
├── html/                           # HTML email templates
│   ├── critical-errors-email-template.html
│   └── pr-issues-email-template.html
├── markdown/                       # Markdown templates
│   └── pr-comment-template.md
└── README.md                       # This file
```

## Template Processing

Templates use a simple placeholder system where variables are enclosed in double curly braces: `{{variableName}}`

### Template Processing Script

The `scripts/process-template.ps1` script handles template processing:

```powershell
.\scripts\process-template.ps1 -TemplatePath "templates\markdown\pr-comment-template.md" -OutputPath "output.md" -Variables @{variableName="value"}
```

### Available Templates

#### 1. PR Comment Template (`templates/markdown/pr-comment-template.md`)

Used for generating PR comments with validation results.

**Variables:**
- `statusIcon` - Status emoji (✅, 🚨, ⚠️, 📝)
- `totalCritical` - Total critical errors
- `psCriticalErrors` - PowerShell critical errors
- `yamlCriticalErrors` - YAML critical errors
- `totalHigh` - Total high priority issues
- `psHighErrors` - PowerShell high priority issues
- `yamlHighErrors` - YAML high priority issues
- `totalIssues` - Total issues found
- `psTotalIssues` - PowerShell total issues
- `yamlTotalIssues` - YAML total issues
- `statusMessage` - Status message
- `psChangedFilesList` - List of changed PowerShell files
- `yamlChangedFilesList` - List of changed YAML files
- `recommendations` - Recommendations text
- `workflowRunUrl` - URL to workflow run
- `powerShellBestPracticesUrl` - URL to PowerShell best practices
- `runId` - Workflow run ID

#### 2. Critical Errors Email Template (`templates/html/critical-errors-email-template.html`)

Used for sending email notifications about critical errors.

**Variables:**
- `repository` - Repository name
- `branch` - Branch name
- `commit` - Commit SHA
- `author` - Commit author
- `timestamp` - Timestamp
- `psCriticalErrors` - PowerShell critical errors
- `yamlCriticalErrors` - YAML critical errors
- `psHighErrors` - PowerShell high priority issues
- `yamlHighErrors` - YAML high priority issues
- `totalIssues` - Total issues
- `psChangedFiles` - Changed PowerShell files
- `yamlChangedFiles` - Changed YAML files
- `workflowRunUrl` - URL to workflow run
- `commitUrl` - URL to commit

#### 3. PR Issues Email Template (`templates/html/pr-issues-email-template.html`)

Used for sending email notifications about issues in pull requests.

**Variables:**
- `repository` - Repository name
- `prNumber` - Pull request number
- `prTitle` - Pull request title
- `author` - PR author
- `branch` - Branch name
- `psCriticalErrors` - PowerShell critical errors
- `yamlCriticalErrors` - YAML critical errors
- `psHighErrors` - PowerShell high priority issues
- `yamlHighErrors` - YAML high priority issues
- `totalIssues` - Total issues
- `prUrl` - URL to pull request
- `workflowRunUrl` - URL to workflow run

## Customization

### Adding New Templates

1. Create a new template file in the appropriate directory (`html/` or `markdown/`)
2. Use the `{{variableName}}` syntax for placeholders
3. Update the workflow to process the template using `scripts/process-template.ps1`

### Modifying Existing Templates

1. Edit the template file directly
2. Update the workflow if new variables are needed
3. Test the template processing with sample data

### Environment Variables

The workflows use the following environment variables that can be customized:

- `DEV_TEAM_EMAIL` - Email address for the development team
- `REPO_ADMINS` - Email address for repository administrators

These can be set as repository variables or secrets in GitHub.

## Benefits of Template System

1. **Separation of Concerns**: Templates are separate from workflow logic
2. **Maintainability**: Easy to update templates without modifying workflows
3. **Reusability**: Templates can be reused across different workflows
4. **Version Control**: Template changes are tracked separately
5. **Testing**: Templates can be tested independently
6. **Customization**: Easy to customize for different organizations

## Migration from Inline Templates

The previous workflows had HTML and Markdown content embedded directly in the YAML files. This has been migrated to the template system for better maintainability and organization.

### Before (Inline)
```yaml
html_body: |
  <html>
  <head>
    <style>...</style>
  </head>
  <body>
    <h2>Critical Errors</h2>
    <p>Repository: ${{ github.repository }}</p>
  </body>
  </html>
```

### After (Template)
```yaml
- name: Process Template
  run: |
    .\scripts\process-template.ps1 -TemplatePath "templates\html\critical-errors-email-template.html" -OutputPath "email.html" -Variables @{repository="${{ github.repository }}"}
- name: Send Email
  uses: dawidd6/action-send-mail@v3
  with:
    html_body: ${{ steps.process-template.outputs.content }}
```
