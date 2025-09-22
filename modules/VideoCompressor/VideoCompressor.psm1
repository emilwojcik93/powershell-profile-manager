# VideoCompressor Module
# PowerShell module for video compression optimized for cloud storage platforms

function Test-FFmpegInstallation {
    <#
    .SYNOPSIS
    Checks if FFmpeg is available and installs it if not found
    
    .DESCRIPTION
    This function checks for FFmpeg installation in the system PATH and winget packages.
    If not found, it offers to install FFmpeg using winget.
    
    .OUTPUTS
    [bool] Returns $true if FFmpeg is available, $false otherwise
    
    .EXAMPLE
    Test-FFmpegInstallation
    #>
    
    # Check if ffmpeg is available in PATH
    $ffmpegAvailable = Get-Command ffmpeg -ErrorAction SilentlyContinue
    $ffprobeAvailable = Get-Command ffprobe -ErrorAction SilentlyContinue
    
    # If not found in PATH, check winget packages directory
    if (-not $ffmpegAvailable -or -not $ffprobeAvailable) {
        Write-Host "FFmpeg not found in PATH. Checking winget packages..." -ForegroundColor Yellow
        $wingetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages"
        
        if (Test-Path $wingetPath) {
            # Look for FFmpeg packages
            $ffmpegDirs = @(
                "Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe",
                "BtbN.FFmpeg*",
                "*FFmpeg*"
            )
            
            foreach ($pattern in $ffmpegDirs) {
                $packageDirs = Get-ChildItem -Path $wingetPath -Directory -Name $pattern -ErrorAction SilentlyContinue
                
                foreach ($packageDir in $packageDirs) {
                    $fullPackagePath = Join-Path $wingetPath $packageDir
                    
                    # Look for bin directories recursively
                    $binDirs = Get-ChildItem -Path $fullPackagePath -Recurse -Directory -Name "bin" -ErrorAction SilentlyContinue
                    
                    foreach ($binDir in $binDirs) {
                        $binPath = Join-Path $fullPackagePath $binDir
                        $ffmpegExe = Join-Path $binPath "ffmpeg.exe"
                        $ffprobeExe = Join-Path $binPath "ffprobe.exe"
                        
                        if ((Test-Path $ffmpegExe) -and (Test-Path $ffprobeExe)) {
                            Write-Host "Found FFmpeg installation at: $binPath" -ForegroundColor Green
                            
                            # Add to current session PATH
                            if ($env:PATH -notlike "*$binPath*") {
                                $env:PATH += ";$binPath"
                                Write-Host "Added to current session PATH: $binPath" -ForegroundColor Green
                            }
                            
                            # Ask user if they want to add to permanent PATH
                            $addToPermanentPath = Read-Host "Add FFmpeg to permanent system PATH? (y/n)"
                            if ($addToPermanentPath -eq 'y' -or $addToPermanentPath -eq 'Y') {
                                try {
                                    # Get current user PATH
                                    $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
                                    if ($userPath -notlike "*$binPath*") {
                                        $newUserPath = "$userPath;$binPath"
                                        [System.Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
                                        Write-Host "Added to permanent user PATH. Restart PowerShell for changes to take effect." -ForegroundColor Green
                                    } else {
                                        Write-Host "FFmpeg is already in permanent PATH." -ForegroundColor Yellow
                                    }
                                } catch {
                                    Write-Host "Failed to update permanent PATH: $($_.Exception.Message)" -ForegroundColor Red
                                }
                            }
                            
                            # Verify the commands are now available
                            $ffmpegAvailable = Get-Command ffmpeg -ErrorAction SilentlyContinue
                            $ffprobeAvailable = Get-Command ffprobe -ErrorAction SilentlyContinue
                            
                            if ($ffmpegAvailable -and $ffprobeAvailable) {
                                Write-Host "FFmpeg is now available!" -ForegroundColor Green
                                return $true
                            }
                        }
                    }
                }
            }
        }
    }
    
    if (-not $ffmpegAvailable -or -not $ffprobeAvailable) {
        Write-Host "FFmpeg is not recognized as an internal or external command." -ForegroundColor Red
        Write-Host "FFmpeg is required for video compression." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Available installation options via winget:" -ForegroundColor Cyan
        Write-Host "1. Gyan.FFmpeg (MSVC build - Best Windows compatibility)" -ForegroundColor Green
        Write-Host "2. BtbN.FFmpeg.GPL (MinGW build - Latest features)" -ForegroundColor Yellow
        Write-Host ""
        
        $install = Read-Host "Do you want to install FFmpeg now? (y/n)"
        
        if ($install -eq 'y' -or $install -eq 'Y') {
            Write-Host "Installing FFmpeg (Gyan.FFmpeg)..." -ForegroundColor Yellow
            
            try {
                winget install Gyan.FFmpeg --accept-package-agreements --accept-source-agreements
                
                # Refresh PATH in current session
                $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
                
                # Verify installation
                Start-Sleep -Seconds 3
                $ffmpegAvailable = Get-Command ffmpeg -ErrorAction SilentlyContinue
                
                if (-not $ffmpegAvailable) {
                    Write-Host "Primary installation failed. Trying alternative package (BtbN.FFmpeg.GPL)..." -ForegroundColor Yellow
                    winget install BtbN.FFmpeg.GPL --accept-package-agreements --accept-source-agreements
                    
                    # Refresh PATH again
                    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
                    Start-Sleep -Seconds 3
                    $ffmpegAvailable = Get-Command ffmpeg -ErrorAction SilentlyContinue
                }
                
                if ($ffmpegAvailable) {
                    Write-Host "FFmpeg installed successfully!" -ForegroundColor Green
                    Write-Host "You may need to restart PowerShell for PATH changes to take effect." -ForegroundColor Yellow
                    return $true
                }
                else {
                    Write-Host "FFmpeg installation failed. Please install manually or restart PowerShell." -ForegroundColor Red
                    Write-Host "Manual installation: Download from https://ffmpeg.org/download.html" -ForegroundColor Yellow
                    return $false
                }
            }
            catch {
                Write-Host "Error installing FFmpeg: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "Please try installing manually:" -ForegroundColor Yellow
                Write-Host "  winget install Gyan.FFmpeg" -ForegroundColor Cyan
                Write-Host "  or: winget install BtbN.FFmpeg.GPL" -ForegroundColor Cyan
                return $false
            }
        }
        else {
            Write-Host "FFmpeg installation cancelled. Cannot proceed without FFmpeg." -ForegroundColor Red
            return $false
        }
    }
    
    return $true
}

function Get-VideoProperties {
    <#
    .SYNOPSIS
    Uses ffprobe to analyze video properties for optimal compression
    
    .DESCRIPTION
    Analyzes video file properties including duration, resolution, frame rate,
    bitrates, and codecs using ffprobe.
    
    .PARAMETER VideoPath
    Path to the video file to analyze
    
    .OUTPUTS
    [hashtable] Video properties including duration, resolution, frame rate, etc.
    
    .EXAMPLE
    Get-VideoProperties -VideoPath "C:\Videos\MyVideo.mp4"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$VideoPath
    )
    
    try {
        # Get video information using ffprobe
        $probeOutput = ffprobe -v quiet -print_format json -show_streams -show_format "$VideoPath" | ConvertFrom-Json
        
        $videoStream = $probeOutput.streams | Where-Object { $_.codec_type -eq "video" } | Select-Object -First 1
        $audioStream = $probeOutput.streams | Where-Object { $_.codec_type -eq "audio" } | Select-Object -First 1
        
        $properties = @{
            Duration = [math]::Round([double]$probeOutput.format.duration, 2)
            Width = [int]$videoStream.width
            Height = [int]$videoStream.height
            FrameRate = if ($videoStream.r_frame_rate) { 
                $fps = $videoStream.r_frame_rate.Split('/')
                [math]::Round([double]$fps[0] / [double]$fps[1], 2)
            } else { 30 }
            VideoBitrate = if ($videoStream.bit_rate) { [int]$videoStream.bit_rate } else { 0 }
            AudioBitrate = if ($audioStream.bit_rate) { [int]$audioStream.bit_rate } else { 128000 }
            VideoCodec = $videoStream.codec_name
            AudioCodec = if ($audioStream) { $audioStream.codec_name } else { "none" }
            FileSize = [math]::Round((Get-Item $VideoPath).Length / 1MB, 2)
        }
        
        return $properties
    }
    catch {
        Write-Host "Error analyzing video: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Get-OptimalCompressionSettings {
    <#
    .SYNOPSIS
    Determines optimal compression settings based on video properties and target platform
    
    .DESCRIPTION
    Analyzes video properties and determines optimal compression settings including
    resolution, frame rate, CRF, and hardware acceleration options.
    
    .PARAMETER VideoProperties
    Hashtable containing video properties from Get-VideoProperties
    
    .PARAMETER CompressionMode
    Compression mode: Fast, Balanced, or Quality
    
    .OUTPUTS
    [hashtable] Compression settings including resolution, frame rate, CRF, etc.
    
    .EXAMPLE
    $props = Get-VideoProperties -VideoPath "video.mp4"
    $settings = Get-OptimalCompressionSettings -VideoProperties $props -CompressionMode "Quality"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$VideoProperties,
        
        [Parameter(Mandatory = $false)]
        [string]$CompressionMode = "Balanced"
    )
    
    $width = $VideoProperties.Width
    $height = $VideoProperties.Height
    $fps = $VideoProperties.FrameRate
    $duration = $VideoProperties.Duration
    
    # Determine target resolution (maintain aspect ratio)
    $targetWidth = $width
    $targetHeight = $height
    
    # Optimize for cloud storage - limit resolution for better streaming
    if ($width -gt 1920 -or $height -gt 1080) {
        # Scale down to 1080p max while maintaining aspect ratio
        $aspectRatio = $width / $height
        if ($aspectRatio -gt (16/9)) {
            $targetWidth = 1920
            $targetHeight = [math]::Round(1920 / $aspectRatio / 2) * 2  # Even number
        } else {
            $targetHeight = 1080
            $targetWidth = [math]::Round(1080 * $aspectRatio / 2) * 2   # Even number
        }
    }
    
    # Optimize frame rate
    $targetFps = $fps
    if ($fps -gt 60) { $targetFps = 60 }
    elseif ($fps -gt 30 -and $duration -gt 600) { $targetFps = 30 }  # Long videos benefit from 30fps
    
    # Determine CRF based on content type and duration
    $crf = 23  # Default balanced quality
    if ($duration -lt 300) { $crf = 21 }      # Short videos - higher quality
    elseif ($duration -gt 3600) { $crf = 25 } # Long videos - more compression
    
    # Audio bitrate optimization
    $audioBitrate = "128k"
    if ($VideoProperties.AudioBitrate -gt 0) {
        if ($VideoProperties.AudioBitrate -le 96000) { $audioBitrate = "96k" }
        elseif ($VideoProperties.AudioBitrate -ge 256000) { $audioBitrate = "192k" }
    }
    
    # Choose preset and CRF based on compression mode
    switch ($CompressionMode) {
        "Fast" {
            $preset = "fast"
            $crf = $crf + 2  # Slightly higher CRF for faster encoding
        }
        "Quality" {
            $preset = "slow" 
            $crf = $crf - 1  # Lower CRF for better quality
        }
        default { # "Balanced"
            $preset = "medium"
            # Keep calculated CRF as is
        }
    }
    
    # Try to detect hardware acceleration capabilities (only if ffmpeg is available)
    $hwEncoder = $null
    $hwAvailable = $false
    
    if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
        # Check for Intel QuickSync (common on Intel CPUs like Core Ultra)
        try {
            $null = ffmpeg -hide_banner -f lavfi -i testsrc2=duration=1:size=320x240:rate=1 -c:v h264_qsv -f null - 2>$null
            if ($LASTEXITCODE -eq 0) {
                $hwEncoder = "h264_qsv"
                $hwAvailable = $true
            }
        } catch { }
        
        # Check for NVIDIA NVENC if QuickSync not available
        if (-not $hwAvailable) {
            try {
                $null = ffmpeg -hide_banner -f lavfi -i testsrc2=duration=1:size=320x240:rate=1 -c:v h264_nvenc -f null - 2>$null
                if ($LASTEXITCODE -eq 0) {
                    $hwEncoder = "h264_nvenc"
                    $hwAvailable = $true
                }
            } catch { }
        }
    }
    
    $settings = @{
        Resolution = "${targetWidth}x${targetHeight}"
        FrameRate = $targetFps
        CRF = $crf
        AudioBitrate = $audioBitrate
        Preset = $preset
        Profile = "high"
        Level = "4.0"
        HardwareEncoder = $hwEncoder
        HardwareAvailable = $hwAvailable
    }
    
    return $settings
}

