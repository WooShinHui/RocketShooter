param([Parameter(Mandatory=$true)][string]$BuildPath)
$ErrorActionPreference = "Stop"
[xml]$built = Get-Content -LiteralPath $BuildPath -Raw
$balance = $built.SelectNodes('//Item[@class="ReplicatedStorage"]/Item[@class="ModuleScript"][Properties/string[@name="Name"]="BalanceConfig"]')
$camera = $built.SelectNodes('//Item[@class="StarterPlayer"]/Item[@class="StarterPlayerScripts"]/Item[@class="ModuleScript"][Properties/string[@name="Name"]="FlightCamera"]')
$registry = $built.SelectNodes('//Item[@class="ServerScriptService"]/Item[@class="ModuleScript"][Properties/string[@name="Name"]="AssetRegistry"]')
$metrics = $built.SelectNodes('//Item[@class="ServerScriptService"]/Item[@class="ModuleScript"][Properties/string[@name="Name"]="FlightMetrics"]')
$clouds = $built.SelectNodes('//Item[@class="ReplicatedStorage"]/Item[@class="ModuleScript"][Properties/string[@name="Name"]="CloudConfig"]')
if ($balance.Count -ne 1) { throw "Expected exactly one ReplicatedStorage.BalanceConfig ModuleScript" }
if ($camera.Count -ne 1) { throw "Expected exactly one StarterPlayerScripts.FlightCamera ModuleScript" }
if ($registry.Count -ne 1) { throw "Expected exactly one ServerScriptService.AssetRegistry ModuleScript" }
if ($metrics.Count -ne 1) { throw "Expected exactly one ServerScriptService.FlightMetrics ModuleScript" }
if ($clouds.Count -ne 1) { throw "Expected exactly one ReplicatedStorage.CloudConfig ModuleScript" }
foreach ($module in @($balance[0], $camera[0], $registry[0], $metrics[0], $clouds[0])) {
    $source = $module.SelectSingleNode('Properties/*[@name="Source"]')
    if ($null -eq $source -or [string]::IsNullOrWhiteSpace($source.InnerText)) { throw "Empty module source" }
}
Write-Output "PASS Rojo artifact: BalanceConfig, FlightCamera, AssetRegistry, FlightMetrics and CloudConfig class, location, uniqueness and source"
