#Requires -Version 5.1

<#
.SYNOPSIS
    Test SCP functionality to localhost on Windows 11

.DESCRIPTION
    This script tests SCP (Secure Copy Protocol) functionality to localhost
    by creating test files and attempting to copy them via SCP to the same machine.
    It verifies that the SSH server is running and SCP is working correctly.

.PARAMETER TestUser
    The username to use for SCP testing (defaults to current user)

.PARAMETER TestPort
    The SSH port to use for testing (defaults to 22)

.PARAMETER Cleanup
    Whether to cleanup test files after testing (defaults to true)

.EXAMPLE
    .\test-scp-localhost.ps1

.EXAMPLE
    .\test-scp-localhost.ps1 -TestUser "myuser" -TestPort 2222

.NOTES
    Author: PowerShell Profile Manager
    Requires: SSH server running on Windows 11
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$TestUser = $env:USERNAME,
    
    [Parameter()]
    [int]$TestPort = 22,
    
    [Parameter()]
    [switch]$Cleanup = $true
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to test SSH connectivity
function Test-SSHConnectivity {
    param(
        [string]$Hostname,
        [int]$Port,
        [string]$Username
    )
    
    try {
        Write-ColorOutput "Testing SSH connectivity to ${Hostname}:${Port} as ${Username}..." -Color 'Yellow'
        
        # Test SSH connection
        $sshTest = ssh -o ConnectTimeout=10 -o BatchMode=yes -p $Port "${Username}@${Hostname}" "echo 'SSH connection successful'" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput '[OK] SSH connection successful' -Color 'Green'
            return $true
        } else {
            Write-ColorOutput "[ERROR] SSH connection failed: $sshTest" -Color 'Red'
            return $false
        }
    } catch {
        Write-ColorOutput "[ERROR] SSH test failed: $($_.Exception.Message)" -Color 'Red'
        return $false
    }
}

# Function to test SCP functionality
function Test-SCPFunctionality {
    param(
        [string]$Hostname,
        [int]$Port,
        [string]$Username,
        [string]$SourceFile,
        [string]$DestinationPath
    )
    
    try {
        Write-ColorOutput "Testing SCP upload from ${SourceFile} to ${Username}@${Hostname}:${DestinationPath}..." -Color 'Yellow'
        
        # Test SCP upload
        $scpTest = scp -P $Port -o ConnectTimeout=10 -o BatchMode=yes "${SourceFile}" "${Username}@${Hostname}:${DestinationPath}" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput '[OK] SCP upload successful' -Color 'Green'
            return $true
        } else {
            Write-ColorOutput "[ERROR] SCP upload failed: $scpTest" -Color 'Red'
            return $false
        }
    } catch {
        Write-ColorOutput "[ERROR] SCP test failed: $($_.Exception.Message)" -Color 'Red'
        return $false
    }
}

# Function to test SCP download
function Test-SCPDownload {
    param(
        [string]$Hostname,
        [int]$Port,
        [string]$Username,
        [string]$RemoteFile,
        [string]$LocalPath
    )
    
    try {
        Write-ColorOutput "Testing SCP download from ${Username}@${Hostname}:${RemoteFile} to ${LocalPath}..." -Color 'Yellow'
        
        # Test SCP download
        $scpTest = scp -P $Port -o ConnectTimeout=10 -o BatchMode=yes "${Username}@${Hostname}:${RemoteFile}" "${LocalPath}" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput '[OK] SCP download successful' -Color 'Green'
            return $true
        } else {
            Write-ColorOutput "[ERROR] SCP download failed: $scpTest" -Color 'Red'
            return $false
        }
    } catch {
        Write-ColorOutput "[ERROR] SCP download test failed: $($_.Exception.Message)" -Color 'Red'
        return $false
    }
}

