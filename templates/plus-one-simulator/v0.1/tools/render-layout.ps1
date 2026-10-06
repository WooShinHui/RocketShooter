# Deterministic UI/lifecycle diagram from the captured layout. No live mutation.
# Icons are schematic; reference/current-ui.png retains the exact actual art.
param([string]$TemplateRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$taskRoot = [IO.Path]::GetFullPath($TemplateRoot)
$runtime = Get-Content -Raw -LiteralPath (Join-Path $taskRoot 'reference/ui-runtime.json') | ConvertFrom-Json
$width=1365; $height=1100; $topInset=58
$bitmap=New-Object Drawing.Bitmap $width,$height
$g=[Drawing.Graphics]::FromImage($bitmap)
$g.SmoothingMode=[Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint=[Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.Clear([Drawing.Color]::FromArgb(24,26,30))
$svg=New-Object Text.StringBuilder
[void]$svg.AppendLine('<svg xmlns="http://www.w3.org/2000/svg" width="1365" height="1100" viewBox="0 0 1365 1100"><rect width="1365" height="1100" fill="#181a1e"/>')
function ColorOf($v) { [Drawing.Color]::FromArgb([int]$v[0],[int]$v[1],[int]$v[2]) }
function HexOf($v) { '#{0:X2}{1:X2}{2:X2}' -f [int]$v[0],[int]$v[1],[int]$v[2] }
function Rounded($x,$y,$w,$h,$r) {
 $p=New-Object Drawing.Drawing2D.GraphicsPath
 $d=[single][Math]::Min($r*2,[Math]::Min($w,$h))
 if($d -lt 1){$p.AddRectangle([Drawing.RectangleF]::new($x,$y,$w,$h));return ,$p}
 $p.AddArc([single]$x,[single]$y,$d,$d,180,90);$p.AddArc([single]($x+$w-$d),[single]$y,$d,$d,270,90)
 $p.AddArc([single]($x+$w-$d),[single]($y+$h-$d),$d,$d,0,90);$p.AddArc([single]$x,[single]($y+$h-$d),$d,$d,90,90);$p.CloseFigure();return ,$p
}
function DrawBox($x,$y,$w,$h,$rgb,$r=8,$stroke=$true) {
 $p=Rounded $x $y $w $h $r;$b=New-Object Drawing.SolidBrush (ColorOf $rgb);$g.FillPath($b,$p)
 if($stroke){$pen=New-Object Drawing.Pen ([Drawing.Color]::FromArgb(15,16,22)),4;$g.DrawPath($pen,$p);$pen.Dispose()}
 $b.Dispose();$p.Dispose();$col=HexOf $rgb
 [void]$svg.AppendLine("<rect x='$x' y='$y' width='$w' height='$h' rx='$r' fill='$col' stroke='#0f1016' stroke-width='4'/>")
}
function DrawText($text,$x,$y,$w,$h,$size,$rgb,$align='Center') {
 if([string]::IsNullOrWhiteSpace($text)){return}
 $font=[Drawing.Font]::new('Arial',[single]$size,[Drawing.FontStyle]::Bold,[Drawing.GraphicsUnit]::Pixel)
 $format=New-Object Drawing.StringFormat;$format.Alignment=switch($align){'Left'{[Drawing.StringAlignment]::Near};'Right'{[Drawing.StringAlignment]::Far};default{[Drawing.StringAlignment]::Center}};$format.LineAlignment=[Drawing.StringAlignment]::Center
 $box=[Drawing.RectangleF]::new($x,$y,$w,$h);$p=New-Object Drawing.Drawing2D.GraphicsPath
 $p.AddString($text,$font.FontFamily,[int]$font.Style,$size,$box,$format)
 $pen=New-Object Drawing.Pen ([Drawing.Color]::FromArgb(15,16,22)),2.5;$pen.LineJoin=[Drawing.Drawing2D.LineJoin]::Round;$g.DrawPath($pen,$p)
 $brush=New-Object Drawing.SolidBrush (ColorOf $rgb);$g.FillPath($brush,$p)
 $escaped=[Security.SecurityElement]::Escape($text);$color=HexOf $rgb
 $tx=switch($align){'Left'{$x};'Right'{$x+$w};default{$x+$w/2}};$anchor=switch($align){'Left'{'start'};'Right'{'end'};default{'middle'}}
 [void]$svg.AppendLine("<text x='$tx' y='$($y+$h/2)' text-anchor='$anchor' dominant-baseline='middle' font-family='Arial,sans-serif' font-weight='bold' font-size='$size' fill='$color' stroke='#0f1016' stroke-width='.6'>$escaped</text>")
 $font.Dispose();$format.Dispose();$p.Dispose();$pen.Dispose();$brush.Dispose()
}
# Frame/button surfaces are emitted before their text. Transparent containers remain invisible.
$rows=@($runtime.elements | Where-Object {$_.visible -and $_.absoluteSize[0] -gt 0 -and $_.absoluteSize[1] -gt 0})
$gradientIndex=0
foreach($v in $rows){
 if($v.backgroundTransparency -ge .95 -or $v.class -eq 'ImageLabel'){continue}
 $x=[single]$v.absolutePosition[0];$y=[single]($v.absolutePosition[1]+$topInset);$w=[single]$v.absoluteSize[0];$h=[single]$v.absoluteSize[1]
 if($y+$h -gt 800){continue}
 $r=8;if($v.corner){$r=[Math]::Max([double]$v.corner[1],[double]$v.corner[0]*[Math]::Min($w,$h))}
 if($v.path -like '*.XPFill'){$b=New-Object Drawing.SolidBrush (ColorOf $v.background);$g.FillRectangle($b,$x,$y,$w,$h);$b.Dispose();[void]$svg.AppendLine("<rect x='$x' y='$y' width='$w' height='$h' fill='$(HexOf $v.background)'/>")}
 else{DrawBox $x $y $w $h $v.background $r}
 if($v.gradient){
  $p=Rounded $x $y $w $h $r
  $brush=New-Object Drawing.Drawing2D.LinearGradientBrush ([Drawing.RectangleF]::new($x,$y,$w,$h)),([Drawing.Color]::White),([Drawing.Color]::White),([single]$v.gradient.rotation)
  $blend=New-Object Drawing.Drawing2D.ColorBlend $v.gradient.keys.Count
  $colors=@();$positions=@();foreach($key in $v.gradient.keys){$rgb=@([int]($key[1][0]*$v.background[0]/255),[int]($key[1][1]*$v.background[1]/255),[int]($key[1][2]*$v.background[2]/255));$colors+=(ColorOf $rgb);$positions+=[single]$key[0]}
  $blend.Colors=[Drawing.Color[]]$colors;$blend.Positions=[single[]]$positions;$brush.InterpolationColors=$blend;$g.FillPath($brush,$p)
  $gradientIndex++;$id='gradient'+$gradientIndex;[void]$svg.AppendLine("<defs><linearGradient id='$id' x1='0' y1='0' x2='1' y2='1'>")
  foreach($key in $v.gradient.keys){$rgb=@([int]($key[1][0]*$v.background[0]/255),[int]($key[1][1]*$v.background[1]/255),[int]($key[1][2]*$v.background[2]/255));[void]$svg.AppendLine("<stop offset='$($key[0]*100)%' stop-color='$(HexOf $rgb)'/>")}
  [void]$svg.AppendLine("</linearGradient></defs><rect x='$x' y='$y' width='$w' height='$h' rx='$r' fill='url(#$id)'/>")
  $brush.Dispose();$p.Dispose()
 }
}
foreach($v in $rows){
 $x=[single]$v.absolutePosition[0];$y=[single]($v.absolutePosition[1]+$topInset);$w=[single]$v.absoluteSize[0];$h=[single]$v.absoluteSize[1]
 if($v.text){$align=if($v.path -like '*.XPBar.Level'){'Left'}elseif($v.path -like '*.XPValue' -or $v.path -match 'Thrust$|Growth$|PowerMultiplier$|FoodPercent$|FriendBoost$'){'Right'}else{'Center'};if($v.path -like '*FriendBoost'){$align='Left'};DrawText $v.text $x $y $w $h ([single]$v.textSize) $v.textColor $align}
 elseif($v.class -eq 'ImageLabel'){
  $key=($v.path -split '\.')[-1] -replace 'Icon$','';$short=switch -Regex($key){'OPCursor|Cursor'{'>';break};'Rocket'{'R';break};'Trophy'{'T';break};'Rebirth'{'RB';break};'Shop'{'S';break};'Trail'{'FL';break};'Guide'{'?';break};'Settings'{'G';break};'Robux'{'o';break};default {$key}}
  DrawText $short $x $y $w $h ([single][Math]::Min(24,$h*.45)) @(255,255,255)
 }
}
# Currency and common event/result slots are defined in their source, outside the filtered core dump.
DrawText 'T' 12 70 45 45 30 @(255,218,52);DrawText '0' 65 70 165 45 33 @(255,218,52) 'Left'
DrawText 'RB' 12 123 45 45 22 @(255,218,52);DrawText '0' 65 123 165 45 33 @(255,218,52) 'Left'
DrawText 'Gold Ring Event in 30:00' 282 112 800 28 22 @(255,220,62)
DrawText '+1 XP / reward burst follows character' 390 286 585 48 22 @(255,232,106)
DrawText 'COMMON UI GEOMETRY - v0.1' 300 190 765 32 25 @(181,202,224)
DrawText 'Icons are schematic. Exact art: reference/current-ui.png' 265 224 835 28 17 @(151,172,194)
DrawBox 16 815 1333 269 @(22,35,53) 12
DrawText 'SAME +1 SYSTEMS / SWAP THE ACTION' 30 830 1305 36 29 @(115,235,255)
$labels=@('Load / Idle','Click + XP','Level / Power','Action adapter','Bank / Return','Rebirth / Save')
$colors=@(@(51,155,255),@(255,218,52),@(65,215,145),@(171,98,245),@(255,95,85),@(96,110,145))
for($i=0;$i -lt $labels.Count;$i++){DrawBox (30+$i*220) 890 205 64 $colors[$i] 8;DrawText $labels[$i] (30+$i*220) 890 205 64 20 @(255,255,255)}
DrawText 'Rocket  /  Stone  /  Spit  /  Tongue  /  Sword' 95 974 1175 40 25 @(255,218,52)
DrawText 'Preserve: UI / XP / Rebirth / Trophies / Equipment / Training / Boosts / Persistence' 45 1020 1275 34 20 @(181,212,234)
[void]$svg.AppendLine('</svg>')
$bitmap.Save((Join-Path $taskRoot 'ui-layout.png'),[Drawing.Imaging.ImageFormat]::Png)
[IO.File]::WriteAllText((Join-Path $taskRoot 'ui-layout.svg'),$svg.ToString().Replace("`r`n","`n"),[Text.UTF8Encoding]::new($false))
$g.Dispose();$bitmap.Dispose()
# The MCP capture's bytes are JPEG; normalize the retained reference to actual PNG.
$referencePath=Join-Path $taskRoot 'reference/current-ui.png'
$captured=[Drawing.Image]::FromFile($referencePath)
$copy=New-Object Drawing.Bitmap $captured;$captured.Dispose();$copy.Save($referencePath,[Drawing.Imaging.ImageFormat]::Png);$copy.Dispose()
Write-Output 'Rendered ui-layout.png / ui-layout.svg; reference PNG normalized.'
