local ReplicatedStorage = game:GetService("ReplicatedStorage")
local flagModule = ReplicatedStorage:WaitForChild("DestructionSpikeFlag", 15)
if not flagModule or not flagModule:IsA("ModuleScript") then
	warn("[DestructionSpike] DestructionSpikeFlag 모듈의 Rojo 매핑을 확인하세요.")
	return
end
if not require(flagModule).Enabled then return end
if require(flagModule).WorldTargetsOnly then return end

local Players = game:GetService("Players")
local Config = require(script.Parent.DestructibleConfig)
local Trajectory = require(script.Parent.LaunchTrajectory)
local CASCADE_INTERVAL = Config.CascadeInterval
local cannon = workspace:WaitForChild("Canon", 15)
local cylinder = cannon and cannon:WaitForChild("Cylinder", 15)
if not cylinder or not cylinder:IsA("BasePart") then
	warn("[DestructionSpike] Canon.Cylinder가 없어 타깃 생성을 중단합니다.")
	return
end
-- 기존 WorldService와 동일한 초기 대포 프레임을 사용하며 실제 대포를 움직이지 않습니다.
local pivot = cylinder:GetPivot()
local muzzle = Trajectory.AimedMuzzle(pivot, pivot:ToObjectSpace(cylinder.CFrame),
	cylinder.Size.Z, 0, Config.PreviewPitch)
local velocity = Trajectory.Velocity(muzzle.LookVector, Config.PreviewPower, Config.PreviewTiming)
if not velocity then return end
local planar = Vector3.new(velocity.X, 0, velocity.Z).Unit
local right = Vector3.new(-planar.Z, 0, planar.X)
local rotation = CFrame.lookAt(Vector3.zero, planar)
local placements = Config.Placements(Trajectory.Origin(muzzle).Position, velocity, right, workspace.Gravity,
	function(yaw, pitch)
		local aimed = Trajectory.AimedMuzzle(pivot, pivot:ToObjectSpace(cylinder.CFrame), cylinder.Size.Z, yaw, pitch)
		local launch = Trajectory.Velocity(aimed.LookVector, Config.PreviewPower, 1)
		local forward = Vector3.new(launch.X, 0, launch.Z).Unit
		return Trajectory.Origin(aimed).Position, launch, Vector3.new(-forward.Z, 0, forward.X)
	end)

if ReplicatedStorage:FindFirstChild("BarrierDestroyed") or workspace:FindFirstChild("DestructionSpikeBarriers") then
	warn("[DestructionSpike] 생성 대상 이름이 이미 존재하여 초기화를 중단합니다.")
	return
end
local remote = Instance.new("RemoteEvent")
remote.Name, remote.Parent = "BarrierDestroyed", ReplicatedStorage
local folder = Instance.new("Folder")
folder.Name, folder.Parent = "DestructionSpikeBarriers", workspace
local generation, dirty = 0, false
local connections, runTokens = {}, {}

local function playerFromHit(hit)
	local ancestor = hit
	while ancestor and ancestor ~= workspace do
		if ancestor:IsA("Model") then
			local player = Players:GetPlayerFromCharacter(ancestor)
			if player and player.Character == ancestor then return player, ancestor end
		end
		ancestor = ancestor.Parent
	end
	return nil, nil
end

