-- Server-only data catalogue. Keys are logical IDs, never Marketplace asset IDs.
-- Templates must be reviewed local Models/BaseParts in ServerStorage.AssetTemplates.
-- Geometry only: no reward, collision trigger or flight behavior is registered here.
local ServerStorage = game:GetService("ServerStorage")
local Registry = {}
local definitions = {
	["Landmark.CloudOutpost"] = {Category = "Landmark", Geometry = "CloudOutpost"},
	["Cloud.Bank"] = {Category = "Environment", Geometry = "CloudBank", Scale = 1,
		Color = Color3.fromRGB(242, 247, 252)},
	["Cloud.Wisp"] = {Category = "Environment", Geometry = "CloudBank", Scale = 0.65,
		Color = Color3.fromRGB(229, 239, 249)},
	["Test.Obstacle"] = {Category = "Obstacle", Size = Vector3.new(12, 12, 12), Color = Color3.fromRGB(220, 100, 80)},
	["Test.Ring"] = {Category = "Ring", Size = Vector3.new(20, 20, 2), Color = Color3.fromRGB(50, 220, 255)},
	["Test.Environment"] = {Category = "Environment", Size = Vector3.new(8, 16, 8), Color = Color3.fromRGB(70, 160, 100)},
	["Test.Landmark"] = {Category = "Landmark", Size = Vector3.new(10, 30, 10), Color = Color3.fromRGB(245, 190, 60)},
	["Test.LandingTarget"] = {Category = "LandingTarget", Size = Vector3.new(20, 1, 20), Color = Color3.fromRGB(80, 180, 240)},
	-- Optional, deliberately not installed or used by the current course.
	["Local.Landmark"] = {Category = "Landmark", Template = "Landmark",
		Size = Vector3.new(10, 30, 10), Color = Color3.fromRGB(245, 190, 60)},
}
for _, definition in pairs(definitions) do table.freeze(definition) end
Registry.Definitions = table.freeze(definitions)
local warned = {}
local function report(key, message)
	if warned[key] then return end
	warned[key] = true
	warn("[Assets]", key, message)
end

function Registry.Get(key)
	return type(key) == "string" and definitions[key] or nil
end

