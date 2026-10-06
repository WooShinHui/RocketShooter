local Coordinates = require(script.Parent.WorldCoordinates)
local Course = require(script.Parent.CourseSection)
local Assets = require(script.Parent.AssetRegistry)
local Obstacles = require(script.Parent.ObstaclePatterns)
local Clouds = require(script.Parent.CloudSection)
local Destination = require(script.Parent.Destination)
local Builder = {}
Builder.__index = Builder

function Builder.Plans(config)
	local plans, ids = {}, {}
	for _, section in ipairs(config.Sections) do
		assert(section.Kind == "LandingLane", "[World] Unsupported section kind")
		assert(type(section.Id) == "string" and section.Id ~= "", "[World] Section needs an Id")
		for _, key in ipairs({"Start", "Length", "Width", "TileLength", "Height"}) do
			local n = section[key]
			assert(type(n) == "number" and n == n and math.abs(n) < math.huge, "[World] Invalid " .. key)
		end
		assert(section.Length > 0 and section.Width > 0 and section.TileLength > 0, "[World] Invalid section size")
		assert(math.ceil(section.Length / section.TileLength) <= 256, "[World] Split oversized sections")
		local count = section.RepeatCount or 1
		assert(count >= 1 and count <= 10000 and count % 1 == 0, "[World] Invalid repetition count")
		for i = 1, count do
			local plan = table.clone(section)
			plan.Id = section.Id .. "_" .. i
			assert(not ids[plan.Id], "[World] Duplicate section id")
			ids[plan.Id] = true
			plan.Start = section.Start + (i - 1) * section.Length
			table.insert(plans, plan)
		end
	end
	return plans
end

function Builder.new(parent, frame, config, applyGimmick)
	local plans = Builder.Plans(config) -- Validate before creating anything.
	assert(not parent:FindFirstChild("GeneratedWorld"), "[World] GeneratedWorld already exists; preserve it and resolve ownership first")
	local folder = Instance.new("Folder")
	folder.Name = "GeneratedWorld"
	folder:SetAttribute("Owner", "LevelBuilder")
	folder:SetAttribute("LayoutOrigin", frame.Origin)
	folder:SetAttribute("Forward", frame.Forward)
	folder.Parent = parent
	return setmetatable({Folder = folder, Frame = frame, Config = config,
		Plans = plans, Active = {}, UnneededSince = {}, ApplyGimmick = applyGimmick}, Builder)
end

function Builder:Build(plan)
	local model = Instance.new("Model")
	model.Name = plan.Id
	model:SetAttribute("StartDistance", plan.Start)
	model:SetAttribute("Length", plan.Length)
	model:SetAttribute("Kind", plan.Kind)
	for offset = 0, plan.Length - 0.001, plan.TileLength do
		local length = math.min(plan.TileLength, plan.Length - offset)
		local part = Instance.new("Part")
		part.Name = "Floor_" .. tostring(offset)
		part.Size = Vector3.new(plan.Width, 2, length)
		local position = Coordinates.Position(self.Frame, plan.Start + offset + length / 2, 0, plan.Height - 1)
		part.CFrame = CFrame.lookAt(position, position + self.Frame.Forward)
		part.Anchored, part.CanCollide, part.CanTouch = true, true, false
		part.Color = Color3.fromRGB(75, 105, 120)
		part.Material = Enum.Material.SmoothPlastic
		part.Parent = model
	end
	if plan.Course then Course.Build(model, self.Frame, plan, self.Config.Course, self.ApplyGimmick) end
	Obstacles.Build(model, self.Frame, plan, self.Config.Obstacles, self.ApplyGimmick)
	Clouds.Build(model, self.Frame, plan, self.Config.Clouds, self.Config.Destinations)
	Destination.Build(model, self.Frame, plan, self.Config.Destinations)
	-- Optional placements only. Existing CourseSection and Gimmicks keep ownership.
	if type(plan.Assets) == "table" then
		for _, placement in ipairs(plan.Assets) do
			local object
			local ok, err = pcall(function()
				assert(type(placement) == "table", "Asset placement must be a table")
				local offset, lateral, height = placement.Offset or 0, placement.Lateral or 0, placement.Height or 0
				for _, n in ipairs({offset, lateral, height}) do
					assert(type(n) == "number" and n == n and math.abs(n) < math.huge, "Invalid asset position")
				end
				local reason
				object, reason = Assets.Create(placement.Key)
				assert(object, reason)
				local position = Coordinates.Position(self.Frame, plan.Start + offset, lateral, height)
				object:PivotTo(CFrame.lookAt(position, position + self.Frame.Forward))
				object.Parent = model -- Section unload owns all asset cleanup.
			end)
			if not ok then
				if object then object:Destroy() end
				warn("[World] Skipped asset placement in", plan.Id, err)
			end
		end
	end
	model.Parent = self.Folder
	self.Active[plan.Id] = model
end

-- Windows are the UNION of all players, including those standing at a result screen.
function Builder:Update(windows, now)
	for _, plan in ipairs(self.Plans) do
		local wanted = false
		for _, window in ipairs(windows) do
			if plan.Start <= window[2] and plan.Start + plan.Length >= window[1] then wanted = true; break end
		end
		if wanted then
			self.UnneededSince[plan.Id] = nil
			if not self.Active[plan.Id] then self:Build(plan) end
		elseif self.Active[plan.Id] then
			self.UnneededSince[plan.Id] = self.UnneededSince[plan.Id] or now
			if now - self.UnneededSince[plan.Id] >= self.Config.Streaming.UnloadDelay then
				self.Active[plan.Id]:Destroy()
				self.Active[plan.Id], self.UnneededSince[plan.Id] = nil, nil
			end
		end
	end
end

return Builder
