-- A shared bonus can respawn for other players while it is still consumed in
-- this run. Keep its local art hidden until return; server awards remain once.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local consumed,hidden,badges={},{},{}
local function restore()
 for part,previous in hidden do if part.Parent then part.LocalTransparencyModifier=previous end end
 for badge,model in badges do if badge.Parent and model.Parent then badge.Enabled=(model:GetAttribute("AvailableAt")or 0)<=workspace:GetServerTimeNow()end end
 table.clear(badges)
 table.clear(hidden);table.clear(consumed)
end
local event=RS:WaitForChild("BarrierDestroyed")
event.OnClientEvent:Connect(function(data)
 if player:GetAttribute("FlightState")~="Flying"or typeof(data)~="table"then return end
 if data.RunId~=player:GetAttribute("SkyRunSerial")or data.Character~=player.Character then return end
 if data.VisualKind=="Butter"and data.SkyTargetId~=nil then consumed[data.SkyTargetId]=true end
end)
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
 elapsed+=dt;if elapsed<.1 then return end;elapsed=0
 if player:GetAttribute("FlightState")~="Flying"then return end
 local folder=workspace:FindFirstChild("SkyLife");if not folder then return end
 for _,model in folder:GetChildren()do
  if consumed[model:GetAttribute("TargetId")]and model:GetAttribute("VisualKind")=="Butter"then
   for _,part in model:GetDescendants()do if part:IsA("BasePart")then
    if hidden[part]==nil then hidden[part]=part.LocalTransparencyModifier end
    part.LocalTransparencyModifier=1
   elseif part:IsA("BillboardGui")then badges[part]=model;part.Enabled=false end end
  end
 end
end)
player:GetAttributeChangedSignal("FlightState"):Connect(function()if player:GetAttribute("FlightState")~="Flying"then restore()end end)
player:GetAttributeChangedSignal("SkyRunSerial"):Connect(restore)
player.CharacterRemoving:Connect(restore)
script.Destroying:Connect(restore)
