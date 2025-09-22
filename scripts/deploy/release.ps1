# PowerShell Profile Manager Release Preparation Script
# This script prepares the repository for release by creating a compressed package

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\releases",
    
    [Parameter(Mandatory = $false)]
    [string]$Version = "1.0.0",
    
    [Parameter(Mandatory = $false)]
    [switch]$IncludeExamples = $false,
    
    [Parameter(Mandatory = $false)]
    [switch]$CreateInstaller = $true,
    
    [Parameter(Mandatory = $false)]
    [string]$RepositoryUrl = "https://raw.githubusercontent.com/emilwojcik93/powershell-profile-manager/main"
)

function Write-ReleaseLog {
    param(
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    
    switch ($Level) {
        "Info" { Write-Host $logMessage -ForegroundColor White }
        "Success" { Write-Host $logMessage -ForegroundColor Green }
        "Warning" { Write-Host $logMessage -ForegroundColor Yellow }
        "Error" { Write-Host $logMessage -ForegroundColor Red }
    }
}

function Test-RepositoryStructure {
    Write-ReleaseLog "Validating repository structure..." "Info"
    
    $requiredFiles = @(
        "Microsoft.PowerShell_profile.ps1",
        "scripts\install.ps1",
        "scripts\uninstall.ps1",
        "scripts\release.ps1",
        "README.md",
        "CONTRIBUTING.md"
    )
    
    $requiredDirs = @(
        "modules",
        "docs"
    )
    
    $missingFiles = @()
    $missingDirs = @()
    
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            $missingFiles += $file
        }
    }
    
    foreach ($dir in $requiredDirs) {
        if (-not (Test-Path $dir)) {
            $missingDirs += $dir
        }
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-ReleaseLog "Missing required files: $($missingFiles -join ', ')" "Error"
        return $false
    }
    
    if ($missingDirs.Count -gt 0) {
        Write-ReleaseLog "Missing required directories: $($missingDirs -join ', ')" "Error"
        return $false
    }
    
    Write-ReleaseLog "Repository structure validation passed" "Success"
    return $true
}

function Test-Modules {
    Write-ReleaseLog "Testing modules..." "Info"
    
    $moduleDirs = Get-ChildItem -Path "modules" -Directory
    
    foreach ($moduleDir in $moduleDirs) {
        $moduleName = $moduleDir.Name
        
        # Skip example module unless explicitly included
        if ($moduleName -eq "ExampleModule" -and -not $IncludeExamples) {
            Write-ReleaseLog "  Skipping ExampleModule (not included in release)" "Info"
            continue
        }
        
        Write-ReleaseLog "  Testing module: $moduleName" "Info"
        
        $moduleFiles = @(
            "$moduleName.psm1",
            "$moduleName.psd1",
            "README.md"
        )
        
        foreach ($file in $moduleFiles) {
            $filePath = Join-Path $moduleDir.FullName $file
            if (-not (Test-Path $filePath)) {
                Write-ReleaseLog "    Missing file: $file" "Error"
                return $false
            }
        }
        
        # Test module syntax
        try {
            $modulePath = Join-Path $moduleDir.FullName "$moduleName.psm1"
            $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $modulePath -Raw), [ref]$null)
            Write-ReleaseLog "    Syntax validation passed" "Success"
        }
        catch {
            Write-ReleaseLog "    Syntax validation failed: $($_.Exception.Message)" "Error"
            return $false
        }
    }
    
    Write-ReleaseLog "Module testing completed" "Success"
    return $true
}

