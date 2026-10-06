local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local aimRemote = ReplicatedStorage:WaitForChild("AimCannon") :: RemoteEvent
local fireRemote = ReplicatedStorage:WaitForChild("FireCannon") :: RemoteEvent
local flightResultRemote = ReplicatedStorage:WaitForChild("FlightResult") :: RemoteEvent
local returnToSpawnRemote = ReplicatedStorage:WaitForChild("ReturnToSpawn") :: RemoteEvent

local cannonModel = script.Parent
local cylinder = cannonModel:WaitForChild("Cylinder") :: BasePart
local launchPoint = cannonModel:WaitForChild("LaunchPoint") :: BasePart
local proximityPrompt = launchPoint:WaitForChild("ProximityPrompt") :: ProximityPrompt

local currentOccupant: Player? = nil
local basePivotCFrame = cylinder:GetPivot()

-- 대포 상태 초기화 함수 (최상단 배치)
local function resetCannon()
	currentOccupant = nil
	proximityPrompt.Enabled = true
end

Players.PlayerRemoving:Connect(function(player)
	if currentOccupant == player then resetCannon() end
end)

aimRemote.OnServerEvent:Connect(function(player: Player, yaw: number, pitch: number)
	if currentOccupant ~= player then return end
	local targetPivotCFrame = basePivotCFrame * CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
	cylinder:PivotTo(targetPivotCFrame)
	launchPoint.CFrame = cylinder.CFrame * CFrame.new(0, 0, -cylinder.Size.Z / 2)
end)

proximityPrompt.Triggered:Connect(function(player: Player)
	if currentOccupant then return end
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid

	if hrp and humanoid then
		currentOccupant = player
		proximityPrompt.Enabled = false
		humanoid.WalkSpeed = 0

		for _, part in character:GetDescendants() do
			if part:IsA("BasePart") then
				part.Transparency = 1
				part.CanCollide = false
			end
		end

		hrp.Anchored = true
		hrp.CFrame = launchPoint.CFrame
		pcall(function() hrp:SetNetworkOwner(player) end)

		aimRemote:FireClient(player, true, cannonModel)
	end
end)

fireRemote.OnServerEvent:Connect(function(player: Player, timingMultiplier: number)
	if currentOccupant ~= player then return end
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
	if not (hrp and humanoid) then return end

	humanoid.WalkSpeed = 0
	humanoid.JumpHeight = 0

	local mult = (type(timingMultiplier) == "number") and math.clamp(timingMultiplier, 0.5, 2.0) or 1.0

	local leaderstats = player:FindFirstChild("leaderstats")
	local powerLvl = leaderstats and leaderstats:FindFirstChild("PowerLvl") and leaderstats.PowerLvl.Value or 1

	local BASE_POWER = 220
	local totalSpeed = (BASE_POWER + (powerLvl * 30)) * mult

	local startPos = launchPoint.Position
	hrp.CFrame = launchPoint.CFrame * CFrame.new(0, 0, -8)
	hrp.Anchored = false

	local launchVelocity = launchPoint.CFrame.LookVector * totalSpeed
	hrp.AssemblyLinearVelocity = launchVelocity

	fireRemote:FireClient(player, launchVelocity)
	aimRemote:FireClient(player, false, cannonModel)

	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			if part.Name ~= "HumanoidRootPart" then
				part.Transparency = 0
			end
			part.CanCollide = false
		end
	end

	task.delay(0.5, function()
		if character then
			for _, part in character:GetDescendants() do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end)

	resetCannon() -- 발사 완료 후 대포 점유 해제 및 프롬프트 복구

	task.spawn(function()
		task.wait(1)

		local maxDist = 0
		while character and hrp and hrp.Parent and humanoid do
			local currentDist = (hrp.Position - startPos).Magnitude
			if currentDist > maxDist then
				maxDist = currentDist
			end

			local isGrounded = humanoid.FloorMaterial ~= Enum.Material.Air
			local isStopped = hrp.AssemblyLinearVelocity.Magnitude < 3

			if isGrounded or isStopped then
				break
			end
			task.wait(0.1)
		end

		local distMeter = math.floor(maxDist)
		local earnedGold = math.floor(distMeter * 1.5)
		local earnedTrophies = 0
		local isNewRecord = false

		local gimmicksFolder = workspace:FindFirstChild("Gimmicks")
		if gimmicksFolder and hrp then
			for _, zone in ipairs(gimmicksFolder:GetChildren()) do
				if string.find(zone.Name, "TargetZone") and zone:IsA("BasePart") then
					local flatDist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(zone.Position.X, 0, zone.Position.Z)).Magnitude
					if flatDist <= 40 then
						earnedTrophies += 5
					end
				end
			end
		end

		if distMeter >= 300 then
			earnedTrophies += math.floor(distMeter / 300)
		end

		if leaderstats then
			local goldObj = leaderstats:FindFirstChild("Gold")
			local trophyObj = leaderstats:FindFirstChild("Trophies")
			local maxDistObj = leaderstats:FindFirstChild("MaxDistance")

			if goldObj then goldObj.Value += earnedGold end
			if trophyObj then trophyObj.Value += earnedTrophies end
			if maxDistObj then
				if distMeter > maxDistObj.Value then
					maxDistObj.Value = distMeter
					isNewRecord = true
				end
			end
		end

		flightResultRemote:FireClient(player, distMeter, earnedGold, earnedTrophies, isNewRecord)
	end)
end)

returnToSpawnRemote.OnServerEvent:Connect(function(player: Player)
	if currentOccupant == player then
		resetCannon()
	end
	player:LoadCharacter()

	local char = player.Character or player.CharacterAdded:Wait()
	local spawnPart = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildOfClass("SpawnLocation")
	if spawnPart and char then
		task.defer(function()
			char:PivotTo(spawnPart.CFrame + Vector3.new(0, 3, 0))
		end)
	end
end)