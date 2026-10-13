$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$assetDirectory = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../assets/images'))
function Write-SmartShopIcon([string]$Name, [int]$Size, [bool]$Transparent, [bool]$Mono) {
  $bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $scale = $Size / 1024.0
  $graphics.ScaleTransform($scale, $scale)
  if ($Transparent) { $graphics.Clear([System.Drawing.Color]::Transparent) }
  else { $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#4f46e5')) }
  $bagBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
  if ($Mono) { $bagBrush.Color = [System.Drawing.Color]::Black }
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddArc(304,390,64,64,180,90)
  $path.AddArc(656,390,64,64,270,90)
  $path.AddArc(656,690,64,64,0,90)
  $path.AddArc(304,690,64,64,90,90)
  $path.CloseFigure()
  $graphics.FillPath($bagBrush,$path)
  $pen = New-Object System.Drawing.Pen($bagBrush.Color,26)
  $graphics.DrawArc($pen,407,275,210,230,180,180)
  if (-not $Mono) {
    $font = New-Object System.Drawing.Font('Segoe UI',130,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Pixel)
    $inkBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#4f46e5'))
    $graphics.DrawString('S',$font,$inkBrush,445,453)
    $font.Dispose(); $inkBrush.Dispose()
  }
  $bitmap.Save((Join-Path $assetDirectory $Name),[System.Drawing.Imaging.ImageFormat]::Png)
  $pen.Dispose(); $path.Dispose(); $bagBrush.Dispose(); $graphics.Dispose(); $bitmap.Dispose()
}
Write-SmartShopIcon 'smartshop-icon.png' 1024 $false $false
Write-SmartShopIcon 'smartshop-favicon.png' 128 $false $false
Write-SmartShopIcon 'smartshop-splash.png' 512 $true $false
Write-SmartShopIcon 'smartshop-foreground.png' 1024 $true $false
Write-SmartShopIcon 'smartshop-monochrome.png' 1024 $true $true
Write-Output 'SmartShop app icons generated.'
