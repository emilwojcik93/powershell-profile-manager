# PowerShell Profile Manager - Basic Usage Examples
# This file demonstrates basic usage patterns for the Profile Manager

# Example 1: Check Profile Manager Status
Write-Host "=== Profile Manager Status ===" -ForegroundColor Cyan
$status = Get-ProfileManagerStatus
$status | Format-List

# Example 2: List Available Modules
Write-Host "`n=== Available Modules ===" -ForegroundColor Cyan
$modules = Get-ProfileModules
$modules | Format-Table -AutoSize

# Example 3: Check Specific Module Status
Write-Host "`n=== VideoCompressor Module Status ===" -ForegroundColor Cyan
$videoStatus = Get-ProfileModuleStatus -ModuleName "VideoCompressor"
$videoStatus | Format-List

# Example 4: Load/Unload Modules
Write-Host "`n=== Module Management ===" -ForegroundColor Cyan

# Unload a module
Write-Host "Unloading ExampleModule..." -ForegroundColor Yellow
Unload-ProfileModule -ModuleName "ExampleModule"

# Reload a module
Write-Host "Reloading VideoCompressor..." -ForegroundColor Yellow
Reload-ProfileModule -ModuleName "VideoCompressor"

# Example 5: VideoCompressor Usage
Write-Host "`n=== VideoCompressor Examples ===" -ForegroundColor Cyan

# Check if VideoCompressor is available
if (Get-Command Compress-Video -ErrorAction SilentlyContinue) {
    Write-Host "VideoCompressor is available!" -ForegroundColor Green
    
    # Example: Compress a video (replace with actual video path)
    # Compress-Video "C:\Videos\MyVideo.mp4" -CompressionMode "Fast"
    
    Write-Host "To compress a video, use:" -ForegroundColor Yellow
    Write-Host "Compress-Video 'path\to\video.mp4' -CompressionMode 'Fast'" -ForegroundColor White
} else {
    Write-Host "VideoCompressor is not available" -ForegroundColor Red
}

# Example 6: ExampleModule Usage
Write-Host "`n=== ExampleModule Examples ===" -ForegroundColor Cyan

# Check if ExampleModule is available
if (Get-Command Get-ExampleInfo -ErrorAction SilentlyContinue) {
    Write-Host "ExampleModule is available!" -ForegroundColor Green
    
    # Get module information
    $exampleInfo = Get-ExampleInfo
    Write-Host "ExampleModule Info:" -ForegroundColor Yellow
    $exampleInfo | Format-List
    
    # Test module functionality
    Write-Host "Running ExampleModule tests..." -ForegroundColor Yellow
    $testResults = Test-ExampleFunction -TestType "Basic"
    Write-Host "Test Results:" -ForegroundColor Yellow
    $testResults | Format-List
} else {
    Write-Host "ExampleModule is not available" -ForegroundColor Red
}

# Example 7: Configuration Management
Write-Host "`n=== Configuration Management ===" -ForegroundColor Cyan

# Check current configuration
Write-Host "Current ProfileManager configuration:" -ForegroundColor Yellow
$status = Get-ProfileManagerStatus
Write-Host "Log Level: $($status.LogLevel)" -ForegroundColor White
Write-Host "Auto Load Modules: $($status.AutoLoadModules)" -ForegroundColor White
Write-Host "Modules Directory: $($status.ModulesDirectory)" -ForegroundColor White

# Example 8: Error Handling
Write-Host "`n=== Error Handling Examples ===" -ForegroundColor Cyan

# Try to load a non-existent module
Write-Host "Testing error handling..." -ForegroundColor Yellow
try {
    Load-ProfileModule -ModuleName "NonExistentModule"
} catch {
    Write-Host "Expected error caught: $($_.Exception.Message)" -ForegroundColor Red
}

# Example 9: Module Testing
Write-Host "`n=== Module Testing ===" -ForegroundColor Cyan

# Test all available modules
$availableModules = Get-ProfileModules | Where-Object { $_.Available -eq $true }

foreach ($module in $availableModules) {
    $moduleName = $module.Name
    Write-Host "Testing module: $moduleName" -ForegroundColor Yellow
    
    # Check if module has test function
    $testFunction = "Test-$moduleName"
    if (Get-Command $testFunction -ErrorAction SilentlyContinue) {
        try {
            & $testFunction -TestType "Basic"
            Write-Host "  ✓ $moduleName tests passed" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ $moduleName tests failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ⊘ $moduleName has no test function" -ForegroundColor Yellow
    }
}

# Example 10: Cleanup and Maintenance
Write-Host "`n=== Cleanup and Maintenance ===" -ForegroundColor Cyan

Write-Host "Available cleanup functions:" -ForegroundColor Yellow
Write-Host "  Remove-ProfileManager     - Complete removal of ProfileManager" -ForegroundColor White
Write-Host "  Restore-DefaultProfile   - Restore PowerShell profile to default" -ForegroundColor White
Write-Host "  Unload-AllProfileModules - Unload all profile modules" -ForegroundColor White

Write-Host "`nExample usage:" -ForegroundColor Yellow
Write-Host "  Remove-ProfileManager -KeepModules  # Remove config but keep modules" -ForegroundColor White
Write-Host "  Restore-DefaultProfile -Backup      # Restore with backup" -ForegroundColor White

Write-Host "`n=== Examples Complete ===" -ForegroundColor Green
Write-Host "These examples demonstrate the basic usage patterns for the PowerShell Profile Manager." -ForegroundColor White
Write-Host "For more advanced usage, see the documentation in the docs/ directory." -ForegroundColor White
