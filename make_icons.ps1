Add-Type -AssemblyName System.Drawing

function Draw-WheelIcon {
    param($size)
    
    $bitmap = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    
    $center = $size / 2
    $radius = $size * 0.47
    
    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(44, 62, 80))
    $graphics.FillEllipse($bgBrush, $center - $radius - 2, $center - $radius - 2, ($radius + 2) * 2, ($radius + 2) * 2)
    
    $colors = @(
        [System.Drawing.Color]::FromArgb(231, 76, 60),
        [System.Drawing.Color]::FromArgb(52, 152, 219),
        [System.Drawing.Color]::FromArgb(46, 204, 113),
        [System.Drawing.Color]::FromArgb(243, 156, 18),
        [System.Drawing.Color]::FromArgb(155, 89, 182),
        [System.Drawing.Color]::FromArgb(230, 126, 34),
        [System.Drawing.Color]::FromArgb(255, 105, 180),
        [System.Drawing.Color]::FromArgb(26, 188, 156)
    )
    
    $anglePerSegment = 360 / 8
    for ($i = 0; $i -lt 8; $i++) {
        $brush = New-Object System.Drawing.SolidBrush($colors[$i])
        $startAngle = $i * $anglePerSegment - 90
        $graphics.FillPie($brush, $center - $radius, $center - $radius, $radius * 2, $radius * 2, $startAngle, $anglePerSegment)
        $brush.Dispose()
    }
    
    $centerRadius = $radius * 0.2
    $centerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(236, 240, 241))
    $graphics.FillEllipse($centerBrush, $center - $centerRadius, $center - $centerRadius, $centerRadius * 2, $centerRadius * 2)
    
    $centerRadius2 = $radius * 0.15
    $centerBrush2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(52, 73, 94))
    $graphics.FillEllipse($centerBrush2, $center - $centerRadius2, $center - $centerRadius2, $centerRadius2 * 2, $centerRadius2 * 2)
    
    $pointerSize = $size * 0.08
    $points = @(
        [System.Drawing.Point]::new($center, $center - $radius - $pointerSize),
        [System.Drawing.Point]::new($center - $pointerSize/2, $center - $radius + $pointerSize),
        [System.Drawing.Point]::new($center + $pointerSize/2, $center - $radius + $pointerSize)
    )
    $pointerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(231, 76, 60))
    $graphics.FillPolygon($pointerBrush, $points)
    
    $graphics.Dispose()
    $bgBrush.Dispose()
    $centerBrush.Dispose()
    $centerBrush2.Dispose()
    $pointerBrush.Dispose()
    
    return $bitmap
}

Write-Host "Generating icons..." -ForegroundColor Green

$icon192 = Draw-WheelIcon -size 192
$icon192.Save("$PSScriptRoot\web\icons\Icon-192.png", [System.Drawing.Imaging.ImageFormat]::Png)
$icon192.Save("$PSScriptRoot\web\icons\Icon-maskable-192.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Icon-192.png created" -ForegroundColor Cyan

$icon512 = Draw-WheelIcon -size 512
$icon512.Save("$PSScriptRoot\web\icons\Icon-512.png", [System.Drawing.Imaging.ImageFormat]::Png)
$icon512.Save("$PSScriptRoot\web\icons\Icon-maskable-512.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Icon-512.png created" -ForegroundColor Cyan

$favicon = Draw-WheelIcon -size 32
$favicon.Save("$PSScriptRoot\web\favicon.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "favicon.png created" -ForegroundColor Cyan

$icon192.Dispose()
$icon512.Dispose()
$favicon.Dispose()

Write-Host "All icons generated!" -ForegroundColor Green
