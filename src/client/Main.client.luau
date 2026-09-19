local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local aimRemote = ReplicatedStorage:WaitForChild("AimCannon") :: RemoteEvent
local fireRemote = ReplicatedStorage:WaitForChild("FireCannon") :: RemoteEvent
local flightResultRemote = ReplicatedStorage:WaitForChild("FlightResult") :: RemoteEvent
local returnToSpawnRemote = ReplicatedStorage:WaitForChild("ReturnToSpawn") :: RemoteEvent
local buyUpgradeRF = ReplicatedStorage:WaitForChild("BuyUpgrade") :: RemoteFunction
local resetDataRF = ReplicatedStorage:WaitForChild("ResetData") :: RemoteFunction

local renderConnection, inputConnection, gaugeConnection
local yaw, pitch = 0, 0
local SENSITIVITY = 0.15

local isTimingActive = false
local gaugeProgress = 0
local gaugeDirection = 1

local function createGaugeGui()
	local playerGui = player:WaitForChild("PlayerGui")
	local old = playerGui:FindFirstChild("TimingGaugeGui")
	if old then old:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TimingGaugeGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.Parent = playerGui

	local bgBar = Instance.new("Frame")
	bgBar.Name = "BgBar"
	bgBar.Size = UDim2.new(0, 300, 0, 30)
	bgBar.Position = UDim2.new(0.5, -150, 0.8, 0)
	bgBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	bgBar.BorderSizePixel = 0
	bgBar.Parent = screenGui

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 6)
	bgCorner.Parent = bgBar

	local goodZone = Instance.new("Frame")
	goodZone.Size = UDim2.new(0.5, 0, 1, 0)
	goodZone.Position = UDim2.new(0.25, 0, 0, 0)
	goodZone.BackgroundColor3 = Color3.fromRGB(240, 180, 40)
	goodZone.BorderSizePixel = 0
	goodZone.Parent = bgBar

	local perfectZone = Instance.new("Frame")
	perfectZone.Size = UDim2.new(0.15, 0, 1, 0)
	perfectZone.Position = UDim2.new(0.425, 0, 0, 0)
	perfectZone.BackgroundColor3 = Color3.fromRGB(40, 220, 80)
	perfectZone.BorderSizePixel = 0
	perfectZone.Parent = bgBar

	local pointer = Instance.new("Frame")
	pointer.Name = "Pointer"
	pointer.Size = UDim2.new(0, 6, 1, 8)
	pointer.Position = UDim2.new(0, 0, 0, -4)
	pointer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	pointer.BorderSizePixel = 0
	pointer.Parent = bgBar

	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(0, 3)
	pCorner.Parent = pointer

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, 0, 0, 30)
	statusLabel.Position = UDim2.new(0, 0, -1.2, 0)
	statusLabel.Text = "클릭하여 발사 타이밍을 잡으세요!"
	statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	statusLabel.TextSize = 16
	statusLabel.Font = Enum.Font.SourceSansBold
	statusLabel.BackgroundTransparency = 1
	statusLabel.Parent = bgBar

	return screenGui
end

local gaugeGui = createGaugeGui()

