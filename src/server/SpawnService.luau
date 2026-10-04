local Players = game:GetService("Players")
local Service = {}

function Service.Start()
	local spawn = workspace:WaitForChild("SpawnLocation", 15)
	assert(spawn and spawn:IsA("SpawnLocation"), "[Spawn] Workspace.SpawnLocation is required")
	spawn.Enabled, spawn.Neutral = true, true
	-- Session changes only. Multiple neutral spawns otherwise produce random first spawns.
	local function disableOther(object)
		if object:IsA("SpawnLocation") and object ~= spawn then object.Enabled = false end
	end
	for _, object in workspace:GetDescendants() do disableOther(object) end
	workspace.DescendantAdded:Connect(disableOther)
	local connections = {}
	local function watch(player)
		player.RespawnLocation = spawn
		local function place(character)
			local root = character:WaitForChild("HumanoidRootPart", 10)
			local humanoid = character:WaitForChild("Humanoid", 10)
			if player.Parent ~= Players or player.Character ~= character or not root or not humanoid then return end
			local state = player:GetAttribute("FlightState")
			if state and state ~= "Idle" and state ~= "Cancelled" then return end
			root.CFrame = spawn.CFrame * CFrame.new(0, spawn.Size.Y / 2 + humanoid.HipHeight + root.Size.Y / 2 + 0.5, 0)
			root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
		end
		connections[player] = player.CharacterAdded:Connect(place)
		if player.Character then task.spawn(place, player.Character) end
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do watch(player) end
	Players.PlayerRemoving:Connect(function(player)
		if connections[player] then connections[player]:Disconnect(); connections[player] = nil end
	end)
end

return Service
