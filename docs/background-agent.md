# Background Agent Documentation

The PowerShell Profile Manager repository includes a fully automated background agent that continuously monitors and fixes repository issues to ensure all workflows and scripts work correctly.

## Overview

The background agent is configured using Cursor's background agent functionality as described in the [Cursor CLI GitHub Actions documentation](https://cursor.com/docs/cli/github-actions) and [Background Agent documentation](https://cursor.com/docs/background-agent).

## Agent Configuration

- **Agent Name**: repo-agent
- **Agent Key**: key_8033adbd9e8f8879709e9bc936b1879fa96d745013fea2947441b99bb08f35ee
- **Configuration File**: `.cursor/agent.yml`
- **Workflow File**: `.github/workflows/background-agent.yml`

## Features

### Continuous Monitoring
The agent continuously monitors:
- PowerShell script syntax
- Module loading functionality
- GitHub Actions workflows
- Repository structure
- Documentation consistency
- Installation/uninstallation processes
- Release processes

### Automated Testing
The agent runs comprehensive tests:
- **Syntax Validation**: Validates all PowerShell scripts and modules
- **Module Loading**: Tests that all modules load correctly
- **Function Availability**: Verifies all exported functions are available
- **Installation Testing**: Tests installation scripts with various parameters
- **Uninstallation Testing**: Verifies cleanup processes work correctly
- **Release Testing**: Validates release script functionality

### Auto-Fix Capabilities
When issues are detected, the agent attempts to:
- Fix PowerShell syntax errors
- Update module manifests
- Correct parameter definitions
- Update GitHub Actions configurations
- Fix runner compatibility issues
- Update documentation

## Agent Triggers

The agent runs automatically on:
- **Push events** to main or develop branches
- **Pull request** creation and updates
- **Workflow failures** in any GitHub Actions
- **Script errors** or syntax issues
- **Module loading failures**
- **Test failures** in any component
- **Scheduled runs** every hour via cron

## Success Criteria

The agent considers the repository healthy when:
- ✅ All workflows pass successfully
- ✅ All scripts have valid PowerShell syntax
- ✅ All modules load without errors
- ✅ Installation script works correctly
- ✅ Uninstallation script works correctly
- ✅ Release script works correctly
- ✅ Documentation is synchronized with code
- ✅ No linting or syntax errors exist

## Safety Limits

To prevent excessive automation, the agent has safety limits:
- **Maximum 10 commits per hour**
- **Maximum 20 workflow runs per hour**
- **30-minute timeout** for all operations
- **Auto-fix only for safe operations**
- **Manual intervention required** for complex issues

## Monitoring the Agent

### GitHub Actions
Monitor agent activity in the **Actions** tab of the repository:
- Look for "Background Agent - Continuous Testing and Fixing" workflows
- Check the agent report in workflow logs
- Review auto-fix attempts if any issues were detected

### Agent Logs
The agent provides detailed logging:
```
[2024-01-01 12:00:00] ℹ️ Agent initialized successfully
[2024-01-01 12:00:01] 🔍 Validating repository structure...
[2024-01-01 12:00:02] ✅ File exists: Microsoft.PowerShell_profile.ps1
[2024-01-01 12:00:03] ✅ Module loading test passed
[2024-01-01 12:00:04] 📊 Generating agent report...
```

### Workflow Status
Check workflow status badges in the repository:
- Background Agent status
- Validation workflow status
- Test installation status

## Working with the Agent

### Manual Triggers
You can manually trigger the agent:
```bash
# Trigger background agent with full testing
gh workflow run background-agent.yml --ref main

# Trigger with specific mode
gh workflow run background-agent.yml --ref main -f mode=syntax-only
```

### Agent Modes
The agent supports different operation modes:
- **full**: Complete testing and validation (default)
- **syntax-only**: Only PowerShell syntax validation
- **workflows-only**: Only workflow testing
- **modules-only**: Only module testing

### Viewing Results
Check agent results:
```bash
# List recent workflow runs
gh run list --workflow=background-agent.yml

# View specific run details
gh run view <run-id> --log
```

## Agent Configuration Files

### `.cursor/agent.yml`
Main agent configuration file containing:
- Agent behavior settings
- Monitoring configuration
- Event triggers
- Continuous tasks
- Fix strategies
- Success criteria
- Notification settings
- Safety limits

### `.github/workflows/background-agent.yml`
GitHub Actions workflow that implements the agent:
- Multi-PowerShell version testing
- Comprehensive validation steps
- Auto-fix attempts on failures
- Detailed reporting
- Notification system

## Troubleshooting

### Agent Not Running
If the agent isn't running:
1. Check GitHub Actions are enabled for the repository
2. Verify the agent configuration files exist
3. Check for syntax errors in workflow files
4. Ensure proper permissions are set

### Agent Failures
If the agent reports failures:
1. Review the agent logs for specific error messages
2. Check if the issue is a known limitation
3. Verify if manual intervention is required
4. Check if the issue is within safety limits

### Manual Intervention Required
Some issues require manual intervention:
- Complex syntax errors that can't be automatically fixed
- Structural changes to the repository
- Breaking changes in dependencies
- Security-related issues

## Best Practices

### Working with the Agent
- Let the agent run its course before making manual changes
- Review agent reports before pushing new changes
- Use appropriate commit messages to help the agent understand changes
- Monitor agent status regularly

### Configuration Updates
- Test configuration changes in a branch first
- Update agent documentation when changing behavior
- Ensure safety limits are appropriate for your workflow
- Keep agent configuration synchronized with repository needs

### Performance Optimization
- Use specific agent modes when full testing isn't needed
- Schedule heavy operations during off-peak hours
- Monitor agent resource usage
- Adjust safety limits based on repository activity

## Integration with Development Workflow

The background agent integrates seamlessly with your development workflow:

1. **Development**: Write code normally
2. **Commit**: Push changes to repository
3. **Agent Activation**: Agent automatically tests changes
4. **Validation**: Agent validates all components
5. **Auto-Fix**: Agent fixes simple issues automatically
6. **Notification**: Agent reports results
7. **Manual Review**: Review any issues requiring manual intervention

This ensures that your PowerShell Profile Manager repository maintains high quality and reliability automatically, allowing you to focus on feature development while the agent handles quality assurance.

## Related Documentation

- [Cursor CLI GitHub Actions](https://cursor.com/docs/cli/github-actions)
- [Cursor Background Agent](https://cursor.com/docs/background-agent)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [PowerShell Module Development](./module-development.md)
- [Installation Guide](./installation.md)
- [Troubleshooting Guide](./troubleshooting.md)
