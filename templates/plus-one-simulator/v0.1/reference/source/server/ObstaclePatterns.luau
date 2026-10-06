local Assets = require(script.Parent.AssetRegistry)
local Coordinates = require(script.Parent.WorldCoordinates)
local Obstacles = {}

-- Pure placement expansion: all distances, sizes and density come from LevelConfig.
function Obstacles.Placements(config)
	local result = {}
	for _, pattern in ipairs(config or {}) do
		local ok, err = pcall(function()
			assert(type(pattern.Id) == "string" and type(pattern.Key) == "string", "Missing obstacle id/key")
			for _, name in ipairs({"Start", "Lateral", "Height", "Width", "HeightSize", "Depth", "Count", "Spacing", "SideOffset", "Gap"}) do
				local n = pattern[name]
				assert(type(n) == "number" and n == n and math.abs(n) < math.huge, "Invalid " .. name)
			end
			assert(pattern.Count >= 1 and pattern.Count <= 32 and pattern.Count % 1 == 0
				and pattern.Spacing > 0 and pattern.Width > 0 and pattern.HeightSize > 0 and pattern.Depth > 0 and pattern.Gap > 0, "Invalid dimensions/count")
			assert(pattern.Pattern == "Single" or pattern.Pattern == "Alternating" or pattern.Pattern == "Choice", "Unknown pattern")
			for i = 1, pattern.Count do
				local function add(side, suffix)
					table.insert(result, {Id = pattern.Id .. ":" .. i .. ":" .. suffix, Key = pattern.Key,
						Pattern = pattern.Pattern, Distance = pattern.Start + (i - 1) * pattern.Spacing,
						Lateral = pattern.Lateral + side, Height = pattern.Height,
						Size = Vector3.new(pattern.Width, pattern.HeightSize, pattern.Depth)})
				end
				if pattern.Pattern == "Choice" then
					add(0, "Center")
					add(-(pattern.Width + pattern.Gap), "Left")
					add(pattern.Width + pattern.Gap, "Right")
				else
					add(pattern.Pattern == "Alternating" and (i % 2 == 1 and -1 or 1) * pattern.SideOffset or 0, "Block")
				end
			end
		end)
		if not ok then warn("[Obstacles] Skipped invalid pattern", err) end
	end
	return result
end

function Obstacles.Build(model, frame, plan, config, applyGimmick)
	for _, placement in ipairs(Obstacles.Placements(config)) do
		if placement.Distance < plan.Start or placement.Distance >= plan.Start + plan.Length then continue end
		local object
		local ok, err = pcall(function()
			object = Assets.Create(placement.Key)
			-- PHASE 4 uses box obstacles; a Model template cannot silently change the hit volume.
			if object and not object:IsA("BasePart") then object:Destroy(); object = Assets.Create("Test.Obstacle") end
			assert(object, "Obstacle asset unavailable")
			object.Name, object.Size = "FlightObstacle", placement.Size
			local position = Coordinates.Position(frame, placement.Distance, placement.Lateral, placement.Height)
			object.CFrame = CFrame.lookAt(position, position + frame.Forward)
			object.Anchored, object.CanCollide, object.CanTouch = true, false, true
			object:SetAttribute("ObstacleId", placement.Id)
			object:SetAttribute("ObstaclePattern", placement.Pattern)
			object.Touched:Connect(function(hit) applyGimmick(object, hit, "Bomb") end)
			object.Parent = model
		end)
		if not ok then
			if object then object:Destroy() end
			warn("[Obstacles] Skipped asset", placement.Id, err)
		end
	end
end

return Obstacles