aimRemote.OnClientEvent:Connect(function(enable: boolean, cannon: Model)
	if enable and cannon then
		camera.CameraType = Enum.CameraType.Scriptable
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		yaw, pitch = 0, 0

		renderConnection = RunService.RenderStepped:Connect(function()
			local delta = UserInputService:GetMouseDelta()
			yaw = math.clamp(yaw - (delta.X * SENSITIVITY), -30, 30)
			pitch = math.clamp(pitch - (delta.Y * SENSITIVITY), -5, 45)

			local cylinder = cannon:FindFirstChild("Cylinder") :: BasePart
			if cylinder then
				camera.CFrame = cylinder.CFrame * CFrame.new(0, 4, 12) * CFrame.Angles(math.rad(-5), 0, 0)
			end
			aimRemote:FireServer(yaw, pitch)
		end)

		isTimingActive = true
		gaugeProgress = 0
		gaugeDirection = 1
		gaugeGui.Enabled = true

		local bgBar = gaugeGui:WaitForChild("BgBar")
		local pointer = bgBar:WaitForChild("Pointer") :: Frame

		gaugeConnection = RunService.Heartbeat:Connect(function(dt)
			gaugeProgress += dt * 1.2 * gaugeDirection
			if gaugeProgress >= 1 then
				gaugeProgress = 1
				gaugeDirection = -1
			elseif gaugeProgress <= 0 then
				gaugeProgress = 0
				gaugeDirection = 1
			end
			pointer.Position = UDim2.new(gaugeProgress, -3, 0, -4)
		end)

		inputConnection = UserInputService.InputBegan:Connect(function(input, gpe)
			if not gpe and input.UserInputType == Enum.UserInputType.MouseButton1 then
				if isTimingActive then
					isTimingActive = false
					if gaugeConnection then gaugeConnection:Disconnect() end

					local diff = math.abs(gaugeProgress - 0.5)
					local multiplier = 0.7
					local text = "MISS! (0.7x)"

					if diff <= 0.075 then
						multiplier = 1.5
						text = "★ PERFECT! (1.5x) ★"
					elseif diff <= 0.25 then
						multiplier = 1.0
						text = "GOOD! (1.0x)"
					end

					local statusLabel = bgBar:FindFirstChild("StatusLabel") :: TextLabel
					if statusLabel then statusLabel.Text = text end

					task.wait(0.3)
					gaugeGui.Enabled = false
					fireRemote:FireServer(multiplier)
				end
			end
		end)
	else
		if renderConnection then renderConnection:Disconnect() end
		if inputConnection then inputConnection:Disconnect() end
		if gaugeConnection then gaugeConnection:Disconnect() end

		gaugeGui.Enabled = false
		isTimingActive = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		camera.CameraType = Enum.CameraType.Custom

		if player.Character then
			camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
		end
	end
end)

fireRemote.OnClientEvent:Connect(function(launchVelocity)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
	local animate = character:FindFirstChild("Animate") :: LocalScript?

	if not (hrp and humanoid) then return end

	humanoid.WalkSpeed = 0
	humanoid.JumpHeight = 0

	local att0 = hrp:FindFirstChild("FlyAttachment0") or Instance.new("Attachment")
	att0.Name = "FlyAttachment0"
	att0.Position = Vector3.new(0, 1, 0)
	att0.Parent = hrp

	local att1 = hrp:FindFirstChild("FlyAttachment1") or Instance.new("Attachment")
	att1.Name = "FlyAttachment1"
	att1.Position = Vector3.new(0, -1, 0)
	att1.Parent = hrp

	local trail = hrp:FindFirstChild("FlyTrail") or Instance.new("Trail")
	trail.Name = "FlyTrail"
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Lifetime = 0.5
	trail.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(255, 100, 0))
	trail.Transparency = NumberSequence.new(0.2, 1)
	trail.Parent = hrp

	local alignMode = hrp:FindFirstChild("FlyOrientation") or Instance.new("AlignOrientation")
	alignMode.Name = "FlyOrientation"
	alignMode.Attachment0 = att0
	alignMode.CFrame = CFrame.lookAt(Vector3.zero, launchVelocity.Unit) * CFrame.Angles(math.rad(-90), 0, 0)
	alignMode.RigidityEnabled = true
	alignMode.Parent = hrp

	if animate then animate.Disabled = true end
	humanoid.AutoRotate = false
	humanoid.PlatformStand = true
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	hrp.AssemblyLinearVelocity = launchVelocity

	task.delay(6, function()
		if alignMode then alignMode:Destroy() end
		if att0 then att0:Destroy() end
		if att1 then att1:Destroy() end
		if trail then trail:Destroy() end
		if animate then animate.Disabled = false end
		humanoid.AutoRotate = true
		humanoid.PlatformStand = false
		humanoid.WalkSpeed = 16
		humanoid.JumpHeight = 7.2
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end)
end)

