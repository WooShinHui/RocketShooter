local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SteeringInput = require(script.Parent.SteeringInput)
local Audio = require(script.Parent.Audio)
local Presentation = require(script.Parent.PresentationConfig)
local FlightCamera = require(script.Parent.FlightCamera)
local Sky = require(script.Parent.SkyController)
local Controller = {}

function Controller.Start(aimGui, resultGui, remotes, objectiveHud, mobile)
	local player = Players.LocalPlayer
	local aim = remotes.AimCannon
	local fire = remotes.FireCannon
	local result = remotes.FlightResult
	local state = remotes.FlightState
	local returnRemote = remotes.ReturnToSpawn
	local active = nil
	local newestId = 0
	local function cameraRestore()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		local camera = workspace.CurrentCamera
		if camera then
			camera.CameraType = Enum.CameraType.Custom
			local char = player.Character
			if char then camera.CameraSubject = char:FindFirstChildOfClass("Humanoid") end
		end
	end
	local function stopAim(run)
		for _, connection in ipairs(run.aimConnections) do connection:Disconnect() end
		table.clear(run.aimConnections)
		aimGui.Enabled = false
        if run.touchAim then run.touchAim.Stop();run.touchAim=nil end
		cameraRestore()
	end
	local function stopFlight(run)
		if objectiveHud then objectiveHud.Stop() end
		-- Keep this run's metadata for FlightResult, which may follow the Result state event.
		Sky.Reset()
		if run.flightCamera then run.flightCamera.Stop(); run.flightCamera = nil end
		if run.steeringInput then run.steeringInput.Stop(); run.steeringInput = nil end
		for _, effect in ipairs(run.effects) do effect:Destroy() end
		table.clear(run.effects)
		if run.animate and run.animate.Parent then run.animate.Disabled = run.animateDisabled end
		local humanoid = run.character:FindFirstChildOfClass("Humanoid")
		local saved = run.saved
		if humanoid and saved then
			humanoid.WalkSpeed = saved.walkSpeed
			humanoid.UseJumpPower = saved.useJumpPower
			humanoid.JumpPower = saved.jumpPower
			humanoid.JumpHeight = saved.jumpHeight
			humanoid.AutoRotate = saved.autoRotate
			humanoid.PlatformStand = saved.platformStand
			if humanoid.Health > 0 and not saved.platformStand then humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
		end
		run.saved = nil
	end
	local function clear()
		if active then stopAim(active); stopFlight(active) end
		if objectiveHud then objectiveHud.Stop() end
		active = nil
		resultGui.Enabled, aimGui.Enabled = false, false
		cameraRestore()
	end
	local function matches(id, character)
		return active and active.id == id and active.character == character and player.Character == character
	end
	aim.OnClientEvent:Connect(function(enable, cannon, id, character)
		if type(id) ~= "number" or character ~= player.Character then return end
		if not enable then
			if matches(id, character) and active.state ~= "Flying" then stopAim(active) end
			return
		end
		if id <= newestId or not cannon or not cannon:IsA("Model") then return end
		clear()
		newestId = id
		local run = {id = id, character = character, state = "Aiming", aimConnections = {}, effects = {}}
		active = run
		local yaw, pitch, sendElapsed = 0, Presentation.InitialAimPitch, 0
		aimGui.Enabled = true
		aim:FireServer(yaw, pitch, id) -- Immediate click uses the displayed initial aim.
		UserInputService.MouseBehavior = if mobile then Enum.MouseBehavior.Default else Enum.MouseBehavior.LockCenter
        local function launch()
            if active~=run or run.state~="Aiming" then return end
            aim:FireServer(yaw,pitch,id);run.state="LaunchPending";aimGui.Enabled=false;fire:FireServer(1,id)
        end
        if mobile then run.touchAim=mobile.Aim(aimGui,function(x,y)
            yaw=math.clamp(yaw+x,-30,30);pitch=math.clamp(pitch+y,15,75)
        end,launch) end
		table.insert(run.aimConnections, RunService.RenderStepped:Connect(function(dt)
			if active ~= run or player.Character ~= character then return end
			local delta = if mobile then Vector2.zero else UserInputService:GetMouseDelta()
			yaw = math.clamp(yaw - delta.X * 0.15, -30, 30)
			pitch = math.clamp(pitch - delta.Y * 0.15, -5, 75)
			local cylinder = cannon:FindFirstChild("Cylinder")
			local camera = workspace.CurrentCamera
			if cylinder and camera then
				camera.CameraType = Enum.CameraType.Scriptable
				camera.CFrame = cylinder.CFrame * CFrame.new(0, 4, 12) * CFrame.Angles(math.rad(-5), 0, 0)
			end
			sendElapsed += dt
			if sendElapsed >= 1 / 30 then sendElapsed = 0; aim:FireServer(yaw, pitch, id) end
		end))
		table.insert(run.aimConnections, UserInputService.InputBegan:Connect(function(input, processed)
			if mobile or processed or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) or active ~= run or run.state ~= "Aiming" then return end
			run.state = "LaunchPending"
			aimGui.Enabled = false
			fire:FireServer(1, id) -- Server accepts only the baseline launch multiplier.
		end))
	end)
	fire.OnClientEvent:Connect(function(velocity, id, character, saved, steeringSettings, objectiveMeta)
		if not matches(id, character) or (active.state ~= "Aiming" and active.state ~= "LaunchPending") then return end
		local run = active
		stopAim(run)
		run.state, run.saved = "Flying", saved
		Audio.Play("Launch")
		local root, humanoid = character:FindFirstChild("HumanoidRootPart"), character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then return end
		if objectiveHud then
			run.objectiveMeta = objectiveHud.Start(root, objectiveMeta, function()
				return active == run and run.state == "Flying" and player.Character == character
			end)
		end
		local function effect(class, name)
			local obj = Instance.new(class)
			obj.Name = name
			obj.Parent = root
			table.insert(run.effects, obj)
			return obj
		end
		local att0, att1 = effect("Attachment", "FlyAttachment0"), effect("Attachment", "FlyAttachment1")
		att0.Position, att1.Position = Vector3.new(0, 1, 0), Vector3.new(0, -1, 0)
		local trail = effect("Trail", "FlyTrail")
		trail.Attachment0, trail.Attachment1, trail.Lifetime = att0, att1, 0.5
		trail.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(255, 100, 0))
		trail.Transparency = NumberSequence.new(0.2, 1)
		local orientation = effect("AlignOrientation", "FlyOrientation")
		orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		orientation.Attachment0 = att0
		orientation.CFrame = CFrame.lookAt(Vector3.zero, velocity.Unit) * CFrame.Angles(math.rad(-90), 0, 0)
		orientation.RigidityEnabled = true
		run.animate = character:FindFirstChild("Animate")
		if run.animate and run.animate:IsA("LocalScript") then
			run.animateDisabled = run.animate.Disabled
			run.animate.Disabled = true
		else run.animate = nil end
		humanoid.AutoRotate, humanoid.PlatformStand = false, true
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		run.steeringInput = SteeringInput.Start(function(axis)
			if active == run and run.state == "Flying" and player.Character == character then
				remotes.SteerFlight:FireServer(axis, id)
			end
		end, steeringSettings, mobile)
		run.flightCamera = FlightCamera.Start(root, velocity, function()
			return active == run and run.state == "Flying" and player.Character == character
		end)
		-- Initial velocity is applied once, by the server. No fixed-duration cleanup.
	end)
	state.OnClientEvent:Connect(function(value, id, character, reason)
		if not matches(id, character) then return end
		if value == "Effect" then
			if active.state == "Flying" then
				Audio.Play(reason)
				if reason == "Ring" and active.flightCamera then active.flightCamera.Pulse() end
			end
		elseif value == "Descent" then
            local root=character:FindFirstChild("HumanoidRootPart")
            local orientation=root and root:FindFirstChild("FlyOrientation")
            if orientation and type(reason)=="table" and reason.Dive then orientation.CFrame=CFrame.Angles(0,0,math.pi) end
        elseif value == "Region" then
			if active.state == "Flying" then
				if reason.FirstEntry then
					if active.cloudNoticeShown then return end
					active.cloudNoticeShown = true
					Audio.Play("Discovery")
				end
				Sky.SetRegion(reason)
			end
		elseif value == "Destination" then
			if active.state == "Flying" and type(reason) == "table" and type(reason.Id) == "string" then
				active.destinationNotices = active.destinationNotices or {}
				if active.destinationNotices[reason.Id] then return end
				active.destinationNotices[reason.Id] = true
				Sky.ShowDestination(reason)
			end
		elseif value == "Result" then
			stopAim(active); stopFlight(active); active.state = "Result"
		elseif value == "Returning" then
			stopAim(active); stopFlight(active); active.state = "Returning"; resultGui.Enabled = false
		elseif value == "Cancelled" or value == "Idle" then
			clear()
			if reason then warn("[Flight] Run ended:", reason) end
		end
	end)
	result.OnClientEvent:Connect(function(distance, gold, trophies, record, id, character, metrics)
		if not matches(id, character) or active.resultShown or active.state == "Returning" then return end
		stopAim(active); stopFlight(active)
		active.state, active.resultShown = "Result", true
		Audio.Play("Result")
		local frame = resultGui.MainFrame
		local objectiveLabel = frame:FindFirstChild("ObjectiveLabel")
		if objectiveLabel then
			objectiveLabel.Text = "자동으로 발사장에 돌아갑니다"
			local objectiveMeta = active.objectiveMeta
			if objectiveMeta then
				local reachedObjective = active.destinationNotices ~= nil
					and active.destinationNotices[objectiveMeta.id] == true
				if reachedObjective then
					objectiveLabel.Text = "구름 전초기지 도착!"
				elseif type(metrics) == "table" and type(metrics.MaxAltitude) == "number"
					and metrics.MaxAltitude == metrics.MaxAltitude and math.abs(metrics.MaxAltitude) < math.huge then
					if metrics.MaxAltitude < objectiveMeta.requiredAltitude then
						local shortfall = math.ceil(objectiveMeta.requiredAltitude - metrics.MaxAltitude)
						objectiveLabel.Text = string.format("구름 구역까지 %d m 남음",shortfall)
					else
						objectiveLabel.Text = "높이 달성! 다음에는 구름 쪽으로 조준"
					end
				end
			end
		end
		frame.InfoLabel.Text = string.format("최고 높이  %d m   |   파괴 점수  %d\n수련 경험치  +%d XP\n골드  +%d   |   트로피  +%d",metrics and metrics.MaxAltitude or 0,metrics and metrics.SkyScore or 0,metrics and metrics.XPGain or 0,gold,trophies)
		if metrics and metrics.landingType == "SkyIsland" then
			frame.InfoLabel.Text ..= "\n구름 전초기지 도착!"
		end
		if metrics and metrics.DescentRings then
            frame.InfoLabel.Text ..= string.format("\n하락 링 %d / 3 · 착륙 %s\n하락 보너스 트로피 +%d (위 합계에 포함)",metrics.DescentRings,metrics.LandingGrade or "표적 밖",metrics.DescentTrophies or 0)
        end
        local altitudeRecord = metrics and metrics.AltitudeRecord
		frame.RecordBadge.Visible = record or altitudeRecord == true
		frame.RecordBadge.Text = "★ 새로운 최고 기록! ★"
		resultGui.Enabled = false

	end)
	resultGui.MainFrame.ReturnButton.Activated:Connect(function()
		if not active or active.state ~= "Result" then return end
		local now = os.clock()
		if now - (active.lastReturn or -math.huge) < 1 then return end
		active.lastReturn = now
		returnRemote:FireServer(active.id) -- Keep UI until the server acknowledges Returning.
	end)
	player.CharacterRemoving:Connect(function(character)
		if active and active.character == character then clear() end
	end)
	player.CharacterAdded:Connect(function() clear() end)
end

return Controller