function Get-OutputDirectory {
    <#
    .SYNOPSIS
    Determines the best output directory (OneDrive or Videos folder)
    
    .DESCRIPTION
    Checks for OneDrive availability and service status, then determines
    the optimal output directory for compressed videos.
    
    .OUTPUTS
    [string] Path to the output directory
    
    .EXAMPLE
    $outputDir = Get-OutputDirectory
    #>
    
    # Check if OneDrive is available and service is running
    $oneDriveAvailable = $false
    
    if ($env:OneDrive -and (Test-Path $env:OneDrive)) {
        # Check if OneDrive service is running
        $oneDriveService = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
        if ($oneDriveService) {
            $oneDriveAvailable = $true
            $outputDir = Join-Path $env:OneDrive "CompressedVideos"
        }
    }
    
    if (-not $oneDriveAvailable) {
        # Fallback to Videos directory using .NET method
        try {
            $videosPath = [System.Environment]::GetFolderPath('MyVideos')
            $outputDir = Join-Path $videosPath "CompressedVideos"
        }
        catch {
            # Final fallback to user profile
            $outputDir = Join-Path $env:USERPROFILE "Videos\CompressedVideos"
        }
    }
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        Write-Host "Created output directory: $outputDir" -ForegroundColor Green
    }
    
    return $outputDir
}