local function createResultGui()
	local playerGui = player:WaitForChild("PlayerGui")
	local oldGui = playerGui:FindFirstChild("ResultGui")
	if oldGui then oldGui:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ResultGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.Parent = playerGui

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 350, 0, 220)
	mainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 40)
	titleLabel.Text = "🚀 비행 결과"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 22
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.BackgroundTransparency = 1
	titleLabel.Parent = mainFrame

	local recordBadge = Instance.new("TextLabel")
	recordBadge.Name = "RecordBadge"
	recordBadge.Size = UDim2.new(1, 0, 0, 25)
	recordBadge.Position = UDim2.new(0, 0, 0, 35)
	recordBadge.Text = "★ 최고 기록 갱신! ★"
	recordBadge.TextColor3 = Color3.fromRGB(255, 215, 0)
	recordBadge.TextSize = 18
	recordBadge.Font = Enum.Font.SourceSansBold
	recordBadge.BackgroundTransparency = 1
	recordBadge.Visible = false
	recordBadge.Parent = mainFrame

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Name = "InfoLabel"
	infoLabel.Size = UDim2.new(1, 0, 0, 70)
	infoLabel.Position = UDim2.new(0, 0, 0, 65)
	infoLabel.Text = "거리: 0m\n획득 골드: +0 G\n획득 트로피: +0 🏆"
	infoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	infoLabel.TextSize = 18
	infoLabel.Font = Enum.Font.SourceSans
	infoLabel.BackgroundTransparency = 1
	infoLabel.Parent = mainFrame

	local returnBtn = Instance.new("TextButton")
	returnBtn.Name = "ReturnButton"
	returnBtn.Size = UDim2.new(0.8, 0, 0, 45)
	returnBtn.Position = UDim2.new(0.1, 0, 0.73, 0)
	returnBtn.Text = "스폰으로 돌아가기"
	returnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	returnBtn.TextSize = 18
	returnBtn.Font = Enum.Font.SourceSansBold
	returnBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
	returnBtn.BorderSizePixel = 0
	returnBtn.Parent = mainFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = returnBtn

	returnBtn.Activated:Connect(function()
		screenGui.Enabled = false
		returnToSpawnRemote:FireServer()
	end)

	return screenGui
end

local resultGui = createResultGui()

flightResultRemote.OnClientEvent:Connect(function(distance, gold, trophies, isNewRecord)
	local mainFrame = resultGui:WaitForChild("MainFrame")
	local infoLabel = mainFrame:WaitForChild("InfoLabel") :: TextLabel
	local recordBadge = mainFrame:WaitForChild("RecordBadge") :: TextLabel

	infoLabel.Text = string.format("비행 거리: %dm\n획득 골드: +%d G\n획득 트로피: +%d 🏆", distance, gold, trophies or 0)
	recordBadge.Visible = isNewRecord

	resultGui.Enabled = true
end)

