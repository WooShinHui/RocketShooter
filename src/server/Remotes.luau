local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = {}
local schema = {
 SelectRocketTrail = "RemoteFunction",
 SelectRocketSkin = "RemoteFunction",
 ClickTraining = "RemoteEvent",
 ToggleAutoClick = "RemoteFunction",
 ExperienceGained = "RemoteEvent",
	AimCannon = "RemoteEvent",
	FireCannon = "RemoteEvent",
	FlightResult = "RemoteEvent",
	ReturnToSpawn = "RemoteEvent",
	FlightState = "RemoteEvent",
	SteerFlight = "RemoteEvent",
	BuyUpgrade = "RemoteFunction",
	ResetData = "RemoteFunction", -- Legacy compatibility: always returns false.
}

function Remotes.Ensure()
	local found = {}
	-- Validate before creating anything. Never replace an existing Studio object
	-- or silently create another object with the same name and a different class.
	for _, child in ReplicatedStorage:GetChildren() do
		local class = schema[child.Name]
		if class then
			assert(not found[child.Name], "[Remotes] Duplicate name in ReplicatedStorage: " .. child.Name)
			assert(child:IsA(class), "[Remotes] " .. child.Name .. " must be " .. class)
			found[child.Name] = child
		end
	end
	for name, class in pairs(schema) do
		if not found[name] then
			local remote = Instance.new(class)
			remote.Name = name
			remote.Parent = ReplicatedStorage
			found[name] = remote
		end
	end
	-- No yields: safe to call from either server entry point, in any order.
	found.ResetData.OnServerInvoke = function() return false end
	return found
end

return Remotes
