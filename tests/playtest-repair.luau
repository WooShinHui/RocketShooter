-- Section A: production modules with a mock engine; human Studio QA remains required.
do
	local env = flightEnvironment(); local player = env.player(909); local id = env.enter(player)
	env.fire(player, id, 1.5); env.fire(player, id, 0.7)
	check(player:GetAttribute("FlightState") == "Aiming" and #env.rs.FireCannon.sent == 0, "server rejects obsolete timing rewards and penalties")
	env.fire(player, id, 1)
	check(player:GetAttribute("FlightState") == "Flying" and #env.rs.FireCannon.sent == 1, "baseline click preserves authoritative launch flow")
end
do
	local env = environment()
	local player = env.player(910)
	local stats = env.Instance.new("Folder"); stats.Name, stats.Parent = "leaderstats", player
	local gold = env.Instance.new("IntValue"); gold.Name, gold.Value, gold.Changed, gold.Parent = "Gold", 123, event(), stats
	local trophies = env.Instance.new("IntValue"); trophies.Name, trophies.Value, trophies.Changed, trophies.Parent = "Trophies", 45, event(), stats
	newCurrencyHud(env).Start(player)
	local gui = player.PlayerGui.CurrencyHud
	check(gui.ResetOnSpawn == false and gui.Balances.Text:find("—"), "currency HUD preserves loading state without invented balances")
	for _, job in env.queued do job[1]() end
	check(gui.Balances.Text == "골드  123\n트로피  45", "HUD displays stored Gold and Trophies separately")
	gold.Value = 77; gold.Changed:Fire()
	trophies.Value = 52; trophies.Changed:Fire()
	check(gui.Balances.Text == "골드  77\n트로피  52", "HUD follows both server balance changes")
	check(env.writes == 0 and env.opens == 0 and gold.Value == 77 and trophies.Value == 52, "HUD cannot alter currency or DataStore")
end
do
	local env = environment(); env.studio = true
	local player = env.player(911); env.players.LocalPlayer = player
	local signals = {}
	function player:GetAttributeChangedSignal(key)
		if not signals[key] then signals[key] = event() end
		return signals[key]
	end
	local flag = env.Instance.new("ModuleScript")
	flag.Name, flag.__module, flag.Parent = "DestructionSpikeFlag", {Enabled = true}, env.rs
	local space = env.Instance.new("Sky"); space.Name, space.Parent = "SkySpace", env.rs
	function space:Clone()
		local clone = env.Instance.new("Sky"); clone.StarCount = 3000; clone:SetAttribute("Template", "Space"); return clone
	end
	local legacy = space:Clone(); legacy.Parent = env.lighting
	local air = env.Instance.new("Atmosphere"); air.Color, air.Decay, air.Parent = {}, {}, env.lighting
	env.Enum.EasingStyle, env.Enum.EasingDirection = {Quad = "Quad"}, {Out = "Out"}
	env.TweenInfo = {new = function(...) return {...} end}
	local getService = env.game.GetService
	function env.game:GetService(name)
		if name == "TweenService" then return {Create = function(_, object, _, properties)
			return {Cancel = function() end, Play = function() for key, value in properties do object[key] = value end end}
		end} end
		return getService(self, name)
	end
	local sky = newSkyController(env); sky.Start()
	check(legacy.destroyed and env.lighting:GetAttribute("AltitudeLayer") == "GROUND", "preview starts Ground even when Lighting initially contains Space")
	check(env.lighting.FlightSky:GetAttribute("Template") ~= "Space" and env.lighting.FlightSky.StarCount == 0, "missing Ground asset cannot fall back to legacy Space")
	local ground = env.Instance.new("Sky"); ground.Name, ground.Parent = "SkyGround", env.rs
	function ground:Clone()
		local clone = env.Instance.new("Sky"); clone:SetAttribute("Template", "Ground"); return clone
	end
	for _, job in env.queued do job[1]() end
	check(env.lighting.FlightSky:GetAttribute("Template") == "Ground", "late Ground template replaces safe fallback")
	player:SetAttribute("FlightState", "Flying")
	local function altitude(y) player.Character.HumanoidRootPart.Position = env.Vector3.new(0, y, 0); env.step(0.1) end
	altitude(270); check(env.lighting:GetAttribute("AltitudeLayer") == "CLOUD", "ascending reaches the raised first cloud boundary")
	altitude(3600); check(env.lighting:GetAttribute("AltitudeLayer") == "HIGH_ALTITUDE", "ascending reaches High Altitude")
	altitude(100050); check(env.lighting:GetAttribute("AltitudeLayer") == "SPACE" and env.lighting.FlightSky:GetAttribute("Template") == "Space", "Space activates only at its flight altitude")
	altitude(99996); check(env.lighting:GetAttribute("AltitudeLayer") == "SPACE", "descending retains existing hysteresis")
	altitude(99990); check(env.lighting:GetAttribute("AltitudeLayer") == "HIGH_ALTITUDE" and env.lighting.FlightSky:GetAttribute("Template") == "Ground", "descending exits Space and restores Ground sky asset")
	player:SetAttribute("FlightState", "Result"); signals.FlightState:Fire()
	check(env.lighting:GetAttribute("AltitudeLayer") == "GROUND", "result/return resets Ground immediately")
end
do
	local env = environment(); local V, CF = env.Vector3, env.CFrame
	local config, trajectory, steering = newDestructibleConfig(env), newLaunchTrajectory(env), newHorizontalSteering(env)
	local pivot = CF.new(0, 20, 0)
	local function reference(yaw, pitch)
		local muzzle = trajectory.AimedMuzzle(pivot, CF.new(), 2, yaw, pitch)
		local velocity = trajectory.Velocity(muzzle.LookVector, 1, 1)
		local forward = V.new(velocity.X, 0, velocity.Z).Unit
		return trajectory.Origin(muzzle).Position, velocity, V.new(-forward.Z, 0, forward.X)
	end
	local origin, velocity, right = reference(0, 45)
	local placements = config.Placements(origin, velocity, right, 196.2, reference)
	check(placements[6].Center.X < -50 and placements[8].Center.X > 50, "authored targets span both launch directions, not just central trajectory")
	check(math.abs(placements[6].Center.Y - placements[4].Center.Y) > 15 and math.abs(placements[6].Center.Z - placements[4].Center.Z) > 30, "targets span altitude and forward depth as well as lateral space")
	for index, choice in config.Choices do
		local pos, v, side = reference(choice.Yaw, choice.Pitch)
		local control = steering.Create(v)
		for tick = 1, math.floor(choice.Time * 240) do
			local now, dt = tick / 240, 1 / 240
			local axis = choice.Lateral == 0 and 0 or (choice.Lateral > 0 and 1 or -1)
			if choice.Choice >= 3 and now > 0.65 then axis = 0 end
			if tick % 24 == 1 then steering.Accept(control, axis, now) end
			v = steering.Step(control, v, dt, now)
			pos += v * dt - V.new(0, 196.2 * dt * dt / 2, 0)
			v -= V.new(0, 196.2 * dt, 0)
		end
		check((pos - placements[index].Center).Magnitude < 10, "Power 1 ballistic/steering reference reaches target " .. index)
		local contacts = false
		for _, cell in config.Cells(choice.Type) do
			local part = env.Instance.new("Part")
			part.Size, part.CFrame = cell.Size, CF.new(placements[index].Center + cell.Offset)
			contacts = contacts or config.Contains(part, pos, math.sqrt(3))
		end
		check(contacts, "reachable trajectory intersects actual target silhouette " .. index)
	end
	local central = placements[3].Center
	check((central - placements[6].Center).Magnitude > 60 and (central - placements[8].Center).Magnitude > 60, "separate aim routes cannot be collected at the same flight position")
	local assets = newAssetRegistry(env); local outpost = assets.Create("Landmark.CloudOutpost")
	check(outpost.SunlitDeck.CanCollide and outpost.SunlitDeck.CanQuery and outpost.SunlitDeck:GetAttribute("LandingSurface"), "existing outpost deck is a real landing surface")
	check(outpost:FindFirstChild("LandingBeacon") and outpost:FindFirstChild("LandingH") and not outpost:GetAttribute("LandingTarget"), "beacon/H distinguishes destination without adding reward semantics")
end
