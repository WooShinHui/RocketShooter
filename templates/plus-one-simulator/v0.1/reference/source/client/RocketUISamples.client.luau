-- Studio 검수 전용. 더미 값만 표시하며 기존 HUD/게임 모듈을 사용하지 않는다.
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RocketUI = require(ReplicatedStorage:WaitForChild("RocketUI"))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name, gui.Enabled, gui.ResetOnSpawn = "RocketUISamples", false, false
gui.DisplayOrder, gui.ZIndexBehavior = 100, Enum.ZIndexBehavior.Sibling
local root = RocketUI.applyResponsiveScale(gui)

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Samples"
scroll.AnchorPoint, scroll.Position = Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, -32)
scroll.Size = UDim2.new(1, -64, 1, -192)
scroll.BackgroundColor3 = RocketUI.tokens.Colors.PanelBg
scroll.BorderSizePixel, scroll.ScrollBarThickness = 0, 8
scroll.CanvasSize, scroll.AutomaticCanvasSize = UDim2.fromScale(0, 0), Enum.AutomaticSize.Y
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Parent = root
RocketUI.util.applyCorner(scroll, RocketUI.tokens.Corner.Medium)
RocketUI.util.applyStroke(scroll, "Normal")
local padding = Instance.new("UIPadding")
padding.PaddingTop, padding.PaddingBottom = UDim.new(0, 16), UDim.new(0, 24)
padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 16), UDim.new(0, 24)
padding.Parent = scroll
local layout = Instance.new("UIListLayout")
layout.Padding, layout.SortOrder = UDim.new(0, 16), Enum.SortOrder.LayoutOrder
layout.Parent = scroll
local order = 0
local function add(object)
	order += 1
	object.LayoutOrder = order
	return object
end
local function text(parent, value)
	local label = Instance.new("TextLabel")
	label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
	label.Text, label.TextWrapped = value, true
	label.FontFace = RocketUI.tokens.Fonts.Body.FontFace
	label.TextSize, label.TextColor3 = 20, RocketUI.tokens.Colors.TextWhite
	label.ZIndex, label.Parent = 3, parent
	return label
end
local create, colors = RocketUI.create, RocketUI.tokens.Colors
text(add(create.panel({ Size = UDim2.new(1, 0, 0, 112), Parent = scroll })), "RocketUI Showcase · Toggle F8\nDummy data · Default theme · Placeholder icons")
for _, entry in ipairs({ {"Default Panel", colors.PanelBg}, {"Light Panel", colors.PanelBgLight}, {"Dark Panel", colors.StrokeDark} }) do
	text(add(create.panel({ Size = UDim2.new(1, 0, 0, 88), Color = entry[2], Parent = scroll })), entry[1])
end
local status = text(add(create.panel({ Size = UDim2.new(1, 0, 0, 88), Parent = scroll })), "Click a button to preview its animation")
for _, entry in ipairs({ {"Primary Button", colors.Primary}, {"Secondary Button", colors.Secondary}, {"Success Button", colors.Success}, {"Danger Button", colors.Danger} }) do
	local title = entry[1]
	add(create.button({ Size = UDim2.new(1, 0, 0, 88), Text = title, Color = entry[2], OnClick = function() status.Text = title .. " clicked" end, Parent = scroll }))
end
add(create.button({ Size = UDim2.new(1, 0, 0, 88), Text = "Disabled Button", Color = colors.PanelBgLight, Disabled = true, Parent = scroll }))
for _, progress in ipairs({ 0.25, 0.5, 0.75, 1 }) do
	add(create.progressBar({ Size = UDim2.new(1, 0, 0, 48), Progress = progress, Parent = scroll }))
end
for _, entry in ipairs({ {"Gold", 12500}, {"Trophy", 42}, {"Fuel", 75} }) do
	add(create.currencyBadge({ Size = UDim2.new(1, 0, 0, 72), CurrencyName = entry[1], Value = entry[2], Parent = scroll }))
end
add(create.statBadge({ Size = UDim2.new(1, 0, 0, 100), Label = "Launch Power", Value = "Lv.5", Parent = scroll }))
add(create.statBadge({ Size = UDim2.new(1, 0, 0, 100), Label = "Distance", Value = "1,234m", Parent = scroll }))
add(create.objectiveBanner({ Size = UDim2.new(1, 0, 0, 144), Position = UDim2.fromScale(0, 0), AnchorPoint = Vector2.zero, Text = "Reach the Cloud Outpost!", SubText = "Launch toward higher places", Parent = scroll }))
add(create.upgradeButton({ Size = UDim2.new(1, 0, 0, 260), StatName = "Launch Power", CurrentLevel = 5, Cost = 1200, OnClick = function() status.Text = "Upgrade preview · No purchase" end, Parent = scroll }))
local popup
add(create.button({ Size = UDim2.new(1, 0, 0, 88), Text = "Open Popup Preview", Parent = scroll, OnClick = function()
	if popup then return end
	popup = create.popup({ Title = "New Destination", Body = "Cloud Outpost reached!\nPreview with dummy data.", Parent = root })
	popup.Destroying:Connect(function() popup = nil end)
end }))
local close = create.button({ Size = UDim2.fromOffset(180, 88), Position = UDim2.new(1, -32, 1, -16), AnchorPoint = Vector2.new(1, 1), Text = "Close Showcase", FontStyle = "Caption", Parent = root, OnClick = function() gui.Enabled = false end })
close.Name = "CloseSamples"
local inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
	if processed or UserInputService:GetFocusedTextBox() then return end
	if input.KeyCode == Enum.KeyCode.F8 then gui.Enabled = not gui.Enabled end
end)
local enabledConnection = gui:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not gui.Enabled and popup then popup:Destroy() end
end)
gui.Destroying:Connect(function() inputConnection:Disconnect(); enabledConnection:Disconnect() end)
gui.Parent = playerGui