function Compress-Video {
    <#
    .SYNOPSIS
    Compresses video files with optimal settings for cloud storage platforms
    
    .DESCRIPTION
    This function compresses video files using FFmpeg with settings optimized for
    cloud storage platforms like OneDrive, YouTube, SharePoint, and MS Stream.
    
    .PARAMETER SourceVideo
    Path to the source video file to compress
    
    .PARAMETER OutputDirectory
    Optional custom output directory. If not specified, uses OneDrive or Videos folder
    
    .PARAMETER CompressionMode
    Choose compression speed/quality balance: Fast, Balanced, Quality
    - Fast: Quick processing, good quality (faster than real-time)
    - Balanced: Good balance of speed and compression (default)
    - Quality: Best compression, slower processing
    
    .OUTPUTS
    [string] Path to the compressed video file
    
    .EXAMPLE
    Compress-Video "C:\Videos\MyVideo.mp4"
    
    .EXAMPLE
    Compress-Video -SourceVideo ".\Local Development Environment Setup Guide.mp4" -CompressionMode Fast
    
    .EXAMPLE
    Compress-Video -SourceVideo "video.mp4" -OutputDirectory "C:\Compressed" -CompressionMode Quality
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SourceVideo,
        
        [Parameter(Mandatory = $false)]
        [string]$OutputDirectory,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Fast", "Balanced", "Quality")]
        [string]$CompressionMode = "Balanced"
    )
    
    # Check if FFmpeg is available
    if (-not (Test-FFmpegInstallation)) {
        return
    }
    
    # Validate source file
    if (-not (Test-Path $SourceVideo)) {
        Write-Host "Error: Source video file not found: $SourceVideo" -ForegroundColor Red
        return
    }
    
    Write-Host "Analyzing video properties..." -ForegroundColor Yellow
    $videoProps = Get-VideoProperties -VideoPath $SourceVideo
    
    if (-not $videoProps) {
        Write-Host "Failed to analyze video properties." -ForegroundColor Red
        return
    }
    
    # Display video information
    Write-Host "`nVideo Information:" -ForegroundColor Cyan
    Write-Host "Duration: $($videoProps.Duration) seconds"
    Write-Host "Resolution: $($videoProps.Width)x$($videoProps.Height)"
    Write-Host "Frame Rate: $($videoProps.FrameRate) fps"
    Write-Host "File Size: $($videoProps.FileSize) MB"
    Write-Host "Video Codec: $($videoProps.VideoCodec)"
    Write-Host "Audio Codec: $($videoProps.AudioCodec)"
    
    # Get optimal compression settings
    $compressionSettings = Get-OptimalCompressionSettings -VideoProperties $videoProps -CompressionMode $CompressionMode
    
    Write-Host "`nOptimal Compression Settings:" -ForegroundColor Cyan
    Write-Host "Compression Mode: $CompressionMode"
    Write-Host "Target Resolution: $($compressionSettings.Resolution)"
    Write-Host "Target Frame Rate: $($compressionSettings.FrameRate) fps"
    Write-Host "CRF Quality: $($compressionSettings.CRF)"
    Write-Host "Audio Bitrate: $($compressionSettings.AudioBitrate)"
    Write-Host "Preset: $($compressionSettings.Preset)"
    
    if ($compressionSettings.HardwareAvailable) {
        Write-Host "Hardware Encoder: $($compressionSettings.HardwareEncoder) (faster processing)" -ForegroundColor Green
    } else {
        Write-Host "Hardware Encoder: Software only (h264)" -ForegroundColor Yellow
    }
    
    # Determine output directory and file path
    if (-not $OutputDirectory) {
        $OutputDirectory = Get-OutputDirectory
    }
    
    $sourceFileName = [System.IO.Path]::GetFileNameWithoutExtension($SourceVideo)
    $outputFileName = "${sourceFileName}_compressed.mp4"
    $outputPath = Join-Path $OutputDirectory $outputFileName
    
    # Check if output file already exists
    if (Test-Path $outputPath) {
        $counter = 1
        do {
            $outputFileName = "${sourceFileName}_compressed_${counter}.mp4"
            $outputPath = Join-Path $OutputDirectory $outputFileName
            $counter++
        } while (Test-Path $outputPath)
    }
    
    Write-Host "`nStarting compression..." -ForegroundColor Green
    Write-Host "Output will be saved to: $outputPath" -ForegroundColor Yellow
    
    # Build FFmpeg command with optimal settings
    if ($compressionSettings.HardwareAvailable -and $CompressionMode -ne "Quality") {
        # Use hardware encoder for faster processing (except in Quality mode)
        $videoCodec = $compressionSettings.HardwareEncoder
        
        # Calculate target bitrate based on resolution and frame rate
        $pixelCount = ($compressionSettings.Resolution -split 'x')[0] * ($compressionSettings.Resolution -split 'x')[1]
        $targetBitrate = [math]::Round(($pixelCount * $compressionSettings.FrameRate * 0.1) / 1000)  # Rough estimate
        if ($targetBitrate -lt 1000) { $targetBitrate = 1000 }
        if ($targetBitrate -gt 8000) { $targetBitrate = 8000 }
        
        $ffmpegArgs = @(
            "-i", "`"$SourceVideo`""
            "-c:v", $videoCodec
            "-b:v", "${targetBitrate}k"
            "-maxrate", "$([math]::Round($targetBitrate * 1.5))k"
            "-bufsize", "$([math]::Round($targetBitrate * 2))k"
            "-vf", "scale=$($compressionSettings.Resolution)"
            "-r", $compressionSettings.FrameRate
            "-c:a", "aac"
            "-b:a", $compressionSettings.AudioBitrate
            "-movflags", "+faststart"
            "-avoid_negative_ts", "make_zero"
            "-fflags", "+genpts"
            "-y"
            "`"$outputPath`""
        )
    } else {
        # Use software encoder with CRF
        $ffmpegArgs = @(
            "-i", "`"$SourceVideo`""
            "-c:v", "libx264"
            "-preset", $compressionSettings.Preset
            "-crf", $compressionSettings.CRF
            "-profile:v", $compressionSettings.Profile
            "-level", $compressionSettings.Level
            "-vf", "scale=$($compressionSettings.Resolution)"
            "-r", $compressionSettings.FrameRate
            "-c:a", "aac"
            "-b:a", $compressionSettings.AudioBitrate
            "-movflags", "+faststart"
            "-avoid_negative_ts", "make_zero"
            "-fflags", "+genpts"
            "-y"
            "`"$outputPath`""
        )
    }
    
    try {
        $startTime = Get-Date
        Write-Host "Executing: ffmpeg $($ffmpegArgs -join ' ')" -ForegroundColor Gray
        
        # Execute FFmpeg command
        & ffmpeg @ffmpegArgs
        
        $endTime = Get-Date
        $processingTime = ($endTime - $startTime).TotalSeconds
        
        if (Test-Path $outputPath) {
            $outputFileSize = [math]::Round((Get-Item $outputPath).Length / 1MB, 2)
            $compressionRatio = [math]::Round((1 - ($outputFileSize / $videoProps.FileSize)) * 100, 1)
            
            Write-Host "`nCompression completed successfully!" -ForegroundColor Green
            Write-Host "Processing time: $([math]::Round($processingTime, 1)) seconds"
            Write-Host "Original size: $($videoProps.FileSize) MB"
            Write-Host "Compressed size: $outputFileSize MB"
            Write-Host "Compression ratio: $compressionRatio%"
            Write-Host "Output location: $outputPath"
            
            # Open output directory
            $openDir = Read-Host "`nOpen output directory? (y/n)"
            if ($openDir -eq 'y' -or $openDir -eq 'Y') {
                Start-Process "explorer.exe" -ArgumentList $OutputDirectory
            }
            
            return $outputPath
        }
        else {
            Write-Host "Compression failed - output file not found." -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "Error during compression: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Export module members
Export-ModuleMember -Function @(
    'Compress-Video',
    'Test-FFmpegInstallation',
    'Get-VideoProperties',
    'Get-OptimalCompressionSettings',
    'Get-OutputDirectory'
)
