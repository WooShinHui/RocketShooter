local rocketMode=game:GetService("ReplicatedStorage"):FindFirstChild("RocketModeConfig")
if rocketMode and require(rocketMode).Enabled then return end
-- 기존 HUD/입력 시스템과 분리된 비영구 프로토타입 화면.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local SimulatorHUD = require(ReplicatedStorage:WaitForChild("SimulatorHUD", 15))
local Constants = require(ReplicatedStorage:WaitForChild("ProtoFuelConstants"))
local startRemote = ReplicatedStorage:WaitForChild("RequestStartCharge")
local stopRemote = ReplicatedStorage:WaitForChild("RequestStopCharge")
local updateRemote = ReplicatedStorage:WaitForChild("FuelStateUpdate")
local powerUpRemote = ReplicatedStorage:WaitForChild("RequestPowerUp")
local playerGui = player:WaitForChild("PlayerGui")

local function screen(name)
	local gui = Instance.new("ScreenGui")
	gui.Name, gui.ResetOnSpawn, gui.Enabled = name, false, false
	gui.Parent = playerGui
	return gui
end
local function panel(gui, position, size)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position, frame.Size = position, size
	frame.BackgroundColor3 = Color3.fromRGB(20, 30, 45)
	frame.BackgroundTransparency = 0.15
	frame.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	return frame
end
local function label(parent, position, size)
	local text = Instance.new("TextLabel")
	text.BackgroundTransparency = 1
	text.Position, text.Size = position, size
	text.Font, text.TextSize = Enum.Font.Gotham, 16
	text.TextColor3 = Color3.fromRGB(235, 245, 255)
	text.Parent = parent
	return text
end

local fuelGui, nearGui = screen("ProtoFuelHud"), screen("ProtoNearMissHud")
local frame = panel(fuelGui, UDim2.new(0.5, 0, 0, 90), UDim2.fromOffset(300, 158))
local status = label(frame, UDim2.fromOffset(8, 5), UDim2.fromOffset(284, 30))
local note = label(frame, UDim2.fromOffset(8, 61), UDim2.fromOffset(284, 28))
note.TextSize, note.Text = 14, "변기에 앉아 충전 → 추진력 강화 (이번 접속 유지)"
local bonusLabel = label(frame, UDim2.fromOffset(8, 88), UDim2.fromOffset(284, 24))
local powerUp = Instance.new("TextButton")
powerUp.Position, powerUp.Size = UDim2.fromOffset(16, 118), UDim2.fromOffset(268, 30)
powerUp.Text = string.format("추진력 +1 강화\n수련 에너지 %d 소비", Constants.FuelPerPowerLevel)
powerUp.Parent = frame
local track = Instance.new("Frame")
track.Position, track.Size = UDim2.fromOffset(16, 42), UDim2.fromOffset(268, 12)
track.BackgroundColor3, track.BorderSizePixel = Color3.fromRGB(60, 70, 85), 0
track.Parent = frame
local fill = Instance.new("Frame")
fill.Size, fill.BorderSizePixel = UDim2.fromScale(0, 1), 0
fill.BackgroundColor3 = Color3.fromRGB(70, 220, 180)
fill.Parent = track
SimulatorHUD.fuel(fuelGui, frame, status, note, bonusLabel, powerUp, track, fill)
local nearPanel = panel(nearGui, UDim2.new(0.5, 0, 0, 258), UDim2.fromOffset(340, 66))
local nearLabel = label(nearPanel, UDim2.fromOffset(8, 4), UDim2.fromOffset(324, 58))
nearLabel.TextWrapped = true
SimulatorHUD.screen(nearGui, 55)
SimulatorHUD.surface(nearPanel, SimulatorHUD.Colors.Coral)
SimulatorHUD.text(nearLabel, 18)
SimulatorHUD.fit(nearPanel, 340, 300)
local state = {fuel = 0, maxFuel = Constants.MaxFuel, charging = false}
local powerUpPending = false
powerUp.Activated:Connect(function()
	if powerUpPending or state.fuel < Constants.FuelPerPowerLevel then return end
	powerUpPending = true
	local ok, result = pcall(function() return powerUpRemote:InvokeServer() end)
	if ok and type(result) == "table" then
		state.fuel, state.powerBonus = result.fuelRemaining, result.newPowerBonus
	elseif not ok then
		note.Text = "요청에 실패했습니다. 다시 시도하세요"
	end
	powerUpPending = false
end)
local nearby, requested = false, false
local lastRequest, accumulator = -math.huge, 0
local noticeVersion = 0
local activeId, activeCharacter
local emitter, emitterStation

