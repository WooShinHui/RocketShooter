-- 프레젠테이션 전용 모듈. 게임 상태와 저장 데이터에는 접근하지 않는다.
local TweenService = game:GetService("TweenService")
local RocketUI = { tokens = {}, create = {}, util = {} }
local tokens, create, util = RocketUI.tokens, RocketUI.create, RocketUI.util
tokens.Colors = {
	Primary = Color3.fromRGB(50, 130, 255), PrimaryDark = Color3.fromRGB(30, 90, 200),
	Secondary = Color3.fromRGB(255, 200, 50), SecondaryDark = Color3.fromRGB(200, 150, 20),
	Success = Color3.fromRGB(80, 200, 80), Danger = Color3.fromRGB(230, 60, 60),
	PanelBg = Color3.fromRGB(30, 30, 50), PanelBgLight = Color3.fromRGB(45, 45, 70),
	TextWhite = Color3.fromRGB(255, 255, 255), TextDark = Color3.fromRGB(20, 20, 30),
	TextMuted = Color3.fromRGB(180, 180, 200), StrokeDark = Color3.fromRGB(10, 10, 20),
	StrokeLight = Color3.fromRGB(255, 255, 255), Gold = Color3.fromRGB(255, 215, 0),
	Trophy = Color3.fromRGB(200, 160, 255), Fuel = Color3.fromRGB(255, 100, 50),
}
tokens.Fonts = {
	Heading = { FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold), TextSize = 28 },
	Body = { FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold), TextSize = 20 },
	Caption = { FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium), TextSize = 14 },
}
tokens.Corner = { Small = 6, Medium = 10, Large = 16, Pill = 999 }
tokens.Stroke = {}
for name, thickness in pairs({ Thin = 2, Normal = 3, Thick = 4 }) do
	tokens.Stroke[name] = { Thickness = thickness, Color = tokens.Colors.StrokeDark, Transparency = 0 }
end
tokens.Gradient = {
	PanelShine = { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 220)), Transparency = NumberSequence.new(0.85, 0.95), Rotation = 90 },
	ButtonShine = { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(180, 180, 200)), Transparency = NumberSequence.new(0.6, 0.9), Rotation = 90 },
}
tokens.Spacing = { XS = 4, SM = 8, MD = 12, LG = 16, XL = 24 }
tokens.Animation = { ButtonHoverScale = 1.05, ButtonPressScale = 0.95, TweenSpeed = 0.15, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out }
tokens.SafeArea = { Top = 48, Bottom = 16, Left = 16, Right = 16 }

local function new(className, props, parent)
	local object = Instance.new(className)
	for key, value in pairs(props) do object[key] = value end
	object.Parent = parent
	return object
end
local function placement(object, props, defaultSize)
	object.Size = props.Size or defaultSize
	object.Position = props.Position or UDim2.fromScale(0, 0)
	object.AnchorPoint = props.AnchorPoint or Vector2.zero
	object.BorderSizePixel = 0
end
function util.applyCorner(object, radius)
	local corner = object:FindFirstChildOfClass("UICorner") or new("UICorner", {}, object)
	corner.CornerRadius = UDim.new(0, radius or tokens.Corner.Medium)
	return corner
end
function util.applyStroke(object, style)
	local def = tokens.Stroke[style or "Normal"]
	assert(def, "알 수 없는 StrokeStyle")
	local stroke = object:FindFirstChildOfClass("UIStroke") or new("UIStroke", {}, object)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness, stroke.Color, stroke.Transparency = def.Thickness, def.Color, def.Transparency
	return stroke
end
function util.applyGradient(object, def)
	def = def or tokens.Gradient.PanelShine
	local gradient = object:FindFirstChildOfClass("UIGradient") or new("UIGradient", {}, object)
	gradient.Color, gradient.Transparency, gradient.Rotation = def.Color, def.Transparency, def.Rotation
	return gradient
