Add-Type -AssemblyName System.Drawing

$svgContent = @"
<svg width="512" height="512" xmlns="http://www.w3.org/2000/svg">
  <circle cx="256" cy="256" r="240" fill="#2c3e50"/>
  <g transform="translate(256, 256)">
    <path d="M 0,0 L 0,-200 A 200,200 0 0,1 141.4,-141.4 Z" fill="#e74c3c"/>
    <path d="M 0,0 L 141.4,-141.4 A 200,200 0 0,1 200,0 Z" fill="#3498db"/>
    <path d="M 0,0 L 200,0 A 200,200 0 0,1 141.4,141.4 Z" fill="#2ecc71"/>
    <path d="M 0,0 L 141.4,141.4 A 200,200 0 0,1 0,200 Z" fill="#f39c12"/>
    <path d="M 0,0 L 0,200 A 200,200 0 0,1 -141.4,141.4 Z" fill="#9b59b6"/>
    <path d="M 0,0 L -141.4,141.4 A 200,200 0 0,1 -200,0 Z" fill="#e67e22"/>
    <path d="M 0,0 L -200,0 A 200,200 0 0,1 -141.4,-141.4 Z" fill="#ff69b4"/>
    <path d="M 0,0 L -141.4,-141.4 A 200,200 0 0,1 0,-200 Z" fill="#1abc9c"/>
  </g>
  <circle cx="256" cy="256" r="40" fill="#ecf0f1"/>
  <circle cx="256" cy="256" r="30" fill="#34495e"/>
  <polygon points="256,50 240,90 272,90" fill="#e74c3c"/>
</svg>
"@

# Funkcja do rysowania koła fortuny
function Draw-WheelIcon {
    param($size)
    
    $bitmap = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    
    $center = $size / 2
    $radius = $size * 0.47
    
    # Tło - ciemne koło
    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(44, 62, 80))
    $graphics.FillEllipse($bgBrush, $center - $radius - 2, $center - $radius - 2, ($radius + 2) * 2, ($radius + 2) * 2)
    
    # Kolory segmentów
    $colors = @(
        [System.Drawing.Color]::FromArgb(231, 76, 60),   # Red
        [System.Drawing.Color]::FromArgb(52, 152, 219),  # Blue
        [System.Drawing.Color]::FromArgb(46, 204, 113),  # Green
        [System.Drawing.Color]::FromArgb(243, 156, 18),  # Yellow
        [System.Drawing.Color]::FromArgb(155, 89, 182),  # Purple
        [System.Drawing.Color]::FromArgb(230, 126, 34),  # Orange
        [System.Drawing.Color]::FromArgb(255, 105, 180), # Pink
        [System.Drawing.Color]::FromArgb(26, 188, 156)   # Cyan
    )
    
    # Rysuj segmenty
    $anglePerSegment = 360 / 8
    for ($i = 0; $i -lt 8; $i++) {
        $brush = New-Object System.Drawing.SolidBrush($colors[$i])
        $startAngle = $i * $anglePerSegment - 90
        $graphics.FillPie($brush, $center - $radius, $center - $radius, $radius * 2, $radius * 2, $startAngle, $anglePerSegment)
        $brush.Dispose()
    }
    
    # Środkowe koło - jasne
    $centerRadius = $radius * 0.2
    $centerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(236, 240, 241))
    $graphics.FillEllipse($centerBrush, $center - $centerRadius, $center - $centerRadius, $centerRadius * 2, $centerRadius * 2)
    
    # Środkowe koło - ciemne (mniejsze)
    $centerRadius2 = $radius * 0.15
    $centerBrush2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(52, 73, 94))
    $graphics.FillEllipse($centerBrush2, $center - $centerRadius2, $center - $centerRadius2, $centerRadius2 * 2, $centerRadius2 * 2)
    
    # Wskaźnik (trójkąt u góry)
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

# Generuj ikony
Write-Host "Generowanie ikon..." -ForegroundColor Green

$icon192 = Draw-WheelIcon -size 192
$icon192.Save("$PSScriptRoot\web\icons\Icon-192.png", [System.Drawing.Imaging.ImageFormat]::Png)
$icon192.Save("$PSScriptRoot\web\icons\Icon-maskable-192.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "✓ Icon-192.png" -ForegroundColor Cyan

$icon512 = Draw-WheelIcon -size 512
$icon512.Save("$PSScriptRoot\web\icons\Icon-512.png", [System.Drawing.Imaging.ImageFormat]::Png)
$icon512.Save("$PSScriptRoot\web\icons\Icon-maskable-512.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "✓ Icon-512.png" -ForegroundColor Cyan

$favicon = Draw-WheelIcon -size 32
$favicon.Save("$PSScriptRoot\web\favicon.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "✓ favicon.png" -ForegroundColor Cyan

$icon192.Dispose()
$icon512.Dispose()
$favicon.Dispose()

Write-Host "Wszystkie ikony zostaly wygenerowane!" -ForegroundColor Green