local function clearNotice()
	noticeVersion += 1
	nearGui.Enabled = false
end
local function phaseChanged()
	local phase = player:GetAttribute("FlightState")
	if phase ~= "Result" then clearNotice() end
	if phase ~= nil and phase ~= "Idle" then
		fuelGui.Enabled = false
		if emitter then emitter.Enabled = false end
	end
end
player:GetAttributeChangedSignal("FlightState"):Connect(phaseChanged)
player.CharacterRemoving:Connect(function()
	clearNotice()
	activeId, activeCharacter = nil, nil
	nearby, requested = false, false
	fuelGui.Enabled = false
	if emitter then emitter.Enabled = false end
	stopRemote:FireServer()
end)
updateRemote.OnClientEvent:Connect(function(value)
	if type(value) == "table" then state = value end
end)
ReplicatedStorage:WaitForChild("FireCannon").OnClientEvent:Connect(function(_, id, character)
	activeId, activeCharacter = id, character
	clearNotice()
end)
ReplicatedStorage:WaitForChild("FlightResult").OnClientEvent:Connect(function(_, _, _, _, id, character, metrics)
	if id ~= activeId or character ~= activeCharacter or character ~= player.Character
		or type(metrics) ~= "table" or metrics.nearMissTriggered ~= true
		or type(metrics.altitudeShortfall) ~= "number" or metrics.altitudeShortfall <= 0 then return end
	clearNotice()
	local version = noticeVersion
	-- 기존 보상 결과가 먼저 표시된 뒤 별도 피드백을 표시한다.
	task.delay(1.5, function()
		if noticeVersion ~= version or player:GetAttribute("FlightState") ~= "Result" then return end
		nearLabel.Text = string.format("구름 구역까지 높이 %d m 더 필요!", math.ceil(metrics.altitudeShortfall))
		nearGui.Enabled = true
		task.delay(2.5, function() if noticeVersion == version then nearGui.Enabled = false end end)
	end)
end)
RunService.Heartbeat:Connect(function(dt)
	accumulator += dt
	if accumulator < 0.1 then return end
	accumulator = 0
	local station
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local phase = player:GetAttribute("FlightState")
	local seat=humanoid and humanoid.SeatPart
    local toilets=workspace:FindFirstChild("CliffCamp") and workspace.CliffCamp:FindFirstChild("TrainingStations")
    local stats=player:FindFirstChild("leaderstats");local tier=stats and stats:FindFirstChild("TrainingTier")
    station=seat
    nearby=seat~=nil and seat.Name=="ToiletSeat" and toilets~=nil and seat.Parent.Parent==toilets
        and seat.Occupant==humanoid and tier~=nil and (seat.Parent:GetAttribute("TrainingTier") or math.huge)<=tier.Value
        and humanoid.Health>0 and (phase==nil or phase=="Idle")
	if nearby ~= requested or (nearby and os.clock() - lastRequest >= 0.5) then
		requested, lastRequest = nearby, os.clock()
		if nearby then startRemote:FireServer() else stopRemote:FireServer() end
	end
	fuelGui.Enabled = nearby
	local ratio = math.clamp(state.fuel / Constants.FuelPerPowerLevel, 0, 1)
	fill.Size = UDim2.fromScale(ratio, 1)
	status.Text = string.format("수련 에너지 %d %s", math.floor(state.fuel),state.charging and "충전 중" or "")
	bonusLabel.Text = string.format("추진력 +%d", state.powerBonus or 0)
	powerUp.Text=if state.fuel>=Constants.FuelPerPowerLevel then "추진력 +1 강화\n수련 에너지 100 소비" else string.format("강화까지 에너지 %d 남음",math.ceil(Constants.FuelPerPowerLevel-state.fuel))
    powerUp.Active = state.fuel >= Constants.FuelPerPowerLevel and not powerUpPending
	powerUp.AutoButtonColor = powerUp.Active
	powerUp.BackgroundColor3 = powerUp.Active and SimulatorHUD.Colors.Green or Color3.fromRGB(90, 100, 110)
	if emitterStation ~= station then
		if emitter then emitter:Destroy(); emitter = nil end
		emitterStation = station
		if station and station:IsA("BasePart") then
			emitter = Instance.new("ParticleEmitter")
			emitter.Name = "ProtoFuelParticles"
			emitter.Rate, emitter.Lifetime, emitter.Speed = 8, NumberRange.new(0.4, 0.7), NumberRange.new(1, 3)
			emitter.Color = ColorSequence.new(Color3.fromRGB(70, 220, 180))
			emitter.Enabled = false
			emitter.Parent = station
		end
	end
	if emitter then emitter.Enabled = nearby and state.charging end
end)
