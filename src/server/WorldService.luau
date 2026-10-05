local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Config = require(script.Parent.LevelConfig)
local Coordinates = require(script.Parent.WorldCoordinates)
local Builder = require(script.Parent.LevelBuilder)
local Legacy = require(script.Parent.LegacyGimmicks)
local Trajectory = require(script.Parent.LaunchTrajectory)
local Destination = require(script.Parent.Destination)
local Camp = script.Parent.CliffCamp and require(script.Parent.CliffCamp)
local SkyLife = script.Parent.SkyLife and require(script.Parent.SkyLife)
local World = {}
local frame, builder

function World.Start(cannon, applyGimmick)
	if frame then return end
	local cylinder = cannon:FindFirstChild("Cylinder")
	local muzzle = Trajectory.Muzzle(cylinder.CFrame, cylinder.Size.Z)
	local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildOfClass("SpawnLocation")
	local groundY = Config.GroundY
	if groundY == nil then
		assert(spawn and spawn:IsA("BasePart"), "[World] Set LevelConfig.GroundY or provide SpawnLocation")
		groundY = spawn.Position.Y + spawn.Size.Y / 2
	end
	local candidate = Coordinates.Create(muzzle, groundY)
	local route = Config.Course and Config.Course.RingTrajectory
	if route then
		-- Reproduce the existing yaw=0 aim transform without moving the cannon.
		local pivot = cylinder:GetPivot()
		candidate.RingMuzzle = Trajectory.AimedMuzzle(pivot,
			pivot:ToObjectSpace(cylinder.CFrame), cylinder.Size.Z, 0, route.Pitch)
	end
	builder = Builder.new(workspace, candidate, Config, applyGimmick)
	frame = candidate -- Capture once; another player's aiming never rotates the course.
	if Camp then Camp.Start(frame) end
	if SkyLife then SkyLife.Start(frame) end
	Legacy.Start(applyGimmick, Config.LegacyGimmicks)
	if Config.ArchiveHandmadeMap then
		local oldMap = workspace:FindFirstChild("SIMULATOR MAP")
		if oldMap then
			local archive = Instance.new("Folder")
			archive.Name = "HandmadeMapArchive"
			archive.Parent = game:GetService("ServerStorage")
			oldMap.Parent = archive
		end
	end
	local function update()
		local windows = {}
		local settings = Config.Streaming
		for _, player in ipairs(Players:GetPlayers()) do
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root and root:IsA("BasePart") then
				local distance = Coordinates.Project(frame, root.Position)
				local speed = root.AssemblyLinearVelocity:Dot(frame.Forward)
				-- Ignore non-finite physics here; FlightService owns validation/cancellation.
				if distance == distance and math.abs(distance) < math.huge and speed == speed and math.abs(speed) < math.huge then
					local ahead = math.clamp(speed * settings.LookAheadSeconds, -settings.MaxLookAhead, settings.MaxLookAhead)
					table.insert(windows, {distance - settings.Behind + math.min(0, ahead),
						distance + settings.Ahead + math.max(0, ahead)})
				end
			end
		end
		if #windows == 0 then table.insert(windows, {-settings.Behind, settings.Ahead}) end
		builder:Update(windows, os.clock())
	end
	update()
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed >= Config.Streaming.UpdateInterval then elapsed = 0; update() end
	end)
	print("[World] Origin", frame.Origin, "Forward", frame.Forward, "GroundY", groundY,
		"FallenPartsDestroyHeight", workspace.FallenPartsDestroyHeight)
end

function World.TargetCount(position)
	local count = 0
	if not builder then return count end
	for _, section in pairs(builder.Active) do
		for _, zone in section:GetChildren() do
			if zone:IsA("BasePart") and zone:GetAttribute("LandingTarget") then
				local delta = position - zone.Position
				if Vector3.new(delta.X, 0, delta.Z).Magnitude <= 40 then count += 1 end
			end
		end
	end
	return count
end

function World.HazardHit(from,to)
	if SkyLife then return SkyLife.Hit(from,to) end
	return nil
end

function World.BreakSkyEnemy(player,model,visited)
 if SkyLife then return SkyLife.BreakEnemy(player,model,visited)end;return 0
end

function World.CollectSky(player,from,to,visited,onDestroyed)
	if SkyLife then return SkyLife.Collect(player,from,to,visited,onDestroyed)end;return 0
end

function World.GroundY()
	return frame and frame.GroundY or Config.GroundY or 0
end

function World.GetCloudOutpostObjective()
	for _, definition in ipairs(Config.Destinations) do
		if definition.Id == "CloudOutpost" then
			return {
				id = definition.Id,
				displayName = definition.DisplayName,
				requiredAltitude = definition.RequiredAltitude,
				groundY = World.GroundY(),
			}
		end
	end
	return nil
end

function World.SampleDestination(position, metrics, visited)
	if not frame then return nil end
	return Destination.Sample(frame, position, metrics, Config.Destinations, visited)
end

function World.ExitReason(position, velocity)
	if not frame then return nil end
	return Coordinates.ExitReason(frame, position, velocity, workspace.FallenPartsDestroyHeight, Config.Bounds)
end

return World
