Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcPath = Join-Path $projectRoot "icon.png"

if (-not (Test-Path $srcPath)) {
    Write-Error "icon.png not found at $srcPath"
    exit 1
}

$src = [System.Drawing.Bitmap]::FromFile($srcPath)

function Resize-And-Save($relPath, $width, $height) {
    $targetPath = Join-Path $projectRoot $relPath
    $dir = Split-Path -Parent $targetPath
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    
    $dest = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.DrawImage($src, 0, 0, $width, $height)
    $g.Dispose()

    # If target already exists, remove it first to avoid lock
    if (Test-Path $targetPath) {
        Remove-Item -Force $targetPath
    }
    $dest.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $dest.Dispose()
    Write-Host "Generated: $relPath ($width x $height)"
}

# Android mipmap icons
Resize-And-Save "android/app/src/main/res/mipmap-mdpi/ic_launcher.png" 48 48
Resize-And-Save "android/app/src/main/res/mipmap-hdpi/ic_launcher.png" 72 72
Resize-And-Save "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png" 96 96
Resize-And-Save "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png" 144 144
Resize-And-Save "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" 192 192

# iOS app icons
$iosDir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
if (Test-Path (Join-Path $projectRoot $iosDir)) {
    Resize-And-Save "$iosDir/Icon-App-1024x1024@1x.png" 1024 1024
    Resize-And-Save "$iosDir/Icon-App-20x20@1x.png" 20 20
    Resize-And-Save "$iosDir/Icon-App-20x20@2x.png" 40 40
    Resize-And-Save "$iosDir/Icon-App-20x20@3x.png" 60 60
    Resize-And-Save "$iosDir/Icon-App-29x29@1x.png" 29 29
    Resize-And-Save "$iosDir/Icon-App-29x29@2x.png" 58 58
    Resize-And-Save "$iosDir/Icon-App-29x29@3x.png" 87 87
    Resize-And-Save "$iosDir/Icon-App-40x40@1x.png" 40 40
    Resize-And-Save "$iosDir/Icon-App-40x40@2x.png" 80 80
    Resize-And-Save "$iosDir/Icon-App-40x40@3x.png" 120 120
    Resize-And-Save "$iosDir/Icon-App-60x60@2x.png" 120 120
    Resize-And-Save "$iosDir/Icon-App-60x60@3x.png" 180 180
    Resize-And-Save "$iosDir/Icon-App-76x76@1x.png" 76 76
    Resize-And-Save "$iosDir/Icon-App-76x76@2x.png" 152 152
    Resize-And-Save "$iosDir/Icon-App-83.5x83.5@2x.png" 167 167
}
Resize-And-Save "web/favicon.png" 48 48
Resize-And-Save "web/icons/Icon-192.png" 192 192
Resize-And-Save "web/icons/Icon-512.png" 512 512
Resize-And-Save "web/icons/Icon-maskable-192.png" 192 192
Resize-And-Save "web/icons/Icon-maskable-512.png" 512 512

# Assets copies
Resize-And-Save "assets/images/icon.png" 1024 1024
Resize-And-Save "assets/image/icon.png" 1024 1024

# Windows icon
$winDest = New-Object System.Drawing.Bitmap(128, 128)
$winG = [System.Drawing.Graphics]::FromImage($winDest)
$winG.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$winG.DrawImage($src, 0, 0, 128, 128)
$winG.Dispose()
$hIcon = $winDest.GetHicon()
$ico = [System.Drawing.Icon]::FromHandle($hIcon)
$icoPath = Join-Path $projectRoot "windows/runner/resources/app_icon.ico"
if (Test-Path $icoPath) { Remove-Item -Force $icoPath }
$stream = [System.IO.File]::Create($icoPath)
$ico.Save($stream)
$stream.Close()
$winDest.Dispose()
Write-Host "Generated: windows/runner/resources/app_icon.ico"

$src.Dispose()
Write-Host "All icons successfully created and replaced!"