end
local function decorate(object, props, gradient)
	util.applyCorner(object, props.CornerRadius)
	util.applyStroke(object, props.StrokeStyle)
	if props.Gradient ~= false then
		-- 투명 하이라이트는 별도 레이어에 그려 바탕색이 사라지지 않게 한다.
		local shine = new("Frame", { Name = "Shine", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = object.ZIndex }, object)
		util.applyCorner(shine, props.CornerRadius)
		util.applyGradient(shine, gradient)
	end
end
local function label(parent, name, text, style, size, position)
	local font = tokens.Fonts[style or "Body"]
	return new("TextLabel", { Name = name, Text = tostring(text), FontFace = font.FontFace, TextSize = font.TextSize,
		TextColor3 = tokens.Colors.TextWhite, TextWrapped = true, BackgroundTransparency = 1,
		Size = size or UDim2.fromScale(1, 1), Position = position or UDim2.fromScale(0, 0), ZIndex = parent.ZIndex + 2 }, parent)
end
local function icon(parent, image, color, size, position)
	local object = new("ImageLabel", { Name = "Icon", Image = image or "", Size = size, Position = position or UDim2.fromScale(0, 0),
		BackgroundColor3 = color, BackgroundTransparency = if image then 1 else 0, BorderSizePixel = 0, ZIndex = parent.ZIndex + 2 }, parent)
	util.applyCorner(object, tokens.Corner.Pill)
	new("UIAspectRatioConstraint", { AspectRatio = 1 }, object)
	return object
end
local function tween(object, properties, speed)
	local animation = TweenService:Create(object, TweenInfo.new(speed or tokens.Animation.TweenSpeed, tokens.Animation.EasingStyle, tokens.Animation.EasingDirection), properties)
	animation:Play()
	return animation
end
function util.tweenHover(button, enterScale, leaveScale, speed)
	local scale = button:FindFirstChildOfClass("UIScale") or new("UIScale", {}, button)
	local baseColor, hovered, pressed = button.BackgroundColor3, false, false
	local connections, scaleTween, colorTween = {}, nil, nil
	local function update()
		local enabled = button.Interactable
		local target = if enabled and pressed then tokens.Animation.ButtonPressScale elseif enabled and hovered then (enterScale or tokens.Animation.ButtonHoverScale) else (leaveScale or 1)
		if scaleTween then scaleTween:Cancel() end
		if colorTween then colorTween:Cancel() end
		scaleTween = tween(scale, { Scale = target }, speed)
		colorTween = tween(button, { BackgroundColor3 = if enabled and pressed then baseColor:Lerp(tokens.Colors.StrokeDark, 0.2) else baseColor }, speed)
	end
	local function connect(signal, callback) table.insert(connections, signal:Connect(callback)) end
	connect(button.MouseEnter, function() hovered = true; update() end)
	connect(button.MouseLeave, function() hovered = false; pressed = false; update() end)
	connect(button.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then pressed = true; update() end
	end)
	-- 영역 밖에서 놓은 터치/클릭도 원복한다. 전역 입력 구독은 사용하지 않는다.
	connect(button.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then pressed = false; update() end
	end)
	connect(button:GetPropertyChangedSignal("Interactable"), function() pressed = false; update() end)
	local cleaned = false
	local function cleanup()
		if cleaned then return end
		cleaned = true
		for _, connection in ipairs(connections) do connection:Disconnect() end
		if scaleTween then scaleTween:Cancel() end
		if colorTween then colorTween:Cancel() end
	end
	connect(button.Destroying, cleanup)
	return cleanup
