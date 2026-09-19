local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Remotes = require(script.Parent.Remotes)
local Data = require(script.Parent.PlayerData)
local Policy = require(script.Parent.RunPolicy)
local Steering = require(script.Parent.HorizontalSteering)
local SteeringConfig = require(script.Parent.SteeringConfig)
local Flight = {}
local runs = {}
local occupant = nil
local serial = 0
local started = false
local cannon, cylinder, launchPoint, prompt, basePivot
local aimRemote, fireRemote, resultRemote, stateRemote
local playerConnections = {}
local MAX_FLIGHT_SECONDS = 120 -- Abort, never manufacture a landing/reward.

local function vectorFinite(value)
	return typeof(value) == "Vector3" and Policy.finite(value.X)
		and Policy.finite(value.Y) and Policy.finite(value.Z)
end

local function live(run)
	return runs[run.player] == run and not run.cancelled
		and run.player.Parent == Players and run.player.Character == run.character
		and run.character:IsDescendantOf(workspace) and run.root.Parent == run.character
		and run.humanoid.Parent == run.character and run.humanoid.Health > 0
end

local function state(run, value, reason)
	run.state = value
	run.player:SetAttribute("FlightState", value)
	if run.player.Parent == Players then
		stateRemote:FireClient(run.player, value, run.id, run.character, reason)
	end
end

local function release(run)
	if occupant == run then
		occupant = nil
		if prompt.Parent then prompt.Enabled = true end
	end
end

local function restoreParts(run, visibility, collision)
	for part, saved in pairs(run.parts) do
		if part:IsDescendantOf(run.character) then
			if visibility then part.Transparency = saved.transparency end
			if collision then part.CanCollide = saved.collision end
		end
	end
end

local function cleanup(run, restorePosition)
	if run.cleaned then return end
	run.cleaned = true
	run.steering = nil
	for _, connection in ipairs(run.connections) do connection:Disconnect() end
	table.clear(run.connections)
	release(run)
	restoreParts(run, true, true)
	local humanoid, root, saved = run.humanoid, run.root, run.saved
	if humanoid.Parent then
		humanoid.WalkSpeed = saved.walkSpeed
		humanoid.UseJumpPower = saved.useJumpPower
		humanoid.JumpPower = saved.jumpPower
		humanoid.JumpHeight = saved.jumpHeight
		humanoid.AutoRotate = saved.autoRotate
		humanoid.PlatformStand = saved.platformStand
		if humanoid.Health > 0 and not saved.platformStand then
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
	if root.Parent then
		root.Anchored = saved.anchored
		if restorePosition then
			root.CFrame = saved.cframe
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		if not root.Anchored then
			local ok, err = pcall(function() root:SetNetworkOwnershipAuto() end)
			if not ok then warn("[Flight] Ownership restore failed:", err) end
		end
	end
end

local function cancel(run, reason)
	if runs[run.player] ~= run or run.cancelled then return end
	local wasAiming = run.state == "Aiming"
	run.cancelled = true
	cleanup(run, wasAiming or reason == "InvalidPhysics" or reason == "FlightTimeout" or reason == "OwnershipFailed")
	state(run, "Cancelled", reason)
	runs[run.player] = nil
	run.player:SetAttribute("FlightState", "Idle")
end

local function finish(run)
	if not live(run) or run.state ~= "Flying" or run.finalized then return end
	run.finalized = true -- Set before any external call; all reward work below is non-yielding.
	local targets = 0
	local folder = workspace:FindFirstChild("Gimmicks")
	if folder then
		for _, zone in folder:GetChildren() do
			if zone:IsA("BasePart") and string.find(zone.Name, "TargetZone", 1, true) then
				local delta = run.root.Position - zone.Position
				-- Preserve the prototype's XZ radius and +5 per zone.
				if Vector3.new(delta.X, 0, delta.Z).Magnitude <= 40 then targets += 1 end
			end
		end
	end
	local distance, gold, trophies = Policy.reward(run.maxDistance, targets)
	local record = Data.Award(run.player, distance, gold, trophies)
	if record == nil then cancel(run, "DataUnavailable"); return end
	cleanup(run, false)
	state(run, "Result")
	resultRemote:FireClient(run.player, distance, gold, trophies, record, run.id, run.character)
