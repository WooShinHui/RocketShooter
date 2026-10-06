local balanceModule = game:GetService("ReplicatedStorage"):WaitForChild("BalanceConfig", 15)
assert(balanceModule and balanceModule:IsA("ModuleScript"),
	"[Setup] ReplicatedStorage.BalanceConfig must be a ModuleScript. Stop Play, restart rojo serve with default.project.json, reconnect and accept sync.")
local Balance = require(balanceModule)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
-- 설정이 누락되거나 로딩에 실패해도 비행 초기화를 계속합니다.
local SkyIslandConfig = nil
do
	local configModule = ReplicatedStorage:FindFirstChild("SkyIslandConfig")
	if configModule then
		local ok, result = pcall(require, configModule)
		if ok then
			SkyIslandConfig = result
		else
			warn("[FlightService] SkyIslandConfig 로딩 실패; 기본 태그로 착륙을 판정합니다:", result)
		end
	else
		warn("[FlightService] ReplicatedStorage.SkyIslandConfig가 없어 기본 태그로 착륙을 판정합니다.")
	end
end
local Remotes = require(script.Parent.Remotes)
local Data = require(script.Parent.PlayerData)
local Policy = require(script.Parent.RunPolicy)
local Steering = require(script.Parent.HorizontalSteering)
local SteeringConfig = require(script.Parent.SteeringConfig)
local Metrics = require(script.Parent.FlightMetrics)
local Discovery = require(script.Parent.CloudDiscovery)
local Trajectory = require(script.Parent.LaunchTrajectory)
local World = require(script.Parent.WorldService)
local courseModule=script.Parent:FindFirstChild("BreakCourse")
local Course=courseModule and require(courseModule)
local streamingModule=script.Parent:FindFirstChild("FlightStreaming")
local FlightStreaming=streamingModule and require(streamingModule)
local landingModule=script.Parent:FindFirstChild("LimbLanding")
local LimbLanding=landingModule and require(landingModule)
local Flight = {}
local descentModule=script.Parent:FindFirstChild("DescentChallenge")
local Descent=descentModule and require(descentModule)
local fuelModule = script.Parent:FindFirstChild("ProtoFuelService")
local Fuel = fuelModule and require(fuelModule)
local runs = {}
local occupant = nil
local serial = 0
local started = false
local cannon, cylinder, launchPoint, prompt, basePivot
local aimRemote, fireRemote, resultRemote, stateRemote
local playerConnections = {}
local MAX_FLIGHT_SECONDS = 120 -- Abort, never manufacture a landing/reward.

local function landingType(instance)
	local skyIslandTag = SkyIslandConfig and SkyIslandConfig.TAG or "SkyIsland"
	while instance and instance ~= workspace do
		if instance:GetAttribute("IsSkyIsland") == true or CollectionService:HasTag(instance, skyIslandTag) then
			return "SkyIsland"
		end
		instance = instance.Parent
	end
	return "Ground"
end

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
		-- Restore the boarding point once the shot is frozen; high aim must not leave it in the air.
		if cylinder.Parent then cylinder:PivotTo(basePivot) end
		if launchPoint.Parent then launchPoint.CFrame=Trajectory.Muzzle(cylinder.CFrame,cylinder.Size.Z) end
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
	if Course then Course.Destroy(run.breakCourse) end
    if FlightStreaming then FlightStreaming.Destroy(run.streaming) end
	if run.root.Parent then run.root:SetAttribute("Diving",nil) end
    for _,key in {"DiveTargetPosition","DiveTargetsLeft","DiveTargetDistance","DiveTargetActive"} do run.player:SetAttribute(key,nil) end
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

local function returnToSpawn(run, reason)
	local player = run.player
	cleanup(run, run.state == "Aiming")
	state(run, "Returning", reason) -- Reserve the run before yielding.
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
end

local function recover(run, reason)
	-- Move out of the kill plane immediately; never wait there for LoadCharacterAsync.
	cleanup(run, true)
	state(run, "Returning", reason)
	warn("[Flight] Recovering run", run.id, reason)
	task.spawn(function()
		if runs[run.player] ~= run or run.cancelled then return end
		if run.player.Character ~= run.character then cancel(run, "CharacterRemoved"); return end
		returnToSpawn(run, reason)
	end)