end
function util.formatNumber(value)
	assert(type(value) == "number" and value == value and math.abs(value) < math.huge, "유한한 숫자가 필요합니다")
	local magnitude, sign = math.abs(value), if value < 0 then "-" else ""
	for _, unit in ipairs({ {1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"} }) do
		if magnitude >= unit[1] then return sign .. string.format("%.1f", magnitude / unit[1]):gsub("%.0$", "") .. unit[2] end
	end
	return sign .. tostring(math.floor(magnitude + 0.5))
end
function util.formatCurrency(value, currencyName)
	return util.formatNumber(value) .. " " .. currencyName
end
function create.panel(props)
	local frame = new("Frame", { Name = "Panel", BackgroundColor3 = props.Color or tokens.Colors.PanelBg })
	placement(frame, props, UDim2.fromScale(1, 1))
	decorate(frame, props)
	new("UIPadding", { PaddingTop = UDim.new(0, tokens.Spacing.MD), PaddingBottom = UDim.new(0, tokens.Spacing.MD), PaddingLeft = UDim.new(0, tokens.Spacing.MD), PaddingRight = UDim.new(0, tokens.Spacing.MD) }, frame)
	frame.Parent = props.Parent
	return frame
end
function create.button(props)
	local button = new("TextButton", { Name = "Button", BackgroundColor3 = props.Color or tokens.Colors.Primary,
		Text = "", AutoButtonColor = false, Interactable = props.Disabled ~= true })
	placement(button, props, UDim2.fromOffset(220, 88))
	-- 0.55 배율에서 눌림 배율 0.95까지 적용되어도 44px 이상 유지한다.
	new("UISizeConstraint", { MinSize = Vector2.new(85, 85) }, button)
	decorate(button, props, tokens.Gradient.ButtonShine)
	local bevel = new("Frame", { Name = "Bevel", Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 1, -4), BackgroundColor3 = button.BackgroundColor3:Lerp(tokens.Colors.StrokeDark, 0.35), BorderSizePixel = 0, ZIndex = button.ZIndex + 1 }, button)
	util.applyCorner(bevel, props.CornerRadius)
	local text = label(button, "TextLabel", props.Text, props.FontStyle, if props.Icon then UDim2.fromScale(0.72, 1) else UDim2.fromScale(1, 1), if props.Icon then UDim2.fromScale(0.26, 0) else nil)
	text.TextColor3 = props.TextColor or tokens.Colors.TextWhite
	if props.Icon then icon(button, props.Icon, tokens.Colors.Secondary, UDim2.fromScale(0.18, 0.55), UDim2.fromScale(0.04, 0.22)) end
	if props.Disabled then text.TextTransparency = 0.5 end
	util.tweenHover(button)
	if props.OnClick then button.Activated:Connect(function() if button.Interactable then props.OnClick() end end) end
	button.Parent = props.Parent
	return button
end
function util.setProgress(bar, value)
	assert(type(value) == "number" and value == value and math.abs(value) < math.huge, "유한한 진행도가 필요합니다")
	local progress = math.clamp(value, 0, 1)
	bar.Fill.Size = UDim2.fromScale(progress, 1)
	local text = bar:FindFirstChild("ValueLabel")
	if text then text.Text = string.format("%d%%", math.floor(progress * 100 + 0.5)) end
	bar:SetAttribute("Progress", progress)
end
function create.progressBar(props)
	local bar = new("Frame", { Name = "ProgressBar", BackgroundColor3 = props.BackgroundColor or tokens.Colors.PanelBgLight, ClipsDescendants = true })
	placement(bar, props, UDim2.new(1, 0, 0, 48))
	decorate(bar, props)
	local fill = new("Frame", { Name = "Fill", BackgroundColor3 = props.FillColor or tokens.Colors.Success, BorderSizePixel = 0, ZIndex = bar.ZIndex + 1 }, bar)
	util.applyCorner(fill, props.CornerRadius)
	util.applyGradient(fill, { Color = tokens.Gradient.ButtonShine.Color, Transparency = NumberSequence.new(0), Rotation = 90 })
	if props.ShowLabel ~= false then label(bar, "ValueLabel", "", "Body") end
	util.setProgress(bar, props.Progress)
	bar.Parent = props.Parent
	return bar
end
function create.currencyBadge(props)
	local frame = create.panel({ Size = props.Size or UDim2.fromOffset(260, 64), Position = props.Position, AnchorPoint = props.AnchorPoint, Color = props.Color or tokens.Colors.PanelBg, Parent = props.Parent })
	frame.Name = "CurrencyBadge"
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, tokens.Spacing.SM), SortOrder = Enum.SortOrder.LayoutOrder }, frame)
	icon(frame, props.IconId, tokens.Colors[props.CurrencyName] or tokens.Colors.Secondary, UDim2.fromOffset(36, 36)).LayoutOrder = 1
	local text = label(frame, "ValueLabel", if type(props.Value) == "number" then util.formatNumber(props.Value) else props.Value, "Body", UDim2.new(1, -44, 1, 0))
	text.LayoutOrder, text.TextXAlignment = 2, Enum.TextXAlignment.Left
	frame:SetAttribute("CurrencyName", props.CurrencyName)
	return frame
