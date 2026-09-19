local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local cannonDataStore = DataStoreService:GetDataStore("CannonGame_v3")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getOrCreate(name, className)
	local obj = ReplicatedStorage:FindFirstChild(name)
	if not obj then
		obj = Instance.new(className)
		obj.Name = name
		obj.Parent = ReplicatedStorage
	end
	return obj
end

local buyUpgradeRF = getOrCreate("BuyUpgrade", "RemoteFunction") :: RemoteFunction
local resetDataRF = getOrCreate("ResetData", "RemoteFunction") :: RemoteFunction
getOrCreate("AimCannon", "RemoteEvent")
getOrCreate("FireCannon", "RemoteEvent")
getOrCreate("FlightResult", "RemoteEvent")
getOrCreate("ReturnToSpawn", "RemoteEvent")

local movingGimmicks = {}

local function buildMapGimmicks()
	local folder = workspace:FindFirstChild("Gimmicks") or Instance.new("Folder")
	folder.Name = "Gimmicks"
	folder.Parent = workspace
	folder:ClearAllChildren()
	movingGimmicks = {}

	for i = 1, 25 do
		local ring = Instance.new("Part")
		ring.Name = "BoosterRing"
		ring.Shape = Enum.PartType.Cylinder
		ring.Size = Vector3.new(2, 26, 26)
		local basePos = Vector3.new(0, 80 + math.random(-20, 40), -i * 110)
		ring.CFrame = CFrame.new(basePos) * CFrame.Angles(0, 0, math.rad(90))
		ring.Color = Color3.fromRGB(0, 230, 255)
		ring.Material = Enum.Material.Neon
		ring.Anchored = true
		ring.CanCollide = false
		ring.Parent = folder

		table.insert(movingGimmicks, {
			part = ring,
			basePos = basePos,
			speed = 1.5 + math.random() * 1.5,
			range = 30 + math.random(0, 20),
			offset = math.random() * math.pi * 2,
			isRing = true
		})

		local touchDebounce = {}
		ring.Touched:Connect(function(hit)
			local character = hit.Parent
			local player = game.Players:GetPlayerFromCharacter(character)
			if player and not touchDebounce[player] then
				touchDebounce[player] = true
				local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart
				local leaderstats = player:FindFirstChild("leaderstats")
				local boostLvl = leaderstats and leaderstats:FindFirstChild("BoostLvl") and leaderstats.BoostLvl.Value or 1

				if hrp then
					local boostMult = 1.35 + (boostLvl * 0.08)
					hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity * boostMult + Vector3.new(0, 40, 0)
				end
				task.delay(0.8, function() touchDebounce[player] = nil end)
			end
		end)
	end

	for i = 1, 15 do
		local bomb = Instance.new("Part")
		bomb.Name = "ObstacleBomb"
		bomb.Shape = Enum.PartType.Ball
		bomb.Size = Vector3.new(14, 14, 14)
		local basePos = Vector3.new(0, 70 + math.random(-30, 30), -i * 170 - 50)
		bomb.Position = basePos
		bomb.Color = Color3.fromRGB(255, 50, 50)
		bomb.Material = Enum.Material.Neon
		bomb.Anchored = true
		bomb.CanCollide = false
		bomb.Parent = folder

		table.insert(movingGimmicks, {
			part = bomb,
			basePos = basePos,
			speed = 2.0 + math.random(),
			range = 40,
			offset = math.random() * math.pi * 2,
			isRing = false
		})

		local touchDebounce = {}
		bomb.Touched:Connect(function(hit)
			local character = hit.Parent
			local player = game.Players:GetPlayerFromCharacter(character)
			if player and not touchDebounce[player] then
				touchDebounce[player] = true
				local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart

				if hrp then
					hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity * 0.4 + Vector3.new(0, -50, 0)
				end
				task.delay(1, function() touchDebounce[player] = nil end)
			end
		end)
	end

	local targetDistances = {300, 700, 1200, 1800, 2500, 3300}
	for idx, dist in ipairs(targetDistances) do
		local zone = Instance.new("Part")
		zone.Name = "TargetZone_" .. idx
		zone.Size = Vector3.new(70, 1, 70)
		zone.Position = Vector3.new(0, 0.5, -dist)
		zone.Color = Color3.fromRGB(255, 215, 0)
		zone.Material = Enum.Material.Neon
		zone.Anchored = true
		zone.CanCollide = false
		zone.Parent = folder

		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 215, 0)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.Parent = zone
	end
