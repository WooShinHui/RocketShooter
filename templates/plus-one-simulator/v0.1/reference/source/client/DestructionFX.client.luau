local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flagModule = ReplicatedStorage:WaitForChild("DestructionSpikeFlag", 15)
if not flagModule or not flagModule:IsA("ModuleScript") then
	warn("[DestructionSpike] DestructionSpikeFlag 모듈의 Rojo 매핑을 확인하세요.")
	return
end
if not require(flagModule).Enabled then return end

local Butter=require(ReplicatedStorage:WaitForChild("CourseVisualConfig"))
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer
local event = ReplicatedStorage:WaitForChild("BarrierDestroyed", 15)
if not event or not event:IsA("RemoteEvent") then
	warn("[DestructionSpike] BarrierDestroyed 이벤트를 찾을 수 없습니다.")
	return
end

-- Presentation only. The server still owns destruction and its 70ms cadence.
local BURST_GAP = 0.13
local FRAGMENT_CAP, ACCENT_CAP = 48, 32
local random = Random.new()
local fragments, accents, punches = {}, {}, {}
local burstHits, lastHit = 0, -math.huge
local finishThread
local motionConnection
local bound = false
local appliedCamera, appliedFrame
local appliedOffset = CFrame.new()
local fxFolder = Instance.new("Folder")
fxFolder.Name = "DestructionSpikeLocalFX"
fxFolder.Parent = workspace

