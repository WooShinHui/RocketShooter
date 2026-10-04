-- 실제 모듈을 실행하는 모의 엔진 검사입니다. Studio 물리·음원 청취 검사는 아닙니다.
do
	local env = environment()
	local V, CF = env.Vector3, env.CFrame
	local config = newDestructibleConfig(env)
	local steering = newHorizontalSteering(env)
	local horizontal, vertical = Balance.LaunchComponents(1, math.sin(math.rad(45)), 1)
	local origin, velocity, right = V.new(0, 20, 0), V.new(0, vertical, -horizontal), V.new(1, 0, 0)
	local placements = config.Placements(origin, velocity, right, 196.2)
	check(#placements == 8 and placements[2].Center.X == 16 and placements[4].Center.X == 26, "기존 두 선택 지점과 추가 발사 경로의 결정적 배치")
	check(config.Types.Rock.RunScore == 10 and config.Types.FloatingIsland.RunScore == 30 and config.Types.Ruin.RunScore == 50, "임시 점수 10/30/50")
	check(placements[2].Center.Y > 45 and placements[4].Center.Y > 90, "현재 Preview 환경의 상승 고도에 부유섬·폐허 배치")
	local repeated = config.Placements(origin, velocity, right, 196.2)
	check((placements[4].Center - repeated[4].Center).Magnitude == 0, "재생성 시 위치 동일")
	local function simulate(axisAt)
		local control, v, pos = steering.Create(velocity), velocity, origin
		local samples = {}
		for index = 1, 300 do
			local dt, now = 1 / 240, index / 240
			-- 패킷 제한에 맞춰 실제 Accept/Step을 사용합니다.
			if index % 24 == 1 then steering.Accept(control, axisAt(now), now) end
			v = steering.Step(control, v, dt, now)
			pos += v * dt
			samples[index] = pos
		end
		return samples
	end
	local neutral = simulate(function() return 0 end)
	local active = simulate(function(now) return now < 0.8 and 1 or 0 end)
	check(math.abs(active[156].X - 16) < 6, "Power 1 실제 조향 수식으로 첫 부유섬 도달")
	check(math.abs(active[300].X - 26) < 7, "같은 비행에서 두 번째 폐허 도달")
	local returnEasy = simulate(function(now) return now < 0.4 and 1 or -1 end)
	local lateChoice = simulate(function(now) return now < 0.28 and 0 or 1 end)
	check(math.abs(returnEasy[156].X - 16) < 6 and math.abs(returnEasy[300].X) < 6,
		"첫 부유섬 선택 후 반대 조향으로 두 번째 쉬운 Rock 선택 가능")
	check(math.abs(lateChoice[156].X) < 6 and math.abs(lateChoice[300].X - 26) < 7,
		"첫 Rock 선택 후 두 번째 고가치 폐허로 분기 가능")
	check(active[156].X > 6 and active[300].X > 6 and neutral[300].X == 0, "고가치 경로는 각 중앙 Rock을 포기")
	check(math.abs(active[300].Y-neutral[300].Y) < 0.001 and math.abs(active[300].Z-neutral[300].Z) < 0.001, "타깃 선택 조향은 높이·전방 이동을 변경하지 않음")
	local part = env.Instance.new("Part")
	part.Size, part.CFrame = V.new(8, 12, 8), CF.new()
	check(config.Contains(part, V.zero) and not config.Contains(part, V.new(7, 0, 0)), "서버 root 위치 접촉 검증·범위 밖 거부")
	check(#config.Cells("Rock") == 3 and #config.Cells("FloatingIsland") == 4 and #config.Cells("Ruin") == 6, "구조물 실루엣을 구성하는 서로 다른 셀")
	check(PresentationConfig.DestructionSounds.Chain[1].Id ~= PresentationConfig.DestructionSounds.Impact.Id
		and PresentationConfig.DestructionSounds.Chain[2].Id == PresentationConfig.DestructionSounds.Chain[1].Id, "연속 파괴는 단발 타격음과 구분한 짧은 팝 음원을 사용")
	check(PresentationConfig.DestructionProfiles.Ruin.Speed < PresentationConfig.DestructionProfiles.FloatingIsland.Speed
		and PresentationConfig.DestructionProfiles.FloatingIsland.Speed < PresentationConfig.DestructionProfiles.Rock.Speed, "세 재질의 사운드 재생 프로필 차등")

	-- 기존 회귀 환경을 이번 서버 스크립트에 필요한 API만 보강합니다.
	local create = env.Instance.new
	env.Instance.new = function(class)
		local object = create((class == "WedgePart" or class == "CornerWedgePart") and "Part" or class)
		function object:ClearAllChildren()
			for _, child in self:GetChildren() do child:Destroy() end
		end
		return object
	end
	env.UDim2.fromOffset = env.UDim2.new
	env.Color3.new = env.Color3.fromRGB
	for _, material in {"Rock", "Slate", "Ground", "Concrete", "Limestone"} do env.Enum.Material[material] = material end
	local flag = create("ModuleScript")
	flag.Name, flag.__module, flag.Parent = "DestructionSpikeFlag", {Enabled = true}, env.rs
	local cannon = create("Model"); cannon.Name, cannon.Parent = "Canon", env.workspace
	local cylinder = create("Part"); cylinder.Name, cylinder.Parent = "Cylinder", cannon
	local player = env.player(900)
	local signals = {}
	function player:GetAttributeChangedSignal(key)
		if not signals[key] then signals[key] = event() end
		return signals[key]
	end
	local function state(value)
		player:SetAttribute("FlightState", value)
		if signals.FlightState then signals.FlightState:Fire() end
	end
	local pending = {}
	env.task.delay = function(seconds, fn) table.insert(pending, {seconds, fn}) end
	runBarrierSpawner(env, {DestructibleConfig = config, LaunchTrajectory = newLaunchTrajectory(env)})
	local folder = env.workspace:FindFirstChild("DestructionSpikeBarriers")
	check(folder and #folder:GetChildren() == 8, "기존 Spawner가 8개 논리 Target 모델 생성")
	local root = player.Character.HumanoidRootPart
	local function contact(name)
		local target = folder:FindFirstChild(string.match(name, "^(.-)_Cell")):FindFirstChild(name)
		root.CFrame = target.CFrame
		target.Touched:Fire(root)
		return target
	end
	state("Aiming")
	contact("Rock1_Cell1")
	check(player:GetAttribute("DestructionRunScore") == 0, "비행 외 접촉은 무보상")
	state("Flying")
	local rock = contact("Rock1_Cell1")
	rock.Touched:Fire(root)
	check(player:GetAttribute("DestructionRunScore") == 10 and #pending == 3, "중복 접촉은 점수·체인을 중복 지급하지 않음")
	check(pending[1][1] == 0 and pending[2][1] == 0.07 and pending[3][1] == 0.14, "기존 70ms 근접 순서 체인 보존")
	for _, entry in pending do entry[2]() end
	pending = {}
	local remote = env.rs:FindFirstChild("BarrierDestroyed")
	check(#remote.sent == 3 and remote.sent[1][2].MaterialTag == "Rock" and remote.sent[1][2].Award == 10
		and remote.sent[2][2].Award == 0, "재질·점수 파괴 이벤트는 서버가 생성")
	local before = root.AssemblyLinearVelocity
	contact("FloatingIsland2_Cell2")
	contact("Ruin4_Cell2")
	check(player:GetAttribute("DestructionRunScore") == 90 and env.writes == 0 and #env.audio == 0, "세 타입 점수 합산·DataStore 쓰기 없음")
	check((root.AssemblyLinearVelocity-before).Magnitude == 0 and player.Character.Humanoid.Health == 100, "구조물 파괴는 속도·체력에 영향 없음")
	state("Result")
	check(player:GetAttribute("DestructionRunScore") == 90, "결과에서 임시 점수 유지")
	state("Aiming")
	state("Flying")
	local sent = #remote.sent
	for _, entry in pending do entry[2]() end
	check(#remote.sent == sent and player:GetAttribute("DestructionRunScore") == 0, "이전 비행 지연 효과 차단·새 비행 점수 초기화")
	state("Returning")
	check(#folder:GetChildren() == 8, "복귀 시 결정적 재생성")
	-- Every cell of each silhouette must collapse the logical target, even when
	-- the touching limb is outside the old root-only contact check.
	for _, definition in {{"Rock1", "Rock"}, {"FloatingIsland2", "FloatingIsland"}, {"Ruin4", "Ruin"}} do
		for cellIndex = 1, #config.Cells(definition[2]) do
			state("Aiming"); state("Flying")
			pending = {}
			local model = folder:FindFirstChild(definition[1])
			local cell = model:FindFirstChild(definition[1] .. "_Cell" .. cellIndex)
			local body = player.Character.Body
			body.CFrame = cell.CFrame
			root.CFrame = cell.CFrame * CF.new(0, 20, 0)
			cell.Touched:Fire(body)
			cell.Touched:Fire(body)
			check(player:GetAttribute("DestructionRunScore") == config.Types[definition[2]].RunScore
				and #pending == #config.Cells(definition[2]), "any body contact starts one whole-target award/cascade: " .. cell.Name)
			local parts = table.clone(model:GetChildren())
			local eventsBefore = #remote.sent
			for _, job in pending do job[2]() end
			local destroyed = model.Parent == nil
			local awards = 0
			for _, part in parts do destroyed = destroyed and part.Parent == nil end
			for index = eventsBefore + 1, #remote.sent do if remote.sent[index][2].Award > 0 then awards += 1 end end
			check(destroyed and awards == 1, "entire target removed with exactly one score event: " .. definition[1])
			state("Returning")
		end
	end
	state("Aiming"); state("Flying"); pending = {}
	local rockCell = folder.Rock1.Rock1_Cell1
	local accessory = create("Accessory"); accessory.Parent = player.Character
	local handle = create("Part"); handle.CFrame, handle.Parent = rockCell.CFrame, accessory
	rockCell.Touched:Fire(handle)
	check(player:GetAttribute("DestructionRunScore") == 0 and #pending == 0, "accessory contact cannot award a logical target")
end
