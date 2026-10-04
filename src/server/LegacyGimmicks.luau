-- Compatibility owner for the original prototype layout. Never creates GeneratedWorld content.
local RunService = game:GetService("RunService")
local Legacy = {}
local started = false
function Legacy.Start(applyGimmick, mode)
 if started then return end
 assert(mode == "Preserve" or mode == "Disabled", "Invalid legacy Gimmicks mode")
 started = true
 if mode == "Disabled" then
  local folder = workspace:FindFirstChild("Gimmicks")
  if folder then
   -- Session-only archival; the saved Studio objects are not deleted or edited.
   local archive = Instance.new("Folder")
   archive.Name = "LegacyGimmicksArchive"
   archive.Parent = game:GetService("ServerStorage")
   folder.Parent = archive
  end
  return
 end
local movingGimmicks = {}

local function buildMapGimmicks()
	local folder = workspace:FindFirstChild("Gimmicks") or Instance.new("Folder")
	folder.Name = "Gimmicks"
	folder.Parent = workspace
	-- Remove only objects created by this implementation; preserve Studio-owned content.
	for _, child in folder:GetChildren() do
		if child:GetAttribute("Phase0Generated") then child:Destroy() end
	end
	movingGimmicks = {}
	-- A Studio-saved layout may already exist. Reuse it instead of stacking a
	-- second set of rings/targets or deleting hand-authored objects.
	local existingLayout = false
	for _, part in folder:GetChildren() do
		if part:IsA("BasePart") then
			local isRing = part.Name == "BoosterRing"
			local isBomb = part.Name == "ObstacleBomb"
			if isRing or isBomb then
				existingLayout = true
				table.insert(movingGimmicks, {
					part = part, basePos = part.Position, baseRotation = part.CFrame.Rotation,
					speed = isRing and (1.5 + math.random() * 1.5) or (2 + math.random()),
					range = isRing and (30 + math.random(0, 20)) or 40,
					offset = math.random() * math.pi * 2, isRing = isRing,
				})
				part.Touched:Connect(function(hit)
					applyGimmick(part, hit, isRing and "Ring" or "Bomb")
				end)
			elseif string.find(part.Name, "TargetZone", 1, true) then existingLayout = true end
		end
	end
	if existingLayout then
		warn("[Gimmicks] Reusing Studio-owned layout; no duplicate generation. Check all intended rings, bombs and targets exist.")
		return
	end

	for i = 1, 25 do
		local ring = Instance.new("Part")
		ring.Name = "BoosterRing"
		ring.Shape = Enum.PartType.Cylinder
		ring.Size = Vector3.new(2, 26, 26)
		local basePos = Vector3.new(0, 80 + math.random(-20, 40), -i * 110)
		ring.CFrame = CFrame.new(basePos) * CFrame.Angles(0, 0, math.rad(90))
		ring.Color = Color3.fromRGB(0, 230, 255)
		ring.Material = Enum.Material.Neon
		ring.Anchored = true
		ring.CanCollide = false
		ring:SetAttribute("Phase0Generated", true)
		ring.Parent = folder

		table.insert(movingGimmicks, {
			part = ring,
			basePos = basePos,
			speed = 1.5 + math.random() * 1.5,
			range = 30 + math.random(0, 20),
			offset = math.random() * math.pi * 2,
			isRing = true
		})

		ring.Touched:Connect(function(hit)
			applyGimmick(ring, hit, "Ring")
		end)
	end

	for i = 1, 15 do
		local bomb = Instance.new("Part")
		bomb.Name = "ObstacleBomb"
		bomb.Shape = Enum.PartType.Ball
		bomb.Size = Vector3.new(14, 14, 14)
		local basePos = Vector3.new(0, 70 + math.random(-30, 30), -i * 170 - 50)
		bomb.Position = basePos
		bomb.Color = Color3.fromRGB(255, 50, 50)
		bomb.Material = Enum.Material.Neon
		bomb.Anchored = true
		bomb.CanCollide = false
		bomb:SetAttribute("Phase0Generated", true)
		bomb.Parent = folder

		table.insert(movingGimmicks, {
			part = bomb,
			basePos = basePos,
			speed = 2.0 + math.random(),
			range = 40,
			offset = math.random() * math.pi * 2,
			isRing = false
		})

		bomb.Touched:Connect(function(hit)
			applyGimmick(bomb, hit, "Bomb")
		end)
	end

	local targetDistances = {300, 700, 1200, 1800, 2500, 3300}
	for idx, dist in ipairs(targetDistances) do
		local zone = Instance.new("Part")
		zone.Name = "TargetZone_" .. idx
		zone.Size = Vector3.new(70, 1, 70)
		zone.Position = Vector3.new(0, 0.5, -dist)
		zone.Color = Color3.fromRGB(255, 215, 0)
		zone.Material = Enum.Material.Neon
		zone.Anchored = true
		zone.CanCollide = false
		zone:SetAttribute("Phase0Generated", true)
		zone.Parent = folder

		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 215, 0)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.Parent = zone
	end
end

buildMapGimmicks()

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for _, item in ipairs(movingGimmicks) do
		if item.part and item.part.Parent then
			local xOffset = math.sin(now * item.speed + item.offset) * item.range
			local targetPos = item.basePos + Vector3.new(xOffset, 0, 0)
			if item.isRing then
				item.part.CFrame = CFrame.new(targetPos) * (item.baseRotation or CFrame.Angles(0, 0, math.rad(90)))
			else
				item.part.Position = targetPos
			end
		end
	end
end)

end
return Legacy
