-- One visible toilet, independent invisible seat and server XP clock per player.
local Players=game:GetService("Players")
local Physics=game:GetService("PhysicsService")
local Data=require(script.Parent.PlayerData)
local Service={};local sessions={};local autoBlocked={}
local Config=require(game.ReplicatedStorage:WaitForChild("ShowroomConfig"))
local group="SharedTrainingUsers"
if not Physics:IsCollisionGroupRegistered(group)then Physics:RegisterCollisionGroup(group)end
Physics:CollisionGroupSetCollidable(group,group,false)
function Service.Leave(player)
 local s=sessions[player];if not s then return end;sessions[player]=nil;autoBlocked[player]=s.station
 for _,c in s.connections do c:Disconnect()end
 if s.hum.Parent then s.hum.Sit=false end
 s.seat:Destroy()
 for p,old in s.groups do if p.Parent then p.CollisionGroup=old end end
 player:SetAttribute("SharedTrainingTier",nil);player:SetAttribute("TrainingActive",false)
end
function Service.Join(player,station,automatic)
 local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid")
 local tier=station:GetAttribute("TrainingTier");local visual=station:FindFirstChild("ToiletSeat");local base=station:FindFirstChild("Base")
 if not Data.IsReady(player)or not root or not hum or hum.Health<=0 or root.Anchored or not visual or not base then return false,"Training unavailable"end
 if (root.Position-base.Position).Magnitude>14 or (player:GetAttribute("FlightState")or "Idle")~="Idle"then return false,"Move closer to the toilet"end
 if tier>Data.GetLevel(player,"TrainingTier")then local ok,note=Data.BuyTrainingTier(player,tier);if not ok then return false,note end end
 if sessions[player]and sessions[player].station==station then
  if automatic then return true,"Training"end
  Service.Leave(player);return true,"Stop Training"
 end
 Service.Leave(player);autoBlocked[player]=nil
 local seat=Instance.new("Seat");seat.Name="PersonalTrainingSeat_"..player.UserId;seat.Size=visual.Size;seat.CFrame=visual.CFrame;seat.Anchored=true;seat.Transparency=1;seat.CanCollide=false;seat.CanTouch=false;seat.CanQuery=false;seat.Parent=station
 local s={seat=seat,hum=hum,station=station,tier=tier,groups={},connections={},started=os.clock()};sessions[player]=s
 local function groupPart(p)if p:IsA("BasePart")then s.groups[p]=p.CollisionGroup;p.CollisionGroup=group end end
 for _,p in char:GetDescendants()do groupPart(p)end
 table.insert(s.connections,char.DescendantAdded:Connect(groupPart))
 table.insert(s.connections,hum.Died:Connect(function()Service.Leave(player)end))
 table.insert(s.connections,player.CharacterRemoving:Connect(function()Service.Leave(player)end))
 seat:Sit(hum);player:SetAttribute("SharedTrainingTier",tier)
 return true,"Training started · Jump or press E to leave"
end
function Service.ActiveTier(player)
 local s=sessions[player];if not s then return nil end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not Data.IsReady(player)or not root or s.hum.Health<=0 or root.Anchored or (player:GetAttribute("FlightState")or "Idle")~="Idle"or not s.station.Parent or (root.Position-s.seat.Position).Magnitude>10 or (os.clock()-s.started>.5 and (s.hum.SeatPart~=s.seat or s.seat.Occupant~=s.hum))then Service.Leave(player);return nil end
 return s.tier
end
-- After standing up, leave the approach zone before automatic seating resumes.
function Service.AutoJoin(player,stations)
 if Service.ActiveTier(player)then return end
 local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not Data.IsReady(player)or not root or not hum or hum.Health<=0 or root.Anchored or hum.SeatPart or hum.Jump or (player:GetAttribute("FlightState")or "Idle")~="Idle"then return end
 local blocked=autoBlocked[player]
 if blocked then local base=blocked:FindFirstChild("Base");if not base or not Config.Near(base.CFrame:PointToObjectSpace(root.Position),true)then autoBlocked[player]=nil end end
 local nearest,distance
 for _,station in stations:GetChildren()do
  local base=station:FindFirstChild("Base");local tier=station:GetAttribute("TrainingTier")
  if base and tier and tier<=(Data.GetLevel(player,"TrainingTier")or 1)and station~=autoBlocked[player]then
   local localPosition=base.CFrame:PointToObjectSpace(root.Position)
   if Config.Near(localPosition,false)then local d=localPosition.X^2+localPosition.Z^2;if not distance or d<distance then nearest=station;distance=d end end
  end
 end
 if nearest then return Service.Join(player,nearest,true)end
end
Players.PlayerRemoving:Connect(function(player)Service.Leave(player);autoBlocked[player]=nil end)
return Service
