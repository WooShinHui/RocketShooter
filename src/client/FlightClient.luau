local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SteeringInput = require(script.Parent.SteeringInput)
local Controller = {}

function Controller.Start(gaugeGui, resultGui, remotes)
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
		gaugeGui.Enabled = false
		cameraRestore()
	end
	local function stopFlight(run)
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
		active = nil
		resultGui.Enabled, gaugeGui.Enabled = false, false
		cameraRestore()
	end
	local function matches(id, character)
		return active and active.id == id and active.character == character and player.Character == character
	end
	aim.OnClientEvent:Connect(function(enable, cannon, id, character)
		if type(id) ~= "number" or character ~= player.Character then return end
		if not enable then
			if matches(id, character) then stopAim(active) end
			return
		end
		if id <= newestId or not cannon or not cannon:IsA("Model") then return end
		clear()
		newestId = id
		local run = {id = id, character = character, state = "Aiming", aimConnections = {}, effects = {}}
		active = run
		local yaw, pitch, progress, direction, sendElapsed = 0, 0, 0, 1, 0
		local bar = gaugeGui.BgBar
		bar.StatusLabel.Text = "클릭하여 발사 타이밍을 잡으세요!"
		bar.Pointer.Position = UDim2.new(0, -3, 0, -4)
		gaugeGui.Enabled = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		table.insert(run.aimConnections, RunService.RenderStepped:Connect(function(dt)
			if active ~= run or player.Character ~= character then return end
			local delta = UserInputService:GetMouseDelta()
			yaw = math.clamp(yaw - delta.X * 0.15, -30, 30)
			pitch = math.clamp(pitch - delta.Y * 0.15, -5, 45)
			local cylinder = cannon:FindFirstChild("Cylinder")
			local camera = workspace.CurrentCamera
			if cylinder and camera then
				camera.CameraType = Enum.CameraType.Scriptable
				camera.CFrame = cylinder.CFrame * CFrame.new(0, 4, 12) * CFrame.Angles(math.rad(-5), 0, 0)
			end
			sendElapsed += dt
			if sendElapsed >= 1 / 30 then sendElapsed = 0; aim:FireServer(yaw, pitch, id) end
			if run.state == "Aiming" then
				progress += dt * 1.2 * direction
				if progress >= 1 then progress, direction = 1, -1 end
				if progress <= 0 then progress, direction = 0, 1 end
				bar.Pointer.Position = UDim2.new(progress, -3, 0, -4)
			end
		end))
		table.insert(run.aimConnections, UserInputService.InputBegan:Connect(function(input, processed)
			if processed or input.UserInputType ~= Enum.UserInputType.MouseButton1 or active ~= run or run.state ~= "Aiming" then return end
			run.state = "LaunchPending"
			local diff = math.abs(progress - 0.5)
			local multiplier, label = 0.7, "MISS! (0.7x)"
			if diff <= 0.075 then multiplier, label = 1.5, "★ PERFECT! (1.5x) ★"
			elseif diff <= 0.25 then multiplier, label = 1, "GOOD! (1.0x)" end
			bar.StatusLabel.Text = label
			task.delay(0.3, function()
				if active ~= run or run.state ~= "LaunchPending" or player.Character ~= character then return end
				gaugeGui.Enabled = false
				fire:FireServer(multiplier, id)
			end)
		end))
	end)
	fire.OnClientEvent:Connect(function(velocity, id, character, saved, steeringSettings)
		if not matches(id, character) or (active.state ~= "Aiming" and active.state ~= "LaunchPending") then return end
		local run = active
		stopAim(run)
		run.state, run.saved = "Flying", saved
		local root, humanoid = character:FindFirstChild("HumanoidRootPart"), character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then return end
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
		end, steeringSettings)
		-- Initial velocity is applied once, by the server. No fixed-duration cleanup.
	end)
	state.OnClientEvent:Connect(function(value, id, character, reason)
		if not matches(id, character) then return end
		if value == "Result" then
			stopAim(active); stopFlight(active); active.state = "Result"
		elseif value == "Returning" then
			stopAim(active); stopFlight(active); active.state = "Returning"; resultGui.Enabled = false
		elseif value == "Cancelled" or value == "Idle" then
			clear()
			if reason then warn("[Flight] Run ended:", reason) end
		end
	end)
	result.OnClientEvent:Connect(function(distance, gold, trophies, record, id, character)
		if not matches(id, character) or active.resultShown or active.state == "Returning" then return end
		stopAim(active); stopFlight(active)
		active.state, active.resultShown = "Result", true
		local frame = resultGui.MainFrame
		frame.InfoLabel.Text = string.format("비행 거리: %dm\n획득 골드: +%d G\n획득 트로피: +%d 🏆", distance, gold, trophies)
		frame.RecordBadge.Visible = record
		resultGui.Enabled = true
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
