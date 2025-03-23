#!/usr/bin/env pwsh

param (
    [Parameter(Mandatory = $false)]
    [string]$DestPathWsl
)

$Distro = "Ubuntu"

# Use the provided DestPathWsl or fallback to an environment variable
if (-not $DestPathWsl) {
    if (-not $env:DEST_PATH_WSL) {
        Write-Error "Neither DestPathWsl parameter nor DEST_PATH_WSL environment variable is set. Aborting."
        exit 1
    }
    $DestPathWsl = $env:DEST_PATH_WSL
}

# Build UNC-style WSL path
$DestWinPath = "\\wsl.localhost\$Distro" + $DestPathWsl.Replace('/', '\')
$TempFile = "$env:TEMP\frame.jpg"

# Capture a single frame from the webcam
$ffmpeg = "ffmpeg"  # Adjust if ffmpeg is not in PATH
$webcamName = "B525 HD Webcam"  # Update if your device has a different name

Write-Host "Capturing frame from '$webcamName'..."
& $ffmpeg -f dshow -rtbufsize 100M -i "video=$webcamName" -frames:v 1 "$TempFile" | Out-Null

if (-Not (Test-Path $TempFile)) {
    Write-Error "FFmpeg did not produce a frame. Aborting."
    exit 1
}

# Ensure destination folder exists
if (-Not (Test-Path $DestWinPath)) {
    Write-Host "Creating destination folder: $DestWinPath"
    New-Item -ItemType Directory -Path $DestWinPath -Force | Out-Null
}

# Move the frame
$destFile = Join-Path $DestWinPath "frame.jpg"
Move-Item $TempFile $destFile -Force
Write-Host "✅ Frame saved to: $destFile"