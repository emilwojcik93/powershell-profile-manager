# PowerShell Profile Manager

A structured approach to managing your PowerShell profile with modular components for easy customization, loading, and maintenance.

## 🚀 Quick Start

### Installation

```powershell
# Install the profile manager
iwr -useb https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main/scripts/install.ps1 | iex
```

### Basic Usage

```powershell
# Load all modules
. $PROFILE

# Check loaded modules
Get-ProfileModules

# Unload specific module
Unload-ProfileModule VideoCompressor

# Reload specific module
Reload-ProfileModule VideoCompressor
```

## 📁 Repository Structure

```
powershell-profile-manager/
├── README.md                    # This file
├── CONTRIBUTING.md              # Contribution guidelines
├── MIGRATION_GUIDE.md           # Migration guide from gist
├── Microsoft.PowerShell_profile.ps1  # Main profile loader
├── scripts/                     # Installation and utility scripts
│   ├── install.ps1              # Installation script
│   ├── uninstall.ps1            # Uninstallation script
│   └── release.ps1              # Release preparation script
├── modules/                     # Module directory
│   ├── VideoCompressor/         # Video compression module
│   │   ├── VideoCompressor.psm1
│   │   ├── VideoCompressor.psd1
│   │   └── README.md
│   ├── PowerShellMCP/           # MCP Server for Cursor IDE
│   │   ├── PowerShellMCP.psm1
│   │   ├── PowerShellMCP.psd1
│   │   └── README.md
│   └── ExampleModule/           # Example module template
│       ├── ExampleModule.psm1
│       ├── ExampleModule.psd1
│       └── README.md
├── docs/                        # Documentation
│   ├── installation.md          # Installation guide
│   ├── module-development.md    # Module development guide
│   ├── troubleshooting.md       # Troubleshooting guide
│   ├── configuration.md         # Configuration guide
│   └── examples/                # Usage examples
└── .github/workflows/           # CI/CD workflows
    ├── release.yml              # Release automation
    └── test.yml                 # Testing automation
```

## 🎯 Features

- **Modular Design**: Each functionality is a separate module
- **Easy Management**: Load/unload modules individually
- **Error Handling**: Graceful handling of missing or broken modules
- **Auto-Installation**: Automatic setup and configuration
- **Clean Uninstall**: Complete removal with profile restoration
- **Documentation**: Comprehensive docs for each module
- **Release Management**: Automated release preparation
- **Background Agent**: Continuous monitoring and auto-fixing via Cursor agent

## 📦 Available Modules

### VideoCompressor
Compress video files with optimal settings for cloud storage platforms.

```powershell
Compress-Video "MyVideo.mp4" -CompressionMode Quality
```

### PowerShellMCP
MCP Server for Cursor IDE integration, enabling secure PowerShell command execution through AI agents.

```powershell
Start-PowerShellMCPServer
Get-PowerShellMCPStatus
```

### ExampleModule
Template module showing best practices for creating new modules.

## 🔧 Module Management

### Loading Modules
```powershell
# Load all modules (default behavior)
. $PROFILE

# Load specific module
Load-ProfileModule VideoCompressor
```

### Unloading Modules
```powershell
# Unload specific module
Unload-ProfileModule VideoCompressor

# Unload all modules
Unload-AllProfileModules
```

### Module Status
```powershell
# List all available modules
Get-ProfileModules

# Check module status
Get-ProfileModuleStatus VideoCompressor
```

## 🛠️ Development

### Creating a New Module

1. Copy the `ExampleModule` directory
2. Rename files and update content
3. Add module to `$PROFILE` configuration
4. Test and document

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Module Structure

Each module should follow this structure:
```
ModuleName/
├── ModuleName.psm1      # Main module file
├── ModuleName.psd1      # Module manifest
└── README.md            # Module documentation
```

## 📚 Documentation

- [Installation Guide](docs/installation.md)
- [Module Development](docs/module-development.md)
- [Configuration](docs/configuration.md)
- [Troubleshooting](docs/troubleshooting.md)

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- Create an issue for bugs or feature requests
- Check the [troubleshooting guide](docs/troubleshooting.md)
- Review module-specific documentation in `docs/modules/`
