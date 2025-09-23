#Requires -Version 5.1

<#
.SYNOPSIS
    Performs robust web requests with timeouts and fallback methods

.DESCRIPTION
    This function provides a robust way to download files from the internet with:
    - Configurable timeouts
    - Multiple fallback methods (Invoke-WebRequest, Start-BitsTransfer, curl)
    - Retry logic
    - Progress reporting
    - Error handling

.PARAMETER Uri
    The URL to download from

.PARAMETER OutFile
    The local file path to save the download to

.PARAMETER TimeoutSec
    Timeout in seconds (default: 30)

.PARAMETER RetryCount
    Number of retry attempts (default: 3)

.PARAMETER UseBasicParsing
    Use basic parsing for Invoke-WebRequest (default: true)

.PARAMETER ShowProgress
    Show download progress (default: false)

.EXAMPLE
    Invoke-RobustWebRequest -Uri "https://example.com/file.zip" -OutFile "C:\temp\file.zip"
#>

function Invoke-RobustWebRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri,
        
        [Parameter(Mandatory = $true)]
        [string]$OutFile,
        
        [Parameter(Mandatory = $false)]
        [int]$TimeoutSec = 30,
        
        [Parameter(Mandatory = $false)]
        [int]$RetryCount = 3,
        
        [Parameter(Mandatory = $false)]
        [switch]$UseBasicParsing = $true,
        
        [Parameter(Mandatory = $false)]
        [switch]$ShowProgress = $false
    )

$ErrorActionPreference = 'Continue'

function Write-DownloadLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry -ForegroundColor $(switch ($Level) {
        'Error' { 'Red' }
        'Warning' { 'Yellow' }
        'Success' { 'Green' }
        default { 'White' }
    })
}

function Test-DownloadMethod {
    param(
        [string]$Method,
        [string]$Uri,
        [string]$OutFile,
        [int]$TimeoutSec
    )
    
    try {
        Write-DownloadLog "Attempting download using $Method..." 'Info'
        
        switch ($Method) {
            'Invoke-WebRequest' {
                $params = @{
                    Uri = $Uri
                    OutFile = $OutFile
                    UseBasicParsing = $UseBasicParsing
                    TimeoutSec = $TimeoutSec
                }
                if ($ShowProgress) {
                    $params.ProgressAction = { Write-Progress -Activity "Downloading" -Status "Downloading $Uri" -PercentComplete $_.PercentComplete }
                }
                Invoke-WebRequest @params
                return $true
            }
            
            'Start-BitsTransfer' {
                if (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
                    $params = @{
                        Source = $Uri
                        Destination = $OutFile
                    }
                    if ($ShowProgress) {
                        $params.DisplayName = "Downloading $Uri"
                    }
                    Start-BitsTransfer @params
                    return $true
                }
                return $false
            }
            
            'curl' {
                if (Get-Command curl -ErrorAction SilentlyContinue) {
                    $curlArgs = @('-L', '--connect-timeout', $TimeoutSec, '--max-time', $TimeoutSec, '-o', $OutFile, $Uri)
                    if (-not $ShowProgress) {
                        $curlArgs += '--silent'
                    }
                    & curl @curlArgs
                    return $LASTEXITCODE -eq 0
                }
                return $false
            }
            
            'wget' {
                if (Get-Command wget -ErrorAction SilentlyContinue) {
                    $wgetArgs = @('--timeout', $TimeoutSec, '--tries', '1', '-O', $OutFile, $Uri)
                    if (-not $ShowProgress) {
                        $wgetArgs += '--quiet'
                    }
                    & wget @wgetArgs
                    return $LASTEXITCODE -eq 0
                }
                return $false
            }
        }
    } catch {
        Write-DownloadLog "$Method failed: $($_.Exception.Message)" 'Warning'
        return $false
    }
}

# Ensure output directory exists
$outputDir = Split-Path $OutFile -Parent
if ($outputDir -and -not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# List of download methods to try in order
$downloadMethods = @('Invoke-WebRequest', 'Start-BitsTransfer', 'curl', 'wget')

$attempt = 1
foreach ($method in $downloadMethods) {
    Write-DownloadLog "Download attempt $attempt of $($downloadMethods.Count) using $method" 'Info'
    
    if (Test-DownloadMethod -Method $method -Uri $Uri -OutFile $OutFile -TimeoutSec $TimeoutSec) {
        if (Test-Path $OutFile) {
            $fileSize = (Get-Item $OutFile).Length
            Write-DownloadLog "Download successful using $method. File size: $fileSize bytes" 'Success'
            return $true
        }
    }
    
    $attempt++
    
    # Wait before retry
    if ($attempt -le $downloadMethods.Count) {
        Start-Sleep -Seconds 2
    }
}

    Write-DownloadLog "All download methods failed for: $Uri" 'Error'
    return $false
}

# If script is run directly (not dot-sourced), execute with parameters
if ($MyInvocation.InvocationName -ne '.') {
    # Script is being executed directly, not dot-sourced
    # This allows the script to be run standalone for testing
    if ($args.Count -ge 2) {
        $Uri = $args[0]
        $OutFile = $args[1]
        $TimeoutSec = 30
        $ShowProgress = $false
        
        # Parse additional parameters if provided
        for ($i = 2; $i -lt $args.Count; $i++) {
            if ($args[$i] -eq '-TimeoutSec' -and $i + 1 -lt $args.Count) {
                $TimeoutSec = [int]$args[$i + 1]
                $i++
            } elseif ($args[$i] -eq '-ShowProgress') {
                $ShowProgress = $true
            }
        }
        
        Invoke-RobustWebRequest -Uri $Uri -OutFile $OutFile -TimeoutSec $TimeoutSec -ShowProgress:$ShowProgress
    } else {
        Write-Host "Usage: .\Invoke-RobustWebRequest.ps1 -Uri <URL> -OutFile <Path> [-TimeoutSec <Seconds>] [-ShowProgress]"
    }
}
