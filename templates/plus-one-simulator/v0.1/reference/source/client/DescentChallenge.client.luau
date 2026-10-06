local rocketMode=game:GetService("ReplicatedStorage"):FindFirstChild("RocketModeConfig")
if rocketMode and require(rocketMode).Enabled then return end
local Cloud=require(game.ReplicatedStorage:WaitForChild("CloudConfig"))
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local HUD=require(RS:WaitForChild("SimulatorHUD"))
local gui=Instance.new("ScreenGui");gui.Name="DescentGui";gui.ResetOnSpawn=false;HUD.screen(gui,35);gui.Enabled=false;gui.Parent=player:WaitForChild("PlayerGui")
local panel=Instance.new("Frame");panel.Name="Challenge";panel.AnchorPoint=Vector2.new(.5,1);panel.Position=UDim2.new(.5,0,1,-100);panel.Size=UDim2.fromOffset(440,94);HUD.surface(panel,HUD.Colors.Blue);panel.Parent=gui
local title=Instance.new("TextLabel");title.Name="Title";title.Size=UDim2.new(1,-16,0,35);title.Position=UDim2.fromOffset(8,2);HUD.text(title,24,HUD.Colors.Yellow);title.Text="Dive! Steer and break targets!";title.Parent=panel
local status=Instance.new("TextLabel");status.Name="Progress";status.Size=UDim2.new(1,-16,0,50);status.Position=UDim2.fromOffset(8,39);HUD.text(status,18);status.TextWrapped=true;status.Parent=panel
HUD.fit(panel,440,190)
local guideAnchor,guideLabel
local folder,route,activeId,character;local rings={};local launchRight=Vector3.new(1,0,0)
local function clear()
 gui.Enabled=false;if folder then folder:Destroy() end;folder=nil;route=nil;guideAnchor=nil;guideLabel=nil;table.clear(rings)
end
local function line(parent,name,a,b,width,color)
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Material=Enum.Material.Neon;p.Color=color
 p.Size=Vector3.new(width,width,(b-a).Magnitude);p.CFrame=CFrame.lookAt((a+b)/2,b);p.Parent=parent;return p
end
local function circle(parent,name,center,radius,color)
 local group=Instance.new("Model");group.Name=name;group.Parent=parent
 for i=1,24 do local a=(i-1)*math.pi/12;local b=i*math.pi/12
  line(group,"Arc",center+Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius),center+Vector3.new(math.cos(b)*radius,0,math.sin(b)*radius),1.4,color)
 end
 return group
end
local function badge(parent,pos,text)
 local anchor=Instance.new("Part");anchor.Name="LabelAnchor";anchor.Size=Vector3.one;anchor.Position=pos;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.Parent=parent
 local g=Instance.new("BillboardGui");g.Size=UDim2.fromOffset(240,50);g.AlwaysOnTop=true;g.MaxDistance=10000;g.Parent=anchor
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);HUD.text(t,22,HUD.Colors.Yellow);t.Text=text;t.Parent=g
end
local function update(data)
 route=data
 for i,r in data.Rings do
  if rings[i] then for _,p in rings[i]:GetChildren() do if p:IsA("BasePart") then p.Transparency=if r.Passed then .85 else .1;p.Color=if r.Hit then HUD.Colors.Green elseif r.Passed then HUD.Colors.Coral else HUD.Colors.Yellow end end end
 end
