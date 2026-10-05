-- Reusable gameplay HUD skin, inspired by reference-01's layout.
-- Presentation only: callers own state, visibility, purchases and input.
local RocketUI = require(script.Parent:WaitForChild("RocketUI"))
local HUD = { Version = "reference-01-clarity-v2", Colors = {
	Yellow = Color3.fromRGB(255, 218, 52), Blue = Color3.fromRGB(51, 155, 255),
	Coral = Color3.fromRGB(255, 95, 85), Green = Color3.fromRGB(65, 215, 145),
	Ink = Color3.fromRGB(20, 31, 50), White = Color3.fromRGB(255, 255, 255),
} }
local C = HUD.Colors
local Icons=require(script.Parent:WaitForChild("UIIcons"))

function HUD.text(label, size, color)
	label.Font = Enum.Font.GothamBlack
	label.TextSize = size
	label.TextColor3 = color or C.White
	label.TextStrokeColor3 = C.Ink
	label.TextStrokeTransparency = 0
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	return label
end

function HUD.screen(gui, order)
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = order or 20
	gui:SetAttribute("HUDTemplateVersion", HUD.Version)
end

function HUD.surface(frame, color)
	frame.BackgroundColor3 = color or C.Blue
	frame.BackgroundTransparency = 0
	frame.BorderSizePixel = 0
	RocketUI.util.applyCorner(frame, 10)
	RocketUI.util.applyStroke(frame, "Normal")
end

function HUD.button(button, color)
	HUD.surface(button, color)
	HUD.text(button, 24)
	button.BackgroundTransparency = 0
	button.TextWrapped = true
	-- Retain the original TextButton and Activated handlers.
end

-- Scale panels in place: direct child names used by FlightClient stay intact.
function HUD.fit(panel, width, height, onViewport)
	local scale = panel:FindFirstChild("SimulatorScale")
	if scale then return end
	scale = Instance.new("UIScale")
	scale.Name = "SimulatorScale"
	scale.Parent = panel
	local service = game:GetService("Workspace")
	local viewportConnection, cameraConnection, destroyConnection, safeAreaConnection
	local function update()
		local camera = service.CurrentCamera
		local viewport = if camera then camera.ViewportSize else Vector2.new(1280, 720)
		scale.Scale = math.clamp(math.min(viewport.X / (width + 32), viewport.Y / (height + 96)), 0.45, 1)
		if onViewport then onViewport(viewport) end
	end
	local function bind()
		if viewportConnection then viewportConnection:Disconnect() end
		local camera = service.CurrentCamera
		viewportConnection = if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(update) else nil
		update()
	end
	cameraConnection = service:GetPropertyChangedSignal("CurrentCamera"):Connect(bind)
	if onViewport and panel.Parent and panel.Parent:IsA("ScreenGui") then
		safeAreaConnection = panel.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
	end
	destroyConnection = panel.Destroying:Connect(function()
		cameraConnection:Disconnect()
		if viewportConnection then viewportConnection:Disconnect() end
		if safeAreaConnection then safeAreaConnection:Disconnect() end
		destroyConnection:Disconnect()
	end)
	bind()
end

-- Keep trophy text aligned with the menu header, without a background box.
function HUD.leftDockTop(viewport)
 return if viewport.X<700 and viewport.Y>=viewport.X then 210 elseif viewport.Y<500 then 70 else 104
end
function HUD.currency(gui)
 if not gui then return end;HUD.screen(gui,20)
 local label=gui:FindFirstChild("Balances");if not label then return end
 HUD.text(label,32,C.Yellow);label.TextXAlignment=Enum.TextXAlignment.Left
 label.AnchorPoint=Vector2.zero;label.Size=UDim2.fromOffset(232,44)
 local icon=Icons.Image(gui,"Trophy",UDim2.fromOffset(12,52),UDim2.fromOffset(40,40))
 label.TextSize=27
 HUD.fit(label,280,100,function(viewport)
  label.Position=UDim2.fromOffset(58,HUD.leftDockTop(viewport)-52);icon.Position=UDim2.fromOffset(12,HUD.leftDockTop(viewport)-50)
 end)
end

function HUD.shop(gui, frame)
	HUD.screen(gui, 21)
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.Position = UDim2.new(0.5, 0, 1, -20)
	frame.Size = UDim2.fromOffset(380, 68)
	frame.BackgroundTransparency = 1
	local stroke = frame:FindFirstChildOfClass("UIStroke")
	if stroke then stroke:Destroy() end
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("TextLabel") then child.Visible = false end
	end
	local gold, trophies = frame.BuyButtonGold, frame.BuyButtonTrophy
	gold.Position, gold.Size = UDim2.fromOffset(0, 0), UDim2.fromOffset(184, 68)
	trophies.Position, trophies.Size = UDim2.fromOffset(196, 0), UDim2.fromOffset(184, 68)
	HUD.button(gold, C.Yellow)
	HUD.button(trophies, C.Coral)
	HUD.fit(frame, 420, 200,function(v)
		frame.AnchorPoint=if v.Y<500 then Vector2.new(0,1) else Vector2.new(.5,1)
		frame.Position=if v.Y<500 then UDim2.new(0,12,1,-20) else UDim2.new(.5,0,1,-20)
	end)
end