local function createShopGui()
	local playerGui = player:WaitForChild("PlayerGui")
	local oldShop = playerGui:FindFirstChild("ShopGui")
	if oldShop then oldShop:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShopGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local shopFrame = Instance.new("Frame")
	shopFrame.Name = "ShopFrame"
	shopFrame.Size = UDim2.new(0, 240, 0, 255)
	shopFrame.Position = UDim2.new(0, 20, 0.35, 0)
	shopFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	shopFrame.BorderSizePixel = 0
	shopFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = shopFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 35)
	title.Text = "⚡ 상점 & 강화"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 18
	title.Font = Enum.Font.SourceSansBold
	title.BackgroundTransparency = 1
	title.Parent = shopFrame

	local buyBtnGold = Instance.new("TextButton")
	buyBtnGold.Name = "BuyButtonGold"
	buyBtnGold.Size = UDim2.new(0.85, 0, 0, 52)
	buyBtnGold.Position = UDim2.new(0.075, 0, 0.16, 0)
	buyBtnGold.Text = "Power Lvl.1\n비용: 100 G"
	buyBtnGold.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyBtnGold.TextSize = 14
	buyBtnGold.Font = Enum.Font.SourceSansBold
	buyBtnGold.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	buyBtnGold.BorderSizePixel = 0
	buyBtnGold.Parent = shopFrame

	local btnCorner1 = Instance.new("UICorner")
	btnCorner1.CornerRadius = UDim.new(0, 8)
	btnCorner1.Parent = buyBtnGold

	local buyBtnTrophy = Instance.new("TextButton")
	buyBtnTrophy.Name = "BuyButtonTrophy"
	buyBtnTrophy.Size = UDim2.new(0.85, 0, 0, 52)
	buyBtnTrophy.Position = UDim2.new(0.075, 0, 0.40, 0)
	buyBtnTrophy.Text = "부스터 Lvl.1\n비용: 1 🏆"
	buyBtnTrophy.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyBtnTrophy.TextSize = 14
	buyBtnTrophy.Font = Enum.Font.SourceSansBold
	buyBtnTrophy.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
	buyBtnTrophy.BorderSizePixel = 0
	buyBtnTrophy.Parent = shopFrame

	local btnCorner2 = Instance.new("UICorner")
	btnCorner2.CornerRadius = UDim.new(0, 8)
	btnCorner2.Parent = buyBtnTrophy

	local resetBtn = Instance.new("TextButton")
	resetBtn.Name = "ResetButton"
	resetBtn.Size = UDim2.new(0.85, 0, 0, 38)
	resetBtn.Position = UDim2.new(0.075, 0, 0.78, 0)
	resetBtn.Text = "🔄 데이터 초기화 (테스트)"
	resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	resetBtn.TextSize = 13
	resetBtn.Font = Enum.Font.SourceSansBold
	resetBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
	resetBtn.BorderSizePixel = 0
	resetBtn.Parent = shopFrame

	local btnCorner3 = Instance.new("UICorner")
	btnCorner3.CornerRadius = UDim.new(0, 8)
	btnCorner3.Parent = resetBtn

	local function updateShopUI()
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local powerLvl = leaderstats:FindFirstChild("PowerLvl") and leaderstats.PowerLvl.Value or 1
			local boostLvl = leaderstats:FindFirstChild("BoostLvl") and leaderstats.BoostLvl.Value or 1

			local goldCost = math.floor(100 * (1.18 ^ (powerLvl - 1)))
			local trophyCost = boostLvl * 2

			buyBtnGold.Text = string.format("파워 Lvl.%d\n강화: %d G", powerLvl, goldCost)
			buyBtnTrophy.Text = string.format("공중부스트 Lvl.%d\n강화: %d 🏆", boostLvl, trophyCost)
		end
	end

	buyBtnGold.Activated:Connect(function()
		local success = buyUpgradeRF:InvokeServer("Gold")
		if success then updateShopUI() end
	end)

	buyBtnTrophy.Activated:Connect(function()
		local success = buyUpgradeRF:InvokeServer("Trophy")
		if success then updateShopUI() end
	end)

	resetBtn.Activated:Connect(function()
		local success = resetDataRF:InvokeServer()
		if success then updateShopUI() end
	end)

	task.spawn(function()
		local leaderstats = player:WaitForChild("leaderstats")
		leaderstats:WaitForChild("PowerLvl").Changed:Connect(updateShopUI)
		leaderstats:WaitForChild("BoostLvl").Changed:Connect(updateShopUI)
		updateShopUI()
	end)
end

createShopGui()

-- Sky 고도 자동 전환 (첫 스폰/리스폰 완벽 대응)
task.spawn(function()
	local Lighting = game:GetService("Lighting")
	local skyGround = ReplicatedStorage:WaitForChild("SkyGround", 10) :: Sky
	local skySpace = ReplicatedStorage:WaitForChild("SkySpace", 10) :: Sky
	if not (skyGround and skySpace) then return end

	local ALTITUDE_THRESHOLD = 400
	local isSpace = nil

	local function applySky(force: boolean)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart
		if not hrp then return end

		local shouldBeSpace = hrp.Position.Y >= ALTITUDE_THRESHOLD
		if force or (shouldBeSpace ~= isSpace) then
			isSpace = shouldBeSpace

			for _, v in Lighting:GetChildren() do
				if v:IsA("Sky") then v:Destroy() end
			end

			local target = isSpace and skySpace or skyGround
			target:Clone().Parent = Lighting
		end
	end

	if player.Character then
		task.defer(function() applySky(true) end)
	end

	player.CharacterAdded:Connect(function(char)
		isSpace = nil
		char:WaitForChild("HumanoidRootPart", 5)
		applySky(true)
	end)

	RunService.Heartbeat:Connect(function()
		applySky(false)
	end)
end)