# Main execution
try {
    Write-ColorOutput '=== SCP Localhost Test ===' -Color 'Cyan'
    Write-ColorOutput 'Testing SCP functionality to localhost on Windows 11' -Color 'Cyan'
    Write-ColorOutput ''
    
    # Check if SSH server is running
    Write-ColorOutput 'Checking SSH server status...' -Color 'Yellow'
    $sshService = Get-Service -Name 'sshd' -ErrorAction SilentlyContinue
    if ($sshService -and $sshService.Status -eq 'Running') {
        Write-ColorOutput '[OK] SSH server is running' -Color 'Green'
    } else {
        Write-ColorOutput '[ERROR] SSH server is not running. Please start the SSH server first.' -Color 'Red'
        exit 1
    }
    
    # Create test directory
    $testDir = Join-Path $env:TEMP "scp-test-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Write-ColorOutput "Created test directory: $testDir" -Color 'Green'
    
    # Create test file
    $testFile = Join-Path $testDir 'test-file.txt'
    $testContent = @"
SCP Test File
Created: $(Get-Date)
User: $TestUser
Host: localhost
Port: $TestPort
Random Data: $(Get-Random)
"@
    Set-Content -Path $testFile -Value $testContent -Encoding UTF8
    Write-ColorOutput "Created test file: $testFile" -Color 'Green'
    
    # Test SSH connectivity
    $sshSuccess = Test-SSHConnectivity -Hostname 'localhost' -Port $TestPort -Username $TestUser
    if (-not $sshSuccess) {
        Write-ColorOutput '[ERROR] SSH connectivity test failed. Cannot proceed with SCP tests.' -Color 'Red'
        exit 1
    }
    
    # Test SCP upload
    $remoteTestDir = "/tmp/scp-test-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $remoteTestFile = "${remoteTestDir}/test-file.txt"
    
    # Create remote directory first
    Write-ColorOutput 'Creating remote test directory...' -Color 'Yellow'
    $mkdirResult = ssh -p $TestPort "${TestUser}@localhost" "mkdir -p ${remoteTestDir}" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput '[OK] Remote directory created' -Color 'Green'
    } else {
        Write-ColorOutput "[WARNING] Could not create remote directory: $mkdirResult" -Color 'Yellow'
    }
    
    $scpUploadSuccess = Test-SCPFunctionality -Hostname 'localhost' -Port $TestPort -Username $TestUser -SourceFile $testFile -DestinationPath $remoteTestFile
    
    # Test SCP download
    $downloadFile = Join-Path $testDir 'downloaded-file.txt'
    $scpDownloadSuccess = $false
    
    if ($scpUploadSuccess) {
        $scpDownloadSuccess = Test-SCPDownload -Hostname 'localhost' -Port $TestPort -Username $TestUser -RemoteFile $remoteTestFile -LocalPath $downloadFile
        
        # Verify downloaded file
        if ($scpDownloadSuccess -and (Test-Path $downloadFile)) {
            $originalContent = Get-Content $testFile -Raw
            $downloadedContent = Get-Content $downloadFile -Raw
            
            if ($originalContent -eq $downloadedContent) {
                Write-ColorOutput '[OK] Downloaded file content matches original' -Color 'Green'
            } else {
                Write-ColorOutput '[WARNING] Downloaded file content does not match original' -Color 'Yellow'
            }
        }
    }
    
    # Test results summary
    Write-ColorOutput '' -Color 'White'
    Write-ColorOutput '=== Test Results Summary ===' -Color 'Cyan'
    Write-ColorOutput "SSH Connectivity: $(if ($sshSuccess) { '[OK]' } else { '[FAILED]' })" -Color $(if ($sshSuccess) {
            'Green' 
        } else {
            'Red' 
        })
    Write-ColorOutput "SCP Upload: $(if ($scpUploadSuccess) { '[OK]' } else { '[FAILED]' })" -Color $(if ($scpUploadSuccess) {
            'Green' 
        } else {
            'Red' 
        })
    Write-ColorOutput "SCP Download: $(if ($scpDownloadSuccess) { '[OK]' } else { '[FAILED]' })" -Color $(if ($scpDownloadSuccess) {
            'Green' 
        } else {
            'Red' 
        })
    
    # Overall result
    if ($sshSuccess -and $scpUploadSuccess -and $scpDownloadSuccess) {
        Write-ColorOutput '' -Color 'White'
        Write-ColorOutput '[SUCCESS] All SCP tests passed! SCP to localhost is working correctly.' -Color 'Green'
        $exitCode = 0
    } else {
        Write-ColorOutput '' -Color 'White'
        Write-ColorOutput '[FAILED] Some SCP tests failed. Check the output above for details.' -Color 'Red'
        $exitCode = 1
    }
    
    # Cleanup
    if ($Cleanup) {
        Write-ColorOutput '' -Color 'White'
        Write-ColorOutput 'Cleaning up test files...' -Color 'Yellow'
        
        # Clean up local test files
        if (Test-Path $testDir) {
            Remove-Item -Path $testDir -Recurse -Force
            Write-ColorOutput '[OK] Local test files cleaned up' -Color 'Green'
        }
        
        # Clean up remote test files
        if ($scpUploadSuccess) {
            $cleanupResult = ssh -p $TestPort "${TestUser}@localhost" "rm -rf ${remoteTestDir}" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput '[OK] Remote test files cleaned up' -Color 'Green'
            } else {
                Write-ColorOutput "[WARNING] Could not clean up remote test files: $cleanupResult" -Color 'Yellow'
            }
        }
    } else {
        Write-ColorOutput '' -Color 'White'
        Write-ColorOutput 'Test files preserved:' -Color 'Yellow'
        Write-ColorOutput "  Local: $testDir" -Color 'White'
        Write-ColorOutput "  Remote: $remoteTestDir" -Color 'White'
    }
    
    Write-ColorOutput '' -Color 'White'
    Write-ColorOutput "SCP test completed with exit code: $exitCode" -Color 'Cyan'
    exit $exitCode
} catch {
    Write-ColorOutput "[ERROR] Unexpected error during SCP testing: $($_.Exception.Message)" -Color 'Red'
    Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" -Color 'Red'
    exit 1
}