end

buildMapGimmicks()

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for _, item in ipairs(movingGimmicks) do
		if item.part and item.part.Parent then
			local xOffset = math.sin(now * item.speed + item.offset) * item.range
			local targetPos = item.basePos + Vector3.new(xOffset, 0, 0)
			if item.isRing then
				item.part.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, 0, math.rad(90))
			else
				item.part.Position = targetPos
			end
		end
	end
end)

game.Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local gold = Instance.new("IntValue")
	gold.Name = "Gold"
	gold.Value = 0
	gold.Parent = leaderstats

	local trophies = Instance.new("IntValue")
	trophies.Name = "Trophies"
	trophies.Value = 0
	trophies.Parent = leaderstats

	local powerLvl = Instance.new("IntValue")
	powerLvl.Name = "PowerLvl"
	powerLvl.Value = 1
	powerLvl.Parent = leaderstats

	local boostLvl = Instance.new("IntValue")
	boostLvl.Name = "BoostLvl"
	boostLvl.Value = 1
	boostLvl.Parent = leaderstats

	local maxDistance = Instance.new("IntValue")
	maxDistance.Name = "MaxDistance"
	maxDistance.Value = 0
	maxDistance.Parent = leaderstats

	local dataKey = "Player_" .. player.UserId
	local success, savedData = pcall(function()
		return cannonDataStore:GetAsync(dataKey)
	end)

	if success and savedData then
		gold.Value = savedData.Gold or 0
		trophies.Value = savedData.Trophies or 0
		powerLvl.Value = savedData.PowerLvl or 1
		boostLvl.Value = savedData.BoostLvl or 1
		maxDistance.Value = savedData.MaxDistance or 0
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	local dataKey = "Player_" .. player.UserId
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local dataToSave = {
			Gold = leaderstats.Gold.Value,
			Trophies = leaderstats.Trophies.Value,
			PowerLvl = leaderstats.PowerLvl.Value,
			BoostLvl = leaderstats.BoostLvl.Value,
			MaxDistance = leaderstats.MaxDistance.Value,
		}
		pcall(function()
			cannonDataStore:SetAsync(dataKey, dataToSave)
		end)
	end
end)

buyUpgradeRF.OnServerInvoke = function(player, upgradeType)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false end

	if upgradeType == "Gold" then
		local goldObj = leaderstats:FindFirstChild("Gold")
		local powerLvlObj = leaderstats:FindFirstChild("PowerLvl")
		if goldObj and powerLvlObj then
			local cost = math.floor(100 * (1.18 ^ (powerLvlObj.Value - 1)))
			if goldObj.Value >= cost then
				goldObj.Value -= cost
				powerLvlObj.Value += 1
				return true
			end
		end
	elseif upgradeType == "Trophy" then
		local trophyObj = leaderstats:FindFirstChild("Trophies")
		local boostLvlObj = leaderstats:FindFirstChild("BoostLvl")
		if trophyObj and boostLvlObj then
			local cost = boostLvlObj.Value * 2
			if trophyObj.Value >= cost then
				trophyObj.Value -= cost
				boostLvlObj.Value += 1
				return true
			end
		end
	end
	return false
end

resetDataRF.OnServerInvoke = function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		if leaderstats:FindFirstChild("Gold") then leaderstats.Gold.Value = 0 end
		if leaderstats:FindFirstChild("Trophies") then leaderstats.Trophies.Value = 0 end
		if leaderstats:FindFirstChild("PowerLvl") then leaderstats.PowerLvl.Value = 1 end
		if leaderstats:FindFirstChild("BoostLvl") then leaderstats.BoostLvl.Value = 1 end
		if leaderstats:FindFirstChild("MaxDistance") then leaderstats.MaxDistance.Value = 0 end

		local dataKey = "Player_" .. player.UserId
		pcall(function()
			cannonDataStore:SetAsync(dataKey, {
				Gold = 0,
				Trophies = 0,
				PowerLvl = 1,
				BoostLvl = 1,
				MaxDistance = 0
			})
		end)
		return true
	end
	return false
end