function HUD.result(gui, frame)
	HUD.screen(gui, 50)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	HUD.surface(frame, C.Blue)
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("TextLabel") then HUD.text(child, child.TextSize) end
	end
	HUD.text(frame.TitleLabel, 26, C.Yellow)
	HUD.text(frame.RecordBadge, 18, C.Yellow)
	HUD.button(frame.ReturnButton, C.Green)
	frame.TitleLabel.Text="🚀 비행 결과"
	frame.ReturnButton.Text="↩ 발사장으로 돌아가기"
	frame.ReturnButton.Visible=false
    frame.ReturnButton.Size=UDim2.new(.9,0,0,72)
	frame.ReturnButton.Position=UDim2.new(.05,0,1,-86)
	frame.InfoLabel.TextSize=20
    frame.Size=UDim2.fromOffset(500,285)
    frame.InfoLabel.TextWrapped=true
	frame.InfoLabel.Size=UDim2.new(1,-24,0,205)
	frame.InfoLabel.Position=UDim2.fromOffset(12,66)
	frame.ObjectiveLabel.Position=UDim2.fromOffset(12,248)
	frame.ObjectiveLabel.Size=UDim2.new(1,-24,0,30)
	frame.ObjectiveLabel.TextSize=20
	HUD.fit(frame, 500, 285, function(viewport)
		-- Keep the result above the bottom upgrade buttons in the safe area.
		local safeHeight = gui.AbsoluteSize.Y
		if safeHeight <= 0 then safeHeight = viewport.Y end
		frame.Position = UDim2.new(0.5, 0, 0, safeHeight/2)
	end)
end

function HUD.altitude(gui, targetLabel)
	HUD.screen(gui, 22)
	local distance = Instance.new("TextLabel")
	distance.Name = "AltitudeValue"
	distance.AnchorPoint = Vector2.new(0.5, 0)
	distance.Position = UDim2.new(0.5, 0, 0, 8)
	distance.Size = UDim2.fromOffset(350, 64)
	HUD.text(distance, 48, C.Yellow)
	distance.Parent = gui
	HUD.fit(distance, 350, 100)
	HUD.text(targetLabel, 18)
	targetLabel.AnchorPoint = Vector2.new(0.5, 0)
	targetLabel.Position = UDim2.new(0.5, 0, 0, 78)
	targetLabel.Size = UDim2.new(0.85, 0, 0, 46)
	return distance
end

function HUD.fuel(gui, frame, status, note, bonus, button, track, fill)
	HUD.screen(gui, 23)
	frame.Name = "GrowthPanel"
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.Position = UDim2.new(0.5, 0, 1, -110)
	frame.Size = UDim2.fromOffset(400, 178)
	frame.BackgroundTransparency = 1
	HUD.text(status, 18, C.Yellow)
	status.Position, status.Size = UDim2.fromOffset(0, 0), UDim2.fromOffset(280, 32)
	HUD.text(bonus, 16, C.Yellow)
	bonus.Position, bonus.Size = UDim2.fromOffset(280, 0), UDim2.fromOffset(120, 32)
	track.Name = "FuelProgress"
	track.Position, track.Size = UDim2.fromOffset(0, 40), UDim2.fromOffset(400, 30)
	track.ClipsDescendants = true
	HUD.surface(track, C.Ink)
	fill.Name = "Fill"
	fill.BackgroundColor3 = C.Blue
	RocketUI.util.applyCorner(fill, 8)
	-- Decorative segmentation is independent of real fuel progress.
	for i = 1, 11 do
		local line = Instance.new("Frame")
		line.Name = "Segment" .. i
		line.Position, line.Size = UDim2.new(i / 12, -1, 0, 0), UDim2.new(0, 2, 1, 0)
		line.BackgroundColor3, line.BackgroundTransparency = C.White, 0.55
		line.BorderSizePixel, line.ZIndex = 0, fill.ZIndex + 1
		line.Parent = track
	end
	button.Name = "PowerUpButton"
	button.Position, button.Size = UDim2.fromOffset(0, 80), UDim2.fromOffset(400, 68)
	HUD.button(button, C.Green)
	HUD.text(note, 14)
	note.Position, note.Size = UDim2.fromOffset(0, 152), UDim2.fromOffset(400, 24)
	note.TextWrapped = true
	HUD.fit(frame, 440, 284, function(viewport)
		local small=viewport.X<700 or viewport.Y<500
		if small then
			local portrait=viewport.Y>=viewport.X
			frame.AnchorPoint=if portrait then Vector2.new(1,0) else Vector2.new(0,0)
			frame.Position=if portrait then UDim2.new(1,-12,0,210) else UDim2.fromOffset(12,84)
			frame.Size=UDim2.fromOffset(180,210)
			status.Position=UDim2.fromOffset(0,0);status.Size=UDim2.fromOffset(180,30)
			bonus.Position=UDim2.fromOffset(0,32);bonus.Size=UDim2.fromOffset(180,30)
			track.Position=UDim2.fromOffset(0,68);track.Size=UDim2.fromOffset(180,22)
			button.Position=UDim2.fromOffset(0,98);button.Size=UDim2.fromOffset(180,80);button.TextSize=18;note.Visible=false
		else
			frame.AnchorPoint=Vector2.new(.5,1);frame.Position=UDim2.new(.5,0,1,-110);frame.Size=UDim2.fromOffset(400,178)
			status.Position=UDim2.fromOffset(0,0);status.Size=UDim2.fromOffset(280,32)
			bonus.Position=UDim2.fromOffset(280,0);bonus.Size=UDim2.fromOffset(120,32)
			track.Position=UDim2.fromOffset(0,40);track.Size=UDim2.fromOffset(400,30)
			button.Position=UDim2.fromOffset(0,80);button.Size=UDim2.fromOffset(400,68);button.TextSize=20;note.Visible=true
		end
	end)
end

return HUD