local function touched(state, triggerPart, hit)
	if state.triggered or state.generation ~= generation then return end
	if not hit:IsA("BasePart") then return end
	local player, character = playerFromHit(hit)
	if not player or player:GetAttribute("FlightState") ~= "Flying" then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0
		or hit.Parent ~= character -- Distant accessory handles cannot trigger targets.
		or not Config.Contains(triggerPart, hit.Position, math.min(hit.Size.Magnitude / 2, 5)) then return end
	local token = runTokens[player]
	if not token then return end
	state.triggered, dirty = true, true
	state.model:SetAttribute("Destroyed", true)
	for _, part in state.parts do part.CanTouch = false end
	-- 구조물 하나당 한 번만 지급하는 세션 점수입니다. PlayerData와 연결하지 않습니다.
	local award = Config.Types[state.kind].RunScore
	local score = (player:GetAttribute("DestructionRunScore") or 0) + award
	player:SetAttribute("DestructionRunScore", score)
	print("[TargetChoice]", player.Name, Config.Types[state.kind].DisplayName, "+", award, "RunScore", score)
	local remaining = {}
	for index, part in state.parts do
		if part ~= triggerPart then
			table.insert(remaining, {part = part, index = index, distance = (part.Position - triggerPart.Position).Magnitude})
		end
	end
	table.sort(remaining, function(a, b)
		if a.distance == b.distance then return a.index < b.index end
		return a.distance < b.distance
	end)
	local ordered = {triggerPart}
	for _, entry in remaining do table.insert(ordered, entry.part) end
	for index, part in ordered do
		task.delay((index - 1) * CASCADE_INTERVAL, function()
			if state.generation ~= generation or not part.Parent then return end
			if player.Parent == Players and player.Character == character
				and player:GetAttribute("FlightState") == "Flying" and runTokens[player] == token then
				remote:FireClient(player, {Position = part.Position, Size = part.Size, Color = part.Color,
					MaterialTag = state.kind, ClusterId = state.id, Index = index,
					RunScore = score, Award = index == 1 and award or 0})
			end
			part:Destroy()
			if index == #ordered then state.model:Destroy() end
		end)
	end
end

local function rebuild()
	generation += 1
	folder:ClearAllChildren()
	dirty = false
	for id, placement in placements do
		local model = Instance.new("Model")
		model.Name = placement.Type .. id
		model:SetAttribute("TargetId", id)
		model:SetAttribute("TargetType", placement.Type)
		model:SetAttribute("RunScore", Config.Types[placement.Type].RunScore)
		model.Parent = folder
		local state = {model = model, parts = {}, triggered = false, generation = generation, kind = placement.Type, id = id}
		for index, cell in Config.Cells(placement.Type) do
			local part = Instance.new(cell.Class)
			part.Name, part.Size = string.format("%s%d_Cell%d", placement.Type, id, index), cell.Size
			part.CFrame = CFrame.new(placement.Center) * rotation * CFrame.new(cell.Offset)
			part.Color, part.Material = Color3.fromRGB(table.unpack(cell.Color)), Enum.Material[cell.Material]
			part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, true, false
			part:SetAttribute("MaterialTag", placement.Type)
			part:SetAttribute("TargetChoice", placement.Choice)
			part.Touched:Connect(function(hit) touched(state, part, hit) end)
			table.insert(state.parts, part)
			part.Parent = model
		end
		local gui = Instance.new("BillboardGui")
		gui.Name, gui.Size = "TargetValue", UDim2.fromOffset(210, 52)
		gui.StudsOffset, gui.MaxDistance, gui.AlwaysOnTop = Vector3.new(0, 25, 0), 500, false
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
		label.Font, label.TextSize = Enum.Font.GothamBold, 18
		label.TextColor3, label.TextStrokeTransparency = Color3.new(1, 1, 1), 0.3
		label.Text = placement.Type .. " +" .. Config.Types[placement.Type].RunScore .. "\nBreak all · One reward"
		label.TextWrapped = true
		label.Parent, gui.Parent = gui, state.parts[1]
	end
end
local function resetIfDirty()
	if dirty then rebuild() end
end
local function watchPlayer(player)
	if connections[player] then return end
	player:SetAttribute("DestructionRunScore", 0)
	connections[player] = {
		player.CharacterAdded:Connect(resetIfDirty),
		player.CharacterRemoving:Connect(function() runTokens[player] = nil; resetIfDirty() end),
		player:GetAttributeChangedSignal("FlightState"):Connect(function()
			local state = player:GetAttribute("FlightState")
			if state == "Aiming" then
				runTokens[player] = nil
				player:SetAttribute("DestructionRunScore", 0)
			elseif state == "Flying" then
				runTokens[player] = {}
			elseif state ~= "Result" then
				runTokens[player] = nil
			end
			if state == "Returning" then resetIfDirty() end
		end),
	}
end
rebuild()
Players.PlayerAdded:Connect(watchPlayer)
for _, player in Players:GetPlayers() do watchPlayer(player) end
Players.PlayerRemoving:Connect(function(player)
	for _, connection in connections[player] or {} do connection:Disconnect() end
	connections[player], runTokens[player] = nil, nil
	resetIfDirty()
end)