end

local function begin(player)
	if occupant or runs[player] or not Data.IsReady(player) then return end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0
		or not character:IsDescendantOf(workspace) then return end
	if (root.Position - launchPoint.Position).Magnitude > prompt.MaxActivationDistance + 3 then return end
	serial += 1
	local run = {
		id = serial, player = player, character = character, root = root, humanoid = humanoid,
		state = "Aiming", parts = {}, connections = {}, contacts = {}, lastAim = -math.huge,
		created = os.clock(),
		saved = {walkSpeed = humanoid.WalkSpeed, useJumpPower = humanoid.UseJumpPower,
			jumpPower = humanoid.JumpPower, jumpHeight = humanoid.JumpHeight,
			autoRotate = humanoid.AutoRotate, platformStand = humanoid.PlatformStand,
			anchored = root.Anchored, cframe = root.CFrame},
	}
	runs[player], occupant = run, run
	prompt.Enabled = false
	local function hide(part)
		if part:IsA("BasePart") and not run.parts[part] then
			run.parts[part] = {transparency = part.Transparency, collision = part.CanCollide}
			if run.state == "Aiming" then part.Transparency = 1 end
			if run.state == "Aiming" or not run.collisionsRestored then part.CanCollide = false end
		end
	end
	for _, part in character:GetDescendants() do hide(part) end
	table.insert(run.connections, character.DescendantAdded:Connect(hide))
	table.insert(run.connections, humanoid.Died:Connect(function() cancel(run, "Death") end))
	humanoid.WalkSpeed, humanoid.JumpPower, humanoid.JumpHeight = 0, 0, 0
	root.Anchored = true
	cylinder:PivotTo(basePivot)
	launchPoint.CFrame = cylinder.CFrame * CFrame.new(0, 0, -cylinder.Size.Z / 2)
	root.CFrame = launchPoint.CFrame
	player:SetAttribute("FlightState", "Aiming")
	aimRemote:FireClient(player, true, cannon, run.id, character)
end

local function fire(player, multiplier, id)
	local run = runs[player]
	if not Policy.isCurrent(run, id, player.Character) or not live(run)
		or occupant ~= run or run.state ~= "Aiming" or not Policy.validMultiplier(multiplier) then return end
	local level = Data.GetLevel(player, "PowerLvl")
	if not level then cancel(run, "DataUnavailable"); return end
	local velocity = launchPoint.CFrame.LookVector * ((220 + level * 30) * multiplier)
	if not vectorFinite(velocity) or velocity.Magnitude <= 0 then cancel(run, "InvalidLaunch"); return end
	run.startPosition = launchPoint.Position
	run.root.CFrame = launchPoint.CFrame * CFrame.new(0, 0, -8)
	run.root.Anchored = false
	local ok, err = pcall(function()
		local canSet, reason = run.root:CanSetNetworkOwnership()
		if not canSet then error(reason) end
		run.root:SetNetworkOwner(player)
	end)
	if not ok then warn("[Flight] Launch ownership failed:", err); cancel(run, "OwnershipFailed"); return end
	run.state = "Flying"
	run.launchedAt, run.lastSample = os.clock(), os.clock()
	run.lastPosition, run.maxDistance = run.root.Position, (run.root.Position - run.startPosition).Magnitude
	run.speedBudget = velocity.Magnitude
	run.steering = Steering.Create(velocity)
	run.humanoid.AutoRotate, run.humanoid.PlatformStand = false, true
	run.root.AssemblyAngularVelocity = Vector3.zero
	run.root.AssemblyLinearVelocity = velocity -- Client never reapplies this impulse.
	restoreParts(run, true, false)
	player:SetAttribute("FlightState", "Flying")
	fireRemote:FireClient(player, velocity, run.id, run.character, run.saved, SteeringConfig.Client)
	aimRemote:FireClient(player, false, cannon, run.id, run.character)
	release(run)