end

local function finish(run)
	if not live(run) or run.state ~= "Flying" or run.finalized then return end
	run.finalized = true -- Set before any external call; all reward work below is non-yielding.
	local targets = World.TargetCount(run.root.Position)
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
	local metrics = Metrics.Snapshot(run.metrics)
	metrics.landingType = run.landingType or "Ground"
	local protoModule = ReplicatedStorage:FindFirstChild("ProtoFuelConstants")
	if protoModule then
		local proto = require(protoModule)
		local objective = World.GetCloudOutpostObjective()
		local targetAltitude = objective and objective.requiredAltitude or proto.CloudOutpostAltitude
		metrics.altitudeShortfall = targetAltitude - metrics.MaxAltitude
		metrics.nearMissTriggered = metrics.MaxAltitude >= targetAltitude * proto.NearMissThreshold
			and metrics.MaxAltitude < targetAltitude
	end
	local distance, gold, trophies = Policy.reward(run.metrics.RewardDistance, targets)
	metrics.SkyScore = run.skyScore or 0
	metrics.ChainHits=run.breakCourse and run.breakCourse.Count or 0
	metrics.PiercedEnemies=run.piercedEnemies or 0
	metrics.DiveSeconds=run.diveAt and os.clock()-run.diveAt or 0
	trophies += math.floor(metrics.SkyScore / 60)
	if Descent and run.descent then
        local bonus,grade=Descent.Reward(run.descent,run.root.Position,metrics.landingType)
        metrics.DescentRings=run.descent.Count;metrics.DescentTrophies=bonus;metrics.LandingGrade=grade
        trophies+=bonus
    end
    local record, altitudeRecord = Data.Award(run.player, distance, gold, trophies, metrics.MaxAltitude)
	if record == nil then cancel(run, "DataUnavailable"); return end
	metrics.XPGain=Data.AwardFlightXP and Data.AwardFlightXP(run.player,1+math.floor(metrics.MaxAltitude/40)+math.floor(metrics.SkyScore/15)) or 0
	metrics.AltitudeRecord = altitudeRecord == true
	cleanup(run, false)
    metrics.DetachedLimbs=LimbLanding and LimbLanding.Burst(run.character,run.root) or 0
	state(run, "Result")
	resultRemote:FireClient(run.player, distance, gold, trophies, record, run.id, run.character, metrics)
    task.delay(.8,function() if live(run) and run.state=="Result" then returnToSpawn(run,"AutoReturn") end end)
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
	launchPoint.CFrame = Trajectory.Muzzle(cylinder.CFrame, cylinder.Size.Z)
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
	level += Fuel and Fuel.getSessionPowerBonus(player) or 0
	level += Data.GetTrainingPower and Data.GetTrainingPower(player) or 0
	local look = launchPoint.CFrame.LookVector
	local velocity, horizontalSpeed, verticalSpeed = Trajectory.Velocity(look, level, multiplier)
	if not velocity then cancel(run, "InvalidLaunch"); return end
	run.launchHorizontal = horizontalSpeed
	run.ringLiftRemaining = Balance.RingLiftBudget(verticalSpeed)
	if not vectorFinite(velocity) or velocity.Magnitude <= 0 then cancel(run, "InvalidLaunch"); return end
	run.startPosition = launchPoint.Position
	run.root.CFrame = Trajectory.Origin(launchPoint.CFrame)
	run.root.Anchored = false
	local ok, err = pcall(function()
		local canSet, reason = run.root:CanSetNetworkOwnership()
		if not canSet then error(reason) end
		-- Flight integration and server corrections must share one physics owner.
		-- Writing replicated client velocity back each tick restored stale gravity results.
		run.root:SetNetworkOwner(nil)
	end)
	if not ok then warn("[Flight] Launch ownership failed:", err); cancel(run, "OwnershipFailed"); return end
	-- 기존 속도 배율 호출 계약을 유지한다. Fuel 발사 소비는 비활성화되어 있다.
	local fuelBoost = Fuel and Fuel.consumeFuelForLaunch(player) or 1
	velocity, horizontalSpeed, verticalSpeed = Trajectory.Velocity(look, level, multiplier, fuelBoost)
	run.launchHorizontal = horizontalSpeed
	run.ringLiftRemaining = Balance.RingLiftBudget(verticalSpeed)
	run.state = "Flying"
	run.launchedAt, run.lastSample = os.clock(), os.clock()
	run.lastPosition = run.root.Position
	-- Freeze this launch axis and the shared Ground datum; another cannon user
	-- or later steering must not rotate the reference frame of this run.
	run.metrics = Metrics.Create(run.startPosition, velocity, World.GroundY(), run.launchedAt)
	run.skyVisited = {serial=run.id}; run.skyScore = 0;run.piercedEnemies=0;run.extraSkyScore=0;run.effectiveLevel=level
	if Course then run.breakCourse=Course.Create(player,run.id,run.root.Position,velocity,workspace.Gravity,level) end
    if FlightStreaming then run.streaming=FlightStreaming.Create(player,run.root.Position,velocity) end
	run.player:SetAttribute("SkyRunSerial",run.id)
	run.player:SetAttribute("DestructionRunScore",0)
	run.player:SetAttribute("LastSkyHazard",nil)
	run.discovery = Discovery.Create(Data.GetLevel(player, "MaxAltitude") or 0,
		player:GetAttribute("CloudsDiscovered") == true)
	Metrics.Sample(run.metrics, run.lastPosition, run.launchedAt)
	run.destinations = {}
	run.speedBudget = velocity.Magnitude
	run.steering = Steering.Create(velocity)
	run.humanoid.AutoRotate, run.humanoid.PlatformStand = false, true
	run.root.AssemblyAngularVelocity = Vector3.zero
	run.root.AssemblyLinearVelocity = velocity -- Client never reapplies this impulse.
	restoreParts(run, true, false)
	player:SetAttribute("FlightState", "Flying")
	local objectiveMeta = World.GetCloudOutpostObjective()
	fireRemote:FireClient(player, velocity, run.id, run.character, run.saved, SteeringConfig.Client, objectiveMeta)
	aimRemote:FireClient(player, false, cannon, run.id, run.character)
	release(run)
