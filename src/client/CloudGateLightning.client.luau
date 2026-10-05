-- Local lightning conveys gate danger. It does not deal hidden extra damage.
local Players=game:GetService("Players");local Run=game:GetService("RunService");local Tween=game:GetService("TweenService")
local player=Players.LocalPlayer;local folder=Instance.new("Folder");folder.Name="CloudGateLightning";folder.Parent=workspace
local random=Random.new();local pieces={};local nextAt=0;local untilAt=0;local lastIndex
local flash=Instance.new("ColorCorrectionEffect");flash.Name="CloudLightningFlash";flash.Brightness=0;flash.Enabled=false;flash.Parent=game:GetService("Lighting")
local function hide()for _,p in pieces do p.Transparency=1 end;flash.Brightness=0;flash.Enabled=false;untilAt=0 end
for i=1,24 do
 local p=Instance.new("Part");p.Name="LightningSegment";p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=Enum.Material.Neon;p.Color=Color3.fromRGB(156,206,255);p.Transparency=1;p.Parent=folder;table.insert(pieces,p)
end
Run.Heartbeat:Connect(function()
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");local index=player:GetAttribute("CloudGateIndex");local now=os.clock()
 if not root or not index or player:GetAttribute("FlightState")~="Flying"then if untilAt>0 then hide()end;lastIndex=nil;return end
 if index~=lastIndex then nextAt=now+.25;lastIndex=index end
 if untilAt>0 and now>=untilAt then hide()end
 if now<nextAt then return end
 nextAt=now+math.max(1.2,2.4-index*.12)+random:NextNumber(0,.5);untilAt=now+.13
 local camera=workspace.CurrentCamera;local right=camera and camera.CFrame.RightVector or Vector3.xAxis;local forward=camera and camera.CFrame.LookVector or -Vector3.zAxis
 for bolt=1,3 do
  local side=bolt%2==0 and -1 or 1
  local start=root.Position+right*(side*random:NextNumber(45,95))+forward*random:NextNumber(35,80)+Vector3.new(0,75+index*3,0)
  for segment=1,8 do
   local finish=start+Vector3.new(random:NextNumber(-9,9),-random:NextNumber(13,20),random:NextNumber(-9,9))
   local part=pieces[(bolt-1)*8+segment];local delta=finish-start
   part.Size=Vector3.new(.5+index*.08,.5+index*.08,delta.Magnitude);part.CFrame=CFrame.lookAt((start+finish)/2,finish);part.Transparency=0;start=finish
  end
 end
 flash.Enabled=true;flash.Brightness=.14;Tween:Create(flash,TweenInfo.new(.16),{Brightness=0}):Play()
 folder:SetAttribute("StrikeCount",(folder:GetAttribute("StrikeCount")or 0)+1)
 folder:SetAttribute("GateIndex",index)
end)
player.CharacterRemoving:Connect(hide)
