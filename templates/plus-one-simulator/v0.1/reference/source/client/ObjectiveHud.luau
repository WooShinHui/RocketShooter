local RunService = game:GetService("RunService")
local ObjectiveHud = {}
local Cloud=require(game:GetService("ReplicatedStorage"):WaitForChild("CloudConfig",15))
local Layers=Cloud.HeightPresentation
local SimulatorHUD = require(game:GetService("ReplicatedStorage"):WaitForChild("SimulatorHUD", 15))

local function finite(value)
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function valid(meta)
	return type(meta) == "table" and meta.id == "CloudOutpost"
		and type(meta.displayName) == "string" and meta.displayName:match("%S") ~= nil
		and finite(meta.requiredAltitude) and meta.requiredAltitude > 0 and finite(meta.groundY)
end

function ObjectiveHud.new(playerGui)
	local old = playerGui:FindFirstChild("ObjectiveGui")
	if old then old:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name = "ObjectiveGui"
	gui.ResetOnSpawn = false
	gui.Enabled = false
	gui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Name = "AltitudeProgress"
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.new(0.5, 0, 0.95, 0)
	label.Size = UDim2.new(0.8, 0, 0, 65)
	label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	label.BackgroundTransparency = 0.15
	label.BorderSizePixel = 0
	label.TextColor3 = Color3.fromRGB(150, 220, 255)
	label.TextSize = 18
	label.Font = Enum.Font.SourceSansBold
	label.TextWrapped = true
	label.Text = ""
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label

	local altitudeLabel = SimulatorHUD.altitude(gui, label)
	local hud = {}
	local connection
	function hud.Stop()
		if connection then connection:Disconnect(); connection = nil end
		gui.Enabled = false
		label.Text = ""
		altitudeLabel.Text = ""
	end
	function hud.Start(root, objectiveMeta, isActive)
		hud.Stop()
		if not valid(objectiveMeta) then return nil end
		-- A scalar copy belongs to this run; no gameplay decisions are made here.
		objectiveMeta = {
			id = objectiveMeta.id, displayName = objectiveMeta.displayName,
			requiredAltitude = objectiveMeta.requiredAltitude, groundY = objectiveMeta.groundY,
		}
		local function update()
			if not root.Parent or not isActive() then hud.Stop(); return end
			local currentAltitude = root.Position.Y - objectiveMeta.groundY
			if not finite(currentAltitude) then hud.Stop(); return end
			altitudeLabel.Text = "Height "..Cloud.FormatAltitude(math.max(0,currentAltitude))
			local target
            for _,height in Layers.Milestones do if currentAltitude<height then target=height;break end end
            label.Text = if target then "Next Zone "..Cloud.FormatAltitude(target).." · "..Cloud.FormatAltitude(math.max(0,math.ceil(target-currentAltitude))).." remaining" else "Deep Space · Set a new height record!"
			gui.Enabled = true
		end
		connection = RunService.RenderStepped:Connect(update)
		update()
		return objectiveMeta
	end
	return hud
end

return ObjectiveHud
