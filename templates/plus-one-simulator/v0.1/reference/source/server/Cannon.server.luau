require(script.Parent.Remotes).Ensure()
-- Migration gate: never start alongside the Studio-owned Canon > Script.
local cannon = workspace:WaitForChild("Canon", 15)
if not cannon or not cannon:IsA("Model") then
	warn("[Flight] Startup blocked: Workspace.Canon Model not found")
	return
end
for _, child in cannon:GetDescendants() do
	if child:IsA("Script") and child.Enabled then
		warn("[Flight] Startup blocked by active Studio script: " .. child:GetFullName()
			.. ". Stop Play, disable the old Canon Script in edit mode, then start a NEW Play session.")
		return
	end
end
require(script.Parent.RocketFlightService).Start(cannon)
