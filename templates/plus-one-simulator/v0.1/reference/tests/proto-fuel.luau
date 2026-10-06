-- 실제 Fuel 모듈을 모의 엔진에서 검증한다. Studio 물리 검증은 포함하지 않는다.
local function fuelEnvironment()
	local env = environment()
	local module = env.Instance.new("ModuleScript")
	module.Name, module.__module, module.Parent = "ProtoFuelConstants", ProtoFuelConstants, env.rs
	local camp=env.Instance.new("Folder");camp.Name="CliffCamp";camp.Parent=env.workspace
 local stations=env.Instance.new("Folder");stations.Name="TrainingStations";stations.Parent=camp
 local toilet=env.Instance.new("Model");toilet.Name="Toilet1";toilet.Parent=stations;toilet:SetAttribute("TrainingTier",1)
 local station = env.Instance.new("Part");station.Name="ToiletSeat";station.Parent=toilet
	local p = env.player(1201)
	local changed = event()
	local original = p.SetAttribute
	function p:GetAttributeChangedSignal() return changed end
	rawset(p, "SetAttribute", function(self, key, value) original(self, key, value); changed:Fire() end)
	p.Character.HumanoidRootPart.Position = env.Vector3.zero
	local stats=env.Instance.new("Folder");stats.Name="leaderstats";stats.Parent=p
 local tier=env.Instance.new("IntValue");tier.Name="TrainingTier";tier.Value=1;tier.Parent=stats
 p.Character.Humanoid.SeatPart=station;station.Occupant=p.Character.Humanoid
 local fuel = newProtoFuelService(env)
	fuel.Start()
	return env, p, fuel, station
