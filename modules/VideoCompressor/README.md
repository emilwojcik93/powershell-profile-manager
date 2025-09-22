# VideoCompressor Module

A PowerShell module for compressing video files with optimal settings for cloud storage platforms like OneDrive, YouTube, SharePoint, and MS Stream.

## Features

- **Automatic FFmpeg Installation**: Detects and installs FFmpeg if not available
- **Hardware Acceleration**: Supports Intel QuickSync and NVIDIA NVENC
- **Smart Compression**: Analyzes video properties for optimal settings
- **Multiple Modes**: Fast, Balanced, and Quality compression modes
- **Cloud Optimized**: Settings optimized for cloud storage platforms
- **OneDrive Integration**: Automatically uses OneDrive if available

## Functions

### Compress-Video

Main function for compressing video files.

```powershell
# Basic compression (balanced mode)
Compress-Video "MyVideo.mp4"

# Fast processing
Compress-Video "MyVideo.mp4" -CompressionMode Fast

# Best quality
Compress-Video "MyVideo.mp4" -CompressionMode Quality

# Custom output folder
Compress-Video "MyVideo.mp4" -OutputDirectory "C:\Compressed"
```

**Parameters:**
- `SourceVideo` (Mandatory): Path to the source video file
- `OutputDirectory` (Optional): Custom output directory
- `CompressionMode` (Optional): Fast, Balanced, or Quality

### Test-FFmpegInstallation

Checks if FFmpeg is available and offers to install it if not found.

```powershell
Test-FFmpegInstallation
```

### Get-VideoProperties

Analyzes video file properties using ffprobe.

```powershell
$props = Get-VideoProperties -VideoPath "video.mp4"
```

### Get-OptimalCompressionSettings

Determines optimal compression settings based on video properties.

```powershell
$settings = Get-OptimalCompressionSettings -VideoProperties $props -CompressionMode "Quality"
```

### Get-OutputDirectory

Determines the best output directory (OneDrive or Videos folder).

```powershell
$outputDir = Get-OutputDirectory
```

## Compression Modes

### Fast
- **Preset**: fast
- **Use Case**: Quick processing, good quality
- **Processing**: Faster than real-time
- **Quality**: Good

### Balanced (Default)
- **Preset**: medium
- **Use Case**: Good balance of speed and compression
- **Processing**: Real-time to 2x real-time
- **Quality**: Very good

### Quality
- **Preset**: slow
- **Use Case**: Best compression, slower processing
- **Processing**: Slower than real-time
- **Quality**: Excellent

## Hardware Acceleration

The module automatically detects and uses available hardware acceleration:

- **Intel QuickSync** (h264_qsv): Common on Intel CPUs
- **NVIDIA NVENC** (h264_nvenc): Available on NVIDIA GPUs
- **Software Fallback**: Uses libx264 if no hardware acceleration

## Output Locations

The module intelligently chooses output directories:

1. **OneDrive**: If OneDrive is available and running
2. **Videos Folder**: Standard Windows Videos directory
3. **User Profile**: Fallback to user profile

## Requirements

- Windows 10/11
- PowerShell 5.1+
- Internet connection (for FFmpeg auto-install)
- FFmpeg (auto-installed if not available)

## Examples

### Basic Usage
```powershell
# Compress a video with default settings
Compress-Video "C:\Videos\MyVideo.mp4"
```

### Advanced Usage
```powershell
# Compress with custom settings
Compress-Video -SourceVideo "video.mp4" -CompressionMode Quality -OutputDirectory "C:\Compressed"
```

### Batch Processing
```powershell
# Compress multiple videos
Get-ChildItem "C:\Videos\*.mp4" | ForEach-Object {
    Compress-Video $_.FullName -CompressionMode Fast
}
```

## Performance Tips

1. **Use Fast mode** for quick previews
2. **Use Quality mode** for final outputs
3. **Enable hardware acceleration** for faster processing
4. **Use OneDrive** for automatic cloud sync

## Troubleshooting

### FFmpeg Not Found
The module will automatically offer to install FFmpeg using winget. If installation fails:
1. Restart PowerShell
2. Manually install: `winget install Gyan.FFmpeg`
3. Check PATH environment variable

### Hardware Acceleration Issues
If hardware acceleration isn't working:
1. Update graphics drivers
2. Check if your hardware supports the encoder
3. The module will fall back to software encoding

### Large File Sizes
For very large files:
1. Use Quality mode for better compression
2. Consider splitting long videos
3. Check available disk space

## License

This module is part of the PowerShell Profile Manager project and is licensed under the MIT License.