end
function create.statBadge(props)
	local frame = create.panel({ Size = props.Size or UDim2.fromOffset(240, 100), Position = props.Position, AnchorPoint = props.AnchorPoint, Color = props.Color, Parent = props.Parent })
	frame.Name = "StatBadge"
	local left = if props.IconId then 0.22 else 0
	if props.IconId then icon(frame, props.IconId, tokens.Colors.Primary, UDim2.fromScale(0.16, 0.5), UDim2.fromScale(0, 0.25)) end
	label(frame, "Label", props.Label, "Caption", UDim2.fromScale(1 - left, 0.35), UDim2.fromScale(left, 0)).TextColor3 = tokens.Colors.TextMuted
	label(frame, "ValueLabel", props.Value, "Body", UDim2.fromScale(1 - left, 0.65), UDim2.fromScale(left, 0.35))
	return frame
end
function create.objectiveBanner(props)
	local frame = create.panel({ Size = props.Size or UDim2.new(0.8, 0, 0, 120), Position = props.Position or UDim2.new(0.5, 0, 0, tokens.SafeArea.Top), AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0), Color = props.Color or tokens.Colors.Primary, Parent = props.Parent })
	frame.Name = "ObjectiveBanner"
	icon(frame, props.IconId, tokens.Colors.Secondary, UDim2.fromOffset(48, 48), UDim2.new(0, 0, 0.5, -24))
	label(frame, "TextLabel", props.Text, "Body", UDim2.new(1, -64, if props.SubText then 0.6 else 1, 0), UDim2.fromOffset(64, 0))
	if props.SubText then label(frame, "SubText", props.SubText, "Caption", UDim2.new(1, -64, 0.4, 0), UDim2.new(0, 64, 0.6, 0)) end
	return frame
end

-- Instance에는 사용자 정의 메서드를 넣을 수 없으므로 util.closePopup(frame)를 사용한다.
local popupClosers = setmetatable({}, { __mode = "k" })
function util.closePopup(popup)
	local close = popupClosers[popup]
	if close then close() end
