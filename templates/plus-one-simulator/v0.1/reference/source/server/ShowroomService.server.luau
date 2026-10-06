local RS=game:GetService("ReplicatedStorage")
if not require(RS:WaitForChild("RocketModeConfig")).Enabled then return end
local Data=require(script.Parent.PlayerData)
local Training=require(script.Parent.SharedTraining)
local leave=RS:FindFirstChild("LeaveSharedTraining")or Instance.new("RemoteEvent")
assert(leave:IsA("RemoteEvent"),"LeaveSharedTraining class conflict")
leave.Name="LeaveSharedTraining";leave.Parent=RS
leave.OnServerEvent:Connect(function(player)
 if player:GetAttribute("SharedTrainingTier")and (player:GetAttribute("FlightState")or "Idle")=="Idle"then Training.Leave(player)end
end)
local camp=workspace:WaitForChild("CliffCamp",30);if not camp then return end
local function bind(p)
 if not p:IsA("ProximityPrompt")or not p:GetAttribute("DisplayKind")then return end
 p.Triggered:Connect(function(player)
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
  if not p.Enabled or not root or not hum or hum.Health<=0 or not Data.IsReady(player)or (root.Position-p.Parent.Position).Magnitude>14 then return end
  local ok,note
  if p:GetAttribute("DisplayKind")=="Rocket"then ok,note=Data.SelectRocketSkin(player,p:GetAttribute("DisplayIndex"))else ok,note=Training.Join(player,p.Parent.Parent)end
  player:SetAttribute("ShowroomMessage",note or "");player:SetAttribute("ShowroomMessageTime",workspace:GetServerTimeNow());player:SetAttribute("ShowroomSuccess",ok==true)
 end)
end
for _,p in camp:GetDescendants()do bind(p)end
camp.DescendantAdded:Connect(bind)

local elapsed=0
game:GetService("RunService").Heartbeat:Connect(function(dt)
 elapsed+=dt;if elapsed<.2 then return end;elapsed=0
 local stations=camp:FindFirstChild("TrainingStations");if not stations then return end
 for _,player in game:GetService("Players"):GetPlayers()do Training.AutoJoin(player,stations)end
end)
