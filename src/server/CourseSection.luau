local Coordinates = require(script.Parent.WorldCoordinates)
local Trajectory = require(script.Parent.LaunchTrajectory)
local Course = {}

function Course.RingPlacements(frame, config, gravity)
	local route = config.RingTrajectory
	local placements = {}
	if not route or not frame.RingMuzzle then return placements end
	for _, distance in ipairs(route.Distances) do
		local position, tangent = Trajectory.AtForward(frame, frame.RingMuzzle,
			route.PowerLevel, route.Timing, gravity, distance)
		if position and position.Y > frame.GroundY + config.RingRadius then
			table.insert(placements, {Distance = distance, Position = position, Direction = tangent.Unit})
		end
	end
	return placements
end

function Course.Build(model, frame, plan, config, applyGimmick)
	local function part(name, distance, side, height, size, color)
		local object = Instance.new("Part")
		object.Name, object.Size, object.Color = name, size, color
		local position = Coordinates.Position(frame, distance, side, height)
		object.CFrame = CFrame.lookAt(position, position + frame.Forward)
		object.Anchored, object.CanCollide, object.CanTouch = true, false, false
		object.Material = Enum.Material.SmoothPlastic
		object.Parent = model
		return object
	end
	local green, blue, orange = Color3.fromRGB(104, 185, 114), Color3.fromRGB(52, 216, 231), Color3.fromRGB(255, 125, 62)
	for _, tile in model:GetChildren() do tile.Color = green; tile.Material = Enum.Material.Grass end
	local middle = plan.Start + plan.Length / 2
	-- An open center lane and low roadside scenery; no invisible flight walls.
	part("Runway", middle, 0, plan.Height + 0.03, Vector3.new(90, 0.05, plan.Length), Color3.fromRGB(67, 96, 114))
	for side = -1, 1, 2 do
		part("LaneEdge", middle, side * 46, plan.Height + 0.08, Vector3.new(1, 0.1, plan.Length), blue)
		for offset = 32, plan.Length - 1, 128 do
			local d = plan.Start + offset
			local trunk = part("TreeTrunk", d, side * 155, plan.Height + 5, Vector3.new(3, 10, 3), Color3.fromRGB(116, 82, 59))
			trunk.CanCollide = true
			local crown = part("TreeCrown", d, side * 155, plan.Height + 13, Vector3.new(18, 18, 18), Color3.fromRGB(50, 142, 95))
			crown.Shape = Enum.PartType.Ball
		end
	end
	local function each(start, last, step, callback)
		for d = start, last, step do
			if d >= plan.Start and d < plan.Start + plan.Length then callback(d, math.floor((d - start) / step)) end
		end
	end
	for _, placement in ipairs(Course.RingPlacements(frame, config, workspace.Gravity)) do
		local d = placement.Distance
		if d < plan.Start or d >= plan.Start + plan.Length then continue end
		local side = 0
		local height = placement.Position.Y - frame.GroundY
		local radius = config.RingRadius
		-- Ring arcs lie in local XY, so the hole's normal is local -Z/LookVector.
		local ringFrame = CFrame.lookAt(placement.Position, placement.Position + placement.Direction)
		for i = 0, 15 do
			local angle = i * math.pi / 8
			local segment = part("RingArc", d, side, height, Vector3.new(radius * 0.4, 2, 2), blue)
			segment.CFrame = ringFrame * CFrame.Angles(0, 0, angle) * CFrame.new(0, radius, 0)
			segment.Material = Enum.Material.Neon
		end
		local trigger = part("BoosterRing", d, side, height, Vector3.new(radius * 2 - 4, radius * 2 - 4, 5), blue)
		trigger.CFrame = ringFrame -- Trigger plane and visual aperture share the tangent.
		trigger:SetAttribute("ExpectedDirection", placement.Direction)
		trigger.Transparency, trigger.CanTouch, trigger.CanQuery = 1, true, false
		trigger.Touched:Connect(function(hit) applyGimmick(trigger, hit, "Ring") end)
	end
	each(config.BombStart, config.BombEnd, config.BombSpacing, function(d, index)
		local bomb = part("ObstacleBomb", d, index % 2 == 0 and 48 or -48, config.BombHeight, Vector3.new(14, 14, 14), orange)
		bomb.Shape, bomb.Material, bomb.CanTouch = Enum.PartType.Ball, Enum.Material.Neon, true
		bomb.Touched:Connect(function(hit) applyGimmick(bomb, hit, "Bomb") end)
	end)
	each(config.TargetStart, config.TargetEnd, config.TargetSpacing, function(d)
		local target = part("TargetZone", d, 0, plan.Height + 0.12, Vector3.new(70, 0.2, 70), Color3.fromRGB(29, 87, 109))
		target:SetAttribute("LandingTarget", true)
		local landingColor = Color3.fromRGB(65, 240, 235)
		for _, side in {-1, 1} do
			local beam = part("LandingBeacon", d, side * 32, plan.Height + 21, Vector3.new(2, 42, 2), landingColor)
			beam.Material, beam.Transparency = Enum.Material.Neon, 0.25
			part("LandingBorder", d + side * 33, 0, plan.Height + 0.25, Vector3.new(68, 0.1, 2), landingColor).Material = Enum.Material.Neon
			part("LandingH", d, side * 12, plan.Height + 0.25, Vector3.new(3, 0.1, 30), landingColor).Material = Enum.Material.Neon
		end
		part("LandingH", d, 0, plan.Height + 0.25, Vector3.new(27, 0.1, 3), landingColor).Material = Enum.Material.Neon
		local gui = Instance.new("BillboardGui")
		gui.Size, gui.StudsOffset, gui.MaxDistance = UDim2.new(0, 210, 0, 40), Vector3.new(0, 44, 0), 750
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
		label.Text, label.TextColor3, label.TextSize = "LAND HERE · 착륙", landingColor, 20
		label.Font, label.TextStrokeTransparency = Enum.Font.GothamBold, 0.2
		label.Parent, gui.Parent = gui, target
	end)
	for d = math.ceil(math.max(0, plan.Start) / 100) * 100, plan.Start + plan.Length - 1, 100 do
		local sign = part("DistanceMarker", d, -65, plan.Height + 9, Vector3.new(28, 9, 1), Color3.fromRGB(32, 55, 75))
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Back
		gui.Parent = sign
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
		label.Text, label.TextScaled = tostring(d) .. " m", true
		label.Font, label.TextColor3 = Enum.Font.GothamBold, Color3.fromRGB(255, 255, 255)
		label.Parent = gui
	end
end

return Course