local gui = Instance.new("ScreenGui")
gui.Name = "DestructionSpikeFlash"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.Parent = player:WaitForChild("PlayerGui")
local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundColor3 = Color3.new(1, 1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.Parent = gui
local chainLabel=Instance.new("TextLabel")
chainLabel.Name="ChainNotice";chainLabel.AnchorPoint=Vector2.new(.5,.5)
chainLabel.Position=UDim2.fromScale(.5,.35);chainLabel.Size=UDim2.new(.9,0,0,58)
chainLabel.BackgroundTransparency=1;chainLabel.Font=Enum.Font.GothamBlack;chainLabel.TextSize=30
chainLabel.TextColor3=Color3.fromRGB(255,218,52);chainLabel.TextStrokeTransparency=.25;chainLabel.Visible=false;chainLabel.Parent=gui
local noticeSerial=0
local flashTween
local scoreLabel = Instance.new("TextLabel")
scoreLabel.Name = "TemporaryRunScore"
scoreLabel.Size, scoreLabel.Position = UDim2.fromOffset(190, 42), UDim2.new(1, -208, 0, 116)
scoreLabel.BackgroundTransparency = 0.35
scoreLabel.BackgroundColor3, scoreLabel.TextColor3 = Color3.fromRGB(28, 37, 49), Color3.new(1, 1, 1)
scoreLabel.Font, scoreLabel.TextSize = Enum.Font.GothamBold, 20
scoreLabel.Parent = gui
local function updateScore()
	local state = player:GetAttribute("FlightState")
	scoreLabel.Visible = state == "Flying" or state == "Result"
	scoreLabel.Text = "Break Score " .. tostring(player:GetAttribute("DestructionRunScore") or 0)
end
local scoreConnection = player:GetAttributeChangedSignal("DestructionRunScore"):Connect(updateScore)
updateScore()

-- Bounded preloaded voices: impact + six rotating chain voices + finish per material.
-- Old FX skipped unloaded Bomb audio silently, then cut chain playback at 60ms.
local presentation = require(script.Parent.PresentationConfig)
local soundConfig = presentation.DestructionSounds
local profiles = presentation.DestructionProfiles
local soundCues, soundList, warnedSounds = {}, {}, {}
local destroyed = false
local function newVoice(name, cue)
	local sound = Instance.new("Sound")
	sound.Name, sound.SoundId = name, cue.Id
	sound.Volume, sound.PlaybackSpeed = cue.Volume, cue.Speed
	sound.Parent = SoundService
	soundCues[sound] = cue
	table.insert(soundList, sound)
	return sound
end
local pools = {}
for kind in profiles do
	local cues=soundConfig[kind]or soundConfig
	local chains = {}
	-- Six voices preserve the short pop tail at the minimum60ms audio cadence.
	for index = 1, 6 do
		chains[index] = newVoice("Destruction" .. kind .. "Chain" .. index, cues.Chain[(index - 1) % 2 + 1])
	end
	pools[kind] = {Impact = newVoice("Destruction" .. kind .. "Impact", cues.Impact),
		Chain = chains, Next = 0, Finish = newVoice("Destruction" .. kind .. "Finish", cues.Finish)}
end
-- Two bounded accent voices, triggered only by validated non-brick collisions.
local waxConfig=presentation.WaxCrack
local waxVoices={};local waxNext=0;local lastWax=-math.huge
if waxConfig then
 for index,cue in waxConfig.Cues do waxVoices[index]=newVoice("DestructionWaxCrack"..index,cue) end
end
-- Soft Slime objects share nine bounded voices, rotating the three requested wax recordings.
local objectConfig=presentation.ObjectCrack
local objectVoices={};local objectNext=0;local lastObjectAudio=-math.huge
if objectConfig then
 for index=1,9 do
  objectVoices[index]=newVoice("DestructionObjectWax"..index,objectConfig.Cues[(index-1)%#objectConfig.Cues+1])
 end
end
local preloadThread = task.spawn(function()
	local ok, reason = pcall(function()
		ContentProvider:PreloadAsync(soundList, function(id, status)
			if not destroyed and status ~= Enum.AssetFetchStatus.Success then
				warn("[DestructionSpike Audio] Preload unavailable:", id, status)
			end
		end)
	end)
	if not destroyed and not ok then warn("[DestructionSpike Audio] Preload failed:", reason) end
end)
local voices = {}
local function playCue(sound, intensity, profile)
	-- Missing/unloaded audio must never queue an impact that plays late.
	if not sound.IsLoaded then
		if not warnedSounds[sound] then
			warnedSounds[sound] = true
			warn("[DestructionSpike Audio] Skipped unloaded cue; check asset permission/loading:", sound.SoundId)
		end
		return
	end
	local cue = soundCues[sound]
	sound:Stop()
	sound.Volume = math.min(cue.Volume * intensity * profile.Volume, 0.7)
	sound.PlaybackSpeed = math.clamp(cue.Speed * random:NextNumber(0.97, 1.03), 0.85, 1.05) * profile.Speed
	sound.TimePosition = 0
	sound:Play()
	voices[sound] = {started = os.clock(), duration = math.max(cue.Seconds,math.min(sound.TimeLength/sound.PlaybackSpeed,1.4)), volume = sound.Volume}
end

local function screenFlash(opacity, seconds)
	if flashTween then flashTween:Cancel() end
	flash.BackgroundTransparency = 1 - opacity
	flashTween = TweenService:Create(flash, TweenInfo.new(seconds), {BackgroundTransparency = 1})
	flashTween:Play()
end

local function removeOffset()
	-- Only undo a frame still owned by this FX; FlightCamera may have replaced it.
	if appliedCamera and appliedCamera == workspace.CurrentCamera
		and appliedCamera.CFrame == appliedFrame then
		appliedCamera.CFrame = appliedFrame * appliedOffset:Inverse()
	end
	appliedCamera, appliedFrame = nil, nil
end
local function stopPunch()
	removeOffset()
	if bound then
		RunService:UnbindFromRenderStep("DestructionSpikeRemoveOffset")
		RunService:UnbindFromRenderStep("DestructionSpikeApplyOffset")
		bound = false
	end
	punches = {}
end
local function punch(strength, duration)
	while #punches >= 4 do table.remove(punches, 1) end
	table.insert(punches, {started = os.clock(), strength = strength, duration = duration})
	if bound then return end
	bound = true
	RunService:BindToRenderStep("DestructionSpikeRemoveOffset", Enum.RenderPriority.Camera.Value - 1, removeOffset)
	RunService:BindToRenderStep("DestructionSpikeApplyOffset", Enum.RenderPriority.Last.Value + 1, function()
		local now, amount = os.clock(), 0
		for index = #punches, 1, -1 do
			local impulse = punches[index]
			local t = (now - impulse.started) / impulse.duration
			if t >= 1 then
				table.remove(punches, index)
			else
				-- One directed kick/recovery, no random shake or accumulated drift.
				amount += impulse.strength * math.sin(t * math.pi) * (1 - t)
			end
		end
		if #punches == 0 then stopPunch(); return end
		local camera = workspace.CurrentCamera
		if not camera then return end
		removeOffset()
		amount = math.min(amount, 0.28)
		appliedOffset = CFrame.new(0, amount * 0.18, amount)
			* CFrame.Angles(math.rad(-amount * 2.5), 0, 0)
		camera.CFrame = camera.CFrame * appliedOffset
		appliedCamera, appliedFrame = camera, camera.CFrame
	end)
end

local function visualPart(name, color, material, class)
	local part = Instance.new(class or "Part")
	part.Name, part.Color, part.Material = name, color, material
	part.Anchored = true
	part.CanCollide, part.CanTouch, part.CanQuery = false, false, false
	part.CastShadow = false
	return part
end
local function addAccent(part, duration, goal)
	for index = #accents, 1, -1 do
		if not accents[index].part.Parent then table.remove(accents, index) end
	end
	while #accents >= ACCENT_CAP do
		local oldest = table.remove(accents, 1)
		oldest.tween:Cancel()
		oldest.part:Destroy()
	end
	part.Parent = fxFolder
	local tween = TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
	table.insert(accents, {part = part, tween = tween, expires = os.clock() + duration})
	tween:Play()
end

local function impactLayers(data, first, intensity, finishing)
	local tint = data.Color:Lerp(Color3.new(1, 1, 1), 0.65)
	local scale = if data.Pierce then 18 elseif data.CourseHit then 7 else math.clamp(data.Size.Magnitude * 0.32, 1, 2.5)
	if not finishing then
		local core = visualPart("ImpactFlash", tint, Enum.Material.Neon)
		core.Shape = Enum.PartType.Ball
		core.Size = Vector3.one * scale * (first and 0.85 or 0.5)
		core.Position, core.Transparency = data.Position, first and 0.12 or 0.35
		addAccent(core, first and 0.075 or 0.045,
			{Size = core.Size * 1.7, Transparency = 1})
	end
	-- An open eight-segment ring leaves the target visible; no texture/asset needed.
	local camera = workspace.CurrentCamera
	local frame = CFrame.new(data.Position) * (camera and camera.CFrame.Rotation or CFrame.new())
	local radius = scale * (first and 0.7 or 0.45)
	local expansion = finishing and 1.9 or (first and 2.6 or 1.7)
	local duration = finishing and 0.11 or (first and 0.13 or 0.065)
	for index = 1, 8 do
		local angle = index * math.pi / 4
		local radial = Vector3.new(math.cos(angle), math.sin(angle), 0)
		local segment = visualPart("ImpactWave", tint, Enum.Material.Neon)
		segment.Size = Vector3.new(radius * 0.78, first and 0.12 or 0.07, 0.07)
		segment.Transparency = finishing and 0.35 or (first and 0.2 or 0.55)
		segment.CFrame = frame * CFrame.new(radial * radius) * CFrame.Angles(0, 0, angle + math.pi / 2)
		addAccent(segment, duration, {
			CFrame = frame * CFrame.new(radial * radius * expansion) * CFrame.Angles(0, 0, angle + math.pi / 2),
			Size = Vector3.new(radius * expansion * 0.78, 0.025, 0.025), Transparency = 1,
		})
	end
	if first then screenFlash(0.24, 0.085); punch(0.48, 0.12)
	elseif finishing then screenFlash(0.075, 0.055); punch(0.16, 0.085)
	else punch(0.07 * intensity, 0.055) end
end

local function spawnFragments(data, first, intensity)
	local profile = profiles[data.MaterialTag] or profiles.Rock
	local scale = if data.Pierce then 4 elseif data.CourseHit then 2.5 else math.clamp(data.Size.Magnitude * 0.12, 0.4, 0.85)
	for index = 1, first and 9 or 7 do
		while #fragments >= FRAGMENT_CAP do table.remove(fragments, 1).part:Destroy() end
		local shard = visualPart("DestructionSpikeFragment", data.Color, Enum.Material[profile.Material],
			(data.VisualKind=="Butter"or data.VisualKind=="Dumpling")and "Part"or (index % 3 == 0 and "WedgePart" or "Part"))
		local size = scale * profile.FragmentScale * (index <= 2 and random:NextNumber(0.9, 1.4) or random:NextNumber(0.25, 0.7))
		if data.VisualKind=="Butter"or data.VisualKind=="Dumpling"then
   local d=data.VisualKind=="Dumpling"and Butter.Dumpling or Butter
   local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.FileMesh;mesh.MeshId=d.Mesh;mesh.Scale=Vector3.one*(scale/(data.VisualKind=="Dumpling"and 638 or 14));mesh.Parent=shard
  end
  shard.Size = Vector3.new(size, size * random:NextNumber(0.35, 0.9), size * random:NextNumber(0.6, 1.3))
		if data.MaterialTag == "FloatingIsland" and index % 3 == 0 then
			shard.Color, shard.Material = Color3.fromRGB(82, 139, 66), Enum.Material.Grass
			shard.Size = Vector3.new(size * 1.8, 0.08, size)
		elseif data.MaterialTag == "Ruin" then
			shard.Size = Vector3.new(size * 1.5, size * 0.65, size)
		end
		local origin = data.Position + Vector3.new(random:NextNumber(-0.4, 0.4),
			random:NextNumber(-0.4, 0.4), random:NextNumber(-0.4, 0.4)) * scale
		local rotation = CFrame.Angles(random:NextNumber(0, 6.28), random:NextNumber(0, 6.28), random:NextNumber(0, 6.28))
		shard.CFrame, shard.Parent = CFrame.new(origin) * rotation, fxFolder
		local angle = index * math.pi * 2 / (first and 9 or 7) + random:NextNumber(-0.35, 0.35)
		local speed = random:NextNumber(16, 32) * intensity
		table.insert(fragments, {part = shard, origin = origin, rotation = rotation,
			velocity = Vector3.new(math.cos(angle) * speed, random:NextNumber(8, 24), math.sin(angle) * speed),
			spin = Vector3.new(random:NextNumber(-9, 9), random:NextNumber(-9, 9), random:NextNumber(-9, 9)),
			started = os.clock(), lifetime = random:NextNumber(0.28, 0.48) * profile.Lifetime})
	end
end

local function startMotion()
	if motionConnection then return end
	motionConnection = RunService.Heartbeat:Connect(function()
		local now = os.clock()
		for sound, voice in voices do
			local t = (now - voice.started) / voice.duration
			if t >= 1 then
				sound:Stop()
				voices[sound] = nil
			else
				sound.Volume = voice.volume * (1 - math.clamp((t - 0.55) / 0.45, 0, 1))
			end
		end
		for index = #fragments, 1, -1 do
			local fragment = fragments[index]
			local t = now - fragment.started
			if t >= fragment.lifetime or not fragment.part.Parent then
				fragment.part:Destroy()
				table.remove(fragments, index)
			else
				-- Anchored visual ballistics: no physics bodies, contacts or replication.
				fragment.part.CFrame = CFrame.new(fragment.origin + fragment.velocity * t + Vector3.new(0, -55 * t * t, 0))
					* fragment.rotation * CFrame.Angles(fragment.spin.X * t, fragment.spin.Y * t, fragment.spin.Z * t)
				fragment.part.Transparency = math.clamp((t / fragment.lifetime - 0.45) / 0.55, 0, 1)
			end
		end
		for index = #accents, 1, -1 do
			local accent = accents[index]
			if now >= accent.expires or not accent.part.Parent then
				accent.tween:Cancel()
				accent.part:Destroy()
				table.remove(accents, index)
			end
		end
		if #fragments == 0 and #accents == 0 and next(voices) == nil then
			motionConnection:Disconnect()
			motionConnection = nil
		end
	end)
end

local function cancelFinish()
	if finishThread then task.cancel(finishThread); finishThread = nil end
end
local function clearEffects()
	cancelFinish()
	burstHits, lastHit = 0, -math.huge
    noticeSerial+=1;chainLabel.Visible=false
	stopPunch()
	if motionConnection then motionConnection:Disconnect(); motionConnection = nil end
	if flashTween then flashTween:Cancel(); flashTween = nil end
	flash.BackgroundTransparency = 1
	for _, sound in soundList do sound:Stop() end
	voices = {}
	for _, fragment in fragments do fragment.part:Destroy() end
	for _, accent in accents do accent.tween:Cancel(); accent.part:Destroy() end
	fragments, accents = {}, {}
end

local eventConnection = event.OnClientEvent:Connect(function(data)
	if player:GetAttribute("FlightState") ~= "Flying" then return end
	if typeof(data) ~= "table" or typeof(data.Position) ~= "Vector3"
		or typeof(data.Size) ~= "Vector3" or typeof(data.Color) ~= "Color3" then return end
	if data.Character and data.Character~=player.Character then return end
    if data.RunId and data.RunId~=player:GetAttribute("SkyRunSerial") then return end
    if data.CourseHit or data.Pierce or data.PartyChain or (not data.PartyMember and type(data.Award)=="number" and data.Award>0) then
        local flightGui=player.PlayerGui:FindFirstChild("RocketFlightGui")
        local meter=flightGui and flightGui:FindFirstChild("DestructionRewards")
        if meter and meter.Visible then chainLabel.Position=UDim2.fromOffset(gui.AbsoluteSize.X*.5,meter.AbsolutePosition.Y+meter.AbsoluteSize.Y+34-gui.AbsolutePosition.Y) end
        local diveGui=player.PlayerGui:FindFirstChild("DiveBreakGuide")
        local guide=diveGui and diveGui:FindFirstChild("NextLayer")
        local viewport=workspace.CurrentCamera.ViewportSize;local compact=viewport.Y<500 or viewport.X<600
        chainLabel.TextSize=compact and 17 or 30;chainLabel.Size=compact and UDim2.fromOffset(math.min(300,viewport.X-160),28)or UDim2.new(.9,0,0,58)
        local readout=flightGui and flightGui:FindFirstChild("CompactFlightReadout")
        if compact and readout and readout.Visible then chainLabel.Position=UDim2.fromOffset(gui.AbsoluteSize.X*.5,readout.AbsolutePosition.Y+readout.AbsoluteSize.Y+20-gui.AbsolutePosition.Y)end
        if guide and guide.Visible then chainLabel.Position=UDim2.fromOffset(gui.AbsoluteSize.X*.5,guide.AbsolutePosition.Y+guide.AbsoluteSize.Y+(compact and 20 or 34)-gui.AbsolutePosition.Y)end
        noticeSerial+=1;local serial=noticeSerial;chainLabel.Visible=not require(script.Parent.StageCurtains).WarningOnScreen()
        chainLabel.Text=(if data.DiveRing then "Dive Ring "..tostring(data.Index).." streak! +"..tostring(data.Award) elseif data.DiveEnemy then "Brainrot pierced! +"..tostring(data.Award) elseif data.DiveZone then (data.RewardUnits==3 and "Bonus broken! +" or "Dive break! +")..tostring(data.Award) elseif data.Pierce then "Enemy pierced! +"..tostring(data.Award) elseif data.PartyChain then tostring(data.PartyChain).." chain! +"..tostring(data.ChainAward) elseif data.CourseHit then tostring(data.Index).." chain! +"..tostring(data.Award) else "Break +"..tostring(data.Award)).." pts"
        task.delay(.8,function() if serial==noticeSerial then chainLabel.Visible=false end end)
    end
    local now = os.clock()
	local first = data.Index == 1 or burstHits == 0 or now - lastHit >= BURST_GAP
	local kind = profiles[data.MaterialTag] and data.MaterialTag or "Rock"
	local pool, profile = pools[kind], profiles[kind]
	cancelFinish()
	burstHits = first and 1 or burstHits + 1
	lastHit = now
	local intensity = if data.Pierce then 2 else 1 + math.min(burstHits - 1, 6) * 0.035
	impactLayers(data, first, intensity, false)
	spawnFragments(data, first, intensity)
	-- Fragment events can arrive every18ms. Keep audible attacks60ms apart and rotate full pop tails.
	if kind=="Slime" and not data.Pierce and objectConfig then
  if now-lastObjectAudio>=objectConfig.Cooldown then
   lastObjectAudio=now;objectNext=objectNext%#objectVoices+1
   playCue(objectVoices[objectNext],math.min(intensity,1.2),{Volume=1,Speed=1})
  end
 elseif now-(pool.LastAudio or -math.huge)>=.06 then
		pool.LastAudio=now
		if first and kind~="Slime"then playCue(pool.Impact,1,profile)
		else
			pool.Next = pool.Next % #pool.Chain + 1
			playCue(pool.Chain[pool.Next],if kind=="Slime"and first then 1.3 else intensity,profile)
		end
	end
 -- Preserve the previous enemy impact and wax accent; object hits use wax only.
 if waxConfig and data.Pierce and now-lastWax>=waxConfig.Cooldown then
  waxNext=waxNext%#waxVoices+1;lastWax=now
  playCue(waxVoices[waxNext],if data.Pierce then 1.15 else .9,{Volume=1,Speed=1})
 end
	startMotion()
	-- Exactly one cancellable reservation; leaving flight cancels it as well.
	finishThread = task.delay(BURST_GAP, function()
		finishThread = nil
		if player:GetAttribute("FlightState") ~= "Flying" then return end
		burstHits = 0
		impactLayers(data, false, intensity, true)
		if kind~="Slime" or data.Pierce or not objectConfig then playCue(pool.Finish, 1, profile) end
		startMotion()
	end)
end)
local characterConnection = player.CharacterRemoving:Connect(clearEffects)
local stateConnection = player:GetAttributeChangedSignal("FlightState"):Connect(function()
	updateScore()
	if player:GetAttribute("FlightState") ~= "Flying" then clearEffects() end
end)
script.Destroying:Connect(function()
	destroyed = true
	if coroutine.status(preloadThread) ~= "dead" then task.cancel(preloadThread) end
	clearEffects()
	eventConnection:Disconnect()
	characterConnection:Disconnect()
	stateConnection:Disconnect()
	scoreConnection:Disconnect()
	gui:Destroy()
	fxFolder:Destroy()
	for _, sound in soundList do sound:Destroy() end
end)