function Update-VersionNumbers {
    Write-ReleaseLog "Updating version numbers..." "Info"
    
    try {
        # Update main profile script
        $profileContent = Get-Content "Microsoft.PowerShell_profile.ps1" -Raw
        $profileContent = $profileContent -replace 'ModuleVersion = ''[^'']*''', "ModuleVersion = '$Version'"
        Set-Content -Path "Microsoft.PowerShell_profile.ps1" -Value $profileContent -Encoding UTF8
        
        # Update module manifests
        $moduleDirs = Get-ChildItem -Path "modules" -Directory
        
        foreach ($moduleDir in $moduleDirs) {
            $moduleName = $moduleDir.Name
            
            # Skip example module unless explicitly included
            if ($moduleName -eq "ExampleModule" -and -not $IncludeExamples) {
                continue
            }
            
            $manifestPath = Join-Path $moduleDir.FullName "$moduleName.psd1"
            if (Test-Path $manifestPath) {
                $manifestContent = Get-Content $manifestPath -Raw
                $manifestContent = $manifestContent -replace 'ModuleVersion = ''[^'']*''', "ModuleVersion = '$Version'"
                Set-Content -Path $manifestPath -Value $manifestContent -Encoding UTF8
                Write-ReleaseLog "  Updated $moduleName manifest" "Success"
            }
        }
        
        Write-ReleaseLog "Version numbers updated to $Version" "Success"
        return $true
    }
    catch {
        Write-ReleaseLog "Failed to update version numbers: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Create-ReleasePackage {
    Write-ReleaseLog "Creating release package..." "Info"
    
    try {
        # Create output directory
        if (-not (Test-Path $OutputPath)) {
            New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        }
        
        $packageName = "PowerShell-Profile-Manager-v$Version"
        $packagePath = Join-Path $OutputPath $packageName
        
        # Remove existing package if it exists
        if (Test-Path $packagePath) {
            Remove-Item -Path $packagePath -Recurse -Force
        }
        
        # Create package directory
        New-Item -ItemType Directory -Path $packagePath -Force | Out-Null
        
        # Copy main files
        $mainFiles = @(
            "Microsoft.PowerShell_profile.ps1",
            "README.md",
            "CONTRIBUTING.md"
        )
        
        foreach ($file in $mainFiles) {
            if (Test-Path $file) {
                Copy-Item -Path $file -Destination $packagePath -Force
                Write-ReleaseLog "  Copied $file" "Success"
            }
        }
        
        # Copy scripts directory
        $scriptsPath = Join-Path $packagePath "scripts"
        if (Test-Path "scripts") {
            Copy-Item -Path "scripts" -Destination $scriptsPath -Recurse -Force
            Write-ReleaseLog "  Copied scripts directory" "Success"
        }
        
        # Copy modules
        $modulesPath = Join-Path $packagePath "modules"
        New-Item -ItemType Directory -Path $modulesPath -Force | Out-Null
        
        $moduleDirs = Get-ChildItem -Path "modules" -Directory
        
        foreach ($moduleDir in $moduleDirs) {
            $moduleName = $moduleDir.Name
            
            # Skip example module unless explicitly included
            if ($moduleName -eq "ExampleModule" -and -not $IncludeExamples) {
                continue
            }
            
            $destModulePath = Join-Path $modulesPath $moduleName
            Copy-Item -Path $moduleDir.FullName -Destination $destModulePath -Recurse -Force
            Write-ReleaseLog "  Copied module: $moduleName" "Success"
        }
        
        # Copy documentation
        $docsPath = Join-Path $packagePath "docs"
        if (Test-Path "docs") {
            Copy-Item -Path "docs" -Destination $docsPath -Recurse -Force
            Write-ReleaseLog "  Copied documentation" "Success"
        }
        
        Write-ReleaseLog "Release package created: $packagePath" "Success"
        return $packagePath
    }
    catch {
        Write-ReleaseLog "Failed to create release package: $($_.Exception.Message)" "Error"
        return $null
    }
}

function Create-InstallerScript {
    param([string]$PackagePath)
    
    Write-ReleaseLog "Creating installer script..." "Info"
    
    try {
        $installerPath = Join-Path $PackagePath "install.ps1"
        
        # Read the current install script
        $installScript = Get-Content "scripts\install.ps1" -Raw
        
        # Update repository URL to use the release
        $installScript = $installScript -replace 'https://raw\.githubusercontent\.com/[^/]+/[^/]+/main', $RepositoryUrl
        
        # Write the installer script
        Set-Content -Path $installerPath -Value $installScript -Encoding UTF8
        
        Write-ReleaseLog "Installer script created: $installerPath" "Success"
        return $installerPath
    }
    catch {
        Write-ReleaseLog "Failed to create installer script: $($_.Exception.Message)" "Error"
        return $null
    }
}

function Create-ReleaseArchive {
    param([string]$PackagePath)
    
    Write-ReleaseLog "Creating release archive..." "Info"
    
    try {
        $archiveName = "PowerShell-Profile-Manager-v$Version.zip"
        $archivePath = Join-Path $OutputPath $archiveName
        
        # Remove existing archive if it exists
        if (Test-Path $archivePath) {
            Remove-Item -Path $archivePath -Force
        }
        
        # Create ZIP archive
        Compress-Archive -Path "$PackagePath\*" -DestinationPath $archivePath -Force
        
        Write-ReleaseLog "Release archive created: $archivePath" "Success"
        return $archivePath
    }
    catch {
        Write-ReleaseLog "Failed to create release archive: $($_.Exception.Message)" "Error"
        return $null
    }
}

function Create-ReleaseNotes {
    param([string]$PackagePath)
    
    Write-ReleaseLog "Creating release notes..." "Info"
    
    try {
        $releaseNotesPath = Join-Path $PackagePath "RELEASE_NOTES.md"
        
        $releaseNotes = @"
# PowerShell Profile Manager v$Version

## Release Information
- **Version**: $Version
- **Release Date**: $(Get-Date -Format "yyyy-MM-dd")
- **Repository**: $RepositoryUrl

## What's Included

### Core Components
- PowerShell Profile Manager main script
- Installation script
- Uninstallation script
- Comprehensive documentation

### Modules
"@

        # Add module information
        $moduleDirs = Get-ChildItem -Path "modules" -Directory
        
        foreach ($moduleDir in $moduleDirs) {
            $moduleName = $moduleDir.Name
            
            # Skip example module unless explicitly included
            if ($moduleName -eq "ExampleModule" -and -not $IncludeExamples) {
                continue
            }
            
            $manifestPath = Join-Path $moduleDir.FullName "$moduleName.psd1"
            if (Test-Path $manifestPath) {
                $manifest = Import-PowerShellDataFile $manifestPath
                $releaseNotes += "`n- **$moduleName** v$($manifest.ModuleVersion): $($manifest.Description)"
            }
        }
        
        $releaseNotes += @"

## Installation

### Quick Install
```powershell
iwr -useb $RepositoryUrl/install.ps1 | iex
```

### Manual Install
1. Download the release archive
2. Extract to your desired location
3. Run the install.ps1 script

## Usage

After installation, restart PowerShell and use:

```powershell
# Check loaded modules
Get-ProfileModules

# Use VideoCompressor
Compress-Video "MyVideo.mp4"

# Check module status
Get-ProfileModuleStatus VideoCompressor
```

## Documentation

See the `docs/` directory for comprehensive documentation:
- Installation guide
- Module development guide
- Troubleshooting guide

## Support

- GitHub Issues: $RepositoryUrl/issues
- Documentation: $RepositoryUrl/docs
- Examples: $RepositoryUrl/examples

## License

This project is licensed under the MIT License.
"@

        Set-Content -Path $releaseNotesPath -Value $releaseNotes -Encoding UTF8
        
        Write-ReleaseLog "Release notes created: $releaseNotesPath" "Success"
        return $releaseNotesPath
    }
    catch {
        Write-ReleaseLog "Failed to create release notes: $($_.Exception.Message)" "Error"
        return $null
    }
}

function Show-ReleaseSummary {
    param(
        [string]$PackagePath,
        [string]$ArchivePath,
        [string]$ReleaseNotesPath
    )
    
    Write-ReleaseLog "Release Preparation Summary" "Info"
    Write-ReleaseLog "===========================" "Info"
    Write-ReleaseLog ""
    Write-ReleaseLog "Version: $Version" "Info"
    Write-ReleaseLog "Package Path: $PackagePath" "Info"
    Write-ReleaseLog "Archive Path: $ArchivePath" "Info"
    Write-ReleaseLog "Release Notes: $ReleaseNotesPath" "Info"
    Write-ReleaseLog ""
    Write-ReleaseLog "Files Created:" "Info"
    Write-ReleaseLog "  ✓ Release package directory" "Success"
    Write-ReleaseLog "  ✓ Release archive (ZIP)" "Success"
    Write-ReleaseLog "  ✓ Release notes" "Success"
    Write-ReleaseLog "  ✓ Updated installer script" "Success"
    Write-ReleaseLog ""
    Write-ReleaseLog "Next Steps:" "Info"
    Write-ReleaseLog "  1. Test the release package" "Info"
    Write-ReleaseLog "  2. Upload to GitHub releases" "Info"
    Write-ReleaseLog "  3. Update documentation with new version" "Info"
    Write-ReleaseLog "  4. Announce the release" "Info"
}

# Main release preparation process
try {
    Write-ReleaseLog "PowerShell Profile Manager Release Preparation" "Info"
    Write-ReleaseLog "==============================================" "Info"
    Write-ReleaseLog ""
    Write-ReleaseLog "Version: $Version" "Info"
    Write-ReleaseLog "Output Path: $OutputPath" "Info"
    Write-ReleaseLog "Include Examples: $IncludeExamples" "Info"
    Write-ReleaseLog "Create Installer: $CreateInstaller" "Info"
    Write-ReleaseLog "Repository URL: $RepositoryUrl" "Info"
    Write-ReleaseLog ""
    
    # Validate repository structure
    if (-not (Test-RepositoryStructure)) {
        Write-ReleaseLog "Repository structure validation failed" "Error"
        exit 1
    }
    
    # Test modules
    if (-not (Test-Modules)) {
        Write-ReleaseLog "Module testing failed" "Error"
        exit 1
    }
    
    # Update version numbers
    if (-not (Update-VersionNumbers)) {
        Write-ReleaseLog "Version number update failed" "Error"
        exit 1
    }
    
    # Create release package
    $packagePath = Create-ReleasePackage
    if (-not $packagePath) {
        Write-ReleaseLog "Release package creation failed" "Error"
        exit 1
    }
    
    # Create installer script
    if ($CreateInstaller) {
        $installerPath = Create-InstallerScript -PackagePath $packagePath
        if (-not $installerPath) {
            Write-ReleaseLog "Installer script creation failed" "Error"
            exit 1
        }
    }
    
    # Create release archive
    $archivePath = Create-ReleaseArchive -PackagePath $packagePath
    if (-not $archivePath) {
        Write-ReleaseLog "Release archive creation failed" "Error"
        exit 1
    }
    
    # Create release notes
    $releaseNotesPath = Create-ReleaseNotes -PackagePath $packagePath
    if (-not $releaseNotesPath) {
        Write-ReleaseLog "Release notes creation failed" "Error"
        exit 1
    }
    
    # Show summary
    Show-ReleaseSummary -PackagePath $packagePath -ArchivePath $archivePath -ReleaseNotesPath $releaseNotesPath
    
    Write-ReleaseLog "Release preparation completed successfully!" "Success"
}
catch {
    Write-ReleaseLog "Release preparation failed with error: $($_.Exception.Message)" "Error"
    exit 1
}
