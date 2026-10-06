-- Moving local chambers, with personal entry warnings fixed to the launch column.
local Players=game:GetService("Players");local Run=game:GetService("RunService")
local C={};local started=false;local levels,currentLevel,descending
local active={}
function C.SetRecommendations(required,current,diving)levels=required;currentLevel=current;descending=diving end
function C.WarningOnScreen()
 local camera=workspace.CurrentCamera;if not camera then return false end
 for _,entry in active do local sign=entry.Sign
  if sign and sign.Parent and sign.Enabled and sign.Adornee and sign.Adornee.Parent then
   local _,visible=camera:WorldToViewportPoint(sign.Adornee.Position);if visible then return true end
  end
 end
 return false
end
local function remove(entry)
 if entry.Sign then entry.Sign:Destroy()end
 if entry.Anchor then entry.Anchor:Destroy()end
 if entry.Model then entry.Model:Destroy()end
end
local function clear()for i,entry in active do remove(entry);active[i]=nil end end
function C.Start()
 if started then return end;started=true
 local player=Players.LocalPlayer
 local launchOrigin
 local gates=require(game:GetService("ReplicatedStorage"):WaitForChild("CloudConfig")).HeightPresentation.Gates
 local folder=Instance.new("Folder");folder.Name="StageCloudBoxes";folder.Parent=workspace
 local function makeSign(entry)
  if entry.Sign then entry.Sign:Destroy()end
  local sign=Instance.new("SurfaceGui");sign.Name="GateEntryRequirement";sign.ResetOnSpawn=false;sign.Adornee=entry.Anchor;sign.Face=Enum.NormalId.Bottom;sign.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize;sign.CanvasSize=Vector2.new(1024,1024);sign.AlwaysOnTop=false;sign.LightInfluence=0;sign.Enabled=false
  local text=Instance.new("TextLabel");text.Name="Requirement";text.AnchorPoint=Vector2.new(.5,.5);text.Size=UDim2.fromScale(.9,.16);text.Position=UDim2.fromScale(.5,.5);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBlack;text.TextColor3=Color3.fromRGB(255,38,54);text.TextStrokeColor3=Color3.fromRGB(40,5,8);text.TextStrokeTransparency=0;text.RichText=false;text.TextScaled=false;text.TextWrapped=false;text.TextSize=48;text.Parent=sign
  entry.Sign,entry.Text=sign,text;entry.Reference.Value=sign
  sign.Parent=entry.Anchor -- Publish only after the label exists; references survive child-name changes.
 end
 local function make(index)
  local m=Instance.new("Model");m.Name="CloudGate"..index;m:SetAttribute("SkyKind","Decoration")
  local parts={}
  for _,name in {"Floor","Ceiling","Left","Right","Front","Back"}do
   local p=Instance.new("Part");p.Name=name;p.Material=Enum.Material.SmoothPlastic;p.Color=Color3.fromRGB(246,249,255);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=m;table.insert(parts,p)
  end
  local anchor=Instance.new("Part");anchor.Name="FixedEntryWarning"
  anchor.Size=Vector3.new(512,.2,512);anchor.Position=Vector3.new(launchOrigin.X,gates[index].Bottom-4.1,launchOrigin.Z)
  anchor.Anchored=true;anchor.Transparency=1;anchor.CanCollide=false;anchor.CanTouch=false;anchor.CanQuery=false;anchor.CastShadow=false;anchor.Parent=m
  local ref=Instance.new("ObjectValue");ref.Name="EntrySignReference";ref.Parent=anchor
  local entry={Model=m,Anchor=anchor,Reference=ref,Parts=parts};makeSign(entry);m.Parent=folder;return entry
 end
 player.CharacterRemoving:Connect(function()clear();launchOrigin=nil end)
 local elapsed=0
 Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.08 then return end;elapsed=0
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if not root then clear();return end
  -- Capture the launch column; neither sideways drift nor camera motion moves the caption.
  if not launchOrigin then
   local pad=workspace:FindFirstChild("RocketLaunchPad")
   launchOrigin=pad and pad.Position or root.Position
  end
  local camera=workspace.CurrentCamera;local cy=camera and camera.CFrame.Position.Y or root.Position.Y
  local wanted={}
  for i,g in gates do if root.Position.Y>=g.Bottom-700 and root.Position.Y<=g.Top+700 then
   wanted[i]=true;local entry=active[i];if not entry then entry=make(i);active[i]=entry end
   if not entry.Sign.Parent or entry.Text.Parent~=entry.Sign then makeSign(entry)end
   local sign,text=entry.Sign,entry.Text
   sign.Enabled=levels~=nil and not descending and player:GetAttribute("FlightState")=="Flying"and root.Position.Y<g.Bottom-6
   local caption=string.format("Recommended Level %d!",levels and levels[i]or g.Level)
   if text.Text~=caption then text.Text=caption end
   local x,z=root.Position.X,root.Position.Z
   local height=math.min(2048,g.Top-g.Bottom);local y=math.clamp(root.Position.Y,g.Bottom+height/2,g.Top-height/2)
   for _,p in entry.Parts do
    if p.Name=="Floor"or p.Name=="Ceiling"then
     local sy=p.Name=="Floor"and g.Bottom or g.Top;p.Size=Vector3.new(512,8,512);p.Position=Vector3.new(x,sy,z)
     local distance=math.min(math.abs(root.Position.Y-sy),math.abs(cy-sy));p.Transparency=.96*math.clamp(1-distance/30,0,1)
     if (root.Position.Y-sy)*(cy-sy)<0 then p.Transparency=.98 end
    else
     local sx=p.Name=="Left"and -256 or p.Name=="Right"and 256 or 0;local sz=p.Name=="Front"and -256 or p.Name=="Back"and 256 or 0
     p.Size=sx~=0 and Vector3.new(8,height,512)or Vector3.new(512,height,8);p.Position=Vector3.new(x+sx,y,z+sz);p.Transparency=0
    end
   end
  end end
  for i,entry in active do if not wanted[i]then remove(entry);active[i]=nil end end
 end)
end
return C