end

function Flight.ApplyGimmick(part, hit, kind)
	if not started or not hit:IsA("BasePart") then return end
	local character = hit:FindFirstAncestorOfClass("Model")
	local player = character and Players:GetPlayerFromCharacter(character)
	local run = player and runs[player]
	if not run or run.state ~= "Flying" or not live(run) then return end
	local relative = part.CFrame:PointToObjectSpace(run.root.Position)
	local extent = part.Size / 2 + Vector3.new(8, 8, 8)
	if math.abs(relative.X) > extent.X or math.abs(relative.Y) > extent.Y or math.abs(relative.Z) > extent.Z then return end
	local now = os.clock()
	if now < (run.contacts[part] or 0) then return end
	local velocity = run.root.AssemblyLinearVelocity
	if not vectorFinite(velocity) or velocity.Magnitude > run.speedBudget + 100 then cancel(run, "InvalidPhysics"); return end
	if kind == "Ring" then
		local level = Data.GetLevel(player, "BoostLvl")
		if not level then return end
		local mult = 1.35 + level * 0.08
		velocity = velocity * mult + Vector3.new(0, 40, 0)
		run.speedBudget = run.speedBudget * mult + 40
		run.contacts[part] = now + 0.8
	elseif kind == "Bomb" then
		velocity = velocity * 0.4 + Vector3.new(0, -50, 0)
		run.speedBudget += 50
		run.contacts[part] = now + 1
	else return end
	if not vectorFinite(velocity) or not Policy.finite(run.speedBudget) then cancel(run, "InvalidPhysics"); return end
	run.root.AssemblyLinearVelocity = velocity
end

