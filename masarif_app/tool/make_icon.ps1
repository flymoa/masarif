# Kayrsem logo Khatam f PNG 1024x1024 (icone dyal l app).
#   assets/icon/icon.png     : khalfiya khadra kamla (iOS, Android legacy, web)
#   assets/icon/icon_fg.png  : logo bo7do, khalfiya chaffafa (Android adaptive)
Add-Type -AssemblyName System.Drawing
$root = Split-Path $PSScriptRoot
$out = Join-Path $root 'assets\icon'
New-Item -ItemType Directory -Force $out | Out-Null

$green = [System.Drawing.Color]::FromArgb(255, 0x13, 0x42, 0x32)
$gold  = [System.Drawing.Color]::FromArgb(255, 0xE9, 0xB9, 0x49)

function New-RoundRect([single]$x, [single]$y, [single]$w, [single]$h, [single]$r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $p.AddArc($x, $y, $d, $d, 180, 90)
  $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

function Write-Icon([string]$file, [bool]$background, [single]$scale) {
  $size = 1024
  $bmp = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.PixelOffsetMode = 'HighQuality'
  $g.Clear($(if ($background) { $green } else { [System.Drawing.Color]::Transparent }))

  # Espace 100x100 mcentré (b7al l SVG)
  $g.TranslateTransform($size / 2, $size / 2)
  $g.ScaleTransform($scale, $scale)

  $goldBrush = New-Object System.Drawing.SolidBrush $gold
  $greenBrush = New-Object System.Drawing.SolidBrush $green
  $sq = New-RoundRect -30 -30 60 60 6
  $g.FillPath($goldBrush, $sq)
  $state = $g.Save(); $g.RotateTransform(45); $g.FillPath($goldBrush, $sq); $g.Restore($state)

  $g.FillEllipse($greenBrush, -21, -21, 42, 42)
  $ring = New-Object System.Drawing.Pen $gold, 4
  $g.DrawEllipse($ring, -14, -14, 28, 28)

  $m = New-Object System.Drawing.Pen $gold, 3.5
  $m.StartCap = 'Round'; $m.EndCap = 'Round'; $m.LineJoin = 'Round'
  $pts = [System.Drawing.PointF[]]@(
    (New-Object System.Drawing.PointF -6, 6), (New-Object System.Drawing.PointF -6, -6),
    (New-Object System.Drawing.PointF 0, 1), (New-Object System.Drawing.PointF 6, -6),
    (New-Object System.Drawing.PointF 6, 6))
  $g.DrawLines($m, $pts)

  $g.Dispose()
  $bmp.Save((Join-Path $out $file), [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  "wrote $file"
}

# Logo ~600 px f lwost: kayb9a f l "safe zone" dyal Android o iOS.
Write-Icon 'icon.png' $true 7.0
Write-Icon 'icon_fg.png' $false 7.0
