local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local C=require(RS:WaitForChild("ProgressionConfig",15))
local Data=require(script.Parent.PlayerData)
local function remote(name)
	local r=RS:FindFirstChild(name)
	if r then assert(r:IsA("RemoteFunction"),name.." class conflict") else r=Instance.new("RemoteFunction");r.Name=name;r.Parent=RS end
	return r
end
remote("RequestRebirth").OnServerInvoke=function(p,expected)
	return Data.Rebirth(p,expected)
end
remote("BuyTrainingTier").OnServerInvoke=function(p,expected)
	return Data.BuyTrainingTier(p,expected)
end
remote("BuyXPItem").OnServerInvoke=function(p,expected)return Data.BuyXPItem(p,expected)end
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
	elapsed+=dt
	if elapsed<1 then return end
	local seconds=math.min(elapsed,2);elapsed=0
	local world=workspace:FindFirstChild("CliffCamp")
	local stations=world and world:FindFirstChild("TrainingStations")
	for _,p in Players:GetPlayers() do
		local char=p.Character;local root=char and char:FindFirstChild("HumanoidRootPart")
		local hum=char and char:FindFirstChildOfClass("Humanoid")
		local phase=p:GetAttribute("FlightState")
		local active=false
		if Data.IsReady(p) and root and (phase==nil or phase=="Idle") and world then
			local pads=world:FindFirstChild("TrophyPads")
			if pads then for i,pad in C.TrophyPads do
				local tile=pads:FindFirstChild("Pad"..i)
				if tile then local v=tile.CFrame:PointToObjectSpace(root.Position)
					if math.abs(v.X)<12 and math.abs(v.Z)<12 and v.Y>=0 and v.Y<8 and Data.GetLevel(p,"Trophies")>=pad.Required then p:SetAttribute("TrainingBuffIndex",i) end
				end
			end end
			p:SetAttribute("TrainingXPMultiplier",Data.TrophyMultiplier(p))
		end
		Data.PassiveXP(p,seconds) -- Toilets below award only their additional XP.
		if Data.IsReady(p) and root and hum and hum.Health>0 and not root.Anchored
			and (phase==nil or phase=="Idle") and stations then
			for _,station in stations:GetChildren() do
				local belt=station:FindFirstChild("Belt")
				local index=station:GetAttribute("TrainingTier")
				local unlocked=Data.GetLevel(p,"TrainingTier")
				local seat=station:FindFirstChild("ToiletSeat")
                if belt and index<=unlocked and seat and hum.SeatPart==seat and seat.Occupant==hum then
					local v=belt.CFrame:PointToObjectSpace(root.Position)
					if math.abs(v.X)<belt.Size.X/2 and math.abs(v.Z)<belt.Size.Z/2 and v.Y>=0 and v.Y<7 then
						active=Data.Train(p,seconds,index)==true;break
					end
				end
			end
		end
		p:SetAttribute("TrainingActive",active)
	end
end)