function Flight.Start(model)
	if started then return end
	cannon = model
	cylinder = cannon:FindFirstChild("Cylinder")
	launchPoint = cannon:FindFirstChild("LaunchPoint")
	prompt = launchPoint and launchPoint:FindFirstChildOfClass("ProximityPrompt")
	assert(cylinder and cylinder:IsA("BasePart") and launchPoint and launchPoint:IsA("BasePart") and prompt,
		"[Flight] Workspace.Canon requires Cylinder, LaunchPoint and ProximityPrompt")
	local remotes = Remotes.Ensure()
	aimRemote = remotes.AimCannon
	fireRemote = remotes.FireCannon
	resultRemote = remotes.FlightResult
	stateRemote = remotes.FlightState
	basePivot = cylinder:GetPivot()
	started = true
	prompt.Triggered:Connect(begin)
	aimRemote.OnServerEvent:Connect(function(player, yaw, pitch, id)
		local run = runs[player]
		if not Policy.isCurrent(run, id, player.Character) or occupant ~= run
			or run.state ~= "Aiming" or not live(run) or not Policy.validAim(yaw, pitch) then return end
		local now = os.clock()
		if now - run.lastAim < 1 / 40 then return end
		run.lastAim = now
		cylinder:PivotTo(basePivot * CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0))
		launchPoint.CFrame = cylinder.CFrame * CFrame.new(0, 0, -cylinder.Size.Z / 2)
	end)
	fireRemote.OnServerEvent:Connect(fire)
	remotes.SteerFlight.OnServerEvent:Connect(function(player, axis, id)
		local run = runs[player]
		if not Policy.isCurrent(run, id, player.Character) or run.state ~= "Flying"
			or not live(run) or not Data.IsReady(player) then return end
		Steering.Accept(run.steering, axis, os.clock())
	end)
	remotes.ReturnToSpawn.OnServerEvent:Connect(function(player, id)
		local run = runs[player]
		if not Policy.isCurrent(run, id, player.Character) or not live(run)
			or (run.state ~= "Result" and run.state ~= "Aiming" and run.state ~= "Flying") then return end
		cleanup(run, run.state == "Aiming")
		state(run, "Returning") -- Reject further return/fire/prompt requests before yielding.
		local ok, err = pcall(function() player:LoadCharacterAsync() end)
		if runs[player] ~= run or run.cancelled then return end
		if not ok then warn("[Flight] Respawn failed:", err); cancel(run, "ReturnFailed"); return end
		local character = player.Character
		local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildOfClass("SpawnLocation")
		if character and character ~= run.character and spawn and spawn:IsA("BasePart") then
			character:PivotTo(spawn.CFrame + Vector3.new(0, 3, 0))
		end
		state(run, "Idle")
		runs[player] = nil
	end)
	local function watch(player)
		if playerConnections[player] then return end
		playerConnections[player] = player.CharacterRemoving:Connect(function(character)
			local run = runs[player]
			if run and run.character == character and run.state ~= "Returning" then cancel(run, "CharacterRemoved") end
		end)
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do watch(player) end
	Players.PlayerRemoving:Connect(function(player)
		if runs[player] then cancel(runs[player], "PlayerLeft") end
		if playerConnections[player] then playerConnections[player]:Disconnect(); playerConnections[player] = nil end
	end)
	local accumulator = 0
	RunService.Heartbeat:Connect(function(dt)
		accumulator += dt
		if accumulator < 0.05 then return end
		accumulator = 0
		local now = os.clock()
		for _, run in pairs(runs) do
			if run.state == "Returning" then continue end
			if not live(run) or not Data.IsReady(run.player) then cancel(run, "InvalidCharacter"); continue end
			if run.state == "Aiming" and now - run.created > 120 then cancel(run, "AimTimeout"); continue end
			if run.state ~= "Flying" then continue end
			local elapsed = now - run.launchedAt
			if elapsed > MAX_FLIGHT_SECONDS then cancel(run, "FlightTimeout"); continue end
			if not run.collisionsRestored and elapsed >= 0.5 then
				run.collisionsRestored = true
				restoreParts(run, false, true)
			end
			local sampleDt = now - run.lastSample
			run.speedBudget += workspace.Gravity * sampleDt
			local position, velocity = run.root.Position, run.root.AssemblyLinearVelocity
			if not vectorFinite(position) or not vectorFinite(velocity)
				or (position - run.lastPosition).Magnitude > run.speedBudget * math.max(sampleDt, 0.1) + 32
				or velocity.Magnitude > run.speedBudget + 100 then
				cancel(run, "InvalidPhysics"); continue
			end
			run.lastPosition, run.lastSample = position, now
			run.maxDistance = math.max(run.maxDistance, (position - run.startPosition).Magnitude)
			if elapsed >= 1 then
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = {run.character, cannon}
				params.RespectCanCollide = true
				local ground = workspace:Raycast(position, Vector3.new(0, -(run.humanoid.HipHeight + run.root.Size.Y / 2 + 1), 0), params)
				local grounded = run.humanoid.FloorMaterial ~= Enum.Material.Air
					or (ground ~= nil and math.abs(velocity.Y) < 5)
				if grounded then
					run.groundedAt = run.groundedAt or now
					if now - run.groundedAt >= 0.15 then finish(run) end
				else run.groundedAt = nil end
			end
			-- Apply only after validation and landing finalization. A completed run
			-- receives no final steering impulse; rewards/grounding remain PHASE 0 rules.
			if run.state == "Flying" then
				local corrected, budget = Steering.Step(run.steering, velocity, sampleDt, now)
				if budget > 0 then
					run.root.AssemblyLinearVelocity = corrected
					run.speedBudget += budget -- Account for legitimate lateral acceleration.
				end
			end
		end
	end)
	print("[Flight] PHASE 0 Cannon server active (Workspace.Canon)")
end

return Flight
