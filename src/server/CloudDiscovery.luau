local Config = require(script.Parent.LevelConfig).Clouds
local Discovery = {}

function Discovery.Create(bestAltitude, visitedThisSession)
	return {Inside = false, Notified = false,
		Known = visitedThisSession or bestAltitude >= Config.EnterAltitude}
end

-- Metrics were already sampled and validated by FlightService. Never recompute Y here.
function Discovery.Sample(discovery, metrics)
	local inside = metrics.CurrentAltitude >= (discovery.Inside and Config.LeaveAltitude or Config.EnterAltitude)
	if inside == discovery.Inside then return nil end
	discovery.Inside = inside
	local firstEntry = inside and not discovery.Notified
	local firstDiscovery = firstEntry and not discovery.Known
	if firstEntry then discovery.Notified, discovery.Known = true, true end
	return {Region = inside and "Clouds" or "Ground", FirstEntry = firstEntry, FirstDiscovery = firstDiscovery}
end

return Discovery