end

function Flight.ApplyGimmick(part, hit, kind)
	if not started or not hit:IsA("BasePart") then return end
	local character = hit:FindFirstAncestorOfClass("Model")
	local player = character and Players:GetPlayerFromCharacter(character)
	local run = player and runs[player]
	if not run or run.state ~= "Flying" or run.hazardFall or not live(run) then return end
	local relative = part.CFrame:PointToObjectSpace(run.root.Position)
	local extent = part.Size / 2 + Vector3.new(8, 8, 8)
	if math.abs(relative.X) > extent.X or math.abs(relative.Y) > extent.Y or math.abs(relative.Z) > extent.Z then return end
	local now = os.clock()
	-- Stable generated id also survives section unload/rebuild within this run.
	local contactKey = kind == "Bomb" and part:GetAttribute("ObstacleId") or part
	contactKey = contactKey or part
	if now < (run.contacts[contactKey] or 0) then return end
	local velocity = run.root.AssemblyLinearVelocity
	if not vectorFinite(velocity) or velocity.Magnitude > run.speedBudget + 100 then cancel(run, "InvalidPhysics"); return end
	if kind == "Ring" then
		local level = Data.GetLevel(player, "BoostLvl")
		if not level then return end
		local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
		local nextSpeed, nextY, lift = Balance.RingComponents(horizontal.Magnitude, velocity.Y, level,
			run.launchHorizontal, run.ringLiftRemaining)
		run.ringLiftRemaining -= lift
		local direction = horizontal.Magnitude > 0.01 and horizontal.Unit or Vector3.zero
		local boosted = direction * nextSpeed + Vector3.new(0, nextY, 0)
		run.speedBudget += (boosted - velocity).Magnitude
		velocity = boosted
		run.contacts[part] = now + Balance.Ring.Cooldown
	elseif kind == "Bomb" then
		velocity = velocity * Balance.Bomb.SpeedFactor + Vector3.new(0, -Balance.Bomb.DownwardImpulse, 0)
		run.speedBudget += Balance.Bomb.DownwardImpulse
		run.contacts[contactKey] = math.huge -- One penalty per obstacle per run, including legacy bombs.
	else return end
	if not vectorFinite(velocity) or not Policy.finite(run.speedBudget) then cancel(run, "InvalidPhysics"); return end
	run.root.AssemblyLinearVelocity = velocity
	stateRemote:FireClient(player, "Effect", run.id, run.character, kind)
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
	World.Start(cannon, Flight.ApplyGimmick)
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
		launchPoint.CFrame = Trajectory.Muzzle(cylinder.CFrame, cylinder.Size.Z)
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
		returnToSpawn(run)
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
			local exitReason = World.ExitReason(position, velocity)
			if not run.hazardFall and not exitReason and elapsed>=.3 and World.CollectSky then
				local award=World.CollectSky(run.player,run.lastPosition,position,run.skyVisited)
				if run.effectiveLevel and run.effectiveLevel<5 and Course then
                    local limit=Course.Tier(run.effectiveLevel).Count*40*.25
                    local allowed=math.max(0,math.min(award,limit-run.extraSkyScore));run.extraSkyScore+=allowed;award=allowed
                end
                run.skyScore+=award
				run.player:SetAttribute("DestructionRunScore",run.skyScore)
			end
			if not run.hazardFall and elapsed>=1 and World.HazardHit then
				local hit,enemy=World.HazardHit(run.lastPosition,position,now)
				if hit and enemy and velocity.Magnitude>=360 and World.BreakSkyEnemy then
                    local bonus=World.BreakSkyEnemy(run.player,enemy,run.skyVisited)
                    run.skyScore+=bonus;run.piercedEnemies+=if bonus>0 then 1 else 0
                    run.player:SetAttribute("DestructionRunScore",run.skyScore)
                elseif hit then
					run.hazardFall=true
					run.root.AssemblyLinearVelocity=Vector3.new(velocity.X*0.15,-150,velocity.Z*0.15)
					run.speedBudget+=180
					run.player:SetAttribute("LastSkyHazard",hit)
					stateRemote:FireClient(run.player,"Effect",run.id,run.character,"SkyHazard")
				end
			end
			if exitReason then recover(run, exitReason); continue end
            if Descent and not run.hazardFall then
                if not run.descent and not run.descentAttempted and velocity.Y<=0 then
                    run.descentAttempted=true
                    run.descent=Descent.Create(position,velocity,World.GroundY(),workspace.Gravity,run.id)
                    if run.descent then
                        run.diveAt=now;run.root:SetAttribute("Diving",true)
                        local diveVelocity=Vector3.new(0,-math.min(160,Descent.FallSpeed(run.descent,position.Y-World.GroundY())),0)
                        run.speedBudget+= (diveVelocity-velocity).Magnitude
                        run.root.AssemblyLinearVelocity=diveVelocity;velocity=diveVelocity
                        run.root.AssemblyAngularVelocity=Vector3.zero
                        run.root.CFrame=CFrame.lookAt(position,position+run.descent.Forward)*CFrame.Angles(0,0,math.pi)
                        if run.steering then run.steering.Descent=true end
                        stateRemote:FireClient(run.player,"Descent",run.id,run.character,Descent.Payload(run.descent))
                    end
                end
                if run.descent then
                    if Course and run.breakCourse then Course.Update(run.breakCourse,position,run.root.AssemblyLinearVelocity,elapsed,run.descent) end
                    local fallSpeed=Descent.FallSpeed(run.descent,position.Y-World.GroundY())
                    if Course and run.breakCourse then
                        local target,left=Course.DiveTarget(run.breakCourse,position)
                        if target then
                            fallSpeed=math.min(fallSpeed,180);run.diveSlow=true
                        elseif run.diveSlow then
                            local current=run.root.AssemblyLinearVelocity
                            local boost=math.max(0,fallSpeed+current.Y)
                            if boost>0 then run.root:ApplyImpulse(Vector3.new(0,-boost*run.root.AssemblyMass,0));run.speedBudget+=boost end
                            velocity=run.root.AssemblyLinearVelocity;run.diveSlow=false
                        end
                        local destination=target and target.Position or Vector3.new(position.X,run.breakCourse.NextDive or World.GroundY(),position.Z)
                        run.player:SetAttribute("DiveTargetPosition",destination)
                        run.player:SetAttribute("DiveTargetsLeft",left)
                        run.player:SetAttribute("DiveTargetDistance",math.max(0,math.ceil((position.Y-destination.Y)/5)*5))
                        run.player:SetAttribute("DiveTargetActive",target~=nil)
                    end
                    if velocity.Y < -fallSpeed then
                        run.root:ApplyImpulse(Vector3.new(0,(-fallSpeed-velocity.Y)*run.root.AssemblyMass,0))
                    end
                    -- Eliminate forward glide: steering owns only the dive's lateral velocity.
                    if run.steering then
                        local side=run.root.AssemblyLinearVelocity:Dot(run.steering.right)
                        local current=run.root.AssemblyLinearVelocity
                        run.root.AssemblyLinearVelocity=run.steering.right*side+Vector3.new(0,current.Y,0)
                    end
                    if Descent.Sample(run.descent,run.lastPosition,position) then stateRemote:FireClient(run.player,"DescentProgress",run.id,run.character,Descent.Payload(run.descent)) end
                end
            end
            if FlightStreaming then FlightStreaming.Update(run.streaming,position,run.root.AssemblyLinearVelocity,run.descent) end
            if Course and run.breakCourse and not run.hazardFall then
                Course.Update(run.breakCourse,position,run.root.AssemblyLinearVelocity,elapsed,run.descent)
                local award=Course.Sample(run.breakCourse,run.lastPosition,position,function(data)
                    run.courseFxScore=(run.courseFxScore or run.skyScore)+data.Award
                    data.RunScore=run.courseFxScore
                    local ready=math.max(now,run.fxReadyAt or now);run.fxReadyAt=ready+.06
                    task.delay(ready-now,function()
                        if live(run) and run.state=="Flying" then ReplicatedStorage.BarrierDestroyed:FireClient(run.player,data) end
                    end)
                end)
                run.skyScore+=award;run.player:SetAttribute("DestructionRunScore",run.skyScore)
            end
			run.lastPosition, run.lastSample = position, now
			Metrics.Sample(run.metrics, position, now)
			local region = Discovery.Sample(run.discovery, run.metrics)
			if region then
				if region.FirstEntry then run.player:SetAttribute("CloudsDiscovered", true) end
				stateRemote:FireClient(run.player, "Region", run.id, run.character, region)
			end
			local destination = World.SampleDestination(position, run.metrics, run.destinations)
			if destination then
				local attribute = "Discovered_" .. destination.Id
				destination.FirstDiscovery = run.player:GetAttribute(attribute) ~= true
				run.player:SetAttribute(attribute, true) -- Session only; no save schema/reward change.
				stateRemote:FireClient(run.player, "Destination", run.id, run.character, destination)
			end
			if elapsed >= 1 then
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = {run.character, cannon}
				params.RespectCanCollide = true
				local ground = workspace:Raycast(position, Vector3.new(0, -(run.humanoid.HipHeight + run.root.Size.Y / 2 + 1), 0), params)
				local grounded = run.humanoid.FloorMaterial ~= Enum.Material.Air
					or (ground ~= nil and math.abs(velocity.Y) < 5)
				if grounded then
					run.landingType = landingType(ground and ground.Instance)
					run.groundedAt = run.groundedAt or now
					if now - run.groundedAt >= 0.15 then
						if run.hazardFall then recover(run,"SkyHazardFall") else finish(run) end
					end
				else run.groundedAt = nil end
			end
			-- Apply only after validation and landing finalization. A completed run
			-- receives no final steering impulse; rewards/grounding remain PHASE 0 rules.
			if run.state == "Flying" and not run.hazardFall then
				local budget = Steering.Apply(run.steering, run.root, sampleDt, now)
				run.speedBudget += budget -- Account for legitimate lateral acceleration.
			end
		end
	end)
	print("[Flight] PHASE 0 Cannon server active (Workspace.Canon)")
end

return Flight
