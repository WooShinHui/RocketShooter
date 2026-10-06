local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteClient = {}
local required = {
	{"AimCannon", "RemoteEvent"}, {"FireCannon", "RemoteEvent"},
	{"FlightResult", "RemoteEvent"}, {"ReturnToSpawn", "RemoteEvent"},
	{"FlightState", "RemoteEvent"}, {"BuyUpgrade", "RemoteFunction"},
	{"SteerFlight", "RemoteEvent"},
}

function RemoteClient.Wait(timeout)
	local deadline = os.clock() + (timeout or 15)
	local remotes = {}
	for _, spec in ipairs(required) do
		local name, class = spec[1], spec[2]
		local remote = ReplicatedStorage:FindFirstChild(name)
		local remaining = deadline - os.clock()
		if not remote and remaining > 0 then remote = ReplicatedStorage:WaitForChild(name, remaining) end
		if not remote or not remote:IsA(class) then
			warn("[RemoteClient] Initialization stopped: ReplicatedStorage." .. name
				.. " missing or not " .. class .. ". Check server Output and Rojo sync, then restart Play.")
			return nil
		end
		remotes[name] = remote
	end
	return remotes
end

return RemoteClient