local function primitive(definition)
	if definition.Geometry == "CloudOutpost" then
		local model = Instance.new("Model")
		local stone, teal, gold = Color3.fromRGB(218, 213, 189), Color3.fromRGB(29, 87, 109), Color3.fromRGB(243, 180, 58)
		local function block(name, size, position, color, tilt)
			local part = Instance.new("Part")
			part.Name, part.Size = name, size
			part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(tilt or 0))
			part.Color, part.Material = color, Enum.Material.SmoothPlastic
			-- Decoration is noncolliding; only the existing deck below supports landing.
			part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
			part.Parent = model
			return part
		end
		block("FloatingFoundation", Vector3.new(126, 12, 104), Vector3.new(0, -39, 0), teal)
		local deck = block("SunlitDeck", Vector3.new(134, 4, 110), Vector3.new(0, -31, 0), teal)
		-- Reuse the existing deck and FlightService grounding/result flow.
		-- This is a landing surface, not a destructible target or new reward zone.
		deck.CanCollide, deck.CanQuery = true, true
		deck:SetAttribute("LandingSurface", true)
		local landingColor = Color3.fromRGB(65, 240, 235)
		for _, side in {-1, 1} do
			local beam = block("LandingBeacon", Vector3.new(3, 105, 3), Vector3.new(side * 48, 23, 36), landingColor)
			beam.Material, beam.Transparency = Enum.Material.Neon, 0.25
			block("LandingH", Vector3.new(3, 0.3, 34), Vector3.new(side * 12, -28.8, 10), landingColor).Material = Enum.Material.Neon
			block("LandingBorder", Vector3.new(90, 0.3, 2), Vector3.new(0, -28.8, 10 + side * 28), landingColor).Material = Enum.Material.Neon
		end
		block("LandingH", Vector3.new(27, 0.3, 3), Vector3.new(0, -28.8, 10), landingColor).Material = Enum.Material.Neon
		local gui = Instance.new("BillboardGui")
		gui.Size, gui.StudsOffset, gui.MaxDistance = UDim2.new(0, 220, 0, 44), Vector3.new(0, 65, 0), 1000
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
		label.Text, label.TextColor3, label.TextSize = "LAND HERE", landingColor, 22
		label.Font, label.TextStrokeTransparency = Enum.Font.GothamBold, 0.2
		label.Parent, gui.Parent = gui, deck
		block("LowerKeel", Vector3.new(92, 12, 78), Vector3.new(0, -51, 0), teal)
		block("KeelFin", Vector3.new(48, 16, 48), Vector3.new(0, -65, 0), gold)
		for _, side in ipairs({-1, 1}) do
			local x = side * 62
			block("ObservatoryTower", Vector3.new(16, 78, 22), Vector3.new(x, 10, -25), stone)
			block("TowerWindow", Vector3.new(12, 22, 1), Vector3.new(x, 25, -13.5), teal)
			block("GoldenRoof", Vector3.new(25, 8, 31), Vector3.new(x, 53, -25), gold)
			block("Spire", Vector3.new(5, 24, 5), Vector3.new(x, 69, -25), teal)
			block("Flag", Vector3.new(18, 10, 1), Vector3.new(x + side * 8, 73, -25), gold)
			block("SideBalustrade", Vector3.new(4, 12, 85), Vector3.new(side * 65, -23, 0), gold)
			block("SuspensionStrut", Vector3.new(7, 48, 9), Vector3.new(side * 37, -63, 0), stone, side * -35)
		end
		block("HighBridge", Vector3.new(116, 7, 16), Vector3.new(0, 41, -25), teal)
		block("BridgeCrest", Vector3.new(18, 18, 5), Vector3.new(0, 52, -16), gold, 45)
		for _, x in ipairs({-40, -20, 0, 20, 40}) do
			block("ApproachDeckStripe", Vector3.new(2, 0.3, 24), Vector3.new(x, -28.8, 33), gold)
		end
		model.WorldPivot = CFrame.new()
		return model
	end
	if definition.Geometry == "CloudBank" then
		local model = Instance.new("Model")
		-- Opaque, broad ellipsoids overlap into a bank; no transparent sphere stacks.
		local lobes = {
			{Vector3.new(0, 0, 0), Vector3.new(250, 34, 165)},
			{Vector3.new(-65, 8, -12), Vector3.new(145, 50, 125)},
			{Vector3.new(55, 13, 12), Vector3.new(170, 60, 130)},
			{Vector3.new(8, 5, -50), Vector3.new(175, 42, 105)},
		}
		for index, lobe in ipairs(lobes) do
			local part = Instance.new("Part")
			part.Name = "CloudMass_" .. index
			part.Size, part.CFrame = lobe[2] * definition.Scale, CFrame.new(lobe[1] * definition.Scale)
			part.Color, part.Material = definition.Color, Enum.Material.SmoothPlastic
			part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
			part.CastShadow, part.Transparency = false, 0
			-- Built-in mesh: stretched to the Part dimensions, no external asset/script.
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = Enum.MeshType.Sphere
			mesh.Parent = part
			part.Parent = model
		end
		model.WorldPivot = CFrame.new()
		return model
	end
	local part = Instance.new("Part")
	part.Size, part.Color = definition.Size, definition.Color
	part.Material = Enum.Material.SmoothPlastic
	if definition.Shape then part.Shape = definition.Shape end
	part.Transparency = definition.Transparency or 0
	if definition.CanQuery ~= nil then part.CanQuery = definition.CanQuery end
	if definition.CastShadow ~= nil then part.CastShadow = definition.CastShadow end
	part.Anchored, part.CanCollide, part.CanTouch = true, false, false
	return part -- Ring is a placeholder block, not a functional booster.
end

function Registry.Create(key)
	-- Always returns an unparented instance (or nil + reason if even fallback fails).
	-- No yielding/remote loading in LevelBuilder's streaming update.
	if type(key) ~= "string" or key == "" then return nil, "InvalidKey" end
	local definition = Registry.Get(key)
	local object, status = nil, "Primitive"
	if definition and definition.Template then
		local ok, err = pcall(function()
			local folder = ServerStorage:FindFirstChild("AssetTemplates")
			local template = folder and folder:FindFirstChild(definition.Template)
			assert(template and (template:IsA("Model") or template:IsA("BasePart")), "Missing or invalid local template")
			object = template:Clone()
			assert(object, "Template cannot be cloned")
			local parts = 0
			local function prepare(item)
				if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("ModuleScript") then
					item:Destroy() -- Before parenting; never execute template code.
				elseif item:IsA("BasePart") then
					parts += 1
					item.Anchored, item.CanCollide, item.CanTouch = true, false, false
				end
			end
			prepare(object)
			for _, item in object:GetDescendants() do prepare(item) end
			assert(parts > 0, "Template has no geometry")
		end)
		if ok then status = "Template"
		else
			if object then object:Destroy(); object = nil end
			report(key, tostring(err))
			status = "Fallback"
		end
	elseif not definition then
		report(key, "Unknown key; using primitive fallback")
		status = "Fallback"
	end
	if not object then
		local ok, value = pcall(primitive, definition or definitions["Test.Environment"])
		if not ok then report(key, tostring(value)); return nil, "FallbackFailed" end
		object = value
	end
	object.Name = key
	object:SetAttribute("LandingTarget", nil) -- Template metadata must not grant existing target rewards.
	object:SetAttribute("AssetKey", key)
	object:SetAttribute("AssetCategory", definition and definition.Category or "Environment")
	object:SetAttribute("AssetFallback", status == "Fallback")
	return object, status
end

return table.freeze(Registry)
