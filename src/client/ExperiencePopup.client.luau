-- Every popup reflects XP already committed by the server, including idle XP.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local Projection=require(script.Parent.XPProjection)
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local overlay=Instance.new("ScreenGui");overlay.Name="ExperiencePopups";overlay.IgnoreGuiInset=true;overlay.ResetOnSpawn=false;overlay.DisplayOrder=55;overlay.Parent=playerGui
local active={};local pending;local generation=0
local function show(character,gain)
 if character~=player.Character or not character.Parent then return end
 local head=character:FindFirstChild("Head")
 if not head then return end
 local x,y=Projection.Calculate(workspace.CurrentCamera,head.Position+Vector3.new(0,2.5,0),0)
 if not x or player:GetAttribute("ProgressionModalOpen")then return end
 local camera=workspace.CurrentCamera;local compact=camera and (camera.ViewportSize.Y<500 or camera.ViewportSize.X<600)and player:GetAttribute("FlightState")=="Flying"
 while #active>=(compact and 1 or 3)do table.remove(active,1).label:Destroy()end
 local label=Instance.new("TextLabel");label.Name="ExperiencePopup";label.AnchorPoint=Vector2.new(.5,.5);label.Size=UDim2.fromOffset(180,42);label.Visible=false;label.BackgroundTransparency=1;label.Font=Enum.Font.GothamBlack;label.TextSize=25;label.TextColor3=Color3.fromRGB(255,232,106);label.TextStrokeColor3=Color3.fromRGB(35,45,64);label.TextStrokeTransparency=.15;label.Text="+"..gain.." XP";label.Position=UDim2.fromOffset(x,y);label.Parent=overlay
 table.insert(active,{label=label,head=head,born=os.clock()})
end
local function render()
 local camera=workspace.CurrentCamera;local now=os.clock()
 for i=#active,1,-1 do
  local popup=active[i];local age=now-popup.born
  if age>=.95 or not popup.head.Parent then popup.label:Destroy();table.remove(active,i);continue end
  local x,y=Projection.Calculate(camera,popup.head.Position+Vector3.new(0,2.5,0),age)
  if x and not player:GetAttribute("ProgressionModalOpen")then
   if camera and (camera.ViewportSize.Y<500 or camera.ViewportSize.X<600)and player:GetAttribute("FlightState")=="Flying"then x=camera.ViewportSize.X*.5;y=camera.ViewportSize.Y-45-age*10;popup.label.TextSize=16 end
   popup.label.Position=UDim2.fromOffset(x,y)
   popup.label.Visible=true
  else
   popup.label.Visible=false
  end
  local fade=math.clamp((age-.4)/.5,0,1);popup.label.TextTransparency=fade;popup.label.TextStrokeTransparency=.15+.85*fade
 end
end
-- Project after Roblox updates the orbit camera, including quick turns/respawns.
RunService:BindToRenderStep("RocketExperiencePopups",Enum.RenderPriority.Camera.Value+1,render)
overlay.Destroying:Connect(function()RunService:UnbindFromRenderStep("RocketExperiencePopups")end)
RS:WaitForChild("ExperienceGained").OnClientEvent:Connect(function(gain,character)
 if type(gain)~="number"or gain~=gain or gain<=0 or gain==math.huge or gain~=math.floor(gain)or character~=player.Character or not character then return end
 if pending and pending.character==character then pending.gain+=gain;return end
 generation+=1;local token=generation;pending={character=character,gain=gain}
 -- Coalesce simultaneous baseline/toilet/flight awards into their actual total.
 task.delay(.12,function()
  if generation~=token or not pending then return end
  local award=pending;pending=nil;show(award.character,award.gain)
 end)
end)
player.CharacterRemoving:Connect(function()
 generation+=1;pending=nil
 for _,popup in active do popup.label:Destroy()end;table.clear(active)
end)
