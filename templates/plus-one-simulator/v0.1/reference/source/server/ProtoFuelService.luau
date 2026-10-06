-- 세션 메모리만 사용하며 저장 데이터와 경제 시스템에 접근하지 않는다.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage:WaitForChild("ProtoFuelConstants"))
local Fuel = {}
local fuelStates = {}
local sessionPowerBonus = {}
local started = false
local updateRemote

local function get(player)
	local s = fuelStates[player]
	if not s then
		s = {fuel = 0, charging = false, chargeStartTime = os.clock(), lastFlightTime = -math.huge}
		fuelStates[player] = s
	end
	return s
end

local function eligible(player, now, s)
	local phase = player:GetAttribute("FlightState")
	if phase ~= nil and phase ~= "Idle" then return false end
	if now - s.lastFlightTime < Constants.PostFlightCooldown then return false end
	local world=workspace:FindFirstChild("CliffCamp")
    local stations=world and world:FindFirstChild("TrainingStations")
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local seat=humanoid and humanoid.SeatPart
    local station=seat and seat.Parent
    local tier=station and station:GetAttribute("TrainingTier")
    local stats=player:FindFirstChild("leaderstats");local unlocked=stats and stats:FindFirstChild("TrainingTier")
    return player.Parent==Players and root and humanoid and character:IsDescendantOf(workspace) and humanoid.Health>0
        and seat and seat.Name=="ToiletSeat" and seat.Occupant==humanoid and stations and station and station.Parent==stations
        and tier and unlocked and tier<=unlocked.Value
end

local function advance(player, s, now)
	local allowed = eligible(player, now, s) == true
	if s.charging and allowed then
		s.fuel = math.clamp(s.fuel + math.max(0, now - s.chargeStartTime) * Constants.ChargeRate, 0, Constants.MaxFuel)
	end
	s.chargeStartTime = now
	s.charging = allowed and s.fuel < Constants.MaxFuel
end

function Fuel.getFuelState(player)
	local s = get(player)
	return {fuel = s.fuel, maxFuel = Constants.MaxFuel, charging = s.charging,
		powerBonus = Fuel.getSessionPowerBonus(player)}
end

local function send(player)
	if updateRemote and player.Parent == Players then updateRemote:FireClient(player, Fuel.getFuelState(player)) end
end

function Fuel.consumeFuelForLaunch(player)
	-- 기존 반환형은 속도 배율이다. 1은 추가 부스트와 소비가 없음을 뜻한다.
	return 1
end

function Fuel.getSessionPowerBonus(player)
	return sessionPowerBonus[player] or 0
end

function Fuel.consumeFuelForPowerUp(player)
	local s = get(player)
	if started and player.Parent == Players then advance(player, s, os.clock()) end
	local success = started and player.Parent == Players and s.fuel >= Constants.FuelPerPowerLevel
	if success then
		s.fuel -= Constants.FuelPerPowerLevel
		sessionPowerBonus[player] = Fuel.getSessionPowerBonus(player) + 1
	end
	send(player)
	return {success = success == true, newPowerBonus = Fuel.getSessionPowerBonus(player), fuelRemaining = s.fuel}
end

function Fuel.Start()
	if started then return end
	local function remote(name)
		local r = ReplicatedStorage:FindFirstChild(name)
		if r then assert(r:IsA("RemoteEvent"), name .. " 형식이 RemoteEvent가 아닙니다")
		else r = Instance.new("RemoteEvent"); r.Name = name; r.Parent = ReplicatedStorage end
		return r
	end
	local startRemote, stopRemote = remote("RequestStartCharge"), remote("RequestStopCharge")
	updateRemote = remote("FuelStateUpdate")
	started = true
	local function request(player, requested)
		if player.Parent ~= Players then return end
		local s, now = get(player), os.clock()
		if now - (s.lastRequest or -math.huge) < 0.1 then return end
		s.lastRequest = now
		advance(player, s, now)
		s.requested = requested
		advance(player, s, now)
		send(player)
	end
	-- 추가 인자는 받지 않으므로 클라이언트가 보낸 수치나 시각은 사용하지 않는다.
	startRemote.OnServerEvent:Connect(function(player) request(player, true) end)
	stopRemote.OnServerEvent:Connect(function(player) request(player, false) end)
	local function watch(player)
		local s = get(player)
		if s.connection then return end
		s.phase = player:GetAttribute("FlightState")
		s.connection = player:GetAttributeChangedSignal("FlightState"):Connect(function()
			local phase = player:GetAttribute("FlightState")
			if s.phase == "Flying" then s.lastFlightTime = os.clock() end
			s.phase = phase
			if phase ~= nil and phase ~= "Idle" then s.charging, s.requested = false, false end
			s.chargeStartTime = os.clock()
			send(player)
		end)
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do watch(player) end
	Players.PlayerRemoving:Connect(function(player)
		local s = fuelStates[player]
		if s and s.connection then s.connection:Disconnect() end
		fuelStates[player] = nil
		sessionPowerBonus[player] = nil
	end)
	local accumulator = 0
	RunService.Heartbeat:Connect(function(dt)
		accumulator += dt
		if accumulator < 0.1 then return end
		accumulator = 0
		local now = os.clock()
		for player, s in pairs(fuelStates) do
			local previousFuel, previousCharging = s.fuel, s.charging
			advance(player, s, now)
			if previousFuel ~= s.fuel or previousCharging ~= s.charging then send(player) end
		end
	end)
end

return Fuel