end
function create.popup(props)
	local parent = props.Parent
	local ownedGui
	if not parent or parent:IsA("PlayerGui") then
		parent = parent or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		ownedGui = new("ScreenGui", { Name = "RocketUIPopup", ResetOnSpawn = false, DisplayOrder = 101, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets }, parent)
		parent = RocketUI.applyResponsiveScale(ownedGui)
	end
	local overlay = new("Frame", { Name = "Popup", Size = UDim2.fromScale(1, 1), BackgroundColor3 = tokens.Colors.StrokeDark, BackgroundTransparency = 0.35, BorderSizePixel = 0, Active = true, ZIndex = 50 }, parent)
	new("TextButton", { Name = "InputBlocker", Text = "", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, AutoButtonColor = false, ZIndex = 50 }, overlay)
	local panel = create.panel({ Size = props.Size or UDim2.fromScale(0.85, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Parent = overlay })
	panel.ZIndex = 51
	panel.Shine.ZIndex = 51
	label(panel, "Title", props.Title, "Heading", UDim2.fromScale(1, 0.2))
	label(panel, "Body", props.Body or "", "Body", UDim2.fromScale(1, 0.43), UDim2.fromScale(0, 0.2))
	local row = new("ScrollingFrame", { Name = "Buttons", Size = UDim2.fromScale(1, 0.32), Position = UDim2.fromScale(0, 0.68), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.fromScale(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 4, ZIndex = 52 }, panel)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, tokens.Spacing.MD), SortOrder = Enum.SortOrder.LayoutOrder }, row)
	local buttons = props.Buttons or { { Text = "Close", OnClick = function() util.closePopup(overlay) end } }
	for index, def in ipairs(buttons) do
		local button = create.button({ Text = def.Text, Color = def.Color, Size = UDim2.new(1 / math.max(1, #buttons), -tokens.Spacing.MD, 1, -8), OnClick = def.OnClick, Parent = row })
		button.LayoutOrder, button.ZIndex = index, 53
		for _, child in ipairs(button:GetDescendants()) do if child:IsA("GuiObject") then child.ZIndex = 54 end end
	end
	local closing, animation = false, nil
	popupClosers[overlay] = function()
		if closing then return end
		closing = true
		animation = tween(panel, { Size = UDim2.fromScale(0, 0) })
		animation.Completed:Once(function(state)
			if state == Enum.PlaybackState.Completed then if ownedGui then ownedGui:Destroy() else overlay:Destroy() end end
		end)
	end
	overlay.Destroying:Connect(function() popupClosers[overlay] = nil; if animation then animation:Cancel() end end)
	return overlay
end
function create.upgradeButton(props)
	local frame = create.panel({ Size = props.Size or UDim2.new(1, 0, 0, 260), Position = props.Position, Color = props.Color, Parent = props.Parent })
	frame.Name = "UpgradeButton"
	create.statBadge({ Size = UDim2.fromScale(0.46, 0.45), Label = props.StatName, Value = "Lv." .. tostring(props.CurrentLevel), Parent = frame })
	create.currencyBadge({ Size = UDim2.fromScale(0.46, 0.45), Position = UDim2.fromScale(0.54, 0), CurrencyName = "Gold", IconId = props.CurrencyIcon, Value = props.Cost, Parent = frame })
	create.button({ Size = UDim2.fromScale(1, 0.42), Position = UDim2.fromScale(0, 0.56), Text = "Upgrade", Color = props.Color, OnClick = props.OnClick, Parent = frame })
	return frame
end

-- ScreenGui 아래 GuiObject에 UIScale을 적용한다. 반환 root 아래에 UI를 배치한다.
-- 두 번째 반환값은 연결 정리 함수이며 ScreenGui/Root 파괴 시 자동 호출된다.
function RocketUI.applyResponsiveScale(screenGui)
	assert(screenGui:IsA("ScreenGui"), "ScreenGui가 필요합니다")
	assert(not screenGui:FindFirstChild("RocketUIRoot"), "반응형 배율은 한 번만 적용할 수 있습니다")
	screenGui.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
	local root = new("Frame", { Name = "RocketUIRoot", BackgroundTransparency = 1, BorderSizePixel = 0 }, screenGui)
	local scale = new("UIScale", { Name = "ResponsiveScale" }, root)
	local workspaceService = game:GetService("Workspace")
	local viewportConnection, cameraConnection, rootConnection, guiConnection
	local cleaned = false
	local function update()
		local camera = workspaceService.CurrentCamera
		local value = if camera then math.clamp(camera.ViewportSize.X / 1920, 0.55, 1.2) else 1
		scale.Scale = value
		-- 배율 변경 후에도 루트가 화면 전체를 덮도록 보정한다.
		root.Size = UDim2.fromScale(1 / value, 1 / value)
	end
	local function bindCamera()
		if viewportConnection then viewportConnection:Disconnect(); viewportConnection = nil end
		local camera = workspaceService.CurrentCamera
		if camera then viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(update) end
		update()
	end
	local function cleanup()
		if cleaned then return end
		cleaned = true
		for _, connection in ipairs({ cameraConnection, rootConnection, guiConnection }) do connection:Disconnect() end
		if viewportConnection then viewportConnection:Disconnect() end
	end
	cameraConnection = workspaceService:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
	rootConnection = root.Destroying:Connect(cleanup)
	guiConnection = screenGui.Destroying:Connect(cleanup)
	bindCamera()
	return root, cleanup
end
return RocketUI