end
do
	local env, p, fuel = fuelEnvironment()
	runProtoFuelServer(env, fuel)
	local remote = env.rs.RequestPowerUp
	check(remote and remote:IsA("RemoteFunction"), "Power 강화 RemoteFunction 생성")
	local insufficient = remote.OnServerInvoke(p, 1000000, 999)
	check(not insufficient.success and insufficient.fuelRemaining == 0 and insufficient.newPowerBonus == 0,
		"잔량 부족 및 클라이언트 수치 위조는 강화 불가")
	env.rs.RequestStartCharge.OnServerEvent:Fire(p)
	env.step(25)
	local first = remote.OnServerInvoke(p, -100, math.huge)
	check(first.success and first.fuelRemaining == 150 and first.newPowerBonus == 1, "100 Fuel 소비로 세션 Power +1")
	local second = remote.OnServerInvoke(p)
	check(second.success and second.fuelRemaining == 50 and second.newPowerBonus == 2, "연속 강화는 비용과 보너스 누적")
	local third = remote.OnServerInvoke(p)
	check(not third.success and third.fuelRemaining == 50 and third.newPowerBonus == 2, "연속 호출도 잔량 검증 유지")
	check(fuel.getFuelState(p).powerBonus == 2 and env.rs.FuelStateUpdate.sent[#env.rs.FuelStateUpdate.sent][2].powerBonus == 2,
		"서버 Fuel 상태와 갱신 이벤트에 보너스 포함")
	local other = env.player(1700)
	check(fuel.getSessionPowerBonus(other) == 0 and fuel.getFuelState(other).fuel == 0, "플레이어별 세션 자원 격리")
	check(env.writes == 0 and env.reads == 0 and env.opens == 0, "Power 강화는 DataStore를 호출하지 않음")
	env.players.PlayerRemoving:Fire(p)
	check(fuel.getSessionPowerBonus(p) == 0 and fuel.getFuelState(p).fuel == 0, "퇴장 시 Fuel과 Power 보너스 초기화")
end
do
	local env, p, fuel = fuelEnvironment()
	check(fuel.consumeFuelForLaunch(p) == 1, "미충전 FuelBoost는 정확히 1")
	env.rs.RequestStartCharge.OnServerEvent:Fire(p, 1000000, -1000000)
	env.step(2)
	check(fuel.getFuelState(p).fuel == 20, "클라이언트 수치를 무시하고 서버 시간으로 충전")
	env.step(8)
	check(fuel.getFuelState(p).fuel == 100 and fuel.getFuelState(p).charging, "100 Fuel 이후에도 충전 유지")
	env.step(100)
	check(fuel.getFuelState(p).fuel == 1100, "Fuel은 100을 넘어 축적")
	p:SetAttribute("FlightState", "Aiming")
	check(fuel.consumeFuelForLaunch(p) == 1 and fuel.getFuelState(p).fuel == 1100, "발사는 부스트와 Fuel 소비 없음")
	check(fuel.consumeFuelForLaunch(p) == 1, "반복 발사 소비 호출도 중립 배율 유지")
	p:SetAttribute("FlightState", "Flying")
	env.rs.RequestStartCharge.OnServerEvent:Fire(p)
	env.step(10)
	check(fuel.getFuelState(p).fuel == 1100, "비행 중 충전 요청 거부")
	p:SetAttribute("FlightState", "Idle")
	env.rs.RequestStartCharge.OnServerEvent:Fire(p)
	env.step(0.5)
	check(fuel.getFuelState(p).fuel == 1100, "비행 후 쿨다운 동안 충전 금지")
	env.step(0.5)
	env.step(1)
	check(fuel.getFuelState(p).fuel == 1110, "쿨다운 이후 서버 충전 재개")
	check(env.writes == 0 and env.reads == 0 and env.opens == 0, "Fuel은 DataStore에 접근하지 않음")
	env.players.PlayerRemoving:Fire(p)
	check(fuel.getFuelState(p).fuel == 0, "퇴장 시 세션 상태 정리")
end
do
	local env, p, fuel, station = fuelEnvironment()
	env.rs.RequestStartCharge.OnServerEvent:Fire(p)
	env.step(1)
	p.Character.Humanoid.SeatPart=nil
	env.step(10)
	check(fuel.getFuelState(p).fuel == 10 and not fuel.getFuelState(p).charging, "변기에서 일어나면 서버 충전 중단")
	env.rs.RequestStartCharge.OnServerEvent:Fire(p)
	env.step(10)
	check(fuel.getFuelState(p).fuel == 10, "원거리 충전 요청 거부")
	p.Character.Humanoid.SeatPart=nil
	env.rs.RequestStopCharge.OnServerEvent:Fire(p)
	env.step(1)
	check(fuel.getFuelState(p).fuel == 10, "명시적 충전 중단 후 누적 없음")
	env.rs.RequestStartCharge.OnServerEvent:Fire(p)
	p.Character.Humanoid.Health = 0
	env.step(5)
	check(fuel.getFuelState(p).fuel == 10, "사망 캐릭터 충전 금지")
	p.Character.Humanoid.Health = 100
    p.Character.Humanoid.SeatPart=station
	station.Parent = nil
	env.step(5)
	check(fuel.getFuelState(p).fuel == 10, "Station 제거 시 충전 중단")
end
do
	local env = environment()
	local trajectory = newLaunchTrajectory(env)
	local look = env.Vector3.new(0, math.sin(math.rad(45)), -math.cos(math.rad(45)))
	local baseline, h, v = trajectory.Velocity(look, 20, 1)
	local uncharged, h1, v1 = trajectory.Velocity(look, 20, 1, 1)
	local charged, h2, v2 = trajectory.Velocity(look, 20, 1, 1.5)
	check(baseline.X == uncharged.X and baseline.Y == uncharged.Y and baseline.Z == uncharged.Z
		and h == h1 and v == v1, "FuelBoost 1 경로는 기존 발사와 정확히 동일")
	check(h2 == h * 1.5 and v2 == v * 1.5 and charged.Y^2 > baseline.Y^2,
		"FuelBoost는 별도 곱셈 계수로 초기 속도와 탄도 최고고도를 증가시킴")
end
for _, peak in ipairs({0, 139, 140, 179, 199, 200, 210}) do
	local env = flightEnvironment()
	local module = env.Instance.new("ModuleScript")
	module.Name, module.__module, module.Parent = "ProtoFuelConstants", ProtoFuelConstants, env.rs
	local p = env.player(1300 + peak)
	local id = env.enter(p)
	env.fire(p, id)
	p.Character.HumanoidRootPart.Position = env.Vector3.new(0, peak, -100)
	env.step(1)
	p.Character.Humanoid.FloorMaterial = "Grass"
	env.step(0.2); env.step(0.2)
	local result = env.rs.FlightResult.sent[1]
	local metrics = result and result[8]
	-- 모의 World의 목표 메타데이터가 없으면 PLACEHOLDER 200을 사용한다.
	check(metrics and metrics.altitudeShortfall == 200 - peak
		and metrics.nearMissTriggered == (peak >= 140 and peak < 200), "Near-Miss 고도 경계 검증: " .. peak)
end
do
	local env, p, fuel = fuelEnvironment()
	env.rs.RequestStartCharge.OnServerEvent:Fire(p)
	env.step(10)
	env.protoFuel = fuel
	env.awards = {}
	local data = {IsReady = function() return true end, GetLevel = function() return 1 end,
		Award = function(...) table.insert(env.awards, {...}); return true, true end}
	local model = env.Instance.new("Model"); model.Name = "Canon"; model.Parent = env.workspace
	local cylinder = env.Instance.new("Part"); cylinder.Name = "Cylinder"; cylinder.Parent = model
	local launch = env.Instance.new("Part"); launch.Name = "LaunchPoint"; launch.Parent = model
	local prompt = env.Instance.new("ProximityPrompt"); prompt.Parent = launch
	local flight = newFlightService(env, data)
	flight.Start(model)
	p.Character.HumanoidRootPart.Position = launch.Position
	prompt.Triggered:Fire(p)
	local id = env.rs.AimCannon.sent[1][4]
	env.rs.FireCannon.OnServerEvent:Fire(p, 2, id)
	check(fuel.getFuelState(p).fuel == 100, "잘못된 발사 요청은 연료를 소비하지 않음")
	env.rs.FireCannon.OnServerEvent:Fire(p, 1, id)
	local expected = newLaunchTrajectory(env).Velocity(launch.CFrame.LookVector, 1, 1, 1)
	check(p.Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude == expected.Magnitude
		and fuel.getFuelState(p).fuel == 100, "FlightService의 유효 발사도 Fuel 부스트와 소비 없음")
	env.rs.FireCannon.OnServerEvent:Fire(p, 1, id)
	check(#env.rs.FireCannon.sent == 1, "중복 발사 요청으로 추가 발사를 만들 수 없음")
end
do
	local env, p, fuel = fuelEnvironment()
	local data = newPlayerData(env)
	p.leaderstats:Destroy() -- PlayerData creates the real stats for this integration case.
	data.Start(); env.players.PlayerAdded:Fire(p)
	local base = data.GetLevel(p, "PowerLvl")
	env.rs.RequestStartCharge.OnServerEvent:Fire(p); env.step(20)
	fuel.consumeFuelForPowerUp(p); fuel.consumeFuelForPowerUp(p)
	check(data.GetLevel(p, "PowerLvl") == base and p.leaderstats.PowerLvl.Value == base,
		"세션 보너스가 영구 PowerLvl과 leaderstats를 변경하지 않음")
	env.protoFuel = fuel
	local model = env.Instance.new("Model"); model.Name = "Canon"; model.Parent = env.workspace
	local cylinder = env.Instance.new("Part"); cylinder.Name = "Cylinder"; cylinder.Parent = model
	local launch = env.Instance.new("Part"); launch.Name = "LaunchPoint"; launch.Parent = model
	local prompt = env.Instance.new("ProximityPrompt"); prompt.Parent = launch
	newFlightService(env, data).Start(model)
	p.Character.HumanoidRootPart.Position = launch.Position
	prompt.Triggered:Fire(p)
	local id = env.rs.AimCannon.sent[1][4]
	env.rs.FireCannon.OnServerEvent:Fire(p, 1, id)
	local expected = newLaunchTrajectory(env).Velocity(launch.CFrame.LookVector, base + 2, 1)
	check(p.Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude == expected.Magnitude,
		"발사 속도에 영구 Power와 세션 보너스 합산")
	check(data.Save(p) and env.saved.PowerLvl == base and env.saved.Fuel == nil and env.saved.powerBonus == nil,
		"실제 PlayerData 저장 경로도 Fuel과 세션 Power를 저장하지 않음")
end
for _, peak in ipairs({125, 126, 179, 180}) do
	local env = flightEnvironment()
	local module = env.Instance.new("ModuleScript")
	module.Name, module.__module, module.Parent = "ProtoFuelConstants", ProtoFuelConstants, env.rs
	local world = {Start = function() end, GroundY = function() return 0 end,
		TargetCount = function() return 0 end, ExitReason = function() end, SampleDestination = function() end,
		GetCloudOutpostObjective = function() return {requiredAltitude = 180} end}
	-- 이미 생성된 FlightService의 World 모의 객체 대신 별도 모듈에 목표 메타데이터를 주입한다.
	env.world = world
	local flight = newFlightService(env, {IsReady = function() return true end,
		GetLevel = function() return 1 end, Award = function() return true, true end})
	local model = env.Instance.new("Model"); model.Parent = env.workspace
	local cylinder = env.Instance.new("Part"); cylinder.Name = "Cylinder"; cylinder.Parent = model
	local launch = env.Instance.new("Part"); launch.Name = "LaunchPoint"; launch.Parent = model
	local prompt = env.Instance.new("ProximityPrompt"); prompt.Parent = launch
	flight.Start(model)
	local p = env.player(1600 + peak)
	p.Character.HumanoidRootPart.Position = launch.Position
	prompt.Triggered:Fire(p)
	local id = env.rs.AimCannon.sent[#env.rs.AimCannon.sent][4]
	env.rs.FireCannon.OnServerEvent:Fire(p, 1, id)
	p.Character.HumanoidRootPart.Position = env.Vector3.new(0, peak, -100)
	env.step(1)
	p.Character.Humanoid.FloorMaterial = "Grass"
	env.step(0.2); env.step(0.2)
	local metrics = env.rs.FlightResult.sent[1][8]
	check(metrics.altitudeShortfall == 180 - peak and metrics.nearMissTriggered == (peak >= 126 and peak < 180),
		"기존 목표 고도 180의 70% 경계 참조: " .. peak)
end