end
RS:WaitForChild("FireCannon").OnClientEvent:Connect(function(velocity,id,char)
 clear();activeId=id;character=char
 local flat=Vector3.new(velocity.X,0,velocity.Z);if flat.Magnitude>.01 then launchRight=Vector3.new(-flat.Unit.Z,0,flat.Unit.X) end
end)
RS:WaitForChild("FlightState").OnClientEvent:Connect(function(value,id,char,data)
 if id~=activeId or char~=character or char~=player.Character then return end
 if value=="Descent" and type(data)=="table" then
  clear();folder=Instance.new("Folder");folder.Name="LocalDescentChallenge";folder.Parent=workspace
  for i,r in data.Rings do rings[i]=circle(folder,"BonusRing"..i,r.Position,data.RingRadius,HUD.Colors.Yellow);badge(rings[i],r.Position+Vector3.new(0,5,0),"Dive Ring "..i.." · +1 Trophy") end
  circle(folder,"LandingOuter",data.Target,data.TargetRadius,HUD.Colors.Blue)
  circle(folder,"LandingPerfect",data.Target+Vector3.new(0,.1,0),data.PerfectRadius,HUD.Colors.Green)
  badge(folder,data.Target+Vector3.new(0,4,0),"Landing +1 · Perfect +3 Trophies")
  guideAnchor=Instance.new("Part");guideAnchor.Name="DiveBreakTarget";guideAnchor.Size=Vector3.one;guideAnchor.Transparency=1;guideAnchor.Anchored=true;guideAnchor.CanCollide=false;guideAnchor.CanTouch=false;guideAnchor.CanQuery=false;guideAnchor.Parent=folder
  local marker=Instance.new("BillboardGui");marker.Size=UDim2.fromOffset(260,85);marker.AlwaysOnTop=true;marker.MaxDistance=1500;marker.Parent=guideAnchor
  guideLabel=Instance.new("TextLabel");guideLabel.Size=UDim2.fromScale(1,1);HUD.text(guideLabel,28,Color3.fromRGB(100,240,255));guideLabel.TextWrapped=true;guideLabel.Parent=marker
  update(data);gui.Enabled=true
 elseif value=="DescentProgress" and route then update(data)
 elseif value=="Effect" and data=="SkyHazard" then clear()
 elseif value=="Result" or value=="Returning" or value=="Cancelled" or value=="Idle" then clear() end
end)
player.CharacterRemoving:Connect(clear)
RunService.RenderStepped:Connect(function()
 if not route then return end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if not root then clear();return end
 local targetPosition=player:GetAttribute("DiveTargetPosition")
 local activeTarget=player:GetAttribute("DiveTargetActive")==true
 if guideAnchor then guideAnchor.Position=(targetPosition or root.Position)+Vector3.new(0,12,0) end
 if guideLabel then guideLabel.Visible=activeTarget;guideLabel.Text="Break here!\n▼ "..tostring(player:GetAttribute("DiveTargetsLeft") or 0).." target chain" end
 if activeTarget and targetPosition then
  local side=(targetPosition-root.Position):Dot(launchRight)
  local direction=if math.abs(side)<12 then "Stay centered!" elseif side>0 then "Aim right ▶" else "◀ Aim left"
  title.Text="Break Zone · Slow Dive"
  status.Text=string.format("%d left · %d m below\n%s · Break the blue targets!",player:GetAttribute("DiveTargetsLeft") or 0,player:GetAttribute("DiveTargetDistance") or 0,direction)
  return
 end
 title.Text="Fast Dive · Next Break Zone!"
 local nextRing;for _,r in route.Rings do if not r.Passed then nextRing=r;break end end
 local target=if nextRing then nextRing.Position else route.Target
 local side=(target-root.Position):Dot(launchRight)
 local direction=if math.abs(side)<5 then "Keep direction" elseif side>0 then "Right D / →" else "Left A / ←"
 if nextRing then local d=math.max(0,root.Position.Y-nextRing.Position.Y);status.Text=string.format("Ring %d / 3 · Next %s below\n%s · %d m sideways · +1 Trophy per ring",route.Count,Cloud.FormatAltitude(math.ceil(d)),direction,math.ceil(math.abs(side)))
 else local delta=root.Position-route.Target;status.Text=string.format("Ring %d / 3 · Landing %s %.0f m\nPerfect +3 Trophies · On target +1",route.Count,direction,Vector3.new(delta.X,0,delta.Z).Magnitude) end
end